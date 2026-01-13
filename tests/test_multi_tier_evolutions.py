"""Tests for multi-tier evolution system."""
import asyncio
import pytest

FUSION_REGISTRY = "/root/FusionRegistry"
BALL_REGISTRY = "/root/BallRegistry"


@pytest.mark.asyncio
async def test_fusion_registry_has_evolution_tier_enum(game):
    """FusionRegistry should have EvolutionTier enum."""
    # Check TIER_1 value exists (should be 1)
    tier_1 = await game.get_property(FUSION_REGISTRY, "EvolutionTier")
    # We can verify the enum exists by calling get_tier_name
    tier_name = await game.call(FUSION_REGISTRY, "get_tier_name", [1])
    assert tier_name == "Evolved", f"Tier 1 should be 'Evolved', got '{tier_name}'"


@pytest.mark.asyncio
async def test_tier_names(game):
    """Test tier name display."""
    tier_1 = await game.call(FUSION_REGISTRY, "get_tier_name", [1])
    tier_2 = await game.call(FUSION_REGISTRY, "get_tier_name", [2])
    tier_3 = await game.call(FUSION_REGISTRY, "get_tier_name", [3])

    assert tier_1 == "Evolved", f"Tier 1 should be 'Evolved', got '{tier_1}'"
    assert tier_2 == "Advanced", f"Tier 2 should be 'Advanced', got '{tier_2}'"
    assert tier_3 == "Ultimate", f"Tier 3 should be 'Ultimate', got '{tier_3}'"


@pytest.mark.asyncio
async def test_tier_damage_multipliers(game):
    """Test tier damage multipliers."""
    mult_1 = await game.call(FUSION_REGISTRY, "get_tier_damage_multiplier", [1])
    mult_2 = await game.call(FUSION_REGISTRY, "get_tier_damage_multiplier", [2])
    mult_3 = await game.call(FUSION_REGISTRY, "get_tier_damage_multiplier", [3])

    assert abs(mult_1 - 1.5) < 0.01, f"Tier 1 mult should be 1.5, got {mult_1}"
    assert abs(mult_2 - 2.5) < 0.01, f"Tier 2 mult should be 2.5, got {mult_2}"
    assert abs(mult_3 - 4.0) < 0.01, f"Tier 3 mult should be 4.0, got {mult_3}"


@pytest.mark.asyncio
async def test_evolution_starts_at_tier_1(game):
    """Evolution should start at Tier 1."""
    # Start a game to reset state
    await game.call("/root/GameManager", "start_game")
    await asyncio.sleep(0.3)

    # Add two L3 balls that form a known recipe (BURN + IRON = BOMB)
    await game.call(BALL_REGISTRY, "add_ball", [1])  # BURN
    await game.call(BALL_REGISTRY, "level_up_ball", [1])  # L2
    await game.call(BALL_REGISTRY, "level_up_ball", [1])  # L3

    await game.call(BALL_REGISTRY, "add_ball", [6])  # IRON
    await game.call(BALL_REGISTRY, "level_up_ball", [6])  # L2
    await game.call(BALL_REGISTRY, "level_up_ball", [6])  # L3

    # Evolve them
    result = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])
    assert result > 0, "Should create evolved ball (BOMB)"

    # Check tier is 1
    tier = await game.call(FUSION_REGISTRY, "get_evolution_tier", [result])
    assert tier == 1, f"Evolution should start at tier 1, got {tier}"


