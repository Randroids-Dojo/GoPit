"""Tests for stat buildings (BallxPit-style meta-progression)."""
import asyncio
import pytest

# Autoload singletons
META_MANAGER = "/root/MetaManager"
GAME_MANAGER = "/root/GameManager"


async def reset_meta_upgrades(game):
    """Reset MetaManager upgrade levels for testing."""
    # Reset to clean state
    await game.call(META_MANAGER, "reset")
    await asyncio.sleep(0.1)


@pytest.mark.asyncio
async def test_barracks_exists_in_upgrades(game):
    """Barracks (strength) building should exist in permanent upgrades."""
    # Check MetaManager has the upgrade
    level = await game.call(META_MANAGER, "get_upgrade_level", ["strength"])
    assert level is not None, "Strength upgrade should exist"
    assert level >= 0, "Upgrade level should be non-negative"


@pytest.mark.asyncio
async def test_gunsmith_exists_in_upgrades(game):
    """Gunsmith (dexterity) building should exist in permanent upgrades."""
    level = await game.call(META_MANAGER, "get_upgrade_level", ["dexterity"])
    assert level is not None, "Dexterity upgrade should exist"
    assert level >= 0, "Upgrade level should be non-negative"


@pytest.mark.asyncio
async def test_schoolhouse_exists_in_upgrades(game):
    """Schoolhouse (intelligence) building should exist in permanent upgrades."""
    level = await game.call(META_MANAGER, "get_upgrade_level", ["intelligence"])
    assert level is not None, "Intelligence upgrade should exist"
    assert level >= 0, "Upgrade level should be non-negative"


@pytest.mark.asyncio
async def test_consulate_exists_in_upgrades(game):
    """Consulate (leadership) building should exist in permanent upgrades."""
    level = await game.call(META_MANAGER, "get_upgrade_level", ["leadership"])
    assert level is not None, "Leadership upgrade should exist"
    assert level >= 0, "Upgrade level should be non-negative"


@pytest.mark.asyncio
async def test_strength_bonus_getter_exists(game):
    """MetaManager should have get_strength_bonus method."""
    bonus = await game.call(META_MANAGER, "get_strength_bonus")
    assert bonus is not None, "get_strength_bonus should exist"
    assert isinstance(bonus, int), "Strength bonus should be an integer"


@pytest.mark.asyncio
async def test_dexterity_bonus_getter_exists(game):
    """MetaManager should have get_dexterity_bonus method."""
    bonus = await game.call(META_MANAGER, "get_dexterity_bonus")
    assert bonus is not None, "get_dexterity_bonus should exist"
    assert isinstance(bonus, int), "Dexterity bonus should be an integer"


@pytest.mark.asyncio
async def test_intelligence_bonus_getter_exists(game):
    """MetaManager should have get_intelligence_bonus method."""
    bonus = await game.call(META_MANAGER, "get_intelligence_bonus")
    assert bonus is not None, "get_intelligence_bonus should exist"
    assert isinstance(bonus, int), "Intelligence bonus should be an integer"


@pytest.mark.asyncio
async def test_leadership_bonus_getter_exists(game):
    """MetaManager should have get_leadership_bonus method."""
    bonus = await game.call(META_MANAGER, "get_leadership_bonus")
    assert bonus is not None, "get_leadership_bonus should exist"
    assert isinstance(bonus, int), "Leadership bonus should be an integer"


@pytest.mark.asyncio
async def test_character_strength_includes_bonus(game):
    """GameManager.get_character_strength should include meta bonus."""
    # Get character strength
    strength = await game.call(GAME_MANAGER, "get_character_strength")
    assert strength is not None, "get_character_strength should exist"
    assert isinstance(strength, int), "Strength should be an integer"
    assert strength > 0, "Strength should be positive"


@pytest.mark.asyncio
async def test_character_dexterity_includes_bonus(game):
    """GameManager.get_character_dexterity should include meta bonus."""
    dexterity = await game.call(GAME_MANAGER, "get_character_dexterity")
    assert dexterity is not None, "get_character_dexterity should exist"
    assert isinstance(dexterity, int), "Dexterity should be an integer"
    assert dexterity > 0, "Dexterity should be positive"


@pytest.mark.asyncio
async def test_character_intelligence_includes_bonus(game):
    """GameManager.get_character_intelligence should include meta bonus."""
    intelligence = await game.call(GAME_MANAGER, "get_character_intelligence")
    assert intelligence is not None, "get_character_intelligence should exist"
    assert isinstance(intelligence, int), "Intelligence should be an integer"
    assert intelligence > 0, "Intelligence should be positive"


@pytest.mark.asyncio
async def test_status_duration_mult_uses_intelligence(game):
    """Status duration multiplier should exist and be positive."""
    mult = await game.call(GAME_MANAGER, "get_status_duration_mult")
    assert mult is not None, "get_status_duration_mult should exist"
    assert isinstance(mult, float), "Duration mult should be a float"
    assert mult >= 1.0, "Duration mult should be at least 1.0"


@pytest.mark.asyncio
async def test_status_damage_mult_uses_intelligence(game):
    """Status damage multiplier should exist and be positive."""
    mult = await game.call(GAME_MANAGER, "get_status_damage_mult")
    assert mult is not None, "get_status_damage_mult should exist"
    assert isinstance(mult, float), "Damage mult should be a float"
    assert mult >= 1.0, "Damage mult should be at least 1.0"
