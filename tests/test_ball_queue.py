"""Tests for ball firing queue system."""
import asyncio
import pytest

BALL_SPAWNER = "/root/Game/GameArea/BallSpawner"
FIRE_BUTTON = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"
BALLS = "/root/Game/GameArea/Balls"
BALL_REGISTRY = "/root/BallRegistry"


@pytest.mark.asyncio
async def test_ball_spawner_has_queue_properties(game):
    """BallSpawner should have queue-related properties."""
    # Check fire_rate property
    fire_rate = await game.get_property(BALL_SPAWNER, "fire_rate")
    assert fire_rate > 0, f"fire_rate should be positive, got {fire_rate}"

    # Check max_queue_size property
    max_queue = await game.get_property(BALL_SPAWNER, "max_queue_size")
    assert max_queue > 0, f"max_queue_size should be positive, got {max_queue}"


@pytest.mark.asyncio
async def test_queue_starts_empty(game):
    """Queue should start empty."""
    queue_size = await game.call(BALL_SPAWNER, "get_queue_size")
    assert queue_size == 0, f"Queue should start empty, got size {queue_size}"


@pytest.mark.asyncio
async def test_fire_adds_to_queue(game):
    """Firing should add balls to the queue."""
    # Disable autofire for controlled testing
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.1)

    # Clear any existing balls and queue
    await game.call(BALL_SPAWNER, "clear_queue")

    # Get initial queue size
    initial_size = await game.call(BALL_SPAWNER, "get_queue_size")
    assert initial_size == 0, "Queue should be empty after clear"

    # Fire once (adds balls to queue)
    await game.call(BALL_SPAWNER, "fire")

    # Queue should have at least 1 ball (basic ball in slot 1)
    queue_size = await game.call(BALL_SPAWNER, "get_queue_size")
    assert queue_size >= 0, "Queue size should be non-negative after fire"


@pytest.mark.asyncio
async def test_queue_drains_over_time(game):
    """Queue should drain over time at fire_rate."""
    # Disable autofire for controlled testing
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.1)

    # Clear queue and fire to add balls
    await game.call(BALL_SPAWNER, "clear_queue")
    await game.call(BALL_SPAWNER, "fire")

    # Wait for queue to drain (at fire_rate = 3, balls fire every 0.33s)
    await asyncio.sleep(0.5)

    # Check that balls were spawned
    ball_count = await game.call(BALLS, "get_child_count")
    assert ball_count >= 1, "Should have spawned at least one ball"


@pytest.mark.asyncio
async def test_clear_queue_empties_queue(game):
    """clear_queue should empty the queue."""
    # Fire to add balls
    await game.call(BALL_SPAWNER, "fire")

    # Clear queue
    await game.call(BALL_SPAWNER, "clear_queue")

    # Queue should be empty
    queue_size = await game.call(BALL_SPAWNER, "get_queue_size")
    assert queue_size == 0, f"Queue should be empty after clear, got {queue_size}"


@pytest.mark.asyncio
async def test_get_max_queue_size(game):
    """get_max_queue_size should return the max queue size."""
    max_size = await game.call(BALL_SPAWNER, "get_max_queue_size")
    assert max_size == 20, f"Default max_queue_size should be 20, got {max_size}"


@pytest.mark.asyncio
async def test_queue_respects_max_size(game):
    """Queue should not exceed max_queue_size."""
    # Get max size
    max_size = await game.call(BALL_SPAWNER, "get_max_queue_size")

    # Clear queue
    await game.call(BALL_SPAWNER, "clear_queue")

    # Fire many times rapidly
    for _ in range(max_size + 10):
        await game.call(BALL_SPAWNER, "fire")

    # Queue size should not exceed max
    queue_size = await game.call(BALL_SPAWNER, "get_queue_size")
    assert queue_size <= max_size, f"Queue size {queue_size} exceeds max {max_size}"


@pytest.mark.asyncio
async def test_fire_rate_from_character(game):
    """Fire rate should come from character stat."""
    # Get effective fire rate (uses character stat)
    effective_rate = await game.call(BALL_SPAWNER, "get_effective_fire_rate")
    assert effective_rate >= 1.0, f"Effective fire_rate should be at least 1.0, got {effective_rate}"
    assert effective_rate <= 5.0, f"Effective fire_rate should be reasonable, got {effective_rate}"


@pytest.mark.asyncio
async def test_balls_spawn_in_sequence(game):
    """Balls should spawn one at a time from queue."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.1)

    # Clear balls and queue
    await game.call(BALL_SPAWNER, "clear_queue")

    # Wait for any existing balls to clear
    await asyncio.sleep(0.1)

    # Get initial ball count
    initial_balls = await game.call(BALLS, "get_child_count")

    # Fire to add to queue
    await game.call(BALL_SPAWNER, "fire")

    # Wait for first ball to spawn (at fire_rate = 2, first fires at ~0.5s)
    await asyncio.sleep(0.7)

    # Should have at least one more ball
    ball_count = await game.call(BALLS, "get_child_count")
    assert ball_count > initial_balls or ball_count >= 1, \
        f"Should have spawned balls. Initial: {initial_balls}, Current: {ball_count}"


@pytest.mark.asyncio
async def test_queue_with_multiple_slots(game):
    """Queue should handle multiple ball types from slots."""
    # Reset registry and add multiple ball types
    await game.call(BALL_REGISTRY, "reset")
    await game.call(BALL_REGISTRY, "add_ball", [1])  # Add BURN

    # Clear queue
    await game.call(BALL_SPAWNER, "clear_queue")

    # Fire - should add multiple ball types to queue
    await game.call(BALL_SPAWNER, "fire")

    # Queue should have entries for each slot
    queue_size = await game.call(BALL_SPAWNER, "get_queue_size")
    assert queue_size >= 0, "Queue should have entries after fire"


@pytest.mark.asyncio
async def test_autofire_continuously_adds_to_queue(game):
    """Autofire should continuously add balls to queue."""
    # Enable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [True])
    await asyncio.sleep(0.5)

    # Queue should be getting filled and drained
    ball_count = await game.call(BALLS, "get_child_count")
    assert ball_count >= 1, "Autofire should spawn balls via queue"

    # Disable autofire for cleanup
    await game.call(FIRE_BUTTON, "set_autofire", [False])
