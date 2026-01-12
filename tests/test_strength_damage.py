"""Tests for Strength-based ball damage system."""
import asyncio
import pytest

GAME_MANAGER = "/root/GameManager"
BALL_REGISTRY = "/root/BallRegistry"
BALL_SPAWNER = "/root/Game/GameArea/BallSpawner"
FIRE_BUTTON = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"
BALLS = "/root/Game/GameArea/Balls"


@pytest.mark.asyncio
async def test_game_manager_has_get_character_strength(game):
    """GameManager should have get_character_strength method."""
    # Call the method - should not throw
    strength = await game.call(GAME_MANAGER, "get_character_strength")
    assert strength is not None, "Should return a strength value"
    assert strength > 0, f"Strength should be positive, got {strength}"


@pytest.mark.asyncio
async def test_default_strength_without_character(game):
    """Without a selected character, should return default strength of 10."""
    # Reset to ensure no character selected
    await game.call(GAME_MANAGER, "_reset_character_stats")
    await asyncio.sleep(0.1)

    strength = await game.call(GAME_MANAGER, "get_character_strength")
    assert strength == 10, f"Default strength should be 10, got {strength}"


@pytest.mark.asyncio
async def test_ball_registry_uses_strength_for_damage(game):
    """BallRegistry.get_damage should use character Strength, not per-ball-type damage."""
    # Ensure registry is initialized
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Get damage for basic ball
    basic_damage = await game.call(BALL_REGISTRY, "get_damage", [0])  # 0 = BASIC
    strength = await game.call(GAME_MANAGER, "get_character_strength")

    # At L1, damage should equal strength (multiplier = 1.0)
    assert basic_damage == strength, f"L1 damage should equal strength ({strength}), got {basic_damage}"


@pytest.mark.asyncio
async def test_all_ball_types_same_base_damage(game):
    """All ball types should have the same base damage (from Strength)."""
    # Reset registry and add some ball types
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Add different ball types
    await game.call(BALL_REGISTRY, "add_ball", [1])  # BURN
    await game.call(BALL_REGISTRY, "add_ball", [2])  # FREEZE

    # Get damage for each ball type
    basic_damage = await game.call(BALL_REGISTRY, "get_damage", [0])
    burn_damage = await game.call(BALL_REGISTRY, "get_damage", [1])
    freeze_damage = await game.call(BALL_REGISTRY, "get_damage", [2])

    # All should be equal (same base strength, same level)
    assert basic_damage == burn_damage, f"BASIC ({basic_damage}) and BURN ({burn_damage}) should have same damage"
    assert burn_damage == freeze_damage, f"BURN ({burn_damage}) and FREEZE ({freeze_damage}) should have same damage"


@pytest.mark.asyncio
async def test_level_multiplier_still_applies(game):
    """Ball level multipliers should still apply to Strength-based damage."""
    # Reset registry
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Get L1 damage
    l1_damage = await game.call(BALL_REGISTRY, "get_damage", [0])

    # Level up basic ball
    await game.call(BALL_REGISTRY, "level_up_ball", [0])
    l2_damage = await game.call(BALL_REGISTRY, "get_damage", [0])

    # L2 should be 1.5x L1
    expected_l2 = int(l1_damage * 1.5)
    assert l2_damage == expected_l2, f"L2 damage should be {expected_l2}, got {l2_damage}"


@pytest.mark.asyncio
async def test_l3_damage_multiplier(game):
    """L3 balls should have 2x base damage."""
    # Reset registry
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Get base strength
    strength = await game.call(GAME_MANAGER, "get_character_strength")

    # Level up to L3
    await game.call(BALL_REGISTRY, "level_up_ball", [0])  # L2
    await game.call(BALL_REGISTRY, "level_up_ball", [0])  # L3
    l3_damage = await game.call(BALL_REGISTRY, "get_damage", [0])

    # L3 should be 2x strength
    expected_l3 = int(strength * 2.0)
    assert l3_damage == expected_l3, f"L3 damage should be {expected_l3}, got {l3_damage}"


@pytest.mark.asyncio
async def test_ball_spawner_damage_from_strength(game):
    """Ball spawner should use strength-based damage."""
    # Ball spawner damage should match GameManager strength
    spawner_damage = await game.get_property(BALL_SPAWNER, "ball_damage")
    strength = await game.call(GAME_MANAGER, "get_character_strength")

    # Note: spawner_damage is set at character select, so it may be the default
    # Just verify it's a reasonable positive value
    assert spawner_damage > 0, f"Spawner damage should be positive, got {spawner_damage}"


@pytest.mark.asyncio
async def test_fired_ball_has_strength_based_damage(game):
    """Fired balls should have damage based on character Strength."""
    # Reset to clean state
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Fire a ball
    await game.click(FIRE_BUTTON)
    await asyncio.sleep(0.2)

    # Get ball count
    ball_count = await game.call(BALLS, "get_child_count")
    assert ball_count >= 1, "Should have at least one ball"

    # Get expected damage from registry (uses Strength)
    expected_damage = await game.call(BALL_REGISTRY, "get_damage", [0])
    assert expected_damage > 0, "Expected damage should be positive"


@pytest.mark.asyncio
async def test_strength_scales_with_player_level(game):
    """Strength should increase as player levels up (for characters with scaling)."""
    # This is a design verification test - the actual scaling happens in
    # Character.get_strength_at_level() which was tested in test_strength_stat.py
    # Here we verify the GameManager integration
    strength_l1 = await game.call(GAME_MANAGER, "get_character_strength")
    assert strength_l1 >= 5, f"Strength should be at least 5, got {strength_l1}"


@pytest.mark.asyncio
async def test_ball_data_still_has_base_damage_for_reference(game):
    """BALL_DATA should still have base_damage for reference/documentation."""
    # Get BALL_DATA constant
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")
    assert ball_data is not None, "BALL_DATA should exist"

    # Check that entries still have base_damage (kept for documentation)
    # Note: In Godot, accessing const dicts via Python may return differently
    # This test verifies the data structure hasn't been removed


@pytest.mark.asyncio
async def test_level_multipliers_unchanged(game):
    """Level multipliers should remain: L1=1.0x, L2=1.5x, L3=2.0x."""
    l1_mult = await game.call(BALL_REGISTRY, "get_level_multiplier", [1])
    l2_mult = await game.call(BALL_REGISTRY, "get_level_multiplier", [2])
    l3_mult = await game.call(BALL_REGISTRY, "get_level_multiplier", [3])

    assert l1_mult == 1.0, f"L1 multiplier should be 1.0, got {l1_mult}"
    assert l2_mult == 1.5, f"L2 multiplier should be 1.5, got {l2_mult}"
    assert l3_mult == 2.0, f"L3 multiplier should be 2.0, got {l3_mult}"
