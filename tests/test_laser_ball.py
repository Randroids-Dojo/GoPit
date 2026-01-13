"""Tests for the Laser ball type (row/column AoE damage)."""
import asyncio
import pytest

# Laser ball type (18th in enum, 0-indexed = 17)
LASER_BALL_TYPE = 17

# Ball Registry path
BALL_REGISTRY = "BallRegistry"


@pytest.mark.asyncio
async def test_laser_ball_exists_in_registry(game):
    """Laser ball type should exist in BallRegistry.BallType enum."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    assert LASER_BALL_TYPE in ball_data, "Laser ball type should exist in BALL_DATA"


@pytest.mark.asyncio
async def test_laser_ball_has_correct_name(game):
    """Laser ball should have the correct name."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_BALL_TYPE, {})
    assert laser_data.get("name") == "Laser", f"Laser ball name should be 'Laser', got {laser_data.get('name')}"


@pytest.mark.asyncio
async def test_laser_ball_has_laser_effect(game):
    """Laser ball should have 'laser' effect."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_BALL_TYPE, {})
    assert laser_data.get("effect") == "laser", f"Laser ball effect should be 'laser', got {laser_data.get('effect')}"


@pytest.mark.asyncio
async def test_laser_ball_has_red_color(game):
    """Laser ball should have red color."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_BALL_TYPE, {})
    color = laser_data.get("color", {})

    # Color(1.0, 0.1, 0.1) - bright red
    if isinstance(color, dict):
        assert abs(color.get("r", 0) - 1.0) < 0.01, f"Laser ball red should be ~1.0, got {color.get('r')}"
        assert abs(color.get("g", 0) - 0.1) < 0.01, f"Laser ball green should be ~0.1, got {color.get('g')}"
        assert abs(color.get("b", 0) - 0.1) < 0.01, f"Laser ball blue should be ~0.1, got {color.get('b')}"


@pytest.mark.asyncio
async def test_laser_ball_has_moderate_damage(game):
    """Laser ball should have moderate base damage."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_BALL_TYPE, {})
    base_damage = laser_data.get("base_damage", 0)

    assert base_damage == 7, f"Laser ball base_damage should be 7, got {base_damage}"


@pytest.mark.asyncio
async def test_laser_ball_has_fast_speed(game):
    """Laser ball should have slightly fast speed (1.1x)."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_BALL_TYPE, {})
    speed_mult = laser_data.get("speed_multiplier", 0)

    assert abs(speed_mult - 1.1) < 0.01, f"Laser ball speed_multiplier should be 1.1, got {speed_mult}"


@pytest.mark.asyncio
async def test_laser_ball_has_cooldown(game):
    """Laser ball should have a moderate cooldown (AoE effect)."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_BALL_TYPE, {})
    cooldown = laser_data.get("cooldown", 0.0)

    assert cooldown == 0.5, f"Laser ball cooldown should be 0.5, got {cooldown}"


@pytest.mark.asyncio
async def test_laser_ball_description(game):
    """Laser ball should have appropriate description."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    laser_data = ball_data.get(LASER_BALL_TYPE, {})
    description = laser_data.get("description", "")

    assert "row" in description.lower() or "column" in description.lower() or "aoe" in description.lower(), \
        f"Laser ball description should mention row/column AoE, got '{description}'"


@pytest.mark.asyncio
async def test_laser_ball_can_be_added_to_registry(game):
    """Laser ball should be addable to owned balls."""
    # Reset registry
    await game.call(BALL_REGISTRY, "reset")

    # Add laser ball
    await game.call(BALL_REGISTRY, "add_ball", [LASER_BALL_TYPE])

    # Check it's owned
    owned_balls = await game.get_property(BALL_REGISTRY, "owned_balls")

    assert LASER_BALL_TYPE in owned_balls, "Laser ball should be in owned_balls after adding"
    assert owned_balls[LASER_BALL_TYPE] == 1, "Laser ball should be at level 1"


@pytest.mark.asyncio
async def test_laser_ball_can_level_up(game):
    """Laser ball should be able to level up to L3."""
    # Reset registry and add laser ball
    await game.call(BALL_REGISTRY, "reset")
    await game.call(BALL_REGISTRY, "add_ball", [LASER_BALL_TYPE])

    # Level up to L2
    result = await game.call(BALL_REGISTRY, "level_up_ball", [LASER_BALL_TYPE])
    assert result == True, "Should be able to level up to L2"

    level = await game.call(BALL_REGISTRY, "get_ball_level", [LASER_BALL_TYPE])
    assert level == 2, "Laser ball should be at level 2"

    # Level up to L3
    result = await game.call(BALL_REGISTRY, "level_up_ball", [LASER_BALL_TYPE])
    assert result == True, "Should be able to level up to L3"

    level = await game.call(BALL_REGISTRY, "get_ball_level", [LASER_BALL_TYPE])
    assert level == 3, "Laser ball should be at level 3"


@pytest.mark.asyncio
async def test_game_loads_with_laser_ball(game):
    """Game should load successfully with Laser ball type."""
    node = await game.get_node("/root/Game")
    assert node is not None, "Game should load with Laser ball type"
