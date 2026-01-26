"""Tests for the Laser ball types (instant full-screen line damage).

Lazer balls in BallxPit don't launch projectiles - they create instant
full-screen lines that damage all enemies they intersect.

- LASER_H (Horizontal): Creates a line at player's Y position
- LASER_V (Vertical): Creates a line at player's X position
"""
import asyncio
import pytest

# Laser ball types (LASER_H = 17, LASER_V = 18 in enum)
LASER_H_TYPE = 17
LASER_V_TYPE = 18

# Ball Registry path
BALL_REGISTRY = "BallRegistry"


@pytest.mark.asyncio
async def test_laser_h_exists_in_registry(game):
    """Laser H ball type should exist in BallRegistry.BallType enum."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    assert LASER_H_TYPE in ball_data, "Laser H ball type should exist in BALL_DATA"


@pytest.mark.asyncio
async def test_laser_v_exists_in_registry(game):
    """Laser V ball type should exist in BallRegistry.BallType enum."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    assert LASER_V_TYPE in ball_data, "Laser V ball type should exist in BALL_DATA"


@pytest.mark.asyncio
async def test_laser_h_has_correct_name(game):
    """Laser H ball should have the correct name."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_H_TYPE, {})
    assert laser_data.get("name") == "Laser H", f"Laser H ball name should be 'Laser H', got {laser_data.get('name')}"


@pytest.mark.asyncio
async def test_laser_v_has_correct_name(game):
    """Laser V ball should have the correct name."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_V_TYPE, {})
    assert laser_data.get("name") == "Laser V", f"Laser V ball name should be 'Laser V', got {laser_data.get('name')}"


@pytest.mark.asyncio
async def test_laser_h_has_correct_effect(game):
    """Laser H ball should have 'laser_h' effect."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_H_TYPE, {})
    assert laser_data.get("effect") == "laser_h", f"Laser H effect should be 'laser_h', got {laser_data.get('effect')}"


@pytest.mark.asyncio
async def test_laser_v_has_correct_effect(game):
    """Laser V ball should have 'laser_v' effect."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_V_TYPE, {})
    assert laser_data.get("effect") == "laser_v", f"Laser V effect should be 'laser_v', got {laser_data.get('effect')}"


@pytest.mark.asyncio
async def test_laser_h_is_instant_type(game):
    """Laser H ball should be marked as instant (not a projectile)."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_H_TYPE, {})
    assert laser_data.get("is_instant") == True, f"Laser H should have is_instant=true"


@pytest.mark.asyncio
async def test_laser_v_is_instant_type(game):
    """Laser V ball should be marked as instant (not a projectile)."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_V_TYPE, {})
    assert laser_data.get("is_instant") == True, f"Laser V should have is_instant=true"


@pytest.mark.asyncio
async def test_laser_h_has_red_color(game):
    """Laser H ball should have red color."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_H_TYPE, {})
    color = laser_data.get("color", {})

    # Color(1.0, 0.1, 0.1) - bright red
    if isinstance(color, dict):
        assert abs(color.get("r", 0) - 1.0) < 0.01, f"Laser H red should be ~1.0, got {color.get('r')}"
        assert abs(color.get("g", 0) - 0.1) < 0.01, f"Laser H green should be ~0.1, got {color.get('g')}"
        assert abs(color.get("b", 0) - 0.1) < 0.01, f"Laser H blue should be ~0.1, got {color.get('b')}"


@pytest.mark.asyncio
async def test_laser_v_has_blue_color(game):
    """Laser V ball should have blue color."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_V_TYPE, {})
    color = laser_data.get("color", {})

    # Color(0.1, 0.5, 1.0) - blue
    if isinstance(color, dict):
        assert abs(color.get("r", 0) - 0.1) < 0.01, f"Laser V red should be ~0.1, got {color.get('r')}"
        assert abs(color.get("g", 0) - 0.5) < 0.01, f"Laser V green should be ~0.5, got {color.get('g')}"
        assert abs(color.get("b", 0) - 1.0) < 0.01, f"Laser V blue should be ~1.0, got {color.get('b')}"


