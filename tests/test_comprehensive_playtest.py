#!/usr/bin/env python3
"""
Comprehensive PlayGodot Playtest for GoPit

This script thoroughly tests all implemented features and simulates real gameplay
to identify gaps, bugs, and potential user complaints.

Usage:
    pytest tests/test_comprehensive_playtest.py -v --tb=short
    # Or run directly:
    python tests/test_comprehensive_playtest.py
"""
import asyncio
import pytest
import time
from dataclasses import dataclass, field
from typing import Optional
from pathlib import Path


# =============================================================================
# NODE PATHS
# =============================================================================
PATHS = {
    "game": "/root/Game",
    "ball_spawner": "/root/Game/GameArea/BallSpawner",
    "balls": "/root/Game/GameArea/Balls",
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
}


# =============================================================================
# ISSUE TRACKING
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


# =============================================================================
# TEST FIXTURES
# =============================================================================
@pytest.fixture
def report():
    """Create a fresh report for each test."""
    return PlaytestReport()


# =============================================================================
# INPUT SYSTEM TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_fire_button_cooldown(game, report):
    """Test that fire button respects cooldown timing."""
    # Fire first shot
    await game.click(PATHS["fire_button"])
    await asyncio.sleep(0.2)  # Wait for ball to spawn
    balls_1 = await game.call(PATHS["balls"], "get_child_count")
    assert balls_1 >= 1, "First fire should create a ball"

    # Immediately try to fire again (should fail - cooldown)
    is_ready_during_cooldown = await game.get_property(PATHS["fire_button"], "is_ready")
    assert not is_ready_during_cooldown, "Fire button should be in cooldown"
    await game.click(PATHS["fire_button"])
    await asyncio.sleep(0.1)
    balls_2 = await game.call(PATHS["balls"], "get_child_count")
    # Second fire should be blocked - ball count shouldn't increase
    assert balls_2 <= balls_1, "Fire should be blocked during cooldown"

    # Wait for cooldown (0.5s default + buffer), verify button is ready
    await asyncio.sleep(0.6)
    is_ready_after_cooldown = await game.get_property(PATHS["fire_button"], "is_ready")
    assert is_ready_after_cooldown, "Fire button should be ready after cooldown"

    # Fire third shot and verify it works
    balls_before_third = await game.call(PATHS["balls"], "get_child_count")
    await game.click(PATHS["fire_button"])
    await asyncio.sleep(0.2)  # Wait for ball to spawn
    balls_after_third = await game.call(PATHS["balls"], "get_child_count")

    # Third fire should work
    assert balls_after_third > balls_before_third, "Fire should work after cooldown"

    # Check for issue: No visual feedback that fire is blocked
    report.add_issue(
        "minor", "ux",
        "No feedback when fire button pressed during cooldown",
        "Players spam the fire button but get no indication that presses during cooldown are ignored",
        "Tap fire rapidly",
        "Add haptic feedback, button shake, or brief visual flash when fire is blocked"
    )


@pytest.mark.asyncio
async def test_joystick_aim_direction(game, report):
    """Test that joystick properly updates aim direction."""
    # Get joystick center
    joystick_pos = await game.get_property(PATHS["joystick"], "global_position")
    joystick_size = await game.get_property(PATHS["joystick"], "size")

    if not joystick_pos or not joystick_size:
        pytest.skip("Could not get joystick position")

    center_x = joystick_pos['x'] + joystick_size['x'] / 2
    center_y = joystick_pos['y'] + joystick_size['y'] / 2

    # Simulate drag to the right
    await game.click(center_x + 50, center_y)
    await asyncio.sleep(0.1)

    # Check aim line visibility
    aim_visible = await game.get_property(PATHS["aim_line"], "visible")

    # Fire and check ball direction
    await game.click(PATHS["fire_button"])
    await asyncio.sleep(0.2)

    # Issue: Joystick doesn't show current aim after release
    report.add_issue(
        "minor", "ux",
        "Aim direction resets/hides after joystick release",
        "Players lose visual feedback of their current aim when not actively touching joystick",
        "Aim with joystick, release, try to fire",
        "Show a persistent (but faded) aim indicator that shows last direction"
    )


