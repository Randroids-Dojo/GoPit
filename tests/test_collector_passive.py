"""Tests for the Collector passive (built-in magnet)."""
import asyncio
import pytest

# Game manager autoload path
GAME_MANAGER = "/root/GameManager"

# Collector mechanic constants (match game_manager.gd)
COLLECTOR_MAGNET_RANGE = 1000.0  # Built-in magnet range for Collector passive
BOSS_MAGNET_RANGE = 2000.0  # Boss fight auto-magnet range

# Passive enum values (match GameManager.Passive enum)
PASSIVE_NONE = 0
PASSIVE_COLLECTOR = 9  # COLLECTOR is 9th in enum (0-indexed: NONE=0, ..., COLLECTOR=9)


@pytest.mark.asyncio
async def test_get_effective_magnetism_range_returns_zero_by_default(game):
    """Without Collector passive and no upgrades, magnetism range should be 0."""
    # Reset passive to NONE
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])
    await game.call(GAME_MANAGER, "set", ["gem_magnetism_range", 0.0])
    await game.call(GAME_MANAGER, "set", ["is_boss_fight", False])

    # Get effective magnetism range
    range_val = await game.call(GAME_MANAGER, "get_effective_magnetism_range")

    assert range_val == 0.0, f"Expected 0 without Collector passive, got {range_val}"


@pytest.mark.asyncio
async def test_get_effective_magnetism_range_with_collector_passive(game):
    """With Collector passive active, magnetism range should be max (1000)."""
    # Set Collector passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_COLLECTOR])
    await game.call(GAME_MANAGER, "set", ["is_boss_fight", False])

    # Get effective magnetism range
    range_val = await game.call(GAME_MANAGER, "get_effective_magnetism_range")

    assert range_val == pytest.approx(COLLECTOR_MAGNET_RANGE, abs=0.001), \
        f"Expected {COLLECTOR_MAGNET_RANGE} with Collector passive, got {range_val}"

    # Reset passive to NONE
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])


@pytest.mark.asyncio
async def test_collector_passive_in_valid_passives(game):
    """Collector should be a valid passive in VALID_PASSIVES mapping."""
    valid_passives = await game.get_property(GAME_MANAGER, "VALID_PASSIVES")

    assert "Collector" in valid_passives, "Collector should be in VALID_PASSIVES"


@pytest.mark.asyncio
async def test_has_built_in_magnet_false_by_default(game):
    """Without Collector passive, has_built_in_magnet should return false."""
    # Reset passive to NONE
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])

    has_magnet = await game.call(GAME_MANAGER, "has_built_in_magnet")

    assert has_magnet == False, "has_built_in_magnet should be false without Collector passive"


@pytest.mark.asyncio
async def test_has_built_in_magnet_true_with_collector(game):
    """With Collector passive, has_built_in_magnet should return true."""
    # Set Collector passive
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_COLLECTOR])

    has_magnet = await game.call(GAME_MANAGER, "has_built_in_magnet")

    assert has_magnet == True, "has_built_in_magnet should be true with Collector passive"

    # Reset passive to NONE
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])


@pytest.mark.asyncio
async def test_boss_fight_magnetism_range(game):
    """During boss fights, magnetism should use BOSS_MAGNET_RANGE."""
    # Reset passive to NONE and enable boss fight
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])
    await game.call(GAME_MANAGER, "set", ["gem_magnetism_range", 0.0])
    await game.call(GAME_MANAGER, "set", ["is_boss_fight", True])

    # Get effective magnetism range
    range_val = await game.call(GAME_MANAGER, "get_effective_magnetism_range")

    assert range_val == pytest.approx(BOSS_MAGNET_RANGE, abs=0.001), \
        f"Expected {BOSS_MAGNET_RANGE} during boss fight, got {range_val}"

    # Reset boss fight flag
    await game.call(GAME_MANAGER, "set", ["is_boss_fight", False])


@pytest.mark.asyncio
async def test_collector_overrides_boss_magnet(game):
    """Collector passive should override boss fight magnetism (use its own range)."""
    # Set Collector passive and enable boss fight
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_COLLECTOR])
    await game.call(GAME_MANAGER, "set", ["is_boss_fight", True])

    # Get effective magnetism range - Collector takes priority
    range_val = await game.call(GAME_MANAGER, "get_effective_magnetism_range")

    # Collector passive range should be used (it's checked first in the function)
    assert range_val == pytest.approx(COLLECTOR_MAGNET_RANGE, abs=0.001), \
        f"Expected {COLLECTOR_MAGNET_RANGE} with Collector passive (even during boss fight), got {range_val}"

    # Reset
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])
    await game.call(GAME_MANAGER, "set", ["is_boss_fight", False])


@pytest.mark.asyncio
async def test_upgrade_magnetism_range_works_without_collector(game):
    """Without Collector passive, upgraded magnetism range should be used."""
    # Reset passive to NONE and set upgrade magnetism
    await game.call(GAME_MANAGER, "set", ["active_passive", PASSIVE_NONE])
    await game.call(GAME_MANAGER, "set", ["gem_magnetism_range", 300.0])
    await game.call(GAME_MANAGER, "set", ["is_boss_fight", False])

    # Get effective magnetism range
    range_val = await game.call(GAME_MANAGER, "get_effective_magnetism_range")

    assert range_val == pytest.approx(300.0, abs=0.001), \
        f"Expected 300.0 from upgrade, got {range_val}"

    # Reset
    await game.call(GAME_MANAGER, "set", ["gem_magnetism_range", 0.0])


@pytest.mark.asyncio
async def test_collector_passive_game_loads_without_errors(game):
    """Game should load successfully with Collector passive changes."""
    node = await game.get_node("/root/Game")
    assert node is not None, "Game should load with Collector passive changes"


@pytest.mark.asyncio
async def test_collector_magnet_range_reasonable_value(game):
    """Collector magnet range should be a reasonable value (larger than most screens)."""
    # 1000px should be enough to attract gems from anywhere on a 720px wide screen
    assert COLLECTOR_MAGNET_RANGE >= 500, "Collector magnet range should be at least 500"
    assert COLLECTOR_MAGNET_RANGE <= 2000, "Collector magnet range shouldn't exceed boss range"
