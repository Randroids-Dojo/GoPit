"""Tests for the ball slot system (GoPit-6zk)."""
import asyncio
import pytest


@pytest.mark.asyncio
async def test_slot_system_exists(game):
    """Verify BallRegistry has ball_slots array."""
    ball_slots = await game.get_property("/root/BallRegistry", "ball_slots")
    assert ball_slots is not None
    assert isinstance(ball_slots, list)


@pytest.mark.asyncio
async def test_max_slots_is_five(game):
    """Verify MAX_SLOTS constant is 5."""
    max_slots = await game.get_property("/root/BallRegistry", "MAX_SLOTS")
    assert max_slots == 5


@pytest.mark.asyncio
async def test_initial_slot_has_basic_ball(game):
    """After game start, slot 0 should have Basic ball at L1."""
    # Start game to initialize registry
    await game.call("/root/Game", "start_game")
    await asyncio.sleep(0.3)

    ball_slots = await game.get_property("/root/BallRegistry", "ball_slots")
    assert ball_slots[0] is not None
    assert ball_slots[0]["ball_type"] == 0  # BASIC = 0
    assert ball_slots[0]["level"] == 1


@pytest.mark.asyncio
async def test_add_ball_fills_empty_slot(game):
    """Adding a new ball type should fill an empty slot."""
    # Start game
    await game.call("/root/Game", "start_game")
    await asyncio.sleep(0.3)

    # Add a new ball type (BURN = 1)
    result = await game.call("/root/BallRegistry", "add_ball", [1])
    assert result == True

    # Verify it's in a slot
    slot_idx = await game.call("/root/BallRegistry", "get_slot_index", [1])
    assert slot_idx >= 0


@pytest.mark.asyncio
async def test_add_same_ball_levels_up(game):
    """Adding same ball type should level it up instead of adding new slot."""
    # Start game
    await game.call("/root/Game", "start_game")
    await asyncio.sleep(0.3)

    # Basic ball starts at L1, adding again should level to L2
    result = await game.call("/root/BallRegistry", "add_ball", [0])
    assert result == True

    # Verify level increased
    level = await game.call("/root/BallRegistry", "get_ball_level", [0])
    assert level == 2


@pytest.mark.asyncio
async def test_get_equipped_slots_returns_filled_only(game):
    """get_equipped_slots should only return non-null slots."""
    # Start game
    await game.call("/root/Game", "start_game")
    await asyncio.sleep(0.3)

    equipped = await game.call("/root/BallRegistry", "get_equipped_slots")
    assert len(equipped) >= 1  # At least basic ball

    # Verify all are valid (have ball_type)
    for slot in equipped:
        assert "ball_type" in slot
        assert "level" in slot


@pytest.mark.asyncio
async def test_has_empty_slot_with_slots_available(game):
    """has_empty_slot should return True when slots available."""
    # Start game
    await game.call("/root/Game", "start_game")
    await asyncio.sleep(0.3)

    has_empty = await game.call("/root/BallRegistry", "has_empty_slot")
    assert has_empty == True  # Only 1 slot used, 4 empty


@pytest.mark.asyncio
async def test_fire_spawns_all_equipped_types(game):
    """Firing should spawn all equipped ball types simultaneously."""
    fire_button = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"
    balls_path = "/root/Game/GameArea/Balls"

    # Add a second ball type (BURN)
    result = await game.call("/root/BallRegistry", "add_ball", [1])
    assert result == True

    # Verify we have 2 equipped slots
    equipped = await game.call("/root/BallRegistry", "get_equipped_slots")
    assert len(equipped) == 2, f"Expected 2 equipped slots, got {len(equipped)}"

    # Wait for button to be ready
    is_ready = await game.get_property(fire_button, "is_ready")
    while not is_ready:
        await asyncio.sleep(0.1)
        is_ready = await game.get_property(fire_button, "is_ready")

    # Click fire button (like existing fire tests)
    await game.click(fire_button)
    await asyncio.sleep(0.3)

    # Check ball count - should have at least 2 (one per slot type)
    child_count = await game.call(balls_path, "get_child_count")
    assert child_count >= 2, f"Expected at least 2 balls (one per slot), got {child_count}"


@pytest.mark.asyncio
async def test_slot_display_exists(game):
    """Verify SlotDisplay UI component exists in HUD."""
    slot_display = await game.get_node("/root/Game/UI/HUD/SlotDisplay")
    assert slot_display is not None