@pytest.mark.asyncio
async def test_can_upgrade_evolution_method(game):
    """Test can_upgrade_evolution method."""
    # Start a game
    await game.call("/root/GameManager", "start_game")
    await asyncio.sleep(0.3)

    # Create an evolution first (BURN + IRON = BOMB)
    await game.call(BALL_REGISTRY, "add_ball", [1])
    await game.call(BALL_REGISTRY, "level_up_ball", [1])
    await game.call(BALL_REGISTRY, "level_up_ball", [1])

    await game.call(BALL_REGISTRY, "add_ball", [6])
    await game.call(BALL_REGISTRY, "level_up_ball", [6])
    await game.call(BALL_REGISTRY, "level_up_ball", [6])

    evolved_type = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])

    # Should not be upgradeable without L3 balls
    can_upgrade = await game.call(FUSION_REGISTRY, "can_upgrade_evolution", [evolved_type])
    assert can_upgrade is False, "Should not be upgradeable without L3 balls"

    # Add another L3 ball
    await game.call(BALL_REGISTRY, "add_ball", [2])  # FREEZE
    await game.call(BALL_REGISTRY, "level_up_ball", [2])
    await game.call(BALL_REGISTRY, "level_up_ball", [2])

    # Now should be upgradeable
    can_upgrade = await game.call(FUSION_REGISTRY, "can_upgrade_evolution", [evolved_type])
    assert can_upgrade is True, "Should be upgradeable with L3 ball available"


@pytest.mark.asyncio
async def test_upgrade_evolution_increases_tier(game):
    """Test that upgrading evolution increases tier."""
    await game.call("/root/GameManager", "start_game")
    await asyncio.sleep(0.3)

    # Create BOMB evolution (BURN + IRON)
    await game.call(BALL_REGISTRY, "add_ball", [1])
    await game.call(BALL_REGISTRY, "level_up_ball", [1])
    await game.call(BALL_REGISTRY, "level_up_ball", [1])

    await game.call(BALL_REGISTRY, "add_ball", [6])
    await game.call(BALL_REGISTRY, "level_up_ball", [6])
    await game.call(BALL_REGISTRY, "level_up_ball", [6])

    evolved_type = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])
    tier_before = await game.call(FUSION_REGISTRY, "get_evolution_tier", [evolved_type])
    assert tier_before == 1, "Should start at tier 1"

    # Add sacrifice L3 ball (FREEZE)
    await game.call(BALL_REGISTRY, "add_ball", [2])
    await game.call(BALL_REGISTRY, "level_up_ball", [2])
    await game.call(BALL_REGISTRY, "level_up_ball", [2])

    # Upgrade
    success = await game.call(FUSION_REGISTRY, "upgrade_evolution", [evolved_type, 2])
    assert success is True, "Upgrade should succeed"

    tier_after = await game.call(FUSION_REGISTRY, "get_evolution_tier", [evolved_type])
    assert tier_after == 2, f"Should be tier 2 after upgrade, got {tier_after}"


@pytest.mark.asyncio
async def test_tier_3_is_max(game):
    """Test that tier 3 cannot be upgraded further."""
    await game.call("/root/GameManager", "start_game")
    await asyncio.sleep(0.3)

    # Create evolution at Tier 1
    await game.call(BALL_REGISTRY, "add_ball", [1])  # BURN
    await game.call(BALL_REGISTRY, "level_up_ball", [1])
    await game.call(BALL_REGISTRY, "level_up_ball", [1])

    await game.call(BALL_REGISTRY, "add_ball", [6])  # IRON
    await game.call(BALL_REGISTRY, "level_up_ball", [6])
    await game.call(BALL_REGISTRY, "level_up_ball", [6])

    evolved_type = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])

    # Add L3 balls for upgrades
    for i in range(3):
        await game.call(BALL_REGISTRY, "add_ball", [2 + i])  # FREEZE, POISON, BLEED
        await game.call(BALL_REGISTRY, "level_up_ball", [2 + i])
        await game.call(BALL_REGISTRY, "level_up_ball", [2 + i])

    # Upgrade to Tier 2
    await game.call(FUSION_REGISTRY, "upgrade_evolution", [evolved_type, 2])
    tier = await game.call(FUSION_REGISTRY, "get_evolution_tier", [evolved_type])
    assert tier == 2, "Should be tier 2"

    # Upgrade to Tier 3
    await game.call(FUSION_REGISTRY, "upgrade_evolution", [evolved_type, 3])
    tier = await game.call(FUSION_REGISTRY, "get_evolution_tier", [evolved_type])
    assert tier == 3, "Should be tier 3"

    # Should not be upgradeable anymore
    can_upgrade = await game.call(FUSION_REGISTRY, "can_upgrade_evolution", [evolved_type])
    assert can_upgrade is False, "Tier 3 should not be upgradeable"
