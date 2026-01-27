"""Tests for new enemy types: Golem, Swarm, Archer, Bomber."""
import asyncio
import pytest

GAME = "/root/Game"
ENEMIES_CONTAINER = "/root/Game/GameArea/Enemies"


async def spawn_enemy_of_type(game, enemy_type: str):
    """Spawn a specific enemy type and return its path."""
    # Use the enemy spawner to spawn a specific type
    spawner_path = await game.call(GAME, "get_enemy_spawner_path")
    if not spawner_path:
        spawner_path = "/root/Game/GameArea/Enemies/EnemySpawner"

    # Get the scene path for the enemy type
    scene_paths = {
        "golem": "res://scenes/entities/enemies/golem.tscn",
        "swarm": "res://scenes/entities/enemies/swarm.tscn",
        "archer": "res://scenes/entities/enemies/archer.tscn",
        "bomber": "res://scenes/entities/enemies/bomber.tscn",
    }

    scene_path = scene_paths.get(enemy_type)
    if not scene_path:
        pytest.fail(f"Unknown enemy type: {enemy_type}")

    # Spawn via test helper
    enemy_path = await game.call(GAME, "spawn_test_enemy", [scene_path])
    return enemy_path


# === Golem Tests ===


@pytest.mark.asyncio
async def test_golem_high_hp(game):
    """Golem should have higher HP than base enemy."""
    enemy_path = await spawn_enemy_of_type(game, "golem")
    assert enemy_path, "Should spawn golem"

    hp = await game.get_property(enemy_path, "hp")
    max_hp = await game.get_property(enemy_path, "max_hp")

    # Golem has 3x base HP (base is 10, so 30)
    assert max_hp >= 25, f"Golem should have high HP, got {max_hp}"
    assert hp == max_hp, "HP should be full"

    await game.call(enemy_path, "queue_free")


@pytest.mark.asyncio
async def test_golem_slow_speed(game):
    """Golem should be slower than base enemy."""
    enemy_path = await spawn_enemy_of_type(game, "golem")
    assert enemy_path, "Should spawn golem"

    speed = await game.get_property(enemy_path, "speed")

    # Golem has 0.4x speed (base is 100, so ~40)
    assert speed < 60, f"Golem should be slow, got {speed}"

    await game.call(enemy_path, "queue_free")


@pytest.mark.asyncio
async def test_golem_body_dimensions(game):
    """Golem should have body dimension properties."""
    enemy_path = await spawn_enemy_of_type(game, "golem")
    assert enemy_path, "Should spawn golem"

    body_width = await game.get_property(enemy_path, "body_width")
    body_height = await game.get_property(enemy_path, "body_height")

    assert body_width == 35.0, f"body_width should be 35, got {body_width}"
    assert body_height == 45.0, f"body_height should be 45, got {body_height}"

    await game.call(enemy_path, "queue_free")


# === Swarm Tests ===


@pytest.mark.asyncio
async def test_swarm_low_hp(game):
    """Swarm should have lower HP than base enemy."""
    enemy_path = await spawn_enemy_of_type(game, "swarm")
    assert enemy_path, "Should spawn swarm"

    max_hp = await game.get_property(enemy_path, "max_hp")

    # Swarm has 0.4x base HP (base is 10, so ~4)
    assert max_hp <= 6, f"Swarm should have low HP, got {max_hp}"

    await game.call(enemy_path, "queue_free")


@pytest.mark.asyncio
async def test_swarm_fast_speed(game):
    """Swarm should be faster than base enemy."""
    enemy_path = await spawn_enemy_of_type(game, "swarm")
    assert enemy_path, "Should spawn swarm"

    speed = await game.get_property(enemy_path, "speed")

    # Swarm has 1.6x speed (base is 60, so ~96)
    assert speed > 80, f"Swarm should be fast, got {speed}"

    await game.call(enemy_path, "queue_free")


@pytest.mark.asyncio
async def test_swarm_small_body(game):
    """Swarm should have small body radius."""
    enemy_path = await spawn_enemy_of_type(game, "swarm")
    assert enemy_path, "Should spawn swarm"

    body_radius = await game.get_property(enemy_path, "body_radius")

    assert body_radius == 10.0, f"body_radius should be 10, got {body_radius}"

    await game.call(enemy_path, "queue_free")


# === Archer Tests ===


@pytest.mark.asyncio
async def test_archer_has_shoot_timer(game):
    """Archer should have shooting behavior properties."""
    enemy_path = await spawn_enemy_of_type(game, "archer")
    assert enemy_path, "Should spawn archer"

    # Check that archer has shooting constants
    has_method = await game.call(enemy_path, "has_method", ["_shoot_at_player"])
    assert has_method, "Archer should have _shoot_at_player method"

    await game.call(enemy_path, "queue_free")


@pytest.mark.asyncio
async def test_archer_medium_stats(game):
    """Archer should have medium HP and slower speed."""
    enemy_path = await spawn_enemy_of_type(game, "archer")
    assert enemy_path, "Should spawn archer"

    max_hp = await game.get_property(enemy_path, "max_hp")
    speed = await game.get_property(enemy_path, "speed")

    # Archer has 1.2x HP, 0.7x speed
    assert max_hp >= 10, f"Archer should have medium HP, got {max_hp}"
    assert speed < 100, f"Archer should be slower, got {speed}"

    await game.call(enemy_path, "queue_free")


# === Bomber Tests ===


@pytest.mark.asyncio
async def test_bomber_low_hp(game):
    """Bomber should have lower HP."""
    enemy_path = await spawn_enemy_of_type(game, "bomber")
    assert enemy_path, "Should spawn bomber"

    max_hp = await game.get_property(enemy_path, "max_hp")

    # Bomber has 0.6x base HP
    assert max_hp <= 8, f"Bomber should have low HP, got {max_hp}"

    await game.call(enemy_path, "queue_free")


@pytest.mark.asyncio
async def test_bomber_has_explosion_properties(game):
    """Bomber should have explosion-related properties."""
    enemy_path = await spawn_enemy_of_type(game, "bomber")
    assert enemy_path, "Should spawn bomber"

    body_radius = await game.get_property(enemy_path, "body_radius")
    assert body_radius == 18.0, f"body_radius should be 18, got {body_radius}"

    await game.call(enemy_path, "queue_free")


@pytest.mark.asyncio
async def test_bomber_fast_speed(game):
    """Bomber should be faster than base."""
    enemy_path = await spawn_enemy_of_type(game, "bomber")
    assert enemy_path, "Should spawn bomber"

    speed = await game.get_property(enemy_path, "speed")

    # Bomber has 1.2x speed (base is 60, so ~72)
    assert speed > 65, f"Bomber should be fast, got {speed}"

    await game.call(enemy_path, "queue_free")


# === Enemy Spawner Tests ===


@pytest.mark.asyncio
async def test_all_enemy_types_can_be_spawned(game):
    """All new enemy types should be spawnable."""
    enemy_types = ["golem", "swarm", "archer", "bomber"]

    for enemy_type in enemy_types:
        enemy_path = await spawn_enemy_of_type(game, enemy_type)
        assert enemy_path, f"Should be able to spawn {enemy_type}"

        # Verify it has EnemyBase properties
        hp = await game.get_property(enemy_path, "hp")
        assert hp is not None, f"{enemy_type} should have hp property"

        await game.call(enemy_path, "queue_free")
        await asyncio.sleep(0.1)  # Let the enemy be freed