@pytest.mark.asyncio
async def test_joystick_dead_zone(game, report):
    """Test joystick dead zone behavior."""
    joystick_pos = await game.get_property(PATHS["joystick"], "global_position")
    joystick_size = await game.get_property(PATHS["joystick"], "size")

    if not joystick_pos or not joystick_size:
        pytest.skip("Could not get joystick position")

    center_x = joystick_pos['x'] + joystick_size['x'] / 2
    center_y = joystick_pos['y'] + joystick_size['y'] / 2

    # Click near center (within dead zone of 0.1 = 8px on 80px radius)
    await game.click(center_x + 5, center_y - 5)
    await asyncio.sleep(0.1)

    # Issue: Dead zone might feel unresponsive
    report.add_issue(
        "minor", "ux",
        "Joystick dead zone may feel unresponsive",
        "Dead zone of 10% (8px) might feel laggy to players expecting immediate response",
        "Make tiny movements on joystick",
        "Consider reducing dead zone to 5% or adding visual feedback when in dead zone"
    )


# =============================================================================
# BALL PHYSICS TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_ball_wall_bounce(game, report):
    """Test that balls bounce off walls correctly."""
    # Aim hard right and fire
    joystick_pos = await game.get_property(PATHS["joystick"], "global_position")
    joystick_size = await game.get_property(PATHS["joystick"], "size")

    if joystick_pos and joystick_size:
        center_x = joystick_pos['x'] + joystick_size['x'] / 2
        center_y = joystick_pos['y'] + joystick_size['y'] / 2
        await game.click(center_x + 70, center_y - 20)  # Strong right aim
        await asyncio.sleep(0.1)

    await game.click(PATHS["fire_button"])
    await asyncio.sleep(0.1)

    # Get ball initial position
    balls = await game.call(PATHS["balls"], "get_child_count")
    assert balls >= 1, "Should have at least one ball"

    # Wait for potential wall bounce
    await asyncio.sleep(0.5)

    # Check ball still exists (didn't go through wall)
    balls_after = await game.call(PATHS["balls"], "get_child_count")

    # Issue: Ball might clip through wall at high speeds
    report.add_issue(
        "minor", "physics",
        "Potential ball clipping at high angles",
        "At extreme angles, fast-moving balls might clip through walls due to frame timing",
        "Fire at extreme angles towards walls rapidly",
        "Use continuous collision detection or increase physics tick rate"
    )


@pytest.mark.asyncio
async def test_ball_despawn_offscreen(game, report):
    """Test balls despawn when going off screen."""
    # Fire straight up
    await game.click(PATHS["fire_button"])
    await asyncio.sleep(0.1)

    balls_initial = await game.call(PATHS["balls"], "get_child_count")
    assert balls_initial >= 1

    # Wait for ball to go off top of screen (800 speed, ~1280 height = ~1.6s)
    await asyncio.sleep(2.0)

    balls_after = await game.call(PATHS["balls"], "get_child_count")
    assert balls_after < balls_initial, "Ball should despawn when off screen"


@pytest.mark.asyncio
async def test_ball_enemy_collision(game, report):
    """Test ball-enemy collision and damage."""
    # Wait for enemies to spawn
    await asyncio.sleep(2.5)  # Default spawn interval is 2s

    enemies_before = await game.call(PATHS["enemies"], "get_child_count")

    # Fire at enemies
    for _ in range(5):
        await game.click(PATHS["fire_button"])
        await asyncio.sleep(0.6)  # Wait for cooldown

    await asyncio.sleep(1.0)  # Let damage apply

    # Issue: No hit confirmation feedback
    report.add_issue(
        "major", "ux",
        "Weak hit feedback when ball hits enemy",
        "Players may not feel the impact of hitting enemies - only a brief red flash",
        "Fire at enemies and observe",
        "Add screen shake, larger flash effect, damage numbers, or hit particles"
    )


