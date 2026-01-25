"""Tests for advanced fusion features: evolved ball leveling, multi-evolution, and ultimate fusions."""
import asyncio
import pytest

BALL_REGISTRY = "/root/BallRegistry"
FUSION_REGISTRY = "/root/FusionRegistry"


async def reset_registries(game):
    """Reset both registries to clean state for testing."""
    await game.call(BALL_REGISTRY, "reset")
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)


async def add_l3_basic_ball(game, ball_type: int) -> bool:
    """Add a ball type and level it to L3."""
    # Add ball if not owned
    await game.call(BALL_REGISTRY, "add_ball", [ball_type])
    await asyncio.sleep(0.05)

    # Level up to L2
    success = await game.call(BALL_REGISTRY, "level_up_ball", [ball_type])
    if not success:
        return False
    await asyncio.sleep(0.05)

    # Level up to L3
    success = await game.call(BALL_REGISTRY, "level_up_ball", [ball_type])
    await asyncio.sleep(0.05)
    return success


# =============================================================================
# EVOLVED BALL LEVELING/XP TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_evolved_ball_starts_at_level_1(game):
    """Newly created evolved balls start at level 1."""
    await reset_registries(game)

    # Add BURN (1) and IRON (6) and level them to L3
    await add_l3_basic_ball(game, 1)  # BURN
    await add_l3_basic_ball(game, 6)  # IRON

    # Create BOMB evolution (BURN + IRON)
    result = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])
    assert result != 0, "Should create BOMB evolved ball"  # NONE = 0

    # Check evolved ball level
    level = await game.call(FUSION_REGISTRY, "get_evolved_ball_level", [result])
    assert level == 1, f"Evolved ball should start at level 1, got {level}"


@pytest.mark.asyncio
async def test_evolved_ball_xp_tracking(game):
    """Evolved balls should track XP correctly."""
    await reset_registries(game)

    # Create an evolved ball
    await add_l3_basic_ball(game, 1)  # BURN
    await add_l3_basic_ball(game, 6)  # IRON
    result = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])

    # Check initial XP is 0
    xp = await game.call(FUSION_REGISTRY, "get_evolved_ball_xp", [result])
    assert xp == 0, f"Initial XP should be 0, got {xp}"

    # Add some XP
    await game.call(FUSION_REGISTRY, "add_evolved_ball_xp", [result, 10])
    await asyncio.sleep(0.05)

    xp_after = await game.call(FUSION_REGISTRY, "get_evolved_ball_xp", [result])
    assert xp_after == 10, f"XP should be 10 after adding, got {xp_after}"


@pytest.mark.asyncio
async def test_evolved_ball_level_up_on_xp(game):
    """Evolved balls should level up when reaching XP threshold."""
    await reset_registries(game)

    # Create an evolved ball
    await add_l3_basic_ball(game, 1)  # BURN
    await add_l3_basic_ball(game, 6)  # IRON
    result = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])

    # Check XP needed for level 2 (should be 20)
    xp_needed = await game.call(FUSION_REGISTRY, "get_evolved_ball_xp_to_next_level", [result])
    assert xp_needed == 20, f"XP needed for L2 should be 20, got {xp_needed}"

    # Add exactly enough XP for level 2
    await game.call(FUSION_REGISTRY, "add_evolved_ball_xp", [result, 20])
    await asyncio.sleep(0.1)

    # Check level increased
    level = await game.call(FUSION_REGISTRY, "get_evolved_ball_level", [result])
    assert level == 2, f"Should be level 2 after XP threshold, got {level}"


@pytest.mark.asyncio
async def test_evolved_ball_fusion_ready_at_l3(game):
    """Evolved balls at L3 should be fusion-ready for multi-evolution."""
    await reset_registries(game)

    # Create an evolved ball
    await add_l3_basic_ball(game, 1)  # BURN
    await add_l3_basic_ball(game, 6)  # IRON
    result = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])

    # Not fusion ready at L1
    is_ready = await game.call(FUSION_REGISTRY, "is_evolved_ball_fusion_ready", [result])
    assert is_ready == False, "L1 evolved ball should not be fusion ready"

    # Level up to L2 (20 XP)
    await game.call(FUSION_REGISTRY, "add_evolved_ball_xp", [result, 20])
    await asyncio.sleep(0.05)

    is_ready = await game.call(FUSION_REGISTRY, "is_evolved_ball_fusion_ready", [result])
    assert is_ready == False, "L2 evolved ball should not be fusion ready"

    # Level up to L3 (50 XP from L2)
    await game.call(FUSION_REGISTRY, "add_evolved_ball_xp", [result, 50])
    await asyncio.sleep(0.05)

    is_ready = await game.call(FUSION_REGISTRY, "is_evolved_ball_fusion_ready", [result])
    assert is_ready == True, "L3 evolved ball should be fusion ready"


