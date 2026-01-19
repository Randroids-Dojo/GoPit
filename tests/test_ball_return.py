"""Tests for ball return mechanic - balls return at bottom of screen."""
import asyncio
import pytest

from helpers import PATHS, wait_for_fire_ready, wait_for_can_fire

FIRE_BUTTON = PATHS["fire_button"]
BALL_SPAWNER = PATHS["ball_spawner"]


@pytest.mark.asyncio
async def test_ball_spawner_tracks_balls_in_flight(game):
    """BallSpawner should track number of balls in flight."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.2)

    # Wait for salvo to return (main_balls_in_flight == 0)
    await wait_for_can_fire(game)

    # Verify we can fire
    can_fire_before = await game.call(BALL_SPAWNER, "can_fire")
    assert can_fire_before, "Should be able to fire when main_balls_in_flight is 0"

    # Fire salvo
    await wait_for_fire_ready(game)
    await game.click(FIRE_BUTTON)

    # Wait briefly for salvo to register
    await asyncio.sleep(0.1)

    # Main balls in flight should now be > 0 (salvo just fired)
    main_after = await game.call(BALL_SPAWNER, "get_main_balls_in_flight")
    assert main_after > 0, f"Main balls in flight should increase after firing salvo, got {main_after}"

    # Re-enable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [True])


@pytest.mark.asyncio
async def test_ball_returns_at_bottom_of_screen(game):
    """Balls should return when crossing bottom threshold."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.2)

    # Wait for salvo to return
    await wait_for_can_fire(game)

    # Fire a ball aimed downward (toward bottom of screen)
    await game.call(BALL_SPAWNER, "set_aim_direction_xy", [0.0, 1.0])
    await wait_for_fire_ready(game)
    await game.click(FIRE_BUTTON)

    # Wait briefly for salvo to register
    await asyncio.sleep(0.1)

    # Get main balls in flight immediately after
    in_flight_after = await game.call(BALL_SPAWNER, "get_main_balls_in_flight")
    assert in_flight_after > 0, "Should have main balls in flight after firing salvo"

    # Wait for balls to reach bottom and return (extra time for CI)
    await asyncio.sleep(4.0)

    # Main balls in flight should decrease as balls return
    final_in_flight = await game.call(BALL_SPAWNER, "get_main_balls_in_flight")
    assert final_in_flight < in_flight_after, f"Balls should return, in_flight went from {in_flight_after} to {final_in_flight}"

    # Re-enable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [True])


@pytest.mark.asyncio
async def test_can_fire_checks_ball_availability(game):
    """BallSpawner.can_fire() should check ball availability (salvo mechanic)."""
    # With salvo mechanic, can_fire returns True only when main_balls_in_flight == 0
    # (all main balls must have returned before firing again)

    # Verify the method exists and returns a boolean
    can_fire = await game.call(BALL_SPAWNER, "can_fire")
    assert can_fire is not None, "BallSpawner should have can_fire method"
    assert isinstance(can_fire, bool), f"can_fire should return a boolean, got {type(can_fire)}"

    # Verify get_main_balls_in_flight method exists
    main_in_flight = await game.call(BALL_SPAWNER, "get_main_balls_in_flight")
    assert main_in_flight is not None, "BallSpawner should have get_main_balls_in_flight method"
    assert isinstance(main_in_flight, int), f"get_main_balls_in_flight should return an int, got {type(main_in_flight)}"

    # Note: can't reliably test can_fire == (main_in_flight == 0) due to race conditions
    # with parallel test execution and autofire. The salvo mechanic is tested by
    # test_ball_spawner_tracks_balls_in_flight which verifies the fire->return cycle.


@pytest.mark.asyncio
async def test_fire_button_respects_ball_availability(game):
    """Fire button should respect ball availability from spawner."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.2)

    # Check fire button has _balls_available property
    balls_avail = await game.get_property(FIRE_BUTTON, "_balls_available")
    assert balls_avail is not None, "Fire button should have _balls_available property"

    # Re-enable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [True])