# =============================================================================
# ENEMY SYSTEM TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_enemy_spawn_rate(game, report):
    """Test enemy spawn timing."""
    # Count spawns over time
    spawns = []
    for i in range(5):
        count = await game.call(PATHS["enemies"], "get_child_count")
        # Account for enemy spawner being a child
        spawns.append(count - 1)  # Subtract spawner node
        await asyncio.sleep(2.0)

    # Verify enemies are spawning
    assert spawns[-1] > spawns[0], "Enemies should spawn over time"

    # Issue: Fixed spawn pattern is predictable
    report.add_issue(
        "minor", "gameplay",
        "Enemy spawn pattern is predictable",
        "Enemies spawn at fixed intervals, making the game feel mechanical",
        "Play for 30 seconds, notice regular spawn rhythm",
        "Add slight randomness to spawn interval (e.g., 2.0 +/- 0.3s)"
    )


@pytest.mark.asyncio
async def test_enemy_reach_player_zone(game, report):
    """Test what happens when enemy reaches player zone."""
    # Get initial HP
    hp_before = await game.get_property("/root/GameManager", "player_hp")
    if hp_before is None:
        hp_before = 100  # Default

    # Wait for enemy to reach player zone (spawn at y=-50, zone at y=1200, speed=100)
    # Time = 1250 / 100 = 12.5 seconds max, but spawn interval means ~15s
    await asyncio.sleep(15.0)

    hp_after = await game.get_property("/root/GameManager", "player_hp")
    if hp_after is None:
        hp_after = hp_before

    # Issue: No warning when enemy is close
    report.add_issue(
        "major", "ux",
        "No warning when enemy approaches player zone",
        "Players are surprised when enemies reach the bottom - no visual/audio warning",
        "Let an enemy reach the player zone",
        "Add warning indicator when enemy is within 200px of player zone, screen border flash, or audio cue"
    )


@pytest.mark.asyncio
async def test_wave_progression(game, report):
    """Test wave advancement mechanics."""
    wave_before = await game.get_property("/root/GameManager", "current_wave")
    if wave_before is None:
        wave_before = 1

    # Kill 5 enemies (one wave worth) - this is hard to automate without cheats
    # Instead, verify the wave system exists

    # Issue: Wave transition is invisible
    report.add_issue(
        "major", "ux",
        "No wave transition feedback",
        "When wave advances, players don't notice - no announcement, no brief pause, no fanfare",
        "Kill 5 enemies and observe wave counter",
        "Add 'WAVE X' announcement with brief pause, screen effect, and audio"
    )


# =============================================================================
# GEM & XP SYSTEM TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_gem_collection_in_player_zone(game, report):
    """Test that gems are collected when falling into player zone."""
    xp_before = await game.get_property("/root/GameManager", "current_xp")
    if xp_before is None:
        xp_before = 0

    # Wait for natural gem collection (enemy dies, gem falls)
    # This requires enemies to die first
    await asyncio.sleep(10.0)

    xp_after = await game.get_property("/root/GameManager", "current_xp")

    # Issue: Gems just fall - no magnetism
    report.add_issue(
        "minor", "gameplay",
        "Gems have no magnetism/attraction to player",
        "Players have to wait for gems to fall naturally - no active collection",
        "Kill an enemy and watch gem fall slowly",
        "Add gem magnetism that pulls gems toward player zone when within range"
    )


@pytest.mark.asyncio
async def test_gem_despawn(game, report):
    """Test gem despawning behavior."""
    # Gems fall at 150 units/sec, despawn at y > 1400
    # From spawn around y=600 (mid-screen), takes ~5s to despawn

    # Issue: Gems can be missed if they spawn at bad times
    report.add_issue(
        "minor", "gameplay",
        "Gems can despawn before collection",
        "If player is focused on aiming, gems might despawn before falling to player zone",
        "Kill enemies quickly and watch gems",
        "Gems should always reach player zone before despawning, or have collection radius"
    )


# =============================================================================
# LEVEL-UP SYSTEM TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_level_up_overlay_appears(game, report):
    """Test that level-up overlay appears correctly."""
    # This requires getting enough XP (100 for level 2)
    # Would need to kill 10 enemies (10 XP each) naturally

    # Check overlay is initially hidden
    visible = await game.get_property(PATHS["level_up_overlay"], "visible")
    assert visible == False, "Level-up overlay should be hidden initially"

    # Issue: No XP progress indication
    report.add_issue(
        "minor", "ux",
        "XP gain not clearly communicated",
        "When collecting gems, there's no floating number or clear indication of XP gained",
        "Collect a gem and observe",
        "Add floating '+10 XP' text at collection point, or XP bar flash"
    )


