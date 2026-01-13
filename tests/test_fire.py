"""Test that launches the game and fires a ball."""
import asyncio
import pytest

GAME = "/root/Game"
FIRE_BUTTON = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"
BALLS_CONTAINER = "/root/Game/GameArea/Balls"

# Timeout for waiting operations (seconds)
WAIT_TIMEOUT = 5.0


async def wait_for_fire_ready(game, timeout=WAIT_TIMEOUT):
    """Wait for fire button to be ready with timeout.

    With salvo firing, both cooldown (is_ready) and ball availability
    (_balls_available) must be true before firing is possible.
    """
    elapsed = 0
    while elapsed < timeout:
        is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
        balls_available = await game.get_property(FIRE_BUTTON, "_balls_available")
        if is_ready and balls_available:
            return True
        await asyncio.sleep(0.1)
        elapsed += 0.1
    return False


@pytest.mark.asyncio
async def test_fire_once(game):
    """Launch the game and fire a single ball."""
    # Verify game started
    game_node = await game.get_node(GAME)
    assert game_node is not None, "Game scene should be loaded"

    # Disable autofire so we can test manual firing
    await game.call(FIRE_BUTTON, "set_autofire", [False])

    # Wait for fire button to be ready (may be on cooldown from autofire)
    ready = await wait_for_fire_ready(game)
    assert ready, "Fire button should become ready within timeout"

    # Get initial ball count
    balls_before = await game.call(BALLS_CONTAINER, "get_child_count")
    print(f"Balls before firing: {balls_before}")

    # Click the fire button
    await game.click(FIRE_BUTTON)

    # Wait for ball to spawn from queue (fire_rate=3 means ~0.33s per ball)
    await asyncio.sleep(0.5)

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
    ready = await wait_for_fire_ready(game)
    assert ready, "Fire button should become ready within timeout"

    # Click the fire button
    await game.click(FIRE_BUTTON)

    # Wait for ball to spawn from queue (fire_rate=3 means ~0.33s per ball)
    await asyncio.sleep(0.5)

    # Check ball was spawned
    balls = await game.call(BALLS_CONTAINER, "get_child_count")
    assert balls >= 1, "At least one ball should exist after firing"


@pytest.mark.asyncio
async def test_fire_multiple(game):
    """Fire multiple salvos and verify they spawn correctly.

    With salvo firing, each fire spawns all slot balls at once,
    and we must wait for all balls to return before firing again.
    """
    # Disable autofire so we control when balls fire
    await game.call(FIRE_BUTTON, "set_autofire", [False])

    # Wait for fire button to be ready (cooldown + balls returned)
    ready = await wait_for_fire_ready(game)
    assert ready, "Fire button should become ready within timeout"

    # Fire 2 salvos (more would take too long to wait for returns)
    for i in range(2):
        # Wait for cooldown AND balls to return before firing again
        ready = await wait_for_fire_ready(game)
        assert ready, f"Fire button should become ready for salvo {i+1}"

        await game.click(FIRE_BUTTON)
        await asyncio.sleep(0.2)

    # Check at least one ball is in flight
    balls = await game.call(BALLS_CONTAINER, "get_child_count")
    print(f"Balls after firing 2 salvos: {balls}")
    assert balls >= 1, "At least one ball should exist after firing salvos"
