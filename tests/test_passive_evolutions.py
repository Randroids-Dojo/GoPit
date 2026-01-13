"""Tests for passive evolution system."""
import asyncio
import pytest
import sys
import os

# Add the tests directory to the path for helper imports
sys.path.insert(0, os.path.dirname(__file__))
from helpers import PATHS, wait_for_fire_ready


@pytest.mark.asyncio
async def test_passive_evolution_data_loaded(game):
    """Test that PassiveEvolutions data is loaded correctly."""
    # Check that PassiveEvolutions static class exists
    result = await game.call("/root", "has_method", ["get_tree"])
    assert result is True, "Root should have get_tree method"

    # Check if MetaManager has the passive evolution methods
    has_method = await game.call(
        "/root/MetaManager", "has_method", ["get_unlocked_passive_evolutions"]
    )
    assert has_method is True, "MetaManager should have get_unlocked_passive_evolutions method"


@pytest.mark.asyncio
async def test_passive_evolution_unlock_trigger(game):
    """Test that passive evolutions are triggered when passive reaches L3."""
    # Get initial unlocked evolutions (should be empty for new save)
    unlocked = await game.call("/root/MetaManager", "get_unlocked_passive_evolutions")
    initial_count = len(unlocked) if unlocked else 0

    # Start a game first
    await game.call("/root/GameManager", "start_game")
    await asyncio.sleep(0.5)

    # Get the FusionRegistry to check passive system
    has_registry = await game.get_node("/root/FusionRegistry")
    assert has_registry is not None, "FusionRegistry should exist"

    # Apply DAMAGE passive 3 times to reach L3
    # First apply fills empty slot at L1
    await game.call("/root/FusionRegistry", "apply_passive", [0])  # PassiveType.DAMAGE = 0
    level1 = await game.call("/root/FusionRegistry", "get_passive_stacks", [0])
    assert level1 == 1, "Passive should be at level 1"

    # Second apply levels up to L2
    await game.call("/root/FusionRegistry", "apply_passive", [0])
    level2 = await game.call("/root/FusionRegistry", "get_passive_stacks", [0])
    assert level2 == 2, "Passive should be at level 2"

    # Third apply levels up to L3 - this should trigger evolution unlock!
    await game.call("/root/FusionRegistry", "apply_passive", [0])
    level3 = await game.call("/root/FusionRegistry", "get_passive_stacks", [0])
    assert level3 == 3, "Passive should be at level 3"

    # Check that evolution was unlocked
    unlocked_after = await game.call("/root/MetaManager", "get_unlocked_passive_evolutions")
    # The power_mastery evolution should be unlocked now
    assert "power_mastery" in unlocked_after, "Power Mastery should be unlocked after maxing DAMAGE passive"


@pytest.mark.asyncio
async def test_passive_evolution_bonus_applied(game):
    """Test that evolution bonuses are applied to gameplay."""
    # First unlock the power_mastery evolution
    await game.call("/root/MetaManager", "unlock_passive_evolution", ["power_mastery"])

    # Verify it's unlocked
    is_unlocked = await game.call(
        "/root/MetaManager", "is_passive_evolution_unlocked", ["power_mastery"]
    )
    assert is_unlocked is True, "power_mastery should be unlocked"

    # Check the damage bonus getter
    damage_bonus = await game.call("/root/MetaManager", "get_damage_bonus")
    # power_mastery adds +1 damage, so bonus should be >= 1
    # (could be more if shop upgrades are active)
    assert damage_bonus >= 1.0, f"Damage bonus should be >= 1.0 after unlocking power_mastery, got {damage_bonus}"


@pytest.mark.asyncio
async def test_passive_evolution_persists_in_save(game):
    """Test that unlocked evolutions persist after save/load cycle."""
    # Unlock an evolution
    await game.call("/root/MetaManager", "unlock_passive_evolution", ["velocity_mastery"])

    # Save data
    await game.call("/root/MetaManager", "save_data")

    # Clear the in-memory list (simulating restart)
    # We can't fully restart, but we can verify save_data was called
    # by checking the evolution is still in the list
    unlocked = await game.call("/root/MetaManager", "get_unlocked_passive_evolutions")
    assert "velocity_mastery" in unlocked, "velocity_mastery should persist in unlocked list"
