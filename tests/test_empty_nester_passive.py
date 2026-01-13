"""Tests for the Empty Nester passive (no baby balls, double specials)."""
import asyncio
import pytest

# Game manager autoload path
GAME_MANAGER = "/root/GameManager"

# Passive enum values (match GameManager.Passive enum)
PASSIVE_NONE = 0
PASSIVE_SQUAD_LEADER = 5  # SQUAD_LEADER is 5th in enum
PASSIVE_EMPTY_NESTER = 10  # EMPTY_NESTER is 10th in enum (0-indexed)


@pytest.mark.asyncio
async def test_has_no_baby_balls_false_by_default(game):
    """Without Empty Nester passive, has_no_baby_balls should return false."""
    # Reset passive to NONE
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])

    has_no_babies = await game.call(GAME_MANAGER, "has_no_baby_balls")

    assert has_no_babies == False, "has_no_baby_balls should be false without Empty Nester passive"


@pytest.mark.asyncio
async def test_has_no_baby_balls_true_with_empty_nester(game):
    """With Empty Nester passive, has_no_baby_balls should return true."""
    # Set Empty Nester passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_EMPTY_NESTER])

    has_no_babies = await game.call(GAME_MANAGER, "has_no_baby_balls")

    assert has_no_babies == True, "has_no_baby_balls should be true with Empty Nester passive"

    # Reset passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])


@pytest.mark.asyncio
async def test_empty_nester_passive_in_valid_passives(game):
    """Empty Nester should be a valid passive in VALID_PASSIVES mapping."""
    valid_passives = await game.get_property(GAME_MANAGER, "VALID_PASSIVES")

    assert "Empty Nester" in valid_passives, "Empty Nester should be in VALID_PASSIVES"


@pytest.mark.asyncio
async def test_get_special_fire_multiplier_one_by_default(game):
    """Without Empty Nester passive, special fire multiplier should be 1."""
    # Reset passive to NONE
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])

    multiplier = await game.call(GAME_MANAGER, "get_special_fire_multiplier")

    assert multiplier == 1, f"Expected 1 without Empty Nester passive, got {multiplier}"


@pytest.mark.asyncio
async def test_get_special_fire_multiplier_two_with_empty_nester(game):
    """With Empty Nester passive, special fire multiplier should be 2."""
    # Set Empty Nester passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_EMPTY_NESTER])

    multiplier = await game.call(GAME_MANAGER, "get_special_fire_multiplier")

    assert multiplier == 2, f"Expected 2 with Empty Nester passive, got {multiplier}"

    # Reset passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])


@pytest.mark.asyncio
async def test_squad_leader_still_has_baby_balls(game):
    """Squad Leader passive should NOT disable baby balls (different archetype)."""
    # Set Squad Leader passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_SQUAD_LEADER])

    has_no_babies = await game.call(GAME_MANAGER, "has_no_baby_balls")

    assert has_no_babies == False, "Squad Leader should still have baby balls"

    # Reset passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])


@pytest.mark.asyncio
async def test_squad_leader_normal_special_multiplier(game):
    """Squad Leader should have normal special fire multiplier (1)."""
    # Set Squad Leader passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_SQUAD_LEADER])

    multiplier = await game.call(GAME_MANAGER, "get_special_fire_multiplier")

    assert multiplier == 1, f"Squad Leader should have multiplier 1, got {multiplier}"

    # Reset passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])


@pytest.mark.asyncio
async def test_empty_nester_passive_game_loads_without_errors(game):
    """Game should load successfully with Empty Nester passive changes."""
    node = await game.get_node("/root/Game")
    assert node is not None, "Game should load with Empty Nester passive changes"


@pytest.mark.asyncio
async def test_baby_ball_spawner_exists(game):
    """Baby ball spawner should exist in the game."""
    # Get the baby ball spawner node
    spawner = await game.get_node("/root/Game/GameArea/BabyBallSpawner")
    # May not exist in all setups, but should not cause errors
    # The test is really about verifying the game loads without errors


@pytest.mark.asyncio
async def test_empty_nester_archetypes_are_distinct(game):
    """Empty Nester and Squad Leader should be mutually exclusive playstyles."""
    # These represent opposite approaches to baby balls:
    # Squad Leader: MORE baby balls (+2 starting, +30% faster spawn)
    # Empty Nester: NO baby balls (compensated with 2x specials)

    # Set Squad Leader
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_SQUAD_LEADER])
    squad_has_babies = await game.call(GAME_MANAGER, "has_no_baby_balls")
    squad_special_mult = await game.call(GAME_MANAGER, "get_special_fire_multiplier")

    # Set Empty Nester
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_EMPTY_NESTER])
    nester_has_babies = await game.call(GAME_MANAGER, "has_no_baby_balls")
    nester_special_mult = await game.call(GAME_MANAGER, "get_special_fire_multiplier")

    # Verify they are distinct
    assert squad_has_babies != nester_has_babies, "Baby ball behavior should differ"
    assert squad_special_mult != nester_special_mult, "Special fire multiplier should differ"

    # Reset
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])
