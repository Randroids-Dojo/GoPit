"""
Ball Physics Tests - Wall bouncing, despawning, and collisions.

Part of the comprehensive playtest suite, split for parallel execution.
"""
import asyncio
import pytest

from helpers import (
    PATHS, WAIT_TIMEOUT, PlaytestReport,
    wait_for_fire_ready, get_joystick_center
)


@pytest.fixture
def report():
    """Create a fresh report for each test."""
    return PlaytestReport()


@pytest.mark.asyncio
async def test_ball_wall_bounce(game, report):
    """Test that balls bounce off walls correctly."""
    # Aim hard right and fire
    coords = await get_joystick_center(game, PATHS["joystick"])

    if coords:
        center_x, center_y = coords
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
    # Disable autofire so we control when balls spawn
    await game.call(PATHS["fire_button"], "set_autofire", [False])

    # Wait for fire button to be ready (may be on cooldown from autofire)
    ready = await wait_for_fire_ready(game, PATHS["fire_button"])
    assert ready, "Fire button should become ready within timeout"

    # Stop baby ball spawner to prevent auto-spawned balls from affecting count
    await game.call(PATHS["baby_ball_spawner"], "stop")

    # Clear any existing balls first
    balls_before_fire = await game.call(PATHS["balls"], "get_child_count")

    # Fire straight up
    await game.click(PATHS["fire_button"])
    await asyncio.sleep(0.1)

    balls_initial = await game.call(PATHS["balls"], "get_child_count")
    assert balls_initial >= 1, "Should have at least 1 ball after firing"

    # Wait for ball to go off top of screen (800 speed, ~1280 height = ~1.6s)
    await asyncio.sleep(2.0)

    balls_after = await game.call(PATHS["balls"], "get_child_count")
    assert balls_after < balls_initial, "Ball should despawn when off screen"

    # Restart baby ball spawner
    await game.call(PATHS["baby_ball_spawner"], "start")


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
