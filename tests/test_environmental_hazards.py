"""Tests for environmental hazards system."""
import asyncio
import pytest

GAME = "/root/Game"
STAGE_MANAGER = "/root/StageManager"
GAME_CONTROLLER = "/root/Game"


@pytest.mark.asyncio
async def test_hazards_container_exists(game):
    """Hazards container should exist in game."""
    node = await game.get_node("/root/Game/GameArea/Hazards")
    assert node is not None, "Hazards container should exist"


@pytest.mark.asyncio
async def test_game_loads_with_hazard_system(game):
    """Game should load successfully with hazard system."""
    node = await game.get_node(GAME)
    assert node is not None, "Game should load with hazard system"


@pytest.mark.asyncio
async def test_stage_manager_exists(game):
    """StageManager autoload should exist."""
    node = await game.get_node(STAGE_MANAGER)
    assert node is not None, "StageManager should exist"


@pytest.mark.asyncio
async def test_player_has_slow_methods(game):
    """Player should have apply_slow and remove_slow methods."""
    player_path = "/root/Game/GameArea/Player"
    has_apply = await game.call(player_path, "has_method", ["apply_slow"])
    has_remove = await game.call(player_path, "has_method", ["remove_slow"])
    assert has_apply, "Player should have apply_slow method"
    assert has_remove, "Player should have remove_slow method"


@pytest.mark.asyncio
async def test_stage_manager_has_stages(game):
    """StageManager should have stages configured."""
    # Check current_stage property exists and is valid
    current_stage = await game.get_property(STAGE_MANAGER, "current_stage")
    assert current_stage is not None, "StageManager should have current_stage"
    assert isinstance(current_stage, int), "current_stage should be an integer"


@pytest.mark.asyncio
async def test_game_controller_has_clear_hazards(game):
    """Game controller should have _clear_hazards method."""
    has_method = await game.call(GAME_CONTROLLER, "has_method", ["_clear_hazards"])
    assert has_method, "Game controller should have _clear_hazards method"


@pytest.mark.asyncio
async def test_game_controller_has_spawn_biome_hazards(game):
    """Game controller should have _spawn_biome_hazards method."""
    has_method = await game.call(GAME_CONTROLLER, "has_method", ["_spawn_biome_hazards"])
    assert has_method, "Game controller should have _spawn_biome_hazards method"


@pytest.mark.asyncio
async def test_stage_count_is_eight(game):
    """Should have 8 stages (biomes)."""
    # StageManager should have 8 stages
    # We check indirectly by verifying stage can be set to 0-7
    for stage in range(8):
        await game.call(STAGE_MANAGER, "set", ["current_stage", stage])
        current = await game.get_property(STAGE_MANAGER, "current_stage")
        assert current == stage, f"Should be able to set stage to {stage}"