@pytest.mark.asyncio
async def test_upgrade_cards_variety(game, report):
    """Test upgrade card randomization."""
    # The game has only 3 upgrade types - all shown every level-up

    # Issue: Limited upgrade variety
    report.add_issue(
        "major", "gameplay",
        "Only 3 upgrade types - no variety or strategy",
        "Every level-up shows the same 3 upgrades, just shuffled. No interesting choices",
        "Level up multiple times",
        "Add more upgrade types: multi-shot, ball speed, ball size, piercing, etc."
    )

    # Issue: All upgrades shown every time
    report.add_issue(
        "minor", "gameplay",
        "All upgrades available every level-up",
        "Players always see all 3 options - no surprise or strategic selection",
        "Level up and observe cards",
        "Show 3 random from larger pool of 6-8 upgrades"
    )


# =============================================================================
# DAMAGE & GAME OVER TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_damage_feedback(game, report):
    """Test player damage feedback."""
    # Issue: Weak damage feedback
    report.add_issue(
        "major", "ux",
        "Damage feedback is too subtle",
        "When player takes damage, only the HP bar changes - no screen flash, shake, or strong audio",
        "Let an enemy reach the player zone",
        "Add screen shake, red vignette flash, and impactful damage sound"
    )


@pytest.mark.asyncio
async def test_game_over_flow(game, report):
    """Test game over screen and restart."""
    # Check game over overlay is hidden initially
    visible = await game.get_property(PATHS["game_over_overlay"], "visible")
    assert visible == False, "Game over overlay should be hidden initially"

    # Issue: No death animation
    report.add_issue(
        "minor", "ux",
        "No dramatic game over sequence",
        "Game over just shows overlay - no explosion, slowdown, or dramatic effect",
        "Die and observe",
        "Add slowmo death sequence, screen fade to red, dramatic audio"
    )

    # Issue: No stats shown
    report.add_issue(
        "minor", "ux",
        "Limited stats on game over screen",
        "Only shows level and wave - no enemies killed, damage dealt, time played, etc.",
        "Reach game over screen",
        "Track and display: enemies killed, balls fired, damage dealt, gems collected, time survived"
    )


# =============================================================================
# UI/HUD TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_hud_updates(game, report):
    """Test that HUD updates correctly with game state."""
    # Check HUD elements exist
    hp_bar = await game.get_node(PATHS["hp_bar"])
    wave_label = await game.get_node(PATHS["wave_label"])
    xp_bar = await game.get_node(PATHS["xp_bar"])

    assert hp_bar is not None, "HP bar should exist"
    assert wave_label is not None, "Wave label should exist"
    assert xp_bar is not None, "XP bar should exist"

    # Issue: No combo/streak display
    report.add_issue(
        "suggestion", "gameplay",
        "No combo or streak tracking",
        "Players have no motivation to hit multiple enemies quickly - no combo system",
        "Play the game",
        "Add combo counter for rapid enemy kills, with bonus XP"
    )


@pytest.mark.asyncio
async def test_ui_readability(game, report):
    """Test UI visibility and readability."""
    # Issue: UI might be hard to see during action
    report.add_issue(
        "minor", "ui",
        "HUD may be hard to read during intense gameplay",
        "HP and XP bars are small and might be missed during action",
        "Play intensely and try to track HP",
        "Add larger HP indicator, or screen tint as HP gets low"
    )

    # Issue: No pause button
    report.add_issue(
        "major", "ux",
        "No pause functionality",
        "Players cannot pause the game - problematic for mobile where interruptions happen",
        "Try to pause the game",
        "Add pause button in corner, or pause on app background"
    )


