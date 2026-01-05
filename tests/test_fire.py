"""Test that launches the game and fires a ball."""
import pytest

GAME = "/root/Game"
FIRE_BUTTON = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"
BALLS_CONTAINER = "/root/Game/GameArea/Balls"


@pytest.mark.asyncio
async def test_fire_once(game):
    """Launch the game and fire a single ball."""
    # Verify game started
    game_node = await game.get_node(GAME)
    assert game_node is not None, "Game scene should be loaded"

    # Get initial ball count (should be 0)
    balls_before = await game.call(BALLS_CONTAINER, "get_child_count")
    print(f"Balls before firing: {balls_before}")

    # Click the fire button
    await game.click(FIRE_BUTTON)

    # Small delay to let the ball spawn
    import asyncio
    await asyncio.sleep(0.1)

    # Verify a ball was spawned
    balls_after = await game.call(BALLS_CONTAINER, "get_child_count")
    print(f"Balls after firing: {balls_after}")

    assert balls_after > balls_before, "A ball should have been spawned after firing"


@pytest.mark.asyncio
async def test_fire_with_aim(game):
    """Fire a ball while aiming in a direction."""
    import asyncio

    # Get joystick position for aiming
    joystick_path = "/root/Game/UI/HUD/InputContainer/HBoxContainer/JoystickContainer/VirtualJoystick"

    # Simulate dragging the joystick to aim up-right
    # First get the joystick's global position
    joystick_pos = await game.get(joystick_path, "global_position")
    joystick_size = await game.get(joystick_path, "size")

    if joystick_pos and joystick_size:
        center_x = joystick_pos.x + joystick_size.x / 2
        center_y = joystick_pos.y + joystick_size.y / 2

        # Click and drag to aim up-right
        await game.click(center_x + 30, center_y - 30)

    # Fire
    await game.click(FIRE_BUTTON)
    await asyncio.sleep(0.1)

    # Check ball was spawned
    balls = await game.call(BALLS_CONTAINER, "get_child_count")
    assert balls >= 1, "At least one ball should exist after firing"
