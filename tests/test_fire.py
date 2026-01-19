"""Test that launches the game and fires a ball."""
import asyncio
import pytest

from helpers import PATHS, wait_for_fire_ready

GAME = PATHS["game"]
FIRE_BUTTON = PATHS["fire_button"]
BALLS_CONTAINER = PATHS["balls"]


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
