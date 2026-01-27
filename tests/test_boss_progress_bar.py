"""Tests for the boss progress bar HUD element."""
import asyncio
import pytest

# Node paths
HUD = "/root/Game/UI/HUD"
BOSS_PROGRESS_BAR = "/root/Game/UI/HUD/BossProgressContainer/BossProgressBar"
BOSS_LABEL = "/root/Game/UI/HUD/BossProgressContainer/BossLabel"


@pytest.mark.asyncio
async def test_boss_progress_bar_exists(game):
    """Boss progress bar should exist in the HUD."""
    node = await game.get_node(BOSS_PROGRESS_BAR)
    assert node is not None, "Boss progress bar should exist"


@pytest.mark.asyncio
async def test_boss_progress_bar_has_max_value(game):
    """Boss progress bar should have a max value based on waves before boss."""
    max_value = await game.get_property(BOSS_PROGRESS_BAR, "max_value")
    assert max_value is not None, "Boss progress bar should have max_value"
    assert max_value > 0, "Max value should be positive"


@pytest.mark.asyncio
async def test_boss_progress_bar_value_updates(game):
    """Boss progress bar value should reflect wave progress."""
    value = await game.get_property(BOSS_PROGRESS_BAR, "value")
    assert value is not None, "Boss progress bar should have a value"
    assert value >= 1, "Value should be at least 1 (first wave)"


@pytest.mark.asyncio
async def test_boss_label_exists(game):
    """Boss label should exist next to the progress bar."""
    node = await game.get_node(BOSS_LABEL)
    assert node is not None, "Boss label should exist"


@pytest.mark.asyncio
async def test_boss_label_shows_boss_text(game):
    """Boss label should show 'BOSS' text."""
    text = await game.get_property(BOSS_LABEL, "text")
    assert text is not None, "Boss label should have text"
    assert "BOSS" in text, f"Boss label should contain 'BOSS', got: {text}"
