"""Tests for fission passive upgrade system."""
import asyncio
import pytest

FUSION_REGISTRY = "/root/FusionRegistry"
GAME_MANAGER = "/root/GameManager"


async def reset_fusion_registry(game):
    """Reset FusionRegistry to clean state for testing."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)


@pytest.mark.asyncio
async def test_passive_stacks_start_at_zero(game):
    """All passive stacks should start at 0."""
    await reset_fusion_registry(game)
    # PassiveType.DAMAGE = 0
    stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [0])
    assert stacks == 0, "DAMAGE stacks should start at 0"

    # PassiveType.FIRE_RATE = 1
    stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [1])
    assert stacks == 0, "FIRE_RATE stacks should start at 0"


@pytest.mark.asyncio
async def test_apply_passive_increases_stacks(game):
    """apply_passive should increment the stack count."""
    await reset_fusion_registry(game)
    # Apply DAMAGE passive (type 0)
    result = await game.call(FUSION_REGISTRY, "apply_passive", [0])
    assert result is True, "apply_passive should return true on success"

    stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [0])
    assert stacks == 1, "DAMAGE stacks should be 1 after applying once"

    # Apply again
    await game.call(FUSION_REGISTRY, "apply_passive", [0])
    stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [0])
    assert stacks == 2, "DAMAGE stacks should be 2 after applying twice"


@pytest.mark.asyncio
async def test_passive_max_stacks(game):
    """Passives should respect max_stacks limit."""
    await reset_fusion_registry(game)
    # PassiveType.MULTI_SHOT = 3, max_stacks = 3
    max_stacks = await game.call(FUSION_REGISTRY, "get_passive_max_stacks", [3])
    assert max_stacks == 3, "MULTI_SHOT should have max_stacks of 3"

    # Apply until maxed
    for i in range(max_stacks):
        result = await game.call(FUSION_REGISTRY, "apply_passive", [3])
        assert result is True, f"Should succeed on application {i+1}"

    # Try to apply beyond max
    result = await game.call(FUSION_REGISTRY, "apply_passive", [3])
    assert result is False, "Should fail when at max stacks"

    # Verify stacks didn't exceed max
    stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [3])
    assert stacks == max_stacks, "Stacks should stay at max"


@pytest.mark.asyncio
async def test_get_available_passives(game):
    """get_available_passives should return passives below max stacks."""
    await reset_fusion_registry(game)
    # Initially only 4 passives available (limited by slot count)
    # because we have 4 slots and 20 passives, only 4 can be equipped
    available = await game.call(FUSION_REGISTRY, "get_available_passives")
    # With slot system: all 20 passives available when slots empty
    assert len(available) == 20, "All 20 passives should be available with empty slots"

    # Fill all 4 slots
    for passive_type in [0, 1, 2, 3]:  # DAMAGE, FIRE_RATE, MAX_HP, MULTI_SHOT
        await game.call(FUSION_REGISTRY, "apply_passive", [passive_type])

    # Now only 4 passives available (the 4 that are equipped and can level up)
    available = await game.call(FUSION_REGISTRY, "get_available_passives")
    assert len(available) == 4, "Only 4 equipped passives available when slots full"


@pytest.mark.asyncio
async def test_passive_name_and_description(game):
    """get_passive_name and get_passive_description should return correct values."""
    await reset_fusion_registry(game)
    # PassiveType.DAMAGE = 0
    name = await game.call(FUSION_REGISTRY, "get_passive_name", [0])
    assert name == "Power Up", "DAMAGE passive should be named 'Power Up'"

    desc = await game.call(FUSION_REGISTRY, "get_passive_description", [0])
    assert desc == "+5 Ball Damage", "DAMAGE description should match"

    # PassiveType.MAX_HP = 2
    name = await game.call(FUSION_REGISTRY, "get_passive_name", [2])
    assert name == "Vitality", "MAX_HP passive should be named 'Vitality'"


@pytest.mark.asyncio
async def test_apply_fission_can_include_passives(game):
    """apply_fission should sometimes include passive upgrades."""
    await reset_fusion_registry(game)
    # Run fission multiple times and check for passive upgrades
    found_passive = False
    for _ in range(20):  # Run enough times to statistically expect passives
        result = await game.call(FUSION_REGISTRY, "apply_fission")
        upgrades = result.get("upgrades", [])
        for upgrade in upgrades:
            if upgrade.get("action") == "passive":
                found_passive = True
                break
        if found_passive:
            break

    assert found_passive, "Fission should include passive upgrades (40% chance per upgrade)"


@pytest.mark.asyncio
async def test_apply_passive_max_hp_increases_hp(game):
    """MAX_HP passive should increase max_hp and heal."""
    await reset_fusion_registry(game)
    await game.call(GAME_MANAGER, "reset")
    initial_max_hp = await game.get_property(GAME_MANAGER, "max_hp")

    # Apply MAX_HP passive (type 2)
    await game.call(FUSION_REGISTRY, "apply_passive", [2])

    new_max_hp = await game.get_property(GAME_MANAGER, "max_hp")
    assert new_max_hp == initial_max_hp + 25, "MAX_HP passive should add 25 max HP"


@pytest.mark.asyncio
async def test_apply_passive_magnetism_increases_range(game):
    """MAGNETISM passive should increase gem_magnetism_range."""
    await reset_fusion_registry(game)
    await game.call(GAME_MANAGER, "reset")
    initial_range = await game.get_property(GAME_MANAGER, "gem_magnetism_range")

    # Apply MAGNETISM passive (type 8)
    await game.call(FUSION_REGISTRY, "apply_passive", [8])

    new_range = await game.get_property(GAME_MANAGER, "gem_magnetism_range")
    assert new_range == initial_range + 200.0, "MAGNETISM passive should add 200 range"


# Tests for new passives (10-19)


@pytest.mark.asyncio
async def test_new_passive_armor(game):
    """ARMOR passive should increase armor_percent."""
    await reset_fusion_registry(game)
    await game.call(GAME_MANAGER, "reset")
    initial = await game.get_property(GAME_MANAGER, "armor_percent")
    assert initial == 0.0, "Armor should start at 0"

    # Apply ARMOR passive (type 10)
    await game.call(FUSION_REGISTRY, "apply_passive", [10])
    armor = await game.get_property(GAME_MANAGER, "armor_percent")
    assert armor == 0.05, "ARMOR passive should add 5% damage reduction"


@pytest.mark.asyncio
async def test_new_passive_dodge(game):
    """DODGE passive should increase dodge_chance."""
    await reset_fusion_registry(game)
    await game.call(GAME_MANAGER, "reset")
    initial = await game.get_property(GAME_MANAGER, "dodge_chance")
    assert initial == 0.0, "Dodge chance should start at 0"

    # Apply DODGE passive (type 17)
    await game.call(FUSION_REGISTRY, "apply_passive", [17])
    dodge = await game.get_property(GAME_MANAGER, "dodge_chance")
    assert dodge == 0.05, "DODGE passive should add 5% dodge chance"


@pytest.mark.asyncio
async def test_new_passive_double_xp(game):
    """DOUBLE_XP passive should increase xp_multiplier."""
    await reset_fusion_registry(game)
    await game.call(GAME_MANAGER, "reset")
    initial = await game.get_property(GAME_MANAGER, "xp_multiplier")
    assert initial == 1.0, "XP multiplier should start at 1.0"

    # Apply DOUBLE_XP passive (type 13)
    await game.call(FUSION_REGISTRY, "apply_passive", [13])
    mult = await game.get_property(GAME_MANAGER, "xp_multiplier")
    assert mult == 1.25, "DOUBLE_XP passive should add 25% XP"


@pytest.mark.asyncio
async def test_new_passive_name(game):
    """New passives should have correct names."""
    await reset_fusion_registry(game)
    # ARMOR = 10
    name = await game.call(FUSION_REGISTRY, "get_passive_name", [10])
    assert name == "Armor", "ARMOR passive should be named 'Armor'"

    # THORNS = 11
    name = await game.call(FUSION_REGISTRY, "get_passive_name", [11])
    assert name == "Thorns", "THORNS passive should be named 'Thorns'"

    # LIFE_STEAL = 18
    name = await game.call(FUSION_REGISTRY, "get_passive_name", [18])
    assert name == "Vampirism", "LIFE_STEAL passive should be named 'Vampirism'"

    # SPREAD_SHOT = 19
    name = await game.call(FUSION_REGISTRY, "get_passive_name", [19])
    assert name == "Scatter", "SPREAD_SHOT passive should be named 'Scatter'"


@pytest.mark.asyncio
async def test_total_passive_count(game):
    """There should be 20 total passives."""
    await reset_fusion_registry(game)
    # Get all available passives (should be 20 with empty slots)
    available = await game.call(FUSION_REGISTRY, "get_available_passives")
    assert len(available) == 20, "Should have 20 passives total"