@pytest.mark.asyncio
async def test_evolved_ball_level_multiplier(game):
    """Evolved ball level should affect damage multiplier."""
    await reset_registries(game)

    # Check level multipliers
    mult_l1 = await game.call(FUSION_REGISTRY, "get_evolved_ball_level_multiplier", [1])
    mult_l2 = await game.call(FUSION_REGISTRY, "get_evolved_ball_level_multiplier", [2])
    mult_l3 = await game.call(FUSION_REGISTRY, "get_evolved_ball_level_multiplier", [3])

    assert mult_l1 == 1.0, f"L1 multiplier should be 1.0, got {mult_l1}"
    assert mult_l2 == 1.5, f"L2 multiplier should be 1.5, got {mult_l2}"
    assert mult_l3 == 2.0, f"L3 multiplier should be 2.0, got {mult_l3}"


# =============================================================================
# MULTI-EVOLUTION TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_multi_evolution_recipes_exist(game):
    """FusionRegistry should have multi-evolution recipes defined."""
    await reset_registries(game)

    # Check that multi-evolution recipes dictionary exists
    has_recipes = await game.call(FUSION_REGISTRY, "has_method", ["get_available_multi_evolutions"])
    assert has_recipes == True, "Should have get_available_multi_evolutions method"

    recipes = await game.call(FUSION_REGISTRY, "get_available_multi_evolutions")
    assert isinstance(recipes, list), "Should return a list of available multi-evolutions"


@pytest.mark.asyncio
async def test_has_multi_evolution_recipe_method(game):
    """Should be able to check if a multi-evolution recipe exists."""
    await reset_registries(game)

    # BOMB (evolved) + POISON (basic) = NUCLEAR_BOMB
    # First need to check the recipe without having the balls
    has_method = await game.call(FUSION_REGISTRY, "has_method", ["has_multi_evolution_recipe"])
    assert has_method == True, "Should have has_multi_evolution_recipe method"


@pytest.mark.asyncio
async def test_multi_evolution_creates_tier_2(game):
    """Multi-evolution should create a Tier 2 evolved ball."""
    await reset_registries(game)

    # Create BOMB (BURN + IRON)
    await add_l3_basic_ball(game, 1)  # BURN
    await add_l3_basic_ball(game, 6)  # IRON
    bomb = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])
    assert bomb != 0, "Should create BOMB"

    # Level BOMB to L3 (fusion-ready)
    await game.call(FUSION_REGISTRY, "add_evolved_ball_xp", [bomb, 20])  # L2
    await asyncio.sleep(0.05)
    await game.call(FUSION_REGISTRY, "add_evolved_ball_xp", [bomb, 50])  # L3
    await asyncio.sleep(0.05)

    # Add POISON L3 (type 3)
    await add_l3_basic_ball(game, 3)  # POISON

    # Check multi-evolution is available
    is_ready = await game.call(FUSION_REGISTRY, "is_evolved_ball_fusion_ready", [bomb])
    assert is_ready == True, "BOMB should be L3 and fusion-ready"

    # Perform multi-evolution: BOMB + POISON = NUCLEAR_BOMB
    result = await game.call(FUSION_REGISTRY, "multi_evolve_ball", [bomb, 3])
    assert result != 0, "Multi-evolution should succeed"

    # Check tier is 2
    tier = await game.call(FUSION_REGISTRY, "get_evolution_tier", [result])
    assert tier == 2, f"Multi-evolved ball should be Tier 2, got {tier}"


# =============================================================================
# ULTIMATE FUSION (THREE-WAY) TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_ultimate_fusion_recipes_exist(game):
    """FusionRegistry should have ultimate fusion recipes defined."""
    await reset_registries(game)

    has_method = await game.call(FUSION_REGISTRY, "has_method", ["get_available_ultimate_fusions"])
    assert has_method == True, "Should have get_available_ultimate_fusions method"

    recipes = await game.call(FUSION_REGISTRY, "get_available_ultimate_fusions")
    assert isinstance(recipes, list), "Should return a list of available ultimate fusions"


@pytest.mark.asyncio
async def test_has_ultimate_recipe_method(game):
    """Should be able to check if an ultimate fusion recipe exists."""
    await reset_registries(game)

    has_method = await game.call(FUSION_REGISTRY, "has_method", ["has_ultimate_recipe"])
    assert has_method == True, "Should have has_ultimate_recipe method"


