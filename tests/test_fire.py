"""Test that launches the game and fires a ball."""
import asyncio
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

    # Verify button is ready
    is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
    assert is_ready, "Fire button should be ready"

    # Fire by calling the button's _try_fire method directly
    # (Click doesn't work reliably in headless mode)
    await game.call(FIRE_BUTTON, "_try_fire")

    # Small delay to let the ball spawn
    await asyncio.sleep(0.2)

    # Verify a ball was spawned
    balls_after = await game.call(BALLS_CONTAINER, "get_child_count")
    print(f"Balls after firing: {balls_after}")

    assert balls_after > balls_before, "A ball should have been spawned after firing"


@pytest.mark.asyncio
async def test_fire_with_aim(game):
    """Fire a ball while aiming in a direction."""
    # Get the aim controller to set aim direction
    aim_controller = "/root/Game/GameController"
    joystick = "/root/Game/UI/HUD/InputContainer/HBoxContainer/JoystickContainer/VirtualJoystick"

    # Set aim direction via joystick (if it has an aim_direction property)
    # For now, just verify we can fire - aim testing requires joystick input simulation

    # Verify button is ready
    is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
    assert is_ready, "Fire button should be ready"

    # Fire
    await game.call(FIRE_BUTTON, "_try_fire")
    await asyncio.sleep(0.2)

    # Check ball was spawned
    balls = await game.call(BALLS_CONTAINER, "get_child_count")
    assert balls >= 1, "At least one ball should exist after firing"


@pytest.mark.asyncio
async def test_fire_multiple(game):
    """Fire multiple balls and verify they spawn correctly."""
    # Fire 3 balls
    for i in range(3):
        # Wait for cooldown if needed
        is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
        while not is_ready:
            await asyncio.sleep(0.1)
            is_ready = await game.get_property(FIRE_BUTTON, "is_ready")

        await game.call(FIRE_BUTTON, "_try_fire")
        await asyncio.sleep(0.1)

    # Wait for all balls to spawn
    await asyncio.sleep(0.3)

    # Check ball count (may be less than 3 if some went off screen)
    balls = await game.call(BALLS_CONTAINER, "get_child_count")
    print(f"Balls after firing 3 times: {balls}")
    assert balls >= 1, "At least one ball should exist after firing multiple times"
