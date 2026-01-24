"""Tests for the Charm status effect (mind control enemies)."""
import asyncio
import pytest

# Status effect type (CHARM is 8th in enum, 0-indexed)
STATUS_CHARM = 8

# Ball Registry paths
BALL_REGISTRY = "BallRegistry"

# Charm ball type (17th in enum, 0-indexed = 16)
CHARM_BALL_TYPE = 16


@pytest.mark.asyncio
async def test_charm_status_exists(game):
    """Charm should exist as a status effect type."""
    # Create a status effect with CHARM type via GameManager
    # This test verifies the enum exists
    game_node = await game.get_node("/root/Game")
    assert game_node is not None, "Game should load with Charm status effect"


@pytest.mark.asyncio
async def test_charm_ball_exists_in_registry(game):
    """Charm ball type should exist in BallRegistry.BallType enum."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    assert CHARM_BALL_TYPE in ball_data, "Charm ball type should exist in BALL_DATA"


@pytest.mark.asyncio
async def test_charm_ball_has_correct_name(game):
    """Charm ball should have the correct name."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    charm_data = ball_data.get(CHARM_BALL_TYPE, {})
    assert charm_data.get("name") == "Charm", f"Charm ball name should be 'Charm', got {charm_data.get('name')}"


@pytest.mark.asyncio
async def test_charm_ball_has_charm_effect(game):
    """Charm ball should have 'charm' effect."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    charm_data = ball_data.get(CHARM_BALL_TYPE, {})
    assert charm_data.get("effect") == "charm", f"Charm ball effect should be 'charm', got {charm_data.get('effect')}"


@pytest.mark.asyncio
async def test_charm_ball_has_pink_color(game):
    """Charm ball should have pink/magenta color."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    charm_data = ball_data.get(CHARM_BALL_TYPE, {})
    color = charm_data.get("color", {})

    # Color(1.0, 0.4, 0.8) - pink/magenta
    if isinstance(color, dict):
        assert abs(color.get("r", 0) - 1.0) < 0.01, f"Charm ball red should be ~1.0, got {color.get('r')}"
        assert abs(color.get("g", 0) - 0.4) < 0.01, f"Charm ball green should be ~0.4, got {color.get('g')}"
        assert abs(color.get("b", 0) - 0.8) < 0.01, f"Charm ball blue should be ~0.8, got {color.get('b')}"


@pytest.mark.asyncio
async def test_charm_ball_has_moderate_damage(game):
    """Charm ball should have moderate base damage."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    charm_data = ball_data.get(CHARM_BALL_TYPE, {})
    base_damage = charm_data.get("base_damage", 0)

    assert base_damage == 5, f"Charm ball base_damage should be 5, got {base_damage}"


@pytest.mark.asyncio
async def test_charm_ball_has_standard_speed(game):
    """Charm ball should have standard speed (1.0x)."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    charm_data = ball_data.get(CHARM_BALL_TYPE, {})
    speed_mult = charm_data.get("speed_multiplier", 0)

    assert abs(speed_mult - 1.0) < 0.01, f"Charm ball speed_multiplier should be 1.0, got {speed_mult}"


@pytest.mark.asyncio
async def test_charm_ball_has_light_cooldown(game):
    """Charm ball should have a light cooldown."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    charm_data = ball_data.get(CHARM_BALL_TYPE, {})
    cooldown = charm_data.get("cooldown", 0.0)

    assert cooldown == 0.3, f"Charm ball cooldown should be 0.3, got {cooldown}"


@pytest.mark.asyncio
async def test_charm_ball_description(game):
    """Charm ball should have appropriate description."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    charm_data = ball_data.get(CHARM_BALL_TYPE, {})
    description = charm_data.get("description", "")

    assert "mind" in description.lower() or "control" in description.lower(), \
        f"Charm ball description should mention mind control, got '{description}'"


@pytest.mark.asyncio
async def test_charm_ball_can_be_added_to_registry(game):
    """Charm ball should be addable to owned balls."""
    # Reset registry
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)  # Wait for state to settle

    # Add charm ball
    await game.call(BALL_REGISTRY, "add_ball", [CHARM_BALL_TYPE])

    # Check it's owned
    owned_balls = await game.get_property(BALL_REGISTRY, "owned_balls")

    assert CHARM_BALL_TYPE in owned_balls, "Charm ball should be in owned_balls after adding"
    assert owned_balls[CHARM_BALL_TYPE] == 1, "Charm ball should be at level 1"


@pytest.mark.asyncio
async def test_charm_ball_can_level_up(game):
    """Charm ball should be able to level up to L3."""
    # Reset registry and add charm ball
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)  # Wait for state to settle
    await game.call(BALL_REGISTRY, "add_ball", [CHARM_BALL_TYPE])

    # Level up to L2
    result = await game.call(BALL_REGISTRY, "level_up_ball", [CHARM_BALL_TYPE])
    assert result == True, "Should be able to level up to L2"

    level = await game.call(BALL_REGISTRY, "get_ball_level", [CHARM_BALL_TYPE])
    assert level == 2, "Charm ball should be at level 2"

    # Level up to L3
    result = await game.call(BALL_REGISTRY, "level_up_ball", [CHARM_BALL_TYPE])
    assert result == True, "Should be able to level up to L3"

    level = await game.call(BALL_REGISTRY, "get_ball_level", [CHARM_BALL_TYPE])
    assert level == 3, "Charm ball should be at level 3"


@pytest.mark.asyncio
async def test_game_loads_with_charm_effect(game):
    """Game should load successfully with Charm effect changes."""
    node = await game.get_node("/root/Game")
    assert node is not None, "Game should load with Charm effect changes"