@pytest.mark.asyncio
async def test_get_ultimate_result_method(game):
    """Should be able to get ultimate fusion result."""
    await reset_registries(game)

    has_method = await game.call(FUSION_REGISTRY, "has_method", ["get_ultimate_result"])
    assert has_method == True, "Should have get_ultimate_result method"


@pytest.mark.asyncio
async def test_ultimate_fusion_tier_4(game):
    """Ultimate fusions should create Tier 4 (Legendary) balls."""
    await reset_registries(game)

    # Check tier 4 multiplier exists
    mult = await game.call(FUSION_REGISTRY, "get_tier_damage_multiplier", [4])
    assert mult == 6.0, f"Tier 4 damage multiplier should be 6.0, got {mult}"


# =============================================================================
# RECIPE DISCOVERY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_recipe_discovery_method_exists(game):
    """FusionRegistry should have recipe discovery methods."""
    await reset_registries(game)

    has_method = await game.call(FUSION_REGISTRY, "has_method", ["is_recipe_discovered"])
    assert has_method == True, "Should have is_recipe_discovered method"

    has_method = await game.call(FUSION_REGISTRY, "has_method", ["get_discovered_recipe_count"])
    assert has_method == True, "Should have get_discovered_recipe_count method"


@pytest.mark.asyncio
async def test_evolution_discovers_recipe(game):
    """Performing an evolution should mark the recipe as discovered."""
    await reset_registries(game)

    # Reset discoveries
    await game.call(FUSION_REGISTRY, "reset_discoveries")
    await asyncio.sleep(0.05)

    # Count before
    count_before = await game.call(FUSION_REGISTRY, "get_discovered_recipe_count")
    assert count_before == 0, f"Should start with 0 discovered, got {count_before}"

    # Create BOMB evolution
    await add_l3_basic_ball(game, 1)  # BURN
    await add_l3_basic_ball(game, 6)  # IRON
    result = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])
    await asyncio.sleep(0.1)

    # Count after
    count_after = await game.call(FUSION_REGISTRY, "get_discovered_recipe_count")
    assert count_after == 1, f"Should have 1 discovered after evolution, got {count_after}"


# =============================================================================
# EVOLVED BALL SLOTS TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_evolved_ball_slots_exist(game):
    """FusionRegistry should have evolved ball slot methods."""
    await reset_registries(game)

    has_method = await game.call(FUSION_REGISTRY, "has_method", ["get_active_evolved_slots"])
    assert has_method == True, "Should have get_active_evolved_slots method"

    has_method = await game.call(FUSION_REGISTRY, "has_method", ["assign_evolved_to_empty_slot"])
    assert has_method == True, "Should have assign_evolved_to_empty_slot method"


@pytest.mark.asyncio
async def test_evolved_ball_auto_assigned_to_slot(game):
    """Creating an evolved ball should auto-assign it to a slot."""
    await reset_registries(game)

    # Create an evolved ball
    await add_l3_basic_ball(game, 1)  # BURN
    await add_l3_basic_ball(game, 6)  # IRON
    result = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])
    await asyncio.sleep(0.1)

    # Check it's in a slot
    slots = await game.call(FUSION_REGISTRY, "get_active_evolved_slots")
    assert result in slots, "Evolved ball should be auto-assigned to a slot"


@pytest.mark.asyncio
async def test_get_fusion_ready_evolved_balls(game):
    """Should be able to get list of L3 evolved balls."""
    await reset_registries(game)

    # Create and level an evolved ball to L3
    await add_l3_basic_ball(game, 1)  # BURN
    await add_l3_basic_ball(game, 6)  # IRON
    result = await game.call(FUSION_REGISTRY, "evolve_balls", [1, 6])

    # Check not fusion ready initially
    ready_balls = await game.call(FUSION_REGISTRY, "get_fusion_ready_evolved_balls")
    assert len(ready_balls) == 0, "Should have no fusion-ready evolved balls initially"

    # Level to L3
    await game.call(FUSION_REGISTRY, "add_evolved_ball_xp", [result, 20])  # L2
    await asyncio.sleep(0.05)
    await game.call(FUSION_REGISTRY, "add_evolved_ball_xp", [result, 50])  # L3
    await asyncio.sleep(0.05)

    ready_balls = await game.call(FUSION_REGISTRY, "get_fusion_ready_evolved_balls")
    assert result in ready_balls, "L3 evolved ball should be in fusion-ready list"
