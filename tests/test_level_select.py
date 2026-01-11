"""Tests for level select UI screen."""
import asyncio
import pytest

LEVEL_SELECT = "/root/Game/UI/LevelSelect"
STAGE_MANAGER = "/root/StageManager"
META_MANAGER = "/root/MetaManager"


@pytest.mark.asyncio
async def test_level_select_exists(game):
    """LevelSelect node should exist in the game."""
    node = await game.get_node(LEVEL_SELECT)
    assert node is not None, "LevelSelect should exist"


@pytest.mark.asyncio
async def test_level_select_initially_hidden(game):
    """LevelSelect should be hidden by default."""
    visible = await game.get_property(LEVEL_SELECT, "visible")
    assert visible is False, "LevelSelect should be hidden initially"


@pytest.mark.asyncio
async def test_level_select_get_selected_stage(game):
    """LevelSelect should have get_selected_stage method."""
    selected = await game.call(LEVEL_SELECT, "get_selected_stage")
    assert selected is not None, "LevelSelect should return selected stage"
    assert selected >= 0, f"Selected stage should be >= 0, got {selected}"


@pytest.mark.asyncio
async def test_stage_manager_has_stages(game):
    """StageManager should have loaded stages."""
    total_stages = await game.call(STAGE_MANAGER, "get_total_stages")
    assert total_stages == 4, f"Should have 4 stages, got {total_stages}"


@pytest.mark.asyncio
async def test_stage_manager_get_stage_name(game):
    """StageManager should return current stage name."""
    stage_name = await game.call(STAGE_MANAGER, "get_stage_name")
    assert stage_name is not None, "Should have a stage name"


@pytest.mark.asyncio
async def test_meta_manager_stage_tracking(game):
    """MetaManager should track highest stage cleared."""
    highest = await game.call(META_MANAGER, "get_highest_stage_cleared")
    assert highest is not None, "Should return highest stage cleared"
    assert highest >= 0, f"Highest stage should be >= 0, got {highest}"
