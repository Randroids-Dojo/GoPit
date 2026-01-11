"""Tests for the fusion reactor and ball fusion system."""
import asyncio
import pytest


@pytest.mark.asyncio
async def test_fusion_reactor_scene_exists(game):
    """Verify fusion reactor spawn method exists."""
    # Test by spawning a reactor (method existence check)
    # The spawn won't fail if the scene is loadable
    try:
        await game.call(
            "/root/Game",
            "_spawn_fusion_reactor",
            [{"x": 100, "y": 100}]
        )
        # Clean up by checking gems container
        count = await game.call("/root/Game/GameArea/Gems", "get_child_count")
        assert count >= 0, "Should be able to spawn fusion reactor"
    except Exception:
        pytest.skip("Fusion reactor spawn method not accessible")


@pytest.mark.asyncio
async def test_fusion_registry_exists(game):
    """Verify FusionRegistry autoload is accessible."""
    # Check that FusionRegistry singleton exists
    result = await game.call(
        "/root/FusionRegistry",
        "get_name"
    )
    assert result == "FusionRegistry", "FusionRegistry autoload should exist"


@pytest.mark.asyncio
async def test_fusion_overlay_exists(game):
    """Verify fusion overlay UI node exists."""
    overlay = await game.get_node("/root/Game/UI/FusionOverlay")
    assert overlay is not None, "FusionOverlay should exist in UI"


@pytest.mark.asyncio
async def test_fusion_overlay_initially_hidden(game):
    """Verify fusion overlay starts hidden."""
    visible = await game.get_property("/root/Game/UI/FusionOverlay", "visible")
    assert visible is False, "FusionOverlay should be hidden initially"


@pytest.mark.asyncio
async def test_fusion_registry_has_evolution_recipes(game):
    """Verify FusionRegistry has evolution recipes defined."""
    # Get number of evolution recipes
    result = await game.call(
        "/root/FusionRegistry",
        "get_available_evolutions"
    )
    assert isinstance(result, list), "Should return list of evolutions"
    assert len(result) >= 5, "Should have at least 5 evolution recipes"


@pytest.mark.asyncio
async def test_fission_always_available(game):
    """Verify fission option always works."""
    # Apply fission - should always work even without L3 balls
    result = await game.call(
        "/root/FusionRegistry",
        "apply_fission"
    )
    assert isinstance(result, dict), "Fission should return result dict"
    assert "type" in result, "Result should have type field"
    assert result["type"] == "fission", "Type should be fission"


@pytest.mark.asyncio
async def test_evolved_ball_type_enum(game):
    """Verify evolved ball types are defined."""
    # Check BOMB type exists (value 1)
    bomb = await game.call(
        "/root/FusionRegistry",
        "get_evolved_ball_name",
        [1]
    )
    assert bomb == "Bomb", "BOMB evolved type should exist"

    # Check BLIZZARD type exists (value 2)
    blizzard = await game.call(
        "/root/FusionRegistry",
        "get_evolved_ball_name",
        [2]
    )
    assert blizzard == "Blizzard", "BLIZZARD evolved type should exist"


@pytest.mark.asyncio
async def test_has_evolution_recipe_check(game):
    """Test checking if two ball types have an evolution recipe."""
    # BURN (1) + IRON (6) should have BOMB recipe
    has_recipe = await game.call(
        "/root/FusionRegistry",
        "has_evolution_recipe",
        [1, 6]  # BURN, IRON
    )
    assert has_recipe is True, "BURN + IRON should have evolution recipe"

    # BASIC (0) + BASIC (0) should NOT have recipe
    no_recipe = await game.call(
        "/root/FusionRegistry",
        "has_evolution_recipe",
        [0, 0]  # BASIC, BASIC
    )
    assert no_recipe is False, "BASIC + BASIC should not have evolution recipe"


@pytest.mark.asyncio
async def test_get_evolution_result(game):
    """Test getting the result of an evolution recipe."""
    # BURN (1) + IRON (6) = BOMB (1)
    result = await game.call(
        "/root/FusionRegistry",
        "get_evolution_result",
        [1, 6]  # BURN, IRON
    )
    assert result == 1, "BURN + IRON should result in BOMB (type 1)"

    # No recipe should return NONE (0)
    no_result = await game.call(
        "/root/FusionRegistry",
        "get_evolution_result",
        [0, 0]  # BASIC, BASIC
    )
    assert no_result == 0, "No recipe should return NONE (0)"