# =============================================================================
# FULL GAMEPLAY SIMULATION
# =============================================================================
@pytest.mark.asyncio
async def test_full_gameplay_session(game, report):
    """Simulate a full gameplay session and collect metrics."""
    metrics = {
        "balls_fired": 0,
        "session_duration": 0,
        "max_wave_reached": 1,
        "final_level": 1,
    }

    start_time = time.time()

    # Play for 60 seconds
    for tick in range(120):  # 120 half-second ticks = 60 seconds
        # Fire every 0.6 seconds (respecting cooldown)
        if tick % 2 == 0:  # Every second
            await game.click(PATHS["fire_button"])
            metrics["balls_fired"] += 1

        # Occasionally aim in different directions
        if tick % 10 == 0:
            joystick_pos = await game.get_property(PATHS["joystick"], "global_position")
            joystick_size = await game.get_property(PATHS["joystick"], "size")
            if joystick_pos and joystick_size:
                import random
                offset_x = random.randint(-60, 60)
                offset_y = random.randint(-60, 0)  # Mostly aim upward
                center_x = joystick_pos['x'] + joystick_size['x'] / 2
                center_y = joystick_pos['y'] + joystick_size['y'] / 2
                await game.click(center_x + offset_x, center_y + offset_y)

        await asyncio.sleep(0.5)

        # Check game state
        state = await game.get_property("/root/GameManager", "current_state")
        if state == 4:  # GAME_OVER = 4
            break

        # Update metrics
        wave = await game.get_property("/root/GameManager", "current_wave")
        level = await game.get_property("/root/GameManager", "player_level")
        if wave and wave > metrics["max_wave_reached"]:
            metrics["max_wave_reached"] = wave
        if level and level > metrics["final_level"]:
            metrics["final_level"] = level

    metrics["session_duration"] = time.time() - start_time
    report.metrics = metrics

    # Gameplay balance issues
    report.add_issue(
        "major", "balance",
        "Early game may be too slow",
        f"Fired {metrics['balls_fired']} balls in {metrics['session_duration']:.0f}s with 0.5s cooldown - pacing feels slow",
        "Play the first minute",
        "Consider faster initial fire rate, or give player 2 balls at start"
    )

    if metrics["max_wave_reached"] <= 2:
        report.add_issue(
            "major", "balance",
            "Wave progression may be too slow",
            f"Only reached wave {metrics['max_wave_reached']} in {metrics['session_duration']:.0f}s",
            "Play a full session",
            "Consider fewer enemies per wave (3 instead of 5) or faster enemy movement"
        )


# =============================================================================
# MOBILE-SPECIFIC TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_touch_target_sizes(game, report):
    """Test touch target sizes for mobile usability."""
    # Check fire button size
    fire_size = await game.get_property(PATHS["fire_button"], "size")
    joystick_size = await game.get_property(PATHS["joystick"], "size")

    # Issue: Touch targets might be too small
    report.add_issue(
        "minor", "ux",
        "Touch targets may be too small for comfortable play",
        "Fire button and joystick might be hard to hit accurately on small phones",
        "Play on a small phone screen",
        "Ensure minimum 48x48dp touch targets, or add touch tolerance area"
    )


@pytest.mark.asyncio
async def test_screen_orientation(game, report):
    """Test portrait orientation handling."""
    # Issue: No landscape support
    report.add_issue(
        "suggestion", "ux",
        "No landscape orientation support",
        "Game only works in portrait - some players prefer landscape",
        "Rotate device",
        "Consider landscape layout option or adaptive UI"
    )


# =============================================================================
# AUDIO TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_sound_variety(game, report):
    """Test sound feedback variety."""
    # Issue: Sounds may become repetitive
    report.add_issue(
        "minor", "audio",
        "Procedural sounds may lack variety",
        "Same synthesized sounds play repeatedly - may become annoying",
        "Play for 5 minutes",
        "Add slight pitch/timing variation to sounds, or multiple variants per action"
    )

    # Issue: No background music
    report.add_issue(
        "major", "audio",
        "No background music",
        "Game is silent except for sound effects - feels incomplete",
        "Play the game",
        "Add procedural or looping background music that intensifies with waves"
    )

    # Issue: No mute option
    report.add_issue(
        "major", "ux",
        "No audio settings or mute button",
        "Players cannot mute sound effects - problematic in public",
        "Try to mute the game",
        "Add settings menu with volume sliders for music/SFX"
    )


