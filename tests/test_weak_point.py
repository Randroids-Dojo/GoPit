"""Tests for boss weak point system (Slime King crown = 2x damage)."""
import asyncio
import pytest

GAME = "/root/Game"
ENEMIES_CONTAINER = "/root/Game/GameArea/Enemies"


async def spawn_and_wait_for_boss(game):
    """Spawn a test boss and wait for it to be ready. Returns boss path."""
    boss_path = await game.call(GAME, "spawn_test_boss")
    assert boss_path, "spawn_test_boss should return a valid path"
    # Wait for intro animation to complete (intro_duration = 2.0 seconds)
    # Boss is invulnerable during intro phase
    await asyncio.sleep(2.5)
    return boss_path


@pytest.mark.asyncio
async def test_slime_king_has_weak_point_method(game):
    """Slime King should have take_damage_at_position method for weak point detection."""
    boss = await spawn_and_wait_for_boss(game)

    # Check the method exists
    has_method = await game.call(boss, "has_method", ["take_damage_at_position"])
    assert has_method, "Slime King should have take_damage_at_position method"

    # Clean up
    await game.call(boss, "queue_free")


@pytest.mark.asyncio
async def test_weak_point_multiplier_constant(game):
    """Slime King should have WEAK_POINT_MULTIPLIER = 2.0."""
    boss = await spawn_and_wait_for_boss(game)

    # Check the multiplier constant
    multiplier = await game.get_property(boss, "WEAK_POINT_MULTIPLIER")
    assert multiplier == 2.0, f"WEAK_POINT_MULTIPLIER should be 2.0, got {multiplier}"

    # Clean up
    await game.call(boss, "queue_free")


@pytest.mark.asyncio
async def test_crown_hit_detection(game):
    """Crown area should be detected as weak point (2x damage)."""
    boss = await spawn_and_wait_for_boss(game)

    # Get boss position and body_radius
    pos = await game.get_property(boss, "global_position")
    body_radius = await game.get_property(boss, "body_radius")

    # Crown is at top of boss (negative Y offset in local coords)
    # Crown area: y from -body_radius*0.5 to -body_radius*0.5-30
    crown_y = pos['y'] - body_radius * 0.5 - 15  # Middle of crown area

    # Test hitting crown area - should trigger weak point
    hp_before = await game.get_property(boss, "hp")
    test_damage = 50

    # Call take_damage_at_position_xy with coordinates
    await game.call(boss, "take_damage_at_position_xy", [test_damage, pos['x'], crown_y])

    hp_after = await game.get_property(boss, "hp")
    actual_damage = hp_before - hp_after

    # Should deal 2x damage for crown hit
    expected_damage = test_damage * 2
    assert actual_damage == expected_damage, \
        f"Crown hit should deal {expected_damage} damage (2x), got {actual_damage}"

    # Clean up
    await game.call(boss, "queue_free")


@pytest.mark.asyncio
async def test_body_hit_normal_damage(game):
    """Body area should deal normal damage (not 2x)."""
    boss = await spawn_and_wait_for_boss(game)

    # Get boss position
    pos = await game.get_property(boss, "global_position")

    # Body center (y = 0 in local coords)
    body_y = pos['y']

    # Test hitting body area - should NOT trigger weak point
    hp_before = await game.get_property(boss, "hp")
    test_damage = 50

    await game.call(boss, "take_damage_at_position_xy", [test_damage, pos['x'], body_y])

    hp_after = await game.get_property(boss, "hp")
    actual_damage = hp_before - hp_after

    # Should deal normal damage for body hit
    assert actual_damage == test_damage, \
        f"Body hit should deal {test_damage} damage (1x), got {actual_damage}"

    # Clean up
    await game.call(boss, "queue_free")


@pytest.mark.asyncio
async def test_body_radius_default(game):
    """Slime King should have body_radius = 60."""
    boss = await spawn_and_wait_for_boss(game)

    body_radius = await game.get_property(boss, "body_radius")
    assert body_radius == 60.0, f"body_radius should be 60.0, got {body_radius}"

    await game.call(boss, "queue_free")


@pytest.mark.asyncio
async def test_crown_color_export(game):
    """Slime King should have crown_color property (gold by default)."""
    boss = await spawn_and_wait_for_boss(game)

    crown_color = await game.get_property(boss, "crown_color")
    # Gold color: Color(1.0, 0.85, 0.1)
    assert crown_color is not None, "crown_color should exist"

    await game.call(boss, "queue_free")
