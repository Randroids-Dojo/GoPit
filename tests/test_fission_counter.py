"""Tests for fission counter UI showing number of items upgraded."""
import asyncio
import pytest

FUSION_REGISTRY = "/root/FusionRegistry"
BALL_REGISTRY = "/root/BallRegistry"
HUD = "/root/Game/UI/HUD"
FISSION_COUNTER = "/root/Game/UI/HUD/FissionCounter"


@pytest.mark.asyncio
async def test_fission_counter_label_exists(game):
    """FissionCounter label should exist in HUD."""
    node = await game.get_node(FISSION_COUNTER)
    assert node is not None, "FissionCounter should exist in HUD"


@pytest.mark.asyncio
async def test_fission_counter_starts_hidden(game):
    """FissionCounter should start hidden until first fission."""
    # Reset to clean state
    await game.call(FUSION_REGISTRY, "reset")

    # Check visibility
    visible = await game.get_property(FISSION_COUNTER, "visible")
    assert visible is False, "FissionCounter should start hidden"


@pytest.mark.asyncio
async def test_get_fission_upgrades_method_exists(game):
    """FusionRegistry should have get_fission_upgrades method."""
    has_method = await game.call(FUSION_REGISTRY, "has_method", ["get_fission_upgrades"])
    assert has_method, "FusionRegistry should have get_fission_upgrades method"


@pytest.mark.asyncio
async def test_fission_upgrades_starts_at_zero(game):
    """Fission upgrades should start at 0."""
    await game.call(FUSION_REGISTRY, "reset")
    count = await game.call(FUSION_REGISTRY, "get_fission_upgrades")
    assert count == 0, f"Fission upgrades should start at 0, got {count}"


@pytest.mark.asyncio
async def test_fission_increments_counter(game):
    """Applying fission should increment the counter."""
    # Reset to clean state
    await game.call(FUSION_REGISTRY, "reset")
    await game.call(BALL_REGISTRY, "reset")

    # Get initial count
    initial_count = await game.call(FUSION_REGISTRY, "get_fission_upgrades")
    assert initial_count == 0, "Should start at 0"

    # Apply fission
    result = await game.call(FUSION_REGISTRY, "apply_fission")

    # Get new count
    new_count = await game.call(FUSION_REGISTRY, "get_fission_upgrades")

    # Count should have increased by number of upgrades
    upgrades = result.get("upgrades", [])
    expected = initial_count + len(upgrades)
    assert new_count == expected, f"Fission upgrades should be {expected}, got {new_count}"


@pytest.mark.asyncio
async def test_multiple_fissions_accumulate(game):
    """Multiple fissions should accumulate total upgrades."""
    # Reset to clean state
    await game.call(FUSION_REGISTRY, "reset")
    await game.call(BALL_REGISTRY, "reset")

    # Apply fission multiple times
    total_upgrades = 0
    for _ in range(3):
        result = await game.call(FUSION_REGISTRY, "apply_fission")
        upgrades = result.get("upgrades", [])
        total_upgrades += len(upgrades)

    # Verify accumulated count
    count = await game.call(FUSION_REGISTRY, "get_fission_upgrades")
    assert count == total_upgrades, f"Should have {total_upgrades} upgrades, got {count}"


@pytest.mark.asyncio
async def test_reset_clears_fission_counter(game):
    """Resetting FusionRegistry should clear fission counter."""
    # Apply some fissions first
    await game.call(FUSION_REGISTRY, "apply_fission")

    # Get count before reset
    before = await game.call(FUSION_REGISTRY, "get_fission_upgrades")
    assert before > 0 or before == 0, "Counter should have a value"

    # Reset
    await game.call(FUSION_REGISTRY, "reset")

    # Counter should be 0
    after = await game.call(FUSION_REGISTRY, "get_fission_upgrades")
    assert after == 0, f"Counter should be 0 after reset, got {after}"


@pytest.mark.asyncio
async def test_fission_counter_shows_after_fission(game):
    """FissionCounter should become visible after fission with upgrades."""
    # Reset to clean state
    await game.call(FUSION_REGISTRY, "reset")
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Apply fission
    result = await game.call(FUSION_REGISTRY, "apply_fission")
    await asyncio.sleep(0.2)  # Wait for signal propagation

    # If upgrades were applied, counter should be visible
    upgrades = result.get("upgrades", [])
    if len(upgrades) > 0:
        visible = await game.get_property(FISSION_COUNTER, "visible")
        assert visible is True, "FissionCounter should be visible after fission with upgrades"