@pytest.mark.asyncio
async def test_laser_balls_have_higher_damage(game):
    """Laser balls should have higher base damage (12) since they're instant."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_h_data = ball_data.get(LASER_H_TYPE, {})
    laser_v_data = ball_data.get(LASER_V_TYPE, {})

    assert laser_h_data.get("base_damage") == 12, f"Laser H base_damage should be 12, got {laser_h_data.get('base_damage')}"
    assert laser_v_data.get("base_damage") == 12, f"Laser V base_damage should be 12, got {laser_v_data.get('base_damage')}"


@pytest.mark.asyncio
async def test_laser_balls_have_zero_speed(game):
    """Laser balls should have 0 speed multiplier (they're instant, not projectiles)."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_h_data = ball_data.get(LASER_H_TYPE, {})
    laser_v_data = ball_data.get(LASER_V_TYPE, {})

    assert laser_h_data.get("speed_multiplier") == 0.0, f"Laser H speed_multiplier should be 0.0, got {laser_h_data.get('speed_multiplier')}"
    assert laser_v_data.get("speed_multiplier") == 0.0, f"Laser V speed_multiplier should be 0.0, got {laser_v_data.get('speed_multiplier')}"


@pytest.mark.asyncio
async def test_laser_balls_have_cooldown(game):
    """Laser balls should have a longer cooldown (0.8s) for powerful AoE."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_h_data = ball_data.get(LASER_H_TYPE, {})
    laser_v_data = ball_data.get(LASER_V_TYPE, {})

    assert laser_h_data.get("cooldown") == 0.8, f"Laser H cooldown should be 0.8, got {laser_h_data.get('cooldown')}"
    assert laser_v_data.get("cooldown") == 0.8, f"Laser V cooldown should be 0.8, got {laser_v_data.get('cooldown')}"


@pytest.mark.asyncio
async def test_laser_h_description(game):
    """Laser H ball should have appropriate description."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_H_TYPE, {})
    description = laser_data.get("description", "").lower()

    assert "horizontal" in description or "line" in description, \
        f"Laser H description should mention horizontal/line, got '{description}'"


@pytest.mark.asyncio
async def test_laser_v_description(game):
    """Laser V ball should have appropriate description."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_V_TYPE, {})
    description = laser_data.get("description", "").lower()

    assert "vertical" in description or "line" in description, \
        f"Laser V description should mention vertical/line, got '{description}'"


@pytest.mark.asyncio
async def test_laser_h_can_be_added_to_registry(game):
    """Laser H ball should be addable to owned balls."""
    # Reset registry
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)  # Wait for state to settle

    # Add laser H ball
    await game.call(BALL_REGISTRY, "add_ball", [LASER_H_TYPE])

    # Check it's owned
    owned_balls = await game.get_property(BALL_REGISTRY, "owned_balls")

    assert LASER_H_TYPE in owned_balls, "Laser H ball should be in owned_balls after adding"
    assert owned_balls[LASER_H_TYPE] == 1, "Laser H ball should be at level 1"


@pytest.mark.asyncio
async def test_laser_v_can_be_added_to_registry(game):
    """Laser V ball should be addable to owned balls."""
    # Reset registry
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)  # Wait for state to settle

    # Add laser V ball
    await game.call(BALL_REGISTRY, "add_ball", [LASER_V_TYPE])

    # Check it's owned
    owned_balls = await game.get_property(BALL_REGISTRY, "owned_balls")

    assert LASER_V_TYPE in owned_balls, "Laser V ball should be in owned_balls after adding"
    assert owned_balls[LASER_V_TYPE] == 1, "Laser V ball should be at level 1"


@pytest.mark.asyncio
async def test_laser_ball_can_level_up(game):
    """Laser H ball should be able to level up to L3."""
    # Reset registry and add laser ball
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)  # Wait for state to settle
    await game.call(BALL_REGISTRY, "add_ball", [LASER_H_TYPE])

    # Level up to L2
    result = await game.call(BALL_REGISTRY, "level_up_ball", [LASER_H_TYPE])
    assert result == True, "Should be able to level up to L2"

    level = await game.call(BALL_REGISTRY, "get_ball_level", [LASER_H_TYPE])
    assert level == 2, "Laser H ball should be at level 2"

    # Level up to L3
    result = await game.call(BALL_REGISTRY, "level_up_ball", [LASER_H_TYPE])
    assert result == True, "Should be able to level up to L3"

    level = await game.call(BALL_REGISTRY, "get_ball_level", [LASER_H_TYPE])
    assert level == 3, "Laser H ball should be at level 3"


@pytest.mark.asyncio
async def test_is_instant_type_returns_true_for_lasers(game):
    """is_instant_type() should return true for laser ball types."""
    # Test LASER_H
    is_instant_h = await game.call(BALL_REGISTRY, "is_instant_type", [LASER_H_TYPE])
    assert is_instant_h == True, "is_instant_type should return true for LASER_H"

    # Test LASER_V
    is_instant_v = await game.call(BALL_REGISTRY, "is_instant_type", [LASER_V_TYPE])
    assert is_instant_v == True, "is_instant_type should return true for LASER_V"


@pytest.mark.asyncio
async def test_is_instant_type_returns_false_for_regular_balls(game):
    """is_instant_type() should return false for regular ball types."""
    # Test BASIC (type 0)
    is_instant = await game.call(BALL_REGISTRY, "is_instant_type", [0])
    assert is_instant == False, "is_instant_type should return false for BASIC"

    # Test BURN (type 1)
    is_instant = await game.call(BALL_REGISTRY, "is_instant_type", [1])
    assert is_instant == False, "is_instant_type should return false for BURN"


@pytest.mark.asyncio
async def test_game_loads_with_laser_ball_types(game):
    """Game should load successfully with Laser ball types."""
    node = await game.get_node("/root/Game")
    assert node is not None, "Game should load with Laser ball types"
