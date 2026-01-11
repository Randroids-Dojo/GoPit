"""Tests for fission passive upgrade system."""
import asyncio
import pytest

FUSION_REGISTRY = "/root/FusionRegistry"
GAME_MANAGER = "/root/GameManager"


@pytest.mark.asyncio
async def test_passive_stacks_start_at_zero(game):
    """All passive stacks should start at 0."""
    # PassiveType.DAMAGE = 0
    stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [0])
    assert stacks == 0, "DAMAGE stacks should start at 0"

    # PassiveType.FIRE_RATE = 1
    stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [1])
    assert stacks == 0, "FIRE_RATE stacks should start at 0"


@pytest.mark.asyncio
async def test_apply_passive_increases_stacks(game):
    """apply_passive should increment the stack count."""
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
    # Initially all 10 passives should be available
    available = await game.call(FUSION_REGISTRY, "get_available_passives")
    assert len(available) == 10, "All 10 passives should be available initially"

    # Max out MULTI_SHOT (type 3, max_stacks 3)
    for _ in range(3):
        await game.call(FUSION_REGISTRY, "apply_passive", [3])

    # Now only 9 should be available
    available = await game.call(FUSION_REGISTRY, "get_available_passives")
    assert len(available) == 9, "9 passives should be available after maxing one"
    assert 3 not in available, "MULTI_SHOT should not be in available list"


@pytest.mark.asyncio
async def test_passive_name_and_description(game):
    """get_passive_name and get_passive_description should return correct values."""
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
    initial_max_hp = await game.get_property(GAME_MANAGER, "max_hp")

    # Apply MAX_HP passive (type 2)
    await game.call(FUSION_REGISTRY, "apply_passive", [2])

    new_max_hp = await game.get_property(GAME_MANAGER, "max_hp")
    assert new_max_hp == initial_max_hp + 25, "MAX_HP passive should add 25 max HP"


@pytest.mark.asyncio
async def test_apply_passive_magnetism_increases_range(game):
    """MAGNETISM passive should increase gem_magnetism_range."""
    initial_range = await game.get_property(GAME_MANAGER, "gem_magnetism_range")

    # Apply MAGNETISM passive (type 8)
    await game.call(FUSION_REGISTRY, "apply_passive", [8])

    new_range = await game.get_property(GAME_MANAGER, "gem_magnetism_range")
    assert new_range == initial_range + 200.0, "MAGNETISM passive should add 200 range"
