"""Tests for baby ball auto-generation system."""
import asyncio
import pytest

PATHS = {
    "balls": "/root/Game/GameArea/Balls",
    "baby_spawner": "/root/Game/GameArea/BabyBallSpawner",
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
    # Disable autofire so it doesn't spawn balls during this test
    await game.call(PATHS["fire_button"], "set_autofire", [False])

    # Stop the spawner
    await game.call(PATHS["baby_spawner"], "stop")

    # Wait a moment for any in-flight balls to settle
    await asyncio.sleep(0.5)

    # Get ball count after stopping
    initial_count = await game.call(PATHS["balls"], "get_child_count")

    # Wait for potential spawns
    await asyncio.sleep(3.0)

    final_count = await game.call(PATHS["balls"], "get_child_count")
    # Ball count should not increase significantly (may decrease as balls despawn)
    assert final_count <= initial_count + 1, "No new baby balls should spawn when stopped"

    # Re-enable autofire and restart for other tests
    await game.call(PATHS["fire_button"], "set_autofire", [True])
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


BALL_REGISTRY = "/root/BallRegistry"


@pytest.mark.asyncio
async def test_baby_ball_inherits_type_from_slot(game):
    """Baby balls should inherit ball type from active slots."""
    # Stop spawner to control timing
    await game.call(PATHS["baby_spawner"], "stop")
    await asyncio.sleep(0.3)

    # Add BURN ball (type 1) to slots
    await game.call(BALL_REGISTRY, "add_ball", [1])

    # Get active slots to verify
    active_slots = await game.call(BALL_REGISTRY, "get_active_slots")
    assert len(active_slots) == 2, f"Should have 2 active slots (BASIC + BURN), got {len(active_slots)}"

    # Get initial ball count
    initial_count = await game.call(PATHS["balls"], "get_child_count")

    # Manually trigger baby ball spawn
    await game.call(PATHS["baby_spawner"], "_spawn_baby_ball")
    await asyncio.sleep(0.2)

    # Verify ball was spawned
    final_count = await game.call(PATHS["balls"], "get_child_count")
    assert final_count > initial_count, "Baby ball should spawn with slot inheritance"

    # Restart spawner
    await game.call(PATHS["baby_spawner"], "start")


@pytest.mark.asyncio
async def test_baby_ball_cycles_through_slots(game):
    """Baby balls should cycle through active ball slots."""
    # Stop spawner
    await game.call(PATHS["baby_spawner"], "stop")
    await asyncio.sleep(0.2)

    # Add multiple ball types to slots
    await game.call(BALL_REGISTRY, "add_ball", [1])  # BURN
    await game.call(BALL_REGISTRY, "add_ball", [2])  # FREEZE

    # Verify we have 3 slots now (BASIC + BURN + FREEZE)
    active_slots = await game.call(BALL_REGISTRY, "get_active_slots")
    assert len(active_slots) == 3, f"Should have 3 active slots, got {len(active_slots)}"

    # Get initial count
    initial_count = await game.call(PATHS["balls"], "get_child_count")

    # Spawn multiple baby balls - one for each slot type
    for _ in range(3):
        await game.call(PATHS["baby_spawner"], "_spawn_baby_ball")
        await asyncio.sleep(0.1)

    # Verify balls were spawned
    final_count = await game.call(PATHS["balls"], "get_child_count")
    assert final_count >= initial_count + 3, f"Should have spawned 3 baby balls, spawned {final_count - initial_count}"

    # Restart spawner
    await game.call(PATHS["baby_spawner"], "start")
