"""Tests for enemy spawn formations."""
import asyncio
import pytest

GAME = "/root/Game"
ENEMY_SPAWNER = "/root/Game/GameArea/Enemies/EnemySpawner"
ENEMIES_CONTAINER = "/root/Game/GameArea/Enemies"


@pytest.mark.asyncio
async def test_enemy_spawner_exists(game):
    """EnemySpawner should exist in game."""
    node = await game.get_node(ENEMY_SPAWNER)
    assert node is not None, "EnemySpawner should exist"


@pytest.mark.asyncio
async def test_spawn_formation_method_exists(game):
    """spawn_formation method should exist."""
    has_method = await game.call(ENEMY_SPAWNER, "has_method", ["spawn_formation"])
    assert has_method, "EnemySpawner should have spawn_formation method"


@pytest.mark.asyncio
async def test_get_available_formations_method_exists(game):
    """get_available_formations method should exist."""
    has_method = await game.call(ENEMY_SPAWNER, "has_method", ["get_available_formations"])
    assert has_method, "EnemySpawner should have get_available_formations method"


@pytest.mark.asyncio
async def test_formation_chance_export(game):
    """formation_chance should be configurable."""
    formation_chance = await game.get_property(ENEMY_SPAWNER, "formation_chance")
    assert formation_chance is not None, "formation_chance should be accessible"
    assert 0.0 <= formation_chance <= 1.0, f"formation_chance should be 0-1, got {formation_chance}"


@pytest.mark.asyncio
async def test_spawn_line_formation_helper_exists(game):
    """_spawn_line_formation helper should exist."""
    has_method = await game.call(ENEMY_SPAWNER, "has_method", ["_spawn_line_formation"])
    assert has_method, "EnemySpawner should have _spawn_line_formation method"


@pytest.mark.asyncio
async def test_spawn_v_formation_helper_exists(game):
    """_spawn_v_formation helper should exist."""
    has_method = await game.call(ENEMY_SPAWNER, "has_method", ["_spawn_v_formation"])
    assert has_method, "EnemySpawner should have _spawn_v_formation method"


@pytest.mark.asyncio
async def test_spawn_cluster_formation_helper_exists(game):
    """_spawn_cluster_formation helper should exist."""
    has_method = await game.call(ENEMY_SPAWNER, "has_method", ["_spawn_cluster_formation"])
    assert has_method, "EnemySpawner should have _spawn_cluster_formation method"


@pytest.mark.asyncio
async def test_spawn_diagonal_formation_helper_exists(game):
    """_spawn_diagonal_formation helper should exist."""
    has_method = await game.call(ENEMY_SPAWNER, "has_method", ["_spawn_diagonal_formation"])
    assert has_method, "EnemySpawner should have _spawn_diagonal_formation method"


@pytest.mark.asyncio
async def test_formation_spawn_helper_exists(game):
    """_formation_spawn helper should exist."""
    has_method = await game.call(ENEMY_SPAWNER, "has_method", ["_formation_spawn"])
    assert has_method, "EnemySpawner should have _formation_spawn method"


@pytest.mark.asyncio
async def test_game_loads_with_formations(game):
    """Game should load successfully with spawn formations."""
    node = await game.get_node(GAME)
    assert node is not None, "Game should load with spawn formations"
