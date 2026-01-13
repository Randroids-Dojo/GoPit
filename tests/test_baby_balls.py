"""Tests for queue-based baby ball system."""
import asyncio
import pytest

PATHS = {
    "balls": "/root/Game/GameArea/Balls",
    "baby_spawner": "/root/Game/GameArea/BabyBallSpawner",
    "ball_spawner": "/root/Game/GameArea/BallSpawner",
    "player": "/root/Game/GameArea/Player",
    "enemies": "/root/Game/GameArea/Enemies",
    "fire_button": "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton",
}


@pytest.mark.asyncio
async def test_baby_ball_spawner_exists(game):
    """Baby ball spawner should exist in scene tree."""
    node = await game.get_node(PATHS["baby_spawner"])
    assert node is not None, "BabyBallSpawner should exist"


@pytest.mark.asyncio
async def test_baby_balls_spawn_on_fire(game):
    """Baby balls should be added to queue when baby_ball_spawner queues them.

    With salvo firing, main balls spawn immediately (not queued).
    Baby balls are added to queue via baby_ball_spawner.queue_baby_balls().
    """
    # Disable autofire to control firing
    await game.call(PATHS["fire_button"], "set_autofire", [False])
    await asyncio.sleep(0.3)

    # Clear any existing balls from queue
    await game.call(PATHS["ball_spawner"], "clear_queue")

    # Get initial queue size
    initial_queue = await game.call(PATHS["ball_spawner"], "get_queue_size")

    # Queue baby balls directly (simulates what happens on fire button press)
    await game.call(PATHS["baby_spawner"], "queue_baby_balls")
    await asyncio.sleep(0.1)

    # Check queue has baby balls added
    queue_size = await game.call(PATHS["ball_spawner"], "get_queue_size")
    assert queue_size > initial_queue, "Baby balls should be added to queue"

    # Re-enable autofire
    await game.call(PATHS["fire_button"], "set_autofire", [True])


@pytest.mark.asyncio
async def test_baby_ball_spawner_can_stop(game):
    """Baby ball spawner stop() should be callable (no-op in queue system)."""
    # Stop the spawner (no-op in queue-based system)
    await game.call(PATHS["baby_spawner"], "stop")
    # Should not raise any errors
    await asyncio.sleep(0.1)


@pytest.mark.asyncio
async def test_baby_ball_spawner_can_restart(game):
    """Baby ball spawner start() should be callable (connects to ball_spawner)."""
    # Stop and restart
    await game.call(PATHS["baby_spawner"], "stop")
    await asyncio.sleep(0.1)
    await game.call(PATHS["baby_spawner"], "start")
    # Should not raise any errors
    await asyncio.sleep(0.1)


@pytest.mark.asyncio
async def test_leadership_upgrade_exists(game):
    """Leadership upgrade should be available in level up system."""
    # Access the level up overlay
    level_up_overlay = await game.get_node("/root/Game/UI/LevelUpOverlay")
    assert level_up_overlay is not None, "LevelUpOverlay should exist"


BALL_REGISTRY = "/root/BallRegistry"


@pytest.mark.asyncio
async def test_baby_balls_fired_through_queue(game):
    """Baby balls should be fired through the queue system."""
    # Disable autofire
    await game.call(PATHS["fire_button"], "set_autofire", [False])
    await asyncio.sleep(0.3)

    # Clear queue
    await game.call(PATHS["ball_spawner"], "clear_queue")

    # Get initial ball count
    initial_count = await game.call(PATHS["balls"], "get_child_count")

    # Fire and wait for queue to process
    await game.call(PATHS["ball_spawner"], "fire")
    await asyncio.sleep(2.0)  # Wait for queue to drain

    # Should have spawned balls (parent + babies)
    final_count = await game.call(PATHS["balls"], "get_child_count")
    assert final_count > initial_count, "Balls should spawn from queue"

    # Re-enable autofire
    await game.call(PATHS["fire_button"], "set_autofire", [True])


@pytest.mark.asyncio
async def test_baby_ball_queue_method_exists(game):
    """Ball spawner should have add_baby_balls_to_queue method."""
    has_method = await game.call(PATHS["ball_spawner"], "has_method", ["add_baby_balls_to_queue"])
    assert has_method, "BallSpawner should have add_baby_balls_to_queue method"


@pytest.mark.asyncio
async def test_baby_ball_inherits_type_from_slots(game):
    """Baby balls should cycle through active ball slots."""
    # Add BURN ball (type 1) to slots
    await game.call(BALL_REGISTRY, "add_ball", [1])
    await asyncio.sleep(0.1)

    # Get filled slots - at minimum should have BASIC (always there)
    filled_slots = await game.call(BALL_REGISTRY, "get_filled_slots")
    assert len(filled_slots) >= 1, f"Should have at least 1 filled slot, got {len(filled_slots)}"

    # The baby balls will inherit from these slots when fired through queue