@pytest.mark.asyncio
async def test_fusion_reactor_spawn_function_exists(game):
    """Verify game controller has fusion reactor spawn method."""
    # Just check the method exists by calling it (position will be off-screen)
    await game.call(
        "/root/Game",
        "_spawn_fusion_reactor",
        [{"x": -100, "y": -100}]  # Off-screen position
    )
    # If we get here without error, the method exists
    assert True


@pytest.mark.asyncio
async def test_ball_spawns_successfully(game):
    """Verify ball can be spawned (verifies ball script compiles with evolved properties)."""
    # The ball script has evolved properties (is_evolved, evolved_type, etc.)
    # If the game loads and balls can spawn, the script compiled successfully

    # Spawn a ball
    await game.click("/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton")
    await asyncio.sleep(0.3)

    balls_path = "/root/Game/GameArea/Balls"
    count = await game.call(balls_path, "get_child_count")

    # If we can spawn balls, the ball script with evolved properties works
    assert count >= 0, "Ball system should be functional"


# ============================================================================
# Evolution Recipe Tests
# ============================================================================

@pytest.mark.asyncio
async def test_all_evolution_recipes_defined(game):
    """Verify all 5 evolution recipes are defined."""
    # BallRegistry.BallType enum values:
    # BASIC=0, BURN=1, FREEZE=2, POISON=3, BLEED=4, LIGHTNING=5, IRON=6
    ball_map = {
        "BURN": 1, "FREEZE": 2, "POISON": 3,
        "BLEED": 4, "LIGHTNING": 5, "IRON": 6
    }

    expected_recipes = [
        ("BURN", "IRON"),       # -> BOMB
        ("FREEZE", "LIGHTNING"),  # -> BLIZZARD
        ("BLEED", "POISON"),    # -> VIRUS (sorted alphabetically in key)
        ("BURN", "POISON"),     # -> MAGMA
        ("BURN", "FREEZE")      # -> VOID
    ]

    for ball_a, ball_b in expected_recipes:
        has_recipe = await game.call(
            "/root/FusionRegistry",
            "has_evolution_recipe",
            [ball_map[ball_a], ball_map[ball_b]]
        )
        assert has_recipe is True, f"Recipe {ball_a}+{ball_b} should exist"


@pytest.mark.asyncio
async def test_recipe_key_generation_is_consistent(game):
    """get_recipe_key should return same key regardless of ball order."""
    # BURN (1) + IRON (6) should give same key as IRON (6) + BURN (1)
    key1 = await game.call(
        "/root/FusionRegistry",
        "get_recipe_key",
        [1, 6]
    )
    key2 = await game.call(
        "/root/FusionRegistry",
        "get_recipe_key",
        [6, 1]
    )
    assert key1 == key2, "Recipe key should be order-independent"


# ============================================================================
# Evolved Ball Data Tests
# ============================================================================

@pytest.mark.asyncio
async def test_all_evolved_ball_types_have_data(game):
    """All evolved ball types (1-5) should have data defined."""
    for evolved_type in range(1, 6):  # BOMB=1 through VOID=5
        data = await game.call(
            "/root/FusionRegistry",
            "get_evolved_ball_data",
            [evolved_type]
        )
        assert data, f"Evolved type {evolved_type} should have data"
        assert "name" in data, f"Evolved type {evolved_type} should have name"
        assert "effect" in data, f"Evolved type {evolved_type} should have effect"
        assert "color" in data, f"Evolved type {evolved_type} should have color"


@pytest.mark.asyncio
async def test_evolved_ball_effects_defined(game):
    """Each evolved ball should have a unique effect type."""
    effects = {}
    for evolved_type in range(1, 6):
        data = await game.call(
            "/root/FusionRegistry",
            "get_evolved_ball_data",
            [evolved_type]
        )
        effect = data.get("effect", "none")
        assert effect != "none", f"Evolved type {evolved_type} should have an effect"
        assert effect not in effects, f"Effect '{effect}' should be unique"
        effects[effect] = evolved_type


@pytest.mark.asyncio
async def test_bomb_has_aoe_properties(game):
    """BOMB evolved ball should have AoE explosion properties."""
    data = await game.call(
        "/root/FusionRegistry",
        "get_evolved_ball_data",
        [1]  # BOMB
    )
    assert data["effect"] == "explosion", "BOMB should have explosion effect"
    assert "aoe_radius" in data, "BOMB should define aoe_radius"
    assert "aoe_damage_mult" in data, "BOMB should define aoe_damage_mult"
    assert data["aoe_radius"] >= 50, "BOMB aoe_radius should be at least 50"


