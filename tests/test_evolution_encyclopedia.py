"""Tests for evolution encyclopedia UI."""
import asyncio
import pytest

ENCYCLOPEDIA = "/root/Game/UI/EvolutionEncyclopedia"
PAUSE_OVERLAY = "/root/Game/UI/PauseOverlay"
ENCYCLOPEDIA_BUTTON = "/root/Game/UI/PauseOverlay/DimBackground/Panel/VBoxContainer/EncyclopediaButton"
EVOLUTION_LIST = "/root/Game/UI/EvolutionEncyclopedia/DimBackground/Panel/VBoxContainer/ScrollContainer/EvolutionList"
CLOSE_BUTTON = "/root/Game/UI/EvolutionEncyclopedia/DimBackground/Panel/VBoxContainer/CloseButton"


@pytest.mark.asyncio
async def test_encyclopedia_node_exists(game):
    """Evolution encyclopedia should exist in UI."""
    node = await game.get_node(ENCYCLOPEDIA)
    assert node is not None, "EvolutionEncyclopedia should exist in UI"


@pytest.mark.asyncio
async def test_encyclopedia_starts_hidden(game):
    """Encyclopedia should start hidden."""
    visible = await game.get_property(ENCYCLOPEDIA, "visible")
    assert visible is False, "Encyclopedia should start hidden"


@pytest.mark.asyncio
async def test_encyclopedia_button_exists_in_pause_menu(game):
    """Encyclopedia button should exist in pause menu."""
    node = await game.get_node(ENCYCLOPEDIA_BUTTON)
    assert node is not None, "Encyclopedia button should exist in pause menu"


@pytest.mark.asyncio
async def test_show_encyclopedia_method_exists(game):
    """Encyclopedia should have show_encyclopedia method."""
    has_method = await game.call(ENCYCLOPEDIA, "has_method", ["show_encyclopedia"])
    assert has_method, "Encyclopedia should have show_encyclopedia method"


@pytest.mark.asyncio
async def test_encyclopedia_has_evolution_list(game):
    """Encyclopedia should have evolution list container."""
    node = await game.get_node(EVOLUTION_LIST)
    assert node is not None, "Encyclopedia should have EvolutionList container"


@pytest.mark.asyncio
async def test_encyclopedia_has_close_button(game):
    """Encyclopedia should have close button."""
    node = await game.get_node(CLOSE_BUTTON)
    assert node is not None, "Encyclopedia should have CloseButton"


@pytest.mark.asyncio
async def test_encyclopedia_shows_when_method_called(game):
    """Encyclopedia should become visible when show_encyclopedia is called."""
    # Call show method
    await game.call(ENCYCLOPEDIA, "show_encyclopedia")
    await asyncio.sleep(0.1)

    # Check visibility
    visible = await game.get_property(ENCYCLOPEDIA, "visible")
    assert visible is True, "Encyclopedia should be visible after show_encyclopedia"

    # Clean up - hide it
    await game.set_property(ENCYCLOPEDIA, "visible", False)


@pytest.mark.asyncio
async def test_encyclopedia_populates_evolutions(game):
    """Encyclopedia should populate with evolution entries."""
    # Show encyclopedia to trigger population
    await game.call(ENCYCLOPEDIA, "show_encyclopedia")
    await asyncio.sleep(0.2)

    # Check that evolution list has children
    child_count = await game.call(EVOLUTION_LIST, "get_child_count")
    # We have 10 evolution recipes
    assert child_count >= 5, f"Encyclopedia should have at least 5 evolution entries, got {child_count}"

    # Clean up
    await game.set_property(ENCYCLOPEDIA, "visible", False)
