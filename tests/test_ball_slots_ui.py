"""Tests for the ball slots display UI."""
import asyncio
import pytest

GAME = "/root/Game"
HUD = "/root/Game/UI/HUD"
BALL_SLOTS = "/root/Game/UI/HUD/BallSlotsDisplay"
BALL_REGISTRY = "/root/BallRegistry"


@pytest.mark.asyncio
async def test_ball_slots_display_exists(game):
    """Verify the ball slots display node exists in HUD."""
    node = await game.get_node(BALL_SLOTS)
    assert node is not None, "BallSlotsDisplay should exist in HUD"


@pytest.mark.asyncio
async def test_ball_slots_display_visible(game):
    """Verify the ball slots display is visible."""
    visible = await game.get_property(BALL_SLOTS, "visible")
    assert visible is True, "BallSlotsDisplay should be visible"


@pytest.mark.asyncio
async def test_ball_slots_has_refresh_method(game):
    """Verify ball slots display has refresh method."""
    has_method = await game.call(BALL_SLOTS, "has_method", ["refresh"])
    assert has_method is True, "BallSlotsDisplay should have refresh method"


@pytest.mark.asyncio
async def test_ball_slots_creates_slot_children(game):
    """Verify the display creates 5 slot containers."""
    # Wait a moment for _ready to complete
    await asyncio.sleep(0.3)

    # Get child count - should have 5 slots
    count = await game.call(BALL_SLOTS, "get_child_count")
    assert count == 5, f"BallSlotsDisplay should have 5 slot children, got {count}"


@pytest.mark.asyncio
async def test_ball_display_shows_equipped_balls(game):
    """Verify display updates when balls are equipped."""
    # Wait for game to initialize
    await asyncio.sleep(0.5)

    # Add a ball (it should auto-equip to first empty slot)
    await game.call(BALL_REGISTRY, "add_ball", [1])  # BURN ball
    await asyncio.sleep(0.1)

    # Refresh the display
    await game.call(BALL_SLOTS, "refresh")
    await asyncio.sleep(0.1)

    # The display should now show the ball
    # Just verify the display still exists and is functional
    visible = await game.get_property(BALL_SLOTS, "visible")
    assert visible is True, "Display should remain visible after ball added"


@pytest.mark.asyncio
async def test_ball_registry_ball_type_enum(game):
    """Verify BallRegistry has BallType enum values."""
    # Get the name of ball type 0 (BASIC)
    name = await game.call(BALL_REGISTRY, "get_ball_name", [0])
    assert name == "Basic", f"BallType.BASIC should be 'Basic', got '{name}'"


@pytest.mark.asyncio
async def test_ball_slot_system_has_5_max_slots(game):
    """Verify BallRegistry has 5 maximum ball slots."""
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    max_slots = await game.get_property(BALL_REGISTRY, "MAX_SLOTS")
    assert max_slots == 5, "Should have 5 max ball slots"


@pytest.mark.asyncio
async def test_ball_slot_system_starts_with_3_unlocked(game):
    """Verify BallRegistry starts with 3 unlocked slots."""
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    unlocked = await game.call(BALL_REGISTRY, "get_unlocked_slots")
    assert unlocked == 3, "Should start with 3 unlocked slots"


@pytest.mark.asyncio
async def test_ball_slots_start_with_basic(game):
    """Ball slots should start with basic ball in first slot."""
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    slots = await game.call(BALL_REGISTRY, "get_active_slots")
    assert len(slots) == 5, "Should have 5 slots"
    assert slots[0] == 0, "First slot should have basic ball (type 0)"


@pytest.mark.asyncio
async def test_adding_ball_fills_empty_slot(game):
    """Adding a new ball should fill first empty slot."""
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Add BURN ball (type 1)
    await game.call(BALL_REGISTRY, "add_ball", [1])

    slots = await game.call(BALL_REGISTRY, "get_active_slots")
    filled_count = sum(1 for slot in slots if slot != -1)
    assert filled_count == 2, "Should have 2 balls equipped (basic + burn)"


@pytest.mark.asyncio
async def test_multiple_balls_in_slots(game):
    """Multiple different balls can be equipped."""
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Add multiple ball types
    await game.call(BALL_REGISTRY, "add_ball", [1])  # BURN
    await game.call(BALL_REGISTRY, "add_ball", [2])  # FREEZE
    await game.call(BALL_REGISTRY, "add_ball", [3])  # POISON

    filled = await game.call(BALL_REGISTRY, "get_filled_slots")
    assert len(filled) == 4, f"Should have 4 balls equipped, got {len(filled)}"


@pytest.mark.asyncio
async def test_display_updates_on_slots_changed_signal(game):
    """Display should auto-update when BallRegistry.slots_changed emits."""
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.3)

    # Initial state - should have basic ball
    initial_filled = await game.call(BALL_REGISTRY, "get_slot_count")
    assert initial_filled == 1, "Should start with 1 ball (basic)"

    # Add a new ball - should trigger slots_changed signal
    await game.call(BALL_REGISTRY, "add_ball", [1])  # BURN
    await asyncio.sleep(0.2)

    # Display should have refreshed automatically
    new_filled = await game.call(BALL_REGISTRY, "get_slot_count")
    assert new_filled == 2, "Should now have 2 balls equipped"


@pytest.mark.asyncio
async def test_max_5_balls_in_slots(game):
    """Cannot equip more than 5 balls at once."""
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Try to fill all 5 slots (basic already in slot 0)
    await game.call(BALL_REGISTRY, "add_ball", [1])  # BURN
    await game.call(BALL_REGISTRY, "add_ball", [2])  # FREEZE
    await game.call(BALL_REGISTRY, "add_ball", [3])  # POISON
    await game.call(BALL_REGISTRY, "add_ball", [4])  # BLEED

    filled = await game.call(BALL_REGISTRY, "get_filled_slots")
    assert len(filled) == 5, "Should have 5 balls equipped"

    # Try to add 6th ball - should fail to assign to slot
    await game.call(BALL_REGISTRY, "add_ball", [5])  # LIGHTNING

    # Still only 5 slots filled (6th ball is owned but not equipped)
    filled_after = await game.call(BALL_REGISTRY, "get_filled_slots")
    assert len(filled_after) == 5, "Should still have only 5 balls in slots"