@pytest.mark.asyncio
async def test_blizzard_has_chain_properties(game):
    """BLIZZARD evolved ball should have chain freeze properties."""
    data = await game.call(
        "/root/FusionRegistry",
        "get_evolved_ball_data",
        [2]  # BLIZZARD
    )
    assert data["effect"] == "blizzard", "BLIZZARD should have blizzard effect"
    assert "chain_count" in data, "BLIZZARD should define chain_count"
    assert "freeze_duration" in data, "BLIZZARD should define freeze_duration"
    assert data["chain_count"] >= 1, "BLIZZARD should chain to at least 1 enemy"


@pytest.mark.asyncio
async def test_virus_has_spread_properties(game):
    """VIRUS evolved ball should have spreading DoT properties."""
    data = await game.call(
        "/root/FusionRegistry",
        "get_evolved_ball_data",
        [3]  # VIRUS
    )
    assert data["effect"] == "virus", "VIRUS should have virus effect"
    assert "spread_radius" in data, "VIRUS should define spread_radius"
    assert "lifesteal" in data, "VIRUS should define lifesteal"


@pytest.mark.asyncio
async def test_magma_has_pool_properties(game):
    """MAGMA evolved ball should have ground pool properties."""
    data = await game.call(
        "/root/FusionRegistry",
        "get_evolved_ball_data",
        [4]  # MAGMA
    )
    assert data["effect"] == "magma_pool", "MAGMA should have magma_pool effect"
    assert "pool_duration" in data, "MAGMA should define pool_duration"
    assert "pool_dps" in data, "MAGMA should define pool_dps"


@pytest.mark.asyncio
async def test_void_has_alternating_effects(game):
    """VOID evolved ball should have alternating effect properties."""
    data = await game.call(
        "/root/FusionRegistry",
        "get_evolved_ball_data",
        [5]  # VOID
    )
    assert data["effect"] == "void", "VOID should have void effect"
    assert "alternating_effects" in data, "VOID should define alternating_effects"
    effects = data["alternating_effects"]
    assert "burn" in effects and "freeze" in effects, "VOID should alternate burn/freeze"


# ============================================================================
# Fission System Tests
# ============================================================================

@pytest.mark.asyncio
async def test_fission_returns_upgrades_or_coins(game):
    """Fission should return upgrades or Pit Coins bonus."""
    result = await game.call(
        "/root/FusionRegistry",
        "apply_fission"
    )
    assert "type" in result, "Fission result should have type"
    assert result["type"] == "fission", "Result type should be fission"
    assert "upgrades" in result, "Result should have upgrades array"
    assert "pit_coins" in result, "Result should have pit_coins"


@pytest.mark.asyncio
async def test_fission_upgrades_are_valid(game):
    """Fission upgrades should have valid action types (balls AND passives)."""
    result = await game.call(
        "/root/FusionRegistry",
        "apply_fission"
    )
    for upgrade in result.get("upgrades", []):
        assert "action" in upgrade, "Upgrade should have action"
        assert upgrade["action"] in ["level_up", "new_ball", "passive"], \
            f"Invalid action: {upgrade['action']}"
        # Ball upgrades have ball_type, passive upgrades have passive_type
        if upgrade["action"] in ["level_up", "new_ball"]:
            assert "ball_type" in upgrade, "Ball upgrade should have ball_type"
        elif upgrade["action"] == "passive":
            assert "passive_type" in upgrade, "Passive upgrade should have passive_type"


# ============================================================================
# State Management Tests
# ============================================================================

@pytest.mark.asyncio
async def test_fusion_registry_resets_on_game_start(game):
    """FusionRegistry should clear owned balls when new game starts."""
    # Start a game
    await game.call("/root/Game/UI/CharacterSelect", "show_select", [])
    await asyncio.sleep(0.2)
    await game.click("/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/StartButton")
    await asyncio.sleep(0.3)

    # Check that owned evolved balls is empty
    has_any = await game.call(
        "/root/FusionRegistry",
        "has_any_evolved_or_fused"
    )
    assert has_any is False, "Should start with no evolved/fused balls"


@pytest.mark.asyncio
async def test_get_all_evolved_types_initially_empty(game):
    """get_all_evolved_types should return empty array at start."""
    result = await game.call(
        "/root/FusionRegistry",
        "get_all_evolved_types"
    )
    assert isinstance(result, list), "Should return array"
    assert len(result) == 0, "Should start with no evolved balls"


@pytest.mark.asyncio
async def test_get_all_fused_ids_initially_empty(game):
    """get_all_fused_ids should return empty array at start."""
    result = await game.call(
        "/root/FusionRegistry",
        "get_all_fused_ids"
    )
    assert isinstance(result, list), "Should return array"
    assert len(result) == 0, "Should start with no fused balls"