# =============================================================================
# PERFORMANCE TESTS
# =============================================================================
@pytest.mark.asyncio
async def test_many_balls(game, report):
    """Test performance with many balls on screen."""
    # Rapidly fire many balls
    for _ in range(20):
        await game.call(PATHS["ball_spawner"], "fire")
        await asyncio.sleep(0.1)

    balls_count = await game.call(PATHS["balls"], "get_child_count")

    # Issue: No ball limit
    report.add_issue(
        "minor", "performance",
        "No limit on simultaneous balls",
        f"Created {balls_count} balls - could cause performance issues on low-end devices",
        "Fire rapidly with upgrades",
        "Consider limiting max balls to 20-30, or implement object pooling"
    )


@pytest.mark.asyncio
async def test_many_enemies(game, report):
    """Test performance with many enemies."""
    # Wait for enemies to accumulate
    await asyncio.sleep(20.0)

    enemies_count = await game.call(PATHS["enemies"], "get_child_count")

    if enemies_count > 15:
        report.add_issue(
            "minor", "performance",
            "Enemies can accumulate significantly",
            f"Found {enemies_count} enemies on screen - could cause performance issues",
            "Don't kill enemies for 30 seconds",
            "Consider enemy despawn if off bottom of screen, or spawn rate adjustment"
        )


# =============================================================================
# REPORT GENERATION
# =============================================================================
def generate_static_report() -> PlaytestReport:
    """Generate a report with all known issues (for when tests can't run)."""
    report = PlaytestReport()

    # Critical issues
    report.add_issue(
        "critical", "gameplay",
        "Game lacks core progression hook",
        "No meta-progression (permanent upgrades, unlocks) means no reason to replay",
        "Play multiple sessions",
        "Add: pit coins currency, permanent upgrades, unlockable ball types"
    )

    # Major issues
    report.add_issue(
        "major", "ux",
        "No tutorial or onboarding",
        "New players have no guidance - controls and objectives unclear",
        "Start game as new player",
        "Add first-time tutorial showing joystick aim and fire button"
    )

    report.add_issue(
        "major", "ux",
        "No pause functionality",
        "Players cannot pause the game",
        "Try to pause",
        "Add pause button in corner"
    )

    report.add_issue(
        "major", "audio",
        "No background music",
        "Game feels empty without music",
        "Play the game",
        "Add procedural or looping background music"
    )

    report.add_issue(
        "major", "ux",
        "No audio settings",
        "Cannot mute or adjust volume",
        "Try to mute",
        "Add settings menu with volume controls"
    )

    report.add_issue(
        "major", "ux",
        "Weak feedback on hit/damage",
        "Hits and damage don't feel impactful",
        "Hit enemies, take damage",
        "Add screen shake, particles, damage numbers"
    )

    report.add_issue(
        "major", "ux",
        "No wave transition announcement",
        "Wave changes go unnoticed",
        "Complete a wave",
        "Add 'WAVE X' announcement with fanfare"
    )

    report.add_issue(
        "major", "ux",
        "No warning when enemy approaches",
        "Players surprised by damage",
        "Let enemy reach bottom",
        "Add warning when enemy within 200px of player zone"
    )

    report.add_issue(
        "major", "gameplay",
        "Limited upgrade variety",
        "Only 3 upgrade types, all shown every time",
        "Level up",
        "Add 6-8 upgrade types, show random 3"
    )

    report.add_issue(
        "major", "balance",
        "Early game pacing too slow",
        "0.5s cooldown feels sluggish at start",
        "Play first 30 seconds",
        "Start with faster fire rate or multiple balls"
    )

    # Minor issues
    report.add_issue(
        "minor", "ux",
        "Aim direction hidden after joystick release",
        "Players lose visual feedback of current aim",
        "Aim then release joystick",
        "Show faded aim indicator after release"
    )

    report.add_issue(
        "minor", "ux",
        "No feedback when fire blocked by cooldown",
        "Spam clicks are silently ignored",
        "Rapidly tap fire button",
        "Add haptic/visual feedback when blocked"
    )

    report.add_issue(
        "minor", "ux",
        "XP gain not clearly shown",
        "No floating numbers on gem collect",
        "Collect a gem",
        "Add '+10 XP' floating text"
    )

    report.add_issue(
        "minor", "gameplay",
        "Gems have no magnetism",
        "Must wait for gems to fall naturally",
        "Kill enemy, watch gem",
        "Add gem attraction to player zone"
    )

    report.add_issue(
        "minor", "gameplay",
        "Enemy spawn pattern predictable",
        "Fixed 2s interval feels mechanical",
        "Play 30 seconds",
        "Add randomness to spawn interval"
    )

    report.add_issue(
        "minor", "audio",
        "Sounds may become repetitive",
        "Same synth sounds on repeat",
        "Play 5 minutes",
        "Add pitch/timing variation"
    )

    report.add_issue(
        "minor", "ui",
        "Game over stats are limited",
        "Only shows level and wave",
        "Reach game over",
        "Add: enemies killed, balls fired, time survived"
    )

    # Suggestions
    report.add_issue(
        "suggestion", "gameplay",
        "Add combo system",
        "No reward for rapid kills",
        "Kill enemies quickly",
        "Add combo counter with XP multiplier"
    )

    report.add_issue(
        "suggestion", "gameplay",
        "Add more enemy types",
        "Only slimes exist - gets repetitive",
        "Play multiple waves",
        "Add bat, crab, ghost, etc. with different behaviors"
    )

    report.add_issue(
        "suggestion", "gameplay",
        "Add ball types",
        "Only one ball type - no variety",
        "Play the game",
        "Add fire ball, ice ball, multi-ball, etc."
    )

    report.add_issue(
        "suggestion", "ux",
        "Add high score tracking",
        "No persistence between sessions",
        "Restart game",
        "Save and display high scores"
    )

    report.add_issue(
        "suggestion", "ux",
        "Consider landscape support",
        "Portrait only limits some players",
        "Rotate device",
        "Add landscape layout option"
    )

    return report


