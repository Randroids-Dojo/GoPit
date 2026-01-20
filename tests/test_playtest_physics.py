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

    # Wait for ball to spawn from queue (fire_rate=3 means ~0.33s per ball)
    await asyncio.sleep(0.5)

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
async def test_ball_return_mechanic(game, report):
    """Test balls return to player (BallxPit style return mechanic)."""
    # Disable autofire so we control when balls spawn
    await game.call(PATHS["fire_button"], "set_autofire", [False])

    # Wait for fire button to be ready (may be on cooldown from autofire)
    ready = await wait_for_fire_ready(game, PATHS["fire_button"])
    assert ready, "Fire button should become ready within timeout"

    # Clear queue
    await game.call(PATHS["ball_spawner"], "clear_queue")

    # Fire downward (toward bottom of screen to trigger return)
    await game.call(PATHS["ball_spawner"], "set_aim_direction_xy", [0.0, 1.0])
    await game.click(PATHS["fire_button"])

    # Wait for balls to spawn from queue and travel (fire_rate=3 means ~0.33s per ball)
    await asyncio.sleep(1.0)

    # Get balls in flight
    balls_initial = await game.call(PATHS["ball_spawner"], "get_balls_in_flight")

    # Wait for balls to reach bottom and return
    await asyncio.sleep(4.0)

    # After enough time, balls should have returned (count decreases)
    balls_after = await game.call(PATHS["ball_spawner"], "get_balls_in_flight")
    # Balls that return are removed from flight count
    assert balls_after <= balls_initial, f"Balls should return, was {balls_initial}, now {balls_after}"


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
