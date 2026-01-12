"""
Tests for baby ball count limit based on Leadership stat.
"""

import asyncio
import pytest
from helpers import PATHS, WAIT_TIMEOUT


BABY_BALL_SPAWNER = PATHS["baby_ball_spawner"]
GAME_MANAGER = PATHS["game_manager"]
BALLS = PATHS["balls"]


@pytest.mark.asyncio
async def test_baby_ball_spawner_has_limit_methods(game):
    """Baby ball spawner should have get_max_baby_balls and get_current_baby_count methods."""
    # Check methods exist
    has_max_method = await game.call(BABY_BALL_SPAWNER, "has_method", ["get_max_baby_balls"])
    has_count_method = await game.call(BABY_BALL_SPAWNER, "has_method", ["get_current_baby_count"])

    assert has_max_method, "BabyBallSpawner should have get_max_baby_balls method"
    assert has_count_method, "BabyBallSpawner should have get_current_baby_count method"


@pytest.mark.asyncio
async def test_base_max_babies_is_three(game):
    """Default base_max_babies should be 3."""
    base_max = await game.get_property(BABY_BALL_SPAWNER, "base_max_babies")
    assert base_max == 3, "Base max babies should be 3"


@pytest.mark.asyncio
async def test_get_max_baby_balls_returns_base_without_leadership(game):
    """With no leadership bonus, max baby balls should be base_max_babies."""
    # Reset leadership to 0
    await game.call(GAME_MANAGER, "set", ["leadership", 0.0])

    # Also set the spawner's leadership bonus to 0
    await game.call(BABY_BALL_SPAWNER, "set_leadership", [0.0])

    max_babies = await game.call(BABY_BALL_SPAWNER, "get_max_baby_balls")
    base_max = await game.get_property(BABY_BALL_SPAWNER, "base_max_babies")

    # Should equal base_max + any passive bonus (which is 0 for default character)
    assert max_babies >= base_max, f"Max babies ({max_babies}) should be at least base ({base_max})"


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

    # Count should be 0 before spawner starts
    count = await game.call(BABY_BALL_SPAWNER, "get_current_baby_count")
    assert count == 0, f"Baby count should be 0 at start, got {count}"


@pytest.mark.asyncio
async def test_baby_ball_limit_respected(game):
    """Baby ball spawner should not exceed max limit."""
    # Set a low max by keeping leadership at 0
    await game.call(BABY_BALL_SPAWNER, "set_leadership", [0.0])
    max_babies = await game.call(BABY_BALL_SPAWNER, "get_max_baby_balls")

    # Start game and let baby balls spawn
    await game.call(GAME_MANAGER, "start_game")
    await game.call(BABY_BALL_SPAWNER, "start")

    # Wait for spawner to try spawning several times
    # (base interval is 2s, but we speed up by checking multiple times)
    await asyncio.sleep(3.0)

    # Count baby balls
    count = await game.call(BABY_BALL_SPAWNER, "get_current_baby_count")

    # Should not exceed max
    assert count <= max_babies, f"Baby count ({count}) should not exceed max ({max_babies})"


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
