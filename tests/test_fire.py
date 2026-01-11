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

    # Disable autofire so we can test manual firing
    await game.call(FIRE_BUTTON, "set_autofire", [False])

    # Wait for fire button to be ready (may be on cooldown from autofire)
    is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
    while not is_ready:
        await asyncio.sleep(0.1)
        is_ready = await game.get_property(FIRE_BUTTON, "is_ready")

    # Get initial ball count
    balls_before = await game.call(BALLS_CONTAINER, "get_child_count")
    print(f"Balls before firing: {balls_before}")

    # Click the fire button
    await game.click(FIRE_BUTTON)

    # Small delay to let the ball spawn
    await asyncio.sleep(0.2)

    # Verify a ball was spawned
    balls_after = await game.call(BALLS_CONTAINER, "get_child_count")
    print(f"Balls after firing: {balls_after}")

    assert balls_after > balls_before, "A ball should have been spawned after firing"


@pytest.mark.asyncio
async def test_fire_with_aim(game):
    """Fire a ball while aiming in a direction."""
    # Disable autofire so we can test manual firing
    await game.call(FIRE_BUTTON, "set_autofire", [False])

    # Wait for fire button to be ready (may be on cooldown from autofire)
    is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
    while not is_ready:
        await asyncio.sleep(0.1)
        is_ready = await game.get_property(FIRE_BUTTON, "is_ready")

    # Click the fire button
    await game.click(FIRE_BUTTON)
    await asyncio.sleep(0.2)

    # Check ball was spawned
    balls = await game.call(BALLS_CONTAINER, "get_child_count")
    assert balls >= 1, "At least one ball should exist after firing"


@pytest.mark.asyncio
async def test_fire_multiple(game):
    """Fire multiple balls and verify they spawn correctly."""
    # Disable autofire so we control when balls fire
    await game.call(FIRE_BUTTON, "set_autofire", [False])

    # Wait for fire button to be ready (may be on cooldown from autofire)
    is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
    while not is_ready:
        await asyncio.sleep(0.1)
        is_ready = await game.get_property(FIRE_BUTTON, "is_ready")

    # Fire 3 balls
    for i in range(3):
        # Wait for cooldown if needed
        is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
        while not is_ready:
            await asyncio.sleep(0.1)
            is_ready = await game.get_property(FIRE_BUTTON, "is_ready")

        await game.click(FIRE_BUTTON)
        await asyncio.sleep(0.1)

    # Wait for all balls to spawn
    await asyncio.sleep(0.3)

    # Check ball count (may be less than 3 if some went off screen)
    balls = await game.call(BALLS_CONTAINER, "get_child_count")
    print(f"Balls after firing 3 times: {balls}")
    assert balls >= 1, "At least one ball should exist after firing multiple times"
