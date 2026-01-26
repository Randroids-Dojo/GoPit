"""Tests for ball trajectory matching aim line direction."""
import asyncio
import pytest

from helpers import PATHS, wait_for_fire_ready

BALL_SPAWNER = PATHS["ball_spawner"]
AIM_LINE = PATHS["aim_line"]
FIRE_BUTTON = PATHS["fire_button"]
BALLS_CONTAINER = PATHS["balls"]


@pytest.mark.asyncio
async def test_ball_fires_in_aim_direction(game):
    """Ball should fire in the direction set on ball spawner."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.2)

    # Set aim direction to right (positive X)
    await game.call(BALL_SPAWNER, "set_aim_direction_xy", [1.0, 0.0])
    await asyncio.sleep(0.1)

    # Wait for fire button to be ready
    await wait_for_fire_ready(game)

    # Fire a ball
    await game.call(FIRE_BUTTON, "emit_signal", ["fired"])
    await asyncio.sleep(0.3)  # Wait for queue to drain and ball to spawn

    # Get spawned ball direction
    aim_dir = await game.call(BALL_SPAWNER, "get_aim_direction")
    assert aim_dir is not None, "Should be able to get aim direction"

    # Verify aim direction is approximately right (positive X, zero Y)
    assert aim_dir.get("x", 0) > 0.9, f"Aim X should be ~1.0, got {aim_dir.get('x', 0)}"
    assert abs(aim_dir.get("y", 1)) < 0.1, f"Aim Y should be ~0.0, got {aim_dir.get('y', 0)}"

    # Re-enable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [True])


@pytest.mark.asyncio
async def test_aim_line_and_spawner_directions_match(game):
    """Aim line current_direction should match ball spawner aim direction."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.2)

    # Set aim direction to diagonal (up-right)
    test_dir_x = 0.707
    test_dir_y = -0.707
    await game.call(BALL_SPAWNER, "set_aim_direction_xy", [test_dir_x, test_dir_y])
    await asyncio.sleep(0.1)

    # Get spawner aim direction
    spawner_dir = await game.call(BALL_SPAWNER, "get_aim_direction")
    assert spawner_dir is not None, "Should get spawner aim direction"

    # Verify the direction is correct (normalized up-right)
    assert abs(spawner_dir.get("x", 0) - test_dir_x) < 0.1, \
        f"Spawner X should be ~{test_dir_x}, got {spawner_dir.get('x', 0)}"
    assert abs(spawner_dir.get("y", 0) - test_dir_y) < 0.1, \
        f"Spawner Y should be ~{test_dir_y}, got {spawner_dir.get('y', 0)}"

    # Re-enable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [True])


@pytest.mark.asyncio
async def test_joystick_aim_not_overridden_by_default_keyboard(game):
    """Setting joystick aim should not be overridden by default keyboard aim."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.2)

    # Set aim direction to down (simulating joystick aim)
    await game.call(BALL_SPAWNER, "set_aim_direction_xy", [0.0, 1.0])
    await asyncio.sleep(0.1)

    # Get initial aim direction
    initial_dir = await game.call(BALL_SPAWNER, "get_aim_direction")
    assert initial_dir is not None, "Should get initial aim direction"
    assert initial_dir.get("y", 0) > 0.9, f"Initial aim should be down, got Y={initial_dir.get('y', 0)}"

    # Fire button is ready
    await wait_for_fire_ready(game)

    # Fire (this tests that the direction is preserved)
    await game.call(FIRE_BUTTON, "emit_signal", ["fired"])
    await asyncio.sleep(0.1)

    # The aim direction should still be down (not overridden to UP)
    final_dir = await game.call(BALL_SPAWNER, "get_aim_direction")
    assert final_dir is not None, "Should get final aim direction"
    assert final_dir.get("y", 0) > 0.9, \
        f"Aim should still be down after fire, got Y={final_dir.get('y', 0)}"

    # Re-enable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [True])


@pytest.mark.asyncio
async def test_spawner_has_get_aim_direction_method(game):
    """Ball spawner should have get_aim_direction method for tests."""
    has_method = await game.call(BALL_SPAWNER, "has_method", ["get_aim_direction"])
    assert has_method, "BallSpawner should have get_aim_direction method"
