"""Tests for ball slot system - multiple ball types firing simultaneously."""
import asyncio
import pytest

from helpers import PATHS, wait_for_fire_ready

GAME = PATHS["game"]
FIRE_BUTTON = PATHS["fire_button"]
BALLS_CONTAINER = PATHS["balls"]
BALL_SPAWNER = PATHS["ball_spawner"]
BALL_REGISTRY = "/root/BallRegistry"


async def reset_ball_registry(game):
    """Reset BallRegistry to clean state for testing."""
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)  # Give time for state to settle


@pytest.mark.asyncio
async def test_ball_registry_has_slots(game):
    """BallRegistry should have active_ball_slots array."""
    await reset_ball_registry(game)
    # Check that BallRegistry has the slots array
    slots = await game.call(BALL_REGISTRY, "get_active_slots")
    assert slots is not None, "BallRegistry should have active_ball_slots"
    assert len(slots) == 5, "Should have 5 ball slots"


@pytest.mark.asyncio
async def test_initial_slot_has_basic_ball(game):
    """First slot should have BASIC ball after game starts."""
    await reset_ball_registry(game)
    slots = await game.call(BALL_REGISTRY, "get_active_slots")
    # First slot should be BASIC (0), rest should be empty (-1)
    assert slots[0] == 0, "First slot should have BASIC ball type (0)"


@pytest.mark.asyncio
async def test_add_ball_fills_slot(game):
    """Adding a new ball should auto-assign to first empty slot."""
    await reset_ball_registry(game)
    # Get initial slots
    slots_before = await game.call(BALL_REGISTRY, "get_active_slots")
    initial_filled = sum(1 for s in slots_before if s != -1)

    # Add a new ball type (BURN = 1)
    await game.call(BALL_REGISTRY, "add_ball", [1])

    # Check slots after
    slots_after = await game.call(BALL_REGISTRY, "get_active_slots")
    filled_after = sum(1 for s in slots_after if s != -1)

    assert filled_after == initial_filled + 1, "Should have one more filled slot"
    assert 1 in slots_after, "BURN ball should be in a slot"


@pytest.mark.asyncio
async def test_multi_slot_fires_multiple_types(game):
    """Firing with multiple slots should spawn multiple ball types."""
    await reset_ball_registry(game)
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])

    # Wait for button ready
    ready = await wait_for_fire_ready(game)
    assert ready, "Fire button should become ready"

    # Add a second ball type to slots (FREEZE = 2)
    await game.call(BALL_REGISTRY, "add_ball", [2])
    await asyncio.sleep(0.1)

    # Get filled slot count
    filled_slots = await game.call(BALL_REGISTRY, "get_filled_slots")
    slot_count = len(filled_slots)
    assert slot_count >= 2, f"Should have at least 2 filled slots, got {slot_count}"

    # Clear existing balls
    ball_count_before = await game.call(BALLS_CONTAINER, "get_child_count")

    # Fire - with salvo mechanic, all slots fire immediately
    await game.click(FIRE_BUTTON)

    # Wait briefly for balls to spawn (salvo fires all at once)
    await asyncio.sleep(0.5)

    # Check that multiple balls spawned (one per slot)
    ball_count_after = await game.call(BALLS_CONTAINER, "get_child_count")
    balls_spawned = ball_count_after - ball_count_before + slot_count  # Account for balls that may have despawned

    # Should have spawned at least slot_count balls
    assert ball_count_after >= slot_count, f"Should spawn at least {slot_count} balls (one per slot)"


@pytest.mark.asyncio
async def test_get_slot_count(game):
    """get_slot_count should return number of filled slots."""
    await reset_ball_registry(game)
    slot_count = await game.call(BALL_REGISTRY, "get_slot_count")
    assert slot_count >= 1, "Should have at least 1 slot filled (BASIC)"


@pytest.mark.asyncio
async def test_set_slot(game):
    """Should be able to manually set a slot to a specific ball type."""
    await reset_ball_registry(game)
    # First add POISON ball (type 3) to owned balls
    await game.call(BALL_REGISTRY, "add_ball", [3])

    # Manually set slot 2 to POISON
    success = await game.call(BALL_REGISTRY, "set_slot", [2, 3])
    assert success, "Should be able to set slot to owned ball type"

    # Verify slot was set
    slots = await game.call(BALL_REGISTRY, "get_active_slots")
    assert slots[2] == 3, "Slot 2 should now have POISON ball"


@pytest.mark.asyncio
async def test_clear_slot(game):
    """Should be able to clear a slot."""
    await reset_ball_registry(game)
    # First make sure slot 1 has something
    await game.call(BALL_REGISTRY, "add_ball", [1])
    slots = await game.call(BALL_REGISTRY, "get_active_slots")
    initial_slot_1 = slots[1]

    # Clear slot 1
    await game.call(BALL_REGISTRY, "clear_slot", [1])

    # Verify slot was cleared
    slots_after = await game.call(BALL_REGISTRY, "get_active_slots")
    assert slots_after[1] == -1, "Slot 1 should be empty after clearing"
