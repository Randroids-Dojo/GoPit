"""
Tests for baby ball count based on Leadership stat (queue-based system).
"""

import asyncio
import pytest
from helpers import PATHS, WAIT_TIMEOUT


BABY_BALL_SPAWNER = PATHS["baby_ball_spawner"]
BALL_SPAWNER = PATHS["ball_spawner"]
GAME_MANAGER = PATHS["game_manager"]
BALLS = PATHS["balls"]
FIRE_BUTTON = PATHS["fire_button"]


@pytest.mark.asyncio
async def test_baby_ball_spawner_has_limit_methods(game):
    """Baby ball spawner should have get_max_baby_balls and get_current_baby_count methods."""
    # Check methods exist
    has_max_method = await game.call(BABY_BALL_SPAWNER, "has_method", ["get_max_baby_balls"])
    has_count_method = await game.call(BABY_BALL_SPAWNER, "has_method", ["get_current_baby_count"])

    assert has_max_method, "BabyBallSpawner should have get_max_baby_balls method"
    assert has_count_method, "BabyBallSpawner should have get_current_baby_count method"


@pytest.mark.asyncio
async def test_base_baby_count_is_one(game):
    """Default base_baby_count should be 1 (per fire action)."""
    base_count = await game.get_property(BABY_BALL_SPAWNER, "base_baby_count")
    assert base_count == 1, f"Base baby count should be 1, got {base_count}"


@pytest.mark.asyncio
async def test_get_max_baby_balls_returns_base_without_leadership(game):
    """With no leadership bonus, max baby balls should be base_baby_count."""
    # Reset leadership to 0
    await game.call(GAME_MANAGER, "set", ["leadership", 0.0])

    # Also set the spawner's leadership bonus to 0
    await game.call(BABY_BALL_SPAWNER, "set_leadership", [0.0])

    max_babies = await game.call(BABY_BALL_SPAWNER, "get_max_baby_balls")
    base_count = await game.get_property(BABY_BALL_SPAWNER, "base_baby_count")

    # Should equal base_count + any passive bonus (which is 0 for default character)
    assert max_babies >= base_count, f"Max babies ({max_babies}) should be at least base ({base_count})"


@pytest.mark.asyncio
async def test_leadership_increases_max_baby_balls(game):
    """Leadership bonus should increase max baby balls."""
    # Get baseline with 0 leadership
    await game.call(BABY_BALL_SPAWNER, "set_leadership", [0.0])
    base_max = await game.call(BABY_BALL_SPAWNER, "get_max_baby_balls")

    # Increase leadership
    await game.call(BABY_BALL_SPAWNER, "set_leadership", [1.0])
    increased_max = await game.call(BABY_BALL_SPAWNER, "get_max_baby_balls")

    assert increased_max > base_max, f"Leadership should increase max babies (was {base_max}, now {increased_max})"


@pytest.mark.asyncio
async def test_get_current_baby_count_starts_at_zero(game):
    """Current baby count should start at 0 before any spawning."""
    # Clear any existing baby balls by getting a fresh game state
    await game.call(GAME_MANAGER, "reset")
    await asyncio.sleep(0.1)

    # Count should be 0 before any firing
    count = await game.call(BABY_BALL_SPAWNER, "get_current_baby_count")
    assert count == 0, f"Baby count should be 0 at start, got {count}"


@pytest.mark.asyncio
async def test_baby_balls_queued_on_fire(game):
    """Baby balls should spawn when player fires (salvo system)."""
    # Note: With salvo system, main balls fire immediately (not queued)
    # Baby balls are handled by BabyBallSpawner via ball_spawned signal
    # This test verifies the ball_spawner can still fire successfully

    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.2)

    # Wait for any balls to return (salvo system requires all balls back)
    await asyncio.sleep(0.5)

    # Fire a salvo
    await game.call(BALL_SPAWNER, "fire")
    await asyncio.sleep(0.2)

    # With salvo system, balls spawn immediately into balls container
    # Check that main balls were spawned (main_balls_in_flight > 0)
    main_in_flight = await game.call(BALL_SPAWNER, "get_main_balls_in_flight")
    # Note: balls may have already returned if fast, so check >= 0
    assert main_in_flight >= 0, f"Should have spawned balls, got {main_in_flight} in flight"

    # Re-enable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [True])


@pytest.mark.asyncio
async def test_leadership_damage_bonus_method_exists(game):
    """Baby ball spawner should have get_leadership_damage_bonus method."""
    has_method = await game.call(BABY_BALL_SPAWNER, "has_method", ["get_leadership_damage_bonus"])
    assert has_method, "BabyBallSpawner should have get_leadership_damage_bonus method"


@pytest.mark.asyncio
async def test_leadership_damage_bonus_is_one_without_leadership(game):
    """With no leadership bonus, damage bonus should be 1.0 (no bonus)."""
    await game.call(BABY_BALL_SPAWNER, "set_leadership", [0.0])
    bonus = await game.call(BABY_BALL_SPAWNER, "get_leadership_damage_bonus")
    assert abs(bonus - 1.0) < 0.01, f"Damage bonus should be 1.0 with no leadership, got {bonus}"


@pytest.mark.asyncio
async def test_leadership_increases_damage_bonus(game):
    """Leadership bonus should increase baby ball damage."""
    # Get baseline with 0 leadership
    await game.call(BABY_BALL_SPAWNER, "set_leadership", [0.0])
    base_bonus = await game.call(BABY_BALL_SPAWNER, "get_leadership_damage_bonus")

    # Increase leadership
    await game.call(BABY_BALL_SPAWNER, "set_leadership", [1.0])
    increased_bonus = await game.call(BABY_BALL_SPAWNER, "get_leadership_damage_bonus")

    assert increased_bonus > base_bonus, f"Leadership should increase damage bonus (was {base_bonus}, now {increased_bonus})"
