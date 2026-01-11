"""Tests for game speed toggle system."""
import asyncio
import pytest

GAME_MANAGER = "/root/GameManager"


async def reset_game_manager(game):
    """Reset GameManager to clean state for testing."""
    await game.call(GAME_MANAGER, "reset")
    await asyncio.sleep(0.1)


@pytest.mark.asyncio
async def test_speed_tier_starts_at_normal(game):
    """Game should start at normal speed (tier 0)."""
    await reset_game_manager(game)
    tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert tier == 0, "Should start at speed tier 0 (Normal)"


@pytest.mark.asyncio
async def test_toggle_speed_cycles_tiers(game):
    """toggle_speed should cycle through all tiers."""
    await reset_game_manager(game)
    # Start at Normal (0)
    initial_tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert initial_tier == 0, "Should start at Normal"

    # Toggle to Fast (1)
    await game.call(GAME_MANAGER, "toggle_speed")
    tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert tier == 1, "Should be Fast after first toggle"

    # Toggle to Fast+2 (2)
    await game.call(GAME_MANAGER, "toggle_speed")
    tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert tier == 2, "Should be Fast+2 after second toggle"

    # Toggle to Fast+3 (3)
    await game.call(GAME_MANAGER, "toggle_speed")
    tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert tier == 3, "Should be Fast+3 after third toggle"

    # Toggle back to Normal (0)
    await game.call(GAME_MANAGER, "toggle_speed")
    tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert tier == 0, "Should cycle back to Normal"


@pytest.mark.asyncio
async def test_set_speed_tier(game):
    """set_speed_tier should set specific tier."""
    await reset_game_manager(game)
    # Set to Fast+2
    await game.call(GAME_MANAGER, "set_speed_tier", [2])
    tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert tier == 2, "Should set to Fast+2"

    # Set to Normal
    await game.call(GAME_MANAGER, "set_speed_tier", [0])
    tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert tier == 0, "Should set to Normal"


@pytest.mark.asyncio
async def test_speed_tier_name(game):
    """get_speed_tier_name should return correct name."""
    await reset_game_manager(game)
    # Normal
    await game.call(GAME_MANAGER, "set_speed_tier", [0])
    name = await game.call(GAME_MANAGER, "get_speed_tier_name")
    assert name == "Normal", "Tier 0 should be Normal"

    # Fast
    await game.call(GAME_MANAGER, "set_speed_tier", [1])
    name = await game.call(GAME_MANAGER, "get_speed_tier_name")
    assert name == "Fast", "Tier 1 should be Fast"


@pytest.mark.asyncio
async def test_speed_multiplier(game):
    """get_speed_multiplier should return correct value."""
    await reset_game_manager(game)
    # Normal = 1.0x
    await game.call(GAME_MANAGER, "set_speed_tier", [0])
    mult = await game.call(GAME_MANAGER, "get_speed_multiplier")
    assert mult == 1.0, "Normal should be 1.0x"

    # Fast = 1.5x
    await game.call(GAME_MANAGER, "set_speed_tier", [1])
    mult = await game.call(GAME_MANAGER, "get_speed_multiplier")
    assert mult == 1.5, "Fast should be 1.5x"

    # Fast+2 = 2.5x
    await game.call(GAME_MANAGER, "set_speed_tier", [2])
    mult = await game.call(GAME_MANAGER, "get_speed_multiplier")
    assert mult == 2.5, "Fast+2 should be 2.5x"

    # Fast+3 = 4.0x
    await game.call(GAME_MANAGER, "set_speed_tier", [3])
    mult = await game.call(GAME_MANAGER, "get_speed_multiplier")
    assert mult == 4.0, "Fast+3 should be 4.0x"


@pytest.mark.asyncio
async def test_loot_multiplier(game):
    """get_loot_multiplier should return correct bonus."""
    await reset_game_manager(game)
    # Normal = 1.0x (no bonus)
    await game.call(GAME_MANAGER, "set_speed_tier", [0])
    loot = await game.call(GAME_MANAGER, "get_loot_multiplier")
    assert loot == 1.0, "Normal should have 1.0x loot"

    # Fast = 1.25x (+25%)
    await game.call(GAME_MANAGER, "set_speed_tier", [1])
    loot = await game.call(GAME_MANAGER, "get_loot_multiplier")
    assert loot == 1.25, "Fast should have 1.25x loot"

    # Fast+2 = 1.5x (+50%)
    await game.call(GAME_MANAGER, "set_speed_tier", [2])
    loot = await game.call(GAME_MANAGER, "get_loot_multiplier")
    assert loot == 1.5, "Fast+2 should have 1.5x loot"

    # Fast+3 = 2.0x (+100%)
    await game.call(GAME_MANAGER, "set_speed_tier", [3])
    loot = await game.call(GAME_MANAGER, "get_loot_multiplier")
    assert loot == 2.0, "Fast+3 should have 2.0x loot"


@pytest.mark.asyncio
async def test_speed_tier_clamps_to_valid_range(game):
    """set_speed_tier should clamp to valid range 0-3."""
    await reset_game_manager(game)
    # Try to set beyond max
    await game.call(GAME_MANAGER, "set_speed_tier", [99])
    tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert tier == 3, "Should clamp to max tier 3"

    # Try to set below min
    await game.call(GAME_MANAGER, "set_speed_tier", [-1])
    tier = await game.call(GAME_MANAGER, "get_speed_tier")
    assert tier == 0, "Should clamp to min tier 0"
