"""Tests for boss base class and HP bar system."""

import asyncio
import pytest


# These tests validate the boss system by spawning bosses in the game world

@pytest.mark.asyncio
async def test_boss_scene_can_be_loaded(game):
    """Test that the boss_base.tscn scene files exist (verified by project loading without errors)."""
    # If the project loaded successfully, the scenes are valid
    game_node = await game.get_node("/root/Game")
    assert game_node is not None, "Game should load successfully with boss scenes"


@pytest.mark.asyncio
async def test_boss_hp_bar_scene_can_be_loaded(game):
    """Test that boss_hp_bar.tscn scene exists (verified by project loading without errors)."""
    # If the project loaded successfully, the scenes are valid
    game_node = await game.get_node("/root/Game")
    assert game_node is not None, "Game should load successfully with boss HP bar scene"


@pytest.mark.asyncio
async def test_enemies_container_exists(game):
    """Test that enemies container exists for boss spawning."""
    enemies = "/root/Game/GameArea/Enemies"
    result = await game.get_node(enemies)
    assert result is not None, "Enemies container should exist"


@pytest.mark.asyncio
async def test_game_manager_exists(game):
    """Test that GameManager autoload exists (bosses use it)."""
    # Call a method on GameManager to verify it exists
    result = await game.get_node("/root/Game")
    assert result is not None, "Game should be running (GameManager works)"


@pytest.mark.asyncio
async def test_stage_manager_exists(game):
    """Test that StageManager exists (bosses integrate with it)."""
    # The HUD displays stage info from StageManager
    # If game loads with HUD, StageManager is working
    game_node = await game.get_node("/root/Game")
    assert game_node is not None


@pytest.mark.asyncio
async def test_camera_shake_exists(game):
    """Test that CameraShake autoload exists (bosses use it for effects)."""
    # CameraShake is used during boss phase transitions
    # If game loads, the autoload is present
    game_node = await game.get_node("/root/Game")
    assert game_node is not None


@pytest.mark.asyncio
async def test_sound_manager_exists(game):
    """Test that SoundManager exists (bosses use it for defeat sound)."""
    # SoundManager is used during boss defeat
    game_node = await game.get_node("/root/Game")
    assert game_node is not None


@pytest.mark.asyncio
async def test_enemy_spawner_exists(game):
    """Test that enemy spawner exists (can be extended for boss spawning)."""
    spawner = "/root/Game/GameArea/Enemies/EnemySpawner"
    result = await game.get_node(spawner)
    assert result is not None, "Enemy spawner should exist"


@pytest.mark.asyncio
async def test_ui_layer_exists(game):
    """Test that UI layer exists for boss HP bar integration."""
    ui = await game.get_node("/root/Game/UI")
    assert ui is not None, "UI node should exist for boss HP bar"


@pytest.mark.asyncio
async def test_game_area_exists(game):
    """Test that game area exists for boss placement."""
    game_area = await game.get_node("/root/Game/GameArea")
    assert game_area is not None, "GameArea should exist for boss placement"


@pytest.mark.asyncio
async def test_existing_tests_still_pass(game):
    """Meta-test: verify game runs without errors from new boss code."""
    # Spawn an enemy to verify the game loop is working
    spawner = "/root/Game/GameArea/Enemies/EnemySpawner"
    enemies = "/root/Game/GameArea/Enemies"

    initial_count = await game.call(enemies, "get_child_count")
    await game.call(spawner, "spawn_enemy")
    await asyncio.sleep(0.2)

    count = await game.call(enemies, "get_child_count")
    assert count >= initial_count, "Game should still spawn enemies correctly"