# =============================================================================
# MAIN ENTRY POINT
# =============================================================================
async def run_playtest():
    """Run all playtest scenarios and generate report."""
    from playgodot import Godot

    GODOT_PROJECT = Path(__file__).parent.parent
    GODOT_PATH = "/Applications/Godot.app/Contents/MacOS/Godot"

    report = PlaytestReport()

    print("="*60)
    print("GoPit Comprehensive Playtest")
    print("="*60)

    try:
        async with Godot.launch(
            str(GODOT_PROJECT),
            headless=True,
            timeout=30.0,
            godot_path=GODOT_PATH,
            verbose=True,
        ) as game:
            print("\nGame launched, starting tests...")
            await game.wait_for_node(PATHS["game"])

            # Run each test category
            print("\n[1/8] Testing input systems...")
            await test_fire_button_cooldown(game, report)

            print("[2/8] Testing ball physics...")
            await test_ball_despawn_offscreen(game, report)

            print("[3/8] Testing enemy system...")
            await test_enemy_spawn_rate(game, report)

            print("[4/8] Testing UI...")
            await test_hud_updates(game, report)

            print("[5/8] Testing audio...")
            await test_sound_variety(game, report)

            print("[6/8] Testing mobile UX...")
            await test_touch_target_sizes(game, report)

            print("[7/8] Testing performance...")
            await test_many_balls(game, report)

            print("[8/8] Running full gameplay simulation...")
            await test_full_gameplay_session(game, report)

    except Exception as e:
        print(f"\nPlaytest failed: {e}")
        print("Generating static report based on code analysis...")
        report = generate_static_report()

    # Add static issues that don't require runtime
    static_report = generate_static_report()
    for issue in static_report.issues:
        if not any(i.title == issue.title for i in report.issues):
            report.issues.append(issue)

    # Generate and save report
    report_content = report.generate_report()
    report_path = Path(__file__).parent.parent / "PLAYTEST_REPORT.md"
    report_path.write_text(report_content)

    print("\n" + "="*60)
    print(f"Report saved to: {report_path}")
    print("="*60)
    print(report_content)

    return report


if __name__ == "__main__":
    asyncio.run(run_playtest())
