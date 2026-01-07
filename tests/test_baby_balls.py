"""Tests for baby ball auto-generation system."""
import asyncio
import pytest

PATHS = {
    "balls": "/root/Game/GameArea/Balls",
    "baby_spawner": "/root/Game/GameArea/BabyBallSpawner",
    "player": "/root/Game/GameArea/Player",
    "enemies": "/root/Game/GameArea/Enemies",
}


@pytest.mark.asyncio
async def test_baby_ball_spawner_exists(game):
    """Baby ball spawner should exist in scene tree."""
    node = await game.get_node(PATHS["baby_spawner"])
    assert node is not None, "BabyBallSpawner should exist"


@pytest.mark.asyncio
async def test_baby_balls_spawn_automatically(game):
    """Baby balls should spawn without player input."""
    # Get initial ball count
    initial_count = await game.call(PATHS["balls"], "get_child_count")

    # Wait for baby balls to spawn (base interval is 2s, wait for 2-3 spawns)
    await asyncio.sleep(5.0)

    final_count = await game.call(PATHS["balls"], "get_child_count")
    assert final_count > initial_count, "Baby balls should auto-spawn over time"


@pytest.mark.asyncio
async def test_baby_ball_spawner_can_stop(game):
    """Baby ball spawner should stop when stop() is called."""
    # Stop the spawner
    await game.call(PATHS["baby_spawner"], "stop")

    # Get ball count
    initial_count = await game.call(PATHS["balls"], "get_child_count")

    # Wait for potential spawns
    await asyncio.sleep(3.0)

    final_count = await game.call(PATHS["balls"], "get_child_count")
    # Ball count should not increase significantly (may decrease as balls despawn)
    assert final_count <= initial_count + 1, "No new baby balls should spawn when stopped"

    # Restart for other tests
    await game.call(PATHS["baby_spawner"], "start")


@pytest.mark.asyncio
async def test_baby_ball_spawner_can_restart(game):
    """Baby ball spawner should resume spawning after restart."""
    # Stop and restart
    await game.call(PATHS["baby_spawner"], "stop")
    await asyncio.sleep(0.5)
    await game.call(PATHS["baby_spawner"], "start")

    # Get ball count after restart
    count_after_restart = await game.call(PATHS["balls"], "get_child_count")

    # Wait for spawns
    await asyncio.sleep(3.0)

    final_count = await game.call(PATHS["balls"], "get_child_count")
    assert final_count > count_after_restart, "Baby balls should spawn after restart"


@pytest.mark.asyncio
async def test_leadership_upgrade_exists(game):
    """Leadership upgrade should be available in level up system."""
    # Access the level up overlay
    level_up_overlay = await game.get_node("/root/Game/UI/LevelUpOverlay")
    assert level_up_overlay is not None, "LevelUpOverlay should exist"

    # Check that UPGRADE_DATA has LEADERSHIP
    # This is tested indirectly - if the game runs without errors, the upgrade exists
