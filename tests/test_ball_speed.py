"""Tests for ball speed multiplier-based system."""
import asyncio
import pytest

GAME = "/root/Game"


@pytest.mark.asyncio
async def test_base_ball_speed_constant_exists(game):
    """BallRegistry should have BASE_BALL_SPEED constant."""
    base_speed = await game.get_property("BallRegistry", "BASE_BALL_SPEED")
    assert base_speed == 800.0, f"BASE_BALL_SPEED should be 800.0, got {base_speed}"


@pytest.mark.asyncio
async def test_ball_data_has_speed_multiplier(game):
    """BALL_DATA should use speed_multiplier instead of base_speed."""
    ball_data = await game.get_property("BallRegistry", "BALL_DATA")

    # Check that all ball types have speed_multiplier
    for ball_type, data in ball_data.items():
        assert "speed_multiplier" in data, f"Ball type {ball_type} missing speed_multiplier"
        assert "base_speed" not in data, f"Ball type {ball_type} should not have base_speed (use speed_multiplier)"


@pytest.mark.asyncio
async def test_standard_balls_have_1x_speed(game):
    """Standard balls (Basic, Burn, etc) should have 1.0x speed multiplier."""
    ball_data = await game.get_property("BallRegistry", "BALL_DATA")

    # Ball types that should have standard speed
    standard_balls = [0, 1, 2, 3, 4, 8, 9, 12]  # BASIC, BURN, FREEZE, POISON, BLEED, DISEASE, FROSTBURN, VAMPIRE

    for ball_type in standard_balls:
        if ball_type in ball_data:
            multiplier = ball_data[ball_type].get("speed_multiplier", 1.0)
            assert multiplier == 1.0, f"Ball type {ball_type} should have 1.0x speed, got {multiplier}"


@pytest.mark.asyncio
async def test_iron_ball_is_slow(game):
    """Iron ball should be slower (0.75x speed - heavy)."""
    ball_data = await game.get_property("BallRegistry", "BALL_DATA")

    # BallType.IRON = 6
    iron_multiplier = ball_data[6].get("speed_multiplier", 1.0)
    assert iron_multiplier == 0.75, f"Iron ball should have 0.75x speed (slow/heavy), got {iron_multiplier}"


@pytest.mark.asyncio
async def test_wind_ball_is_fast(game):
    """Wind ball should be fastest (1.25x speed)."""
    ball_data = await game.get_property("BallRegistry", "BALL_DATA")

    # BallType.WIND = 10
    wind_multiplier = ball_data[10].get("speed_multiplier", 1.0)
    assert wind_multiplier == 1.25, f"Wind ball should have 1.25x speed (fast), got {wind_multiplier}"


@pytest.mark.asyncio
async def test_lightning_ball_speed(game):
    """Lightning ball should be fast (1.125x speed)."""
    ball_data = await game.get_property("BallRegistry", "BALL_DATA")

    # BallType.LIGHTNING = 5
    lightning_multiplier = ball_data[5].get("speed_multiplier", 1.0)
    assert lightning_multiplier == 1.125, f"Lightning ball should have 1.125x speed, got {lightning_multiplier}"


@pytest.mark.asyncio
async def test_get_speed_uses_multiplier(game):
    """get_speed should calculate: BASE_BALL_SPEED × speed_multiplier × level_multiplier."""
    # Reset registry and add basic ball
    await game.call("BallRegistry", "reset")

    # Basic ball at L1: 800 × 1.0 × 1.0 = 800
    basic_speed = await game.call("BallRegistry", "get_speed", [0])  # BallType.BASIC
    assert basic_speed == 800.0, f"Basic L1 speed should be 800, got {basic_speed}"


@pytest.mark.asyncio
async def test_iron_speed_calculation(game):
    """Iron ball speed should be 800 × 0.75 × level_mult."""
    await game.call("BallRegistry", "reset")
    await game.call("BallRegistry", "add_ball", [6])  # Add iron ball (BallType.IRON)

    # Iron ball at L1: 800 × 0.75 × 1.0 = 600
    iron_speed = await game.call("BallRegistry", "get_speed", [6])
    assert iron_speed == 600.0, f"Iron L1 speed should be 600, got {iron_speed}"


@pytest.mark.asyncio
async def test_speed_scales_with_level(game):
    """Ball speed should scale with level multiplier."""
    await game.call("BallRegistry", "reset")

    # Level up basic ball to L2
    await game.call("BallRegistry", "level_up_ball", [0])

    # Basic ball at L2: 800 × 1.0 × 1.5 = 1200
    l2_speed = await game.call("BallRegistry", "get_speed", [0])
    assert l2_speed == 1200.0, f"Basic L2 speed should be 1200, got {l2_speed}"

    # Level up to L3
    await game.call("BallRegistry", "level_up_ball", [0])

    # Basic ball at L3: 800 × 1.0 × 2.0 = 1600
    l3_speed = await game.call("BallRegistry", "get_speed", [0])
    assert l3_speed == 1600.0, f"Basic L3 speed should be 1600, got {l3_speed}"


@pytest.mark.asyncio
async def test_get_speed_multiplier_function(game):
    """get_speed_multiplier should return raw multiplier without level scaling."""
    iron_mult = await game.call("BallRegistry", "get_speed_multiplier", [6])
    assert iron_mult == 0.75, f"Iron speed_multiplier should be 0.75, got {iron_mult}"

    wind_mult = await game.call("BallRegistry", "get_speed_multiplier", [10])
    assert wind_mult == 1.25, f"Wind speed_multiplier should be 1.25, got {wind_mult}"
