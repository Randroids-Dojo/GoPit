"""Test the ball slot system - multiple ball types firing simultaneously."""
import asyncio
import pytest

GAME = "/root/Game"
FIRE_BUTTON = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"
BALLS_CONTAINER = "/root/Game/GameArea/Balls"
BALL_REGISTRY = "/root/BallRegistry"

# Timeout for waiting operations (seconds)
WAIT_TIMEOUT = 5.0


async def wait_for_fire_ready(game, timeout=WAIT_TIMEOUT):
    """Wait for fire button to be ready with timeout."""
    elapsed = 0
    while elapsed < timeout:
        is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
        if is_ready:
            return True
        await asyncio.sleep(0.1)
        elapsed += 0.1
    return False


@pytest.mark.asyncio
async def test_ball_slots_initialized(game):
    """Verify ball slots are initialized correctly at game start."""
    # Get ball slots from registry
    slots = await game.get_property(BALL_REGISTRY, "ball_slots")

    assert slots is not None, "Ball slots should exist"
    assert len(slots) == 4, f"Should have 4 ball slots, got {len(slots)}"

    # First slot should have BASIC ball (type 0)
    assert slots[0] == 0, f"First slot should have BASIC ball (0), got {slots[0]}"

    # Remaining slots should be empty (-1)
    for i in range(1, 4):
        assert slots[i] == -1, f"Slot {i} should be empty (-1), got {slots[i]}"


@pytest.mark.asyncio
async def test_fire_single_slot(game):
    """Fire with a single ball type in slot."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await wait_for_fire_ready(game)

    # Get initial ball count
    balls_before = await game.call(BALLS_CONTAINER, "get_child_count")

    # Fire once
    await game.click(FIRE_BUTTON)
    await asyncio.sleep(0.2)

    # Should spawn 1 ball (1 slot × 1 multi-shot)
    balls_after = await game.call(BALLS_CONTAINER, "get_child_count")
    balls_spawned = balls_after - balls_before

    assert balls_spawned == 1, f"Should spawn 1 ball with single slot, got {balls_spawned}"


@pytest.mark.asyncio
async def test_add_ball_fills_slot(game):
    """Adding a new ball type fills the next empty slot."""
    # Add a BURN ball (type 1)
    await game.call(BALL_REGISTRY, "add_ball", [1])

    slots = await game.get_property(BALL_REGISTRY, "ball_slots")

    # Slot 0 should still have BASIC
    assert slots[0] == 0, "Slot 0 should still have BASIC ball"
    # Slot 1 should now have BURN
    assert slots[1] == 1, "Slot 1 should have BURN ball after adding"
    # Remaining slots should be empty
    assert slots[2] == -1, "Slot 2 should be empty"
    assert slots[3] == -1, "Slot 3 should be empty"


@pytest.mark.asyncio
async def test_fire_multiple_slots(game):
    """Fire with multiple ball types - all slots fire simultaneously."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])

    # Add a second ball type (BURN = 1)
    await game.call(BALL_REGISTRY, "add_ball", [1])

    # Wait for fire to be ready
    await wait_for_fire_ready(game)

    # Get initial ball count
    balls_before = await game.call(BALLS_CONTAINER, "get_child_count")

    # Fire once
    await game.click(FIRE_BUTTON)
    await asyncio.sleep(0.2)

    # Should spawn 2 balls (2 slots × 1 multi-shot)
    balls_after = await game.call(BALLS_CONTAINER, "get_child_count")
    balls_spawned = balls_after - balls_before

    assert balls_spawned == 2, f"Should spawn 2 balls with 2 slots, got {balls_spawned}"


@pytest.mark.asyncio
async def test_fire_all_slots_filled(game):
    """Fire with all 4 slots filled."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])

    # Add ball types to fill all slots (BURN=1, FREEZE=2, POISON=3)
    await game.call(BALL_REGISTRY, "add_ball", [1])  # BURN
    await game.call(BALL_REGISTRY, "add_ball", [2])  # FREEZE
    await game.call(BALL_REGISTRY, "add_ball", [3])  # POISON

    # Verify all slots are filled
    slots = await game.get_property(BALL_REGISTRY, "ball_slots")
    assert slots[0] == 0, "Slot 0 should have BASIC"
    assert slots[1] == 1, "Slot 1 should have BURN"
    assert slots[2] == 2, "Slot 2 should have FREEZE"
    assert slots[3] == 3, "Slot 3 should have POISON"

    # Wait for fire to be ready
    await wait_for_fire_ready(game)

    # Get initial ball count
    balls_before = await game.call(BALLS_CONTAINER, "get_child_count")

    # Fire once
    await game.click(FIRE_BUTTON)
    await asyncio.sleep(0.3)

    # Should spawn 4 balls (4 slots × 1 multi-shot)
    balls_after = await game.call(BALLS_CONTAINER, "get_child_count")
    balls_spawned = balls_after - balls_before

    assert balls_spawned == 4, f"Should spawn 4 balls with 4 slots, got {balls_spawned}"


@pytest.mark.asyncio
async def test_get_active_slots(game):
    """Test get_active_slots returns only filled slots."""
    # Initially should have just BASIC
    active = await game.call(BALL_REGISTRY, "get_active_slots")
    assert len(active) == 1, f"Should have 1 active slot initially, got {len(active)}"
    assert active[0] == 0, "Active slot should be BASIC (0)"

    # Add BURN and FREEZE
    await game.call(BALL_REGISTRY, "add_ball", [1])
    await game.call(BALL_REGISTRY, "add_ball", [2])

    active = await game.call(BALL_REGISTRY, "get_active_slots")
    assert len(active) == 3, f"Should have 3 active slots, got {len(active)}"
    assert 0 in active, "BASIC should be in active slots"
    assert 1 in active, "BURN should be in active slots"
    assert 2 in active, "FREEZE should be in active slots"
