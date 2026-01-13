"""Tests for the Cell ball type (clones on bounce)."""
import asyncio
import pytest

# Ball Registry paths
BALL_REGISTRY = "BallRegistry"

# Cell ball type (16th in enum, 0-indexed = 15)
CELL_BALL_TYPE = 15


@pytest.mark.asyncio
async def test_cell_ball_exists_in_registry(game):
    """Cell ball type should exist in BallRegistry.BallType enum."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    assert CELL_BALL_TYPE in ball_data, "Cell ball type should exist in BALL_DATA"


@pytest.mark.asyncio
async def test_cell_ball_has_correct_name(game):
    """Cell ball should have the correct name."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    cell_data = ball_data.get(CELL_BALL_TYPE, {})
    assert cell_data.get("name") == "Cell", f"Cell ball name should be 'Cell', got {cell_data.get('name')}"


@pytest.mark.asyncio
async def test_cell_ball_has_clone_effect(game):
    """Cell ball should have 'cell' effect."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    cell_data = ball_data.get(CELL_BALL_TYPE, {})
    assert cell_data.get("effect") == "cell", f"Cell ball effect should be 'cell', got {cell_data.get('effect')}"


@pytest.mark.asyncio
async def test_cell_ball_has_teal_color(game):
    """Cell ball should have teal/aqua color."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    cell_data = ball_data.get(CELL_BALL_TYPE, {})
    color = cell_data.get("color", {})

    # Color(0.2, 0.8, 0.7) - teal/aqua
    # Colors come back as dicts with r, g, b, a keys
    if isinstance(color, dict):
        assert abs(color.get("r", 0) - 0.2) < 0.01, f"Cell ball red should be ~0.2, got {color.get('r')}"
        assert abs(color.get("g", 0) - 0.8) < 0.01, f"Cell ball green should be ~0.8, got {color.get('g')}"
        assert abs(color.get("b", 0) - 0.7) < 0.01, f"Cell ball blue should be ~0.7, got {color.get('b')}"


@pytest.mark.asyncio
async def test_cell_ball_has_reduced_damage(game):
    """Cell ball should have moderate base damage (balances cloning)."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    cell_data = ball_data.get(CELL_BALL_TYPE, {})
    base_damage = cell_data.get("base_damage", 0)

    assert base_damage == 6, f"Cell ball base_damage should be 6, got {base_damage}"


@pytest.mark.asyncio
async def test_cell_ball_has_slower_speed(game):
    """Cell ball should be slightly slower (0.9x speed)."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    cell_data = ball_data.get(CELL_BALL_TYPE, {})
    speed_mult = cell_data.get("speed_multiplier", 1.0)

    assert abs(speed_mult - 0.9) < 0.01, f"Cell ball speed_multiplier should be 0.9, got {speed_mult}"


@pytest.mark.asyncio
async def test_cell_ball_has_cooldown(game):
    """Cell ball should have a cooldown to balance cloning."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    cell_data = ball_data.get(CELL_BALL_TYPE, {})
    cooldown = cell_data.get("cooldown", 0.0)

    assert cooldown == 0.4, f"Cell ball cooldown should be 0.4, got {cooldown}"


@pytest.mark.asyncio
async def test_cell_ball_description(game):
    """Cell ball should have appropriate description."""
    ball_data = await game.get_property(BALL_REGISTRY, "BALL_DATA")

    cell_data = ball_data.get(CELL_BALL_TYPE, {})
    description = cell_data.get("description", "")

    assert "clone" in description.lower() or "bounce" in description.lower(), \
        f"Cell ball description should mention cloning/bouncing, got '{description}'"


@pytest.mark.asyncio
async def test_cell_ball_can_be_added_to_registry(game):
    """Cell ball should be addable to owned balls."""
    # Reset registry
    await game.call(BALL_REGISTRY, "reset")

    # Add cell ball
    await game.call(BALL_REGISTRY, "add_ball", [CELL_BALL_TYPE])

    # Check it's owned
    owned_balls = await game.get_property(BALL_REGISTRY, "owned_balls")

    assert CELL_BALL_TYPE in owned_balls, "Cell ball should be in owned_balls after adding"
    assert owned_balls[CELL_BALL_TYPE] == 1, "Cell ball should be at level 1"


@pytest.mark.asyncio
async def test_cell_ball_can_level_up(game):
    """Cell ball should be able to level up to L3."""
    # Reset registry and add cell ball
    await game.call(BALL_REGISTRY, "reset")
    await game.call(BALL_REGISTRY, "add_ball", [CELL_BALL_TYPE])

    # Level up to L2
    result = await game.call(BALL_REGISTRY, "level_up_ball", [CELL_BALL_TYPE])
    assert result == True, "Should be able to level up to L2"

    level = await game.call(BALL_REGISTRY, "get_ball_level", [CELL_BALL_TYPE])
    assert level == 2, "Cell ball should be at level 2"

    # Level up to L3
    result = await game.call(BALL_REGISTRY, "level_up_ball", [CELL_BALL_TYPE])
    assert result == True, "Should be able to level up to L3"

    level = await game.call(BALL_REGISTRY, "get_ball_level", [CELL_BALL_TYPE])
    assert level == 3, "Cell ball should be at level 3"


@pytest.mark.asyncio
async def test_cell_ball_speed_calculation(game):
    """Cell ball speed should use correct formula: BASE × 0.9 × level_mult."""
    # Reset registry and add cell ball
    await game.call(BALL_REGISTRY, "reset")
    await game.call(BALL_REGISTRY, "add_ball", [CELL_BALL_TYPE])

    # L1: 800 × 0.9 × 1.0 = 720
    speed = await game.call(BALL_REGISTRY, "get_speed", [CELL_BALL_TYPE])
    assert speed == 720.0, f"Cell L1 speed should be 720, got {speed}"

    # Level up to L2
    await game.call(BALL_REGISTRY, "level_up_ball", [CELL_BALL_TYPE])

    # L2: 800 × 0.9 × 1.5 = 1080
    speed = await game.call(BALL_REGISTRY, "get_speed", [CELL_BALL_TYPE])
    assert speed == 1080.0, f"Cell L2 speed should be 1080, got {speed}"


@pytest.mark.asyncio
async def test_game_loads_with_cell_ball(game):
    """Game should load successfully with Cell ball type changes."""
    node = await game.get_node("/root/Game")
    assert node is not None, "Game should load with Cell ball type changes"
