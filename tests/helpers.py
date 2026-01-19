"""
Shared test helper functions for PlayGodot tests.

This module contains utilities used across multiple test files to avoid duplication.
"""
import asyncio
import time
from dataclasses import dataclass, field


# Timeout for waiting operations (seconds)
WAIT_TIMEOUT = 5.0


# =============================================================================
# NODE PATHS
# =============================================================================
PATHS = {
    "game": "/root/Game",
    "ball_spawner": "/root/Game/GameArea/BallSpawner",
    "balls": "/root/Game/GameArea/Balls",
    "baby_ball_spawner": "/root/Game/GameArea/BabyBallSpawner",
    "enemies": "/root/Game/GameArea/Enemies",
    "enemy_spawner": "/root/Game/GameArea/Enemies/EnemySpawner",
    "gems": "/root/Game/GameArea/Gems",
    "player_zone": "/root/Game/GameArea/PlayerZone",
    "aim_line": "/root/Game/GameArea/AimLine",
    "joystick": "/root/Game/UI/HUD/InputContainer/HBoxContainer/JoystickContainer/VirtualJoystick",
    "fire_button": "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton",
    "hud": "/root/Game/UI/HUD",
    "hp_bar": "/root/Game/UI/HUD/TopBar/HPBar",
    "wave_label": "/root/Game/UI/HUD/TopBar/WaveLabel",
    "xp_bar": "/root/Game/UI/HUD/XPBarContainer/XPBar",
    "level_label": "/root/Game/UI/HUD/XPBarContainer/LevelLabel",
    "game_over_overlay": "/root/Game/UI/GameOverOverlay",
    "level_up_overlay": "/root/Game/UI/LevelUpOverlay",
    "level_up_cards": "/root/Game/UI/LevelUpOverlay/Panel/VBoxContainer/CardsContainer",
    "game_manager": "/root/GameManager",
}


# =============================================================================
# WAIT HELPERS
# =============================================================================
async def wait_for_fire_ready(game, fire_button_path=None, timeout=WAIT_TIMEOUT):
    """Wait for fire button to be ready with timeout.

    With salvo firing, both cooldown (is_ready) and ball availability
    (_balls_available) must be true before firing is possible.
    """
    if fire_button_path is None:
        fire_button_path = PATHS["fire_button"]

    elapsed = 0
    while elapsed < timeout:
        is_ready = await game.get_property(fire_button_path, "is_ready")
        balls_available = await game.get_property(fire_button_path, "_balls_available")
        if is_ready and balls_available:
            return True
        await asyncio.sleep(0.1)
        elapsed += 0.1
    return False


async def wait_for_condition(game, check_fn, timeout=WAIT_TIMEOUT):
    """Wait for a condition function to return True with timeout.

    Args:
        game: The PlayGodot game instance
        check_fn: Async function that returns True when condition is met
        timeout: Maximum wait time in seconds

    Returns:
        True if condition was met, False if timeout
    """
    elapsed = 0
    while elapsed < timeout:
        if await check_fn():
            return True
        await asyncio.sleep(0.1)
        elapsed += 0.1
    return False


async def wait_for_enemy(game, timeout=WAIT_TIMEOUT):
    """Wait for at least one enemy to spawn."""
    async def has_enemy():
        count = await game.call(PATHS["enemies"], "get_child_count")
        return count > 1  # Subtract 1 for spawner node

    return await wait_for_condition(game, has_enemy, timeout)


async def wait_for_visible(game, node_path, timeout=WAIT_TIMEOUT):
    """Wait for a node to become visible.

    Args:
        game: The PlayGodot game instance
        node_path: Path to the node to check visibility
        timeout: Maximum wait time in seconds

    Returns:
        True if node became visible, False if timeout
    """
    async def is_visible():
        return await game.get_property(node_path, "visible")

    return await wait_for_condition(game, is_visible, timeout)


async def wait_for_not_visible(game, node_path, timeout=WAIT_TIMEOUT):
    """Wait for a node to become hidden (not visible).

    Args:
        game: The PlayGodot game instance
        node_path: Path to the node to check visibility
        timeout: Maximum wait time in seconds

    Returns:
        True if node became hidden, False if timeout
    """
    async def is_not_visible():
        return not await game.get_property(node_path, "visible")

    return await wait_for_condition(game, is_not_visible, timeout)


async def wait_for_game_over(game, timeout=WAIT_TIMEOUT):
    """Wait for game over overlay to become visible.

    Args:
        game: The PlayGodot game instance
        timeout: Maximum wait time in seconds

    Returns:
        True if game over overlay became visible, False if timeout
    """
    return await wait_for_visible(game, PATHS["game_over_overlay"], timeout)


async def get_joystick_center(game, joystick_path=None):
    """Get the center coordinates of a joystick.

    Returns:
        Tuple of (center_x, center_y) or None if joystick not found
    """
    if joystick_path is None:
        joystick_path = PATHS["joystick"]

    joystick_pos = await game.get_property(joystick_path, "global_position")
    joystick_size = await game.get_property(joystick_path, "size")

    if not joystick_pos or not joystick_size:
        return None

    center_x = joystick_pos['x'] + joystick_size['x'] / 2
    center_y = joystick_pos['y'] + joystick_size['y'] / 2
    return center_x, center_y


# =============================================================================
# ISSUE TRACKING (for playtest reports)
# =============================================================================
@dataclass
class Issue:
    """Represents a discovered issue during playtesting."""
    severity: str  # critical, major, minor, suggestion
    category: str  # gameplay, ui, physics, balance, ux
    title: str
    description: str
    reproduction: str = ""
    proposed_fix: str = ""


@dataclass
class PlaytestReport:
    """Collects all issues and metrics from a playtest session."""
    issues: list[Issue] = field(default_factory=list)
    metrics: dict = field(default_factory=dict)

    def add_issue(self, severity: str, category: str, title: str,
                  description: str, reproduction: str = "", proposed_fix: str = ""):
        self.issues.append(Issue(severity, category, title, description, reproduction, proposed_fix))

    def generate_report(self) -> str:
        """Generate a markdown report of all findings."""
        lines = ["# GoPit Playtest Report", ""]
        lines.append(f"Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append("")

        # Metrics summary
        lines.append("## Session Metrics")
        lines.append("")
        for key, value in self.metrics.items():
            lines.append(f"- **{key}**: {value}")
        lines.append("")

        # Issues by severity
        severity_order = ["critical", "major", "minor", "suggestion"]
        for severity in severity_order:
            severity_issues = [i for i in self.issues if i.severity == severity]
            if severity_issues:
                lines.append(f"## {severity.upper()} Issues ({len(severity_issues)})")
                lines.append("")
                for issue in severity_issues:
                    lines.append(f"### [{issue.category}] {issue.title}")
                    lines.append("")
                    lines.append(f"**Description:** {issue.description}")
                    if issue.reproduction:
                        lines.append(f"\n**Reproduction:** {issue.reproduction}")
                    if issue.proposed_fix:
                        lines.append(f"\n**Proposed Fix:** {issue.proposed_fix}")
                    lines.append("")

        return "\n".join(lines)
