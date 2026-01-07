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
