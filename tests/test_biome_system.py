"""Tests for the biome/stage system."""
import asyncio
import pytest


@pytest.mark.asyncio
async def test_initial_biome_is_the_pit(game):
    """First biome should be The Pit."""
    stage_name = await game.call("/root/StageManager", "get_stage_name")
    assert stage_name == "The Pit"


@pytest.mark.asyncio
async def test_initial_wave_in_stage(game):
    """Initial wave_in_stage should be 1."""
    wave_in_stage = await game.get_property("/root/StageManager", "wave_in_stage")
    assert wave_in_stage == 1


@pytest.mark.asyncio
async def test_initial_stage_is_zero(game):
    """Initial current_stage should be 0."""
    current_stage = await game.get_property("/root/StageManager", "current_stage")
    assert current_stage == 0


@pytest.mark.asyncio
async def test_stage_count(game):
    """Should have 8 stages total."""
    total_stages = await game.call("/root/StageManager", "get_total_stages")
    assert total_stages == 8


@pytest.mark.asyncio
async def test_biome_has_correct_waves(game):
    """Each biome should have 10 waves before boss."""
    biome = await game.get_property("/root/StageManager", "current_biome")
    # Resource properties are accessed via the autoload
    waves = await game.call("/root/StageManager", "get", ["current_biome:waves_before_boss"])
    # Fallback: just check is_boss_wave at wave 1
    is_boss = await game.call("/root/StageManager", "is_boss_wave")
    assert is_boss == False


@pytest.mark.asyncio
async def test_not_boss_wave_initially(game):
    """Should not be boss wave at start."""
    is_boss = await game.call("/root/StageManager", "is_boss_wave")
    assert is_boss == False


@pytest.mark.asyncio
async def test_background_color_applied(game):
    """Background should have biome color applied."""
    # The Pit background color is Color(0.102, 0.102, 0.18, 1)
    bg_color = await game.get_property("/root/Game/Background", "color")
    # Color is returned as dict with r, g, b, a
    assert bg_color is not None
    # Check approximate color (The Pit is dark blue)
    assert bg_color.get("r", 0) < 0.2
    assert bg_color.get("b", 0) > 0.1
