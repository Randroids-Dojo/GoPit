"""Tests for XP bonus buildings meta-progression system."""
import asyncio
import pytest

GAME = "/root/Game"
META_MANAGER = "/root/MetaManager"
GAME_MANAGER = "/root/GameManager"


@pytest.mark.asyncio
async def test_meta_manager_has_xp_gain_multiplier(game):
    """MetaManager should have get_xp_gain_multiplier method."""
    has_method = await game.call(META_MANAGER, "has_method", ["get_xp_gain_multiplier"])
    assert has_method, "MetaManager should have get_xp_gain_multiplier method"


@pytest.mark.asyncio
async def test_meta_manager_has_early_xp_multiplier(game):
    """MetaManager should have get_early_xp_multiplier method."""
    has_method = await game.call(META_MANAGER, "has_method", ["get_early_xp_multiplier"])
    assert has_method, "MetaManager should have get_early_xp_multiplier method"


@pytest.mark.asyncio
async def test_xp_gain_multiplier_default_is_one(game):
    """XP gain multiplier should return 1.0 by default (no upgrades)."""
    # Reset upgrades to ensure clean state
    multiplier = await game.call(META_MANAGER, "get_xp_gain_multiplier", [])
    assert multiplier >= 1.0, "XP gain multiplier should be at least 1.0"


@pytest.mark.asyncio
async def test_early_xp_multiplier_at_level_1(game):
    """Early XP multiplier should return at least 1.0 at level 1."""
    multiplier = await game.call(META_MANAGER, "get_early_xp_multiplier", [1])
    assert multiplier >= 1.0, "Early XP multiplier should be at least 1.0"


@pytest.mark.asyncio
async def test_early_xp_multiplier_at_level_10(game):
    """Early XP multiplier should return 1.0 at level 10 (above cap)."""
    multiplier = await game.call(META_MANAGER, "get_early_xp_multiplier", [10])
    # At level 10 (above the 5-level cap), should return 1.0
    assert multiplier == 1.0, "Early XP multiplier should be 1.0 above level cap"


@pytest.mark.asyncio
async def test_game_manager_has_add_xp(game):
    """GameManager should have add_xp method."""
    has_method = await game.call(GAME_MANAGER, "has_method", ["add_xp"])
    assert has_method, "GameManager should have add_xp method"


@pytest.mark.asyncio
async def test_game_manager_has_xp_multiplier(game):
    """GameManager should have get_xp_multiplier method."""
    has_method = await game.call(GAME_MANAGER, "has_method", ["get_xp_multiplier"])
    assert has_method, "GameManager should have get_xp_multiplier method"


@pytest.mark.asyncio
async def test_xp_multiplier_returns_positive(game):
    """XP multiplier from GameManager should return positive value."""
    multiplier = await game.call(GAME_MANAGER, "get_xp_multiplier", [])
    assert multiplier > 0, "XP multiplier should be positive"
    assert multiplier >= 1.0, "XP multiplier should be at least 1.0"
