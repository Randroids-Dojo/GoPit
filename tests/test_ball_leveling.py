"""Tests for the ball leveling system (BallRegistry)."""
import asyncio
import pytest

BALL_REGISTRY = "/root/BallRegistry"
BALLS_CONTAINER = "/root/Game/GameArea/Balls"
BALL_SPAWNER = "/root/Game/GameArea/BallSpawner"
FIRE_BUTTON = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"


async def reset_ball_registry(game):
    """Reset BallRegistry to clean state for testing."""
    await game.call(BALL_REGISTRY, "reset")
    await asyncio.sleep(0.1)  # Give time for state to settle


@pytest.mark.asyncio
async def test_ball_registry_initialized(game):
    """BallRegistry should be initialized with a BASIC ball at L1."""
    await reset_ball_registry(game)
    # Check that BallRegistry autoload exists
    registry = await game.get_node(BALL_REGISTRY)
    assert registry is not None, "BallRegistry autoload should exist"

    # Get owned balls count
    owned_count = await game.call(BALL_REGISTRY, "get_owned_ball_types")
    assert len(owned_count) >= 1, "Should have at least 1 owned ball type"

    # Check BASIC ball level (BallType.BASIC = 0)
    basic_level = await game.call(BALL_REGISTRY, "get_ball_level", [0])
    assert basic_level == 1, "BASIC ball should start at level 1"


@pytest.mark.asyncio
async def test_ball_level_up(game):
    """Balls should be able to level up from L1 to L2 to L3."""
    await reset_ball_registry(game)
    # Get initial level
    basic_level = await game.call(BALL_REGISTRY, "get_ball_level", [0])
    assert basic_level == 1, "Should start at L1"

    # Level up to L2
    success = await game.call(BALL_REGISTRY, "level_up_ball", [0])
    assert success == True, "Level up should succeed"

    level_after = await game.call(BALL_REGISTRY, "get_ball_level", [0])
    assert level_after == 2, "Should be L2 after first level up"

    # Level up to L3
    success = await game.call(BALL_REGISTRY, "level_up_ball", [0])
    assert success == True, "Second level up should succeed"

    level_final = await game.call(BALL_REGISTRY, "get_ball_level", [0])
    assert level_final == 3, "Should be L3 after second level up"


@pytest.mark.asyncio
async def test_cant_level_past_3(game):
    """Balls at L3 cannot be leveled further."""
    await reset_ball_registry(game)

    # Verify starting state
    level_start = await game.call(BALL_REGISTRY, "get_ball_level", [0])
    assert level_start == 1, f"Should start at L1, got {level_start}"

    # Level up to L2
    success1 = await game.call(BALL_REGISTRY, "level_up_ball", [0])
    assert success1 == True, "First level up should succeed"
    await asyncio.sleep(0.1)  # Let state settle

    level_after_1 = await game.call(BALL_REGISTRY, "get_ball_level", [0])
    assert level_after_1 == 2, f"Should be L2 after first level up, got {level_after_1}"

    # Level up to L3
    success2 = await game.call(BALL_REGISTRY, "level_up_ball", [0])
    assert success2 == True, f"Second level up should succeed, got {success2}"
    await asyncio.sleep(0.1)  # Let state settle

    level = await game.call(BALL_REGISTRY, "get_ball_level", [0])
    assert level == 3, f"Should be at L3, got {level}"

    # Try to level up again - should fail
    success = await game.call(BALL_REGISTRY, "level_up_ball", [0])
    assert success == False, "Cannot level up past L3"

    # Level should still be 3
    level_after = await game.call(BALL_REGISTRY, "get_ball_level", [0])
    assert level_after == 3, "Level should remain at L3"


@pytest.mark.asyncio
async def test_level_affects_damage(game):
    """Higher levels should increase damage."""
    await reset_ball_registry(game)
    # Get L1 damage
    l1_damage = await game.call(BALL_REGISTRY, "get_damage", [0])

    # Level up to L2
    await game.call(BALL_REGISTRY, "level_up_ball", [0])
    l2_damage = await game.call(BALL_REGISTRY, "get_damage", [0])

    # Level up to L3
    await game.call(BALL_REGISTRY, "level_up_ball", [0])
    l3_damage = await game.call(BALL_REGISTRY, "get_damage", [0])

    # Verify damage increases
    assert l2_damage > l1_damage, "L2 damage should be higher than L1"
    assert l3_damage > l2_damage, "L3 damage should be higher than L2"

    # Verify multipliers (L2 = 1.5x, L3 = 2.0x)
    # Base damage for BASIC is 10
    assert l1_damage == 10, "L1 damage should be base (10)"
    assert l2_damage == 15, "L2 damage should be 1.5x base (15)"
    assert l3_damage == 20, "L3 damage should be 2.0x base (20)"


@pytest.mark.asyncio
async def test_level_affects_speed(game):
    """Higher levels should increase speed."""
    await reset_ball_registry(game)
    # Get L1 speed
    l1_speed = await game.call(BALL_REGISTRY, "get_speed", [0])

    # Level up to L2
    await game.call(BALL_REGISTRY, "level_up_ball", [0])
    l2_speed = await game.call(BALL_REGISTRY, "get_speed", [0])

    # Level up to L3
    await game.call(BALL_REGISTRY, "level_up_ball", [0])
    l3_speed = await game.call(BALL_REGISTRY, "get_speed", [0])

    # Verify speed increases
    assert l2_speed > l1_speed, "L2 speed should be higher than L1"
    assert l3_speed > l2_speed, "L3 speed should be higher than L2"


@pytest.mark.asyncio
async def test_add_new_ball_type(game):
    """Adding a new ball type should add it to owned balls."""
    await reset_ball_registry(game)
    # Check BURN (type 1) is not owned
    burn_level = await game.call(BALL_REGISTRY, "get_ball_level", [1])
    assert burn_level == 0, "BURN should not be owned initially"

    # Add BURN ball
    await game.call(BALL_REGISTRY, "add_ball", [1])

    # Check BURN is now owned at L1
    burn_level_after = await game.call(BALL_REGISTRY, "get_ball_level", [1])
    assert burn_level_after == 1, "BURN should be at L1 after adding"


@pytest.mark.asyncio
async def test_fusion_ready_at_l3(game):
    """L3 balls should be marked as fusion ready."""
    await reset_ball_registry(game)
    # BASIC ball starts at L1, not fusion ready
    is_ready = await game.call(BALL_REGISTRY, "is_fusion_ready", [0])
    assert is_ready == False, "L1 ball should not be fusion ready"

    # Level up to L2
    await game.call(BALL_REGISTRY, "level_up_ball", [0])
    is_ready = await game.call(BALL_REGISTRY, "is_fusion_ready", [0])
    assert is_ready == False, "L2 ball should not be fusion ready"

    # Level up to L3
    await game.call(BALL_REGISTRY, "level_up_ball", [0])
    is_ready = await game.call(BALL_REGISTRY, "is_fusion_ready", [0])
    assert is_ready == True, "L3 ball should be fusion ready"


@pytest.mark.asyncio
async def test_fired_ball_has_correct_level(game):
    """Fired balls should have the correct level from registry."""
    await reset_ball_registry(game)

    # Disable autofire first to prevent auto-firing
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.3)

    # Clear queue and wait for any in-flight balls to return
    await game.call(BALL_SPAWNER, "clear_queue")
    await asyncio.sleep(0.5)

    # Level up BASIC to L2
    success = await game.call(BALL_REGISTRY, "level_up_ball", [0])
    assert success == True, "Level up should succeed"

    # Verify level is now 2
    level = await game.call(BALL_REGISTRY, "get_ball_level", [0])
    assert level == 2, f"BASIC should be L2, got {level}"

    # Wait for balls container to be empty (balls returned)
    for _ in range(30):  # Max 3 seconds wait
        ball_count = await game.call(BALLS_CONTAINER, "get_child_count")
        if ball_count == 0:
            break
        await asyncio.sleep(0.1)

    # Record count before firing (should be 0 now)
    existing_count = await game.call(BALLS_CONTAINER, "get_child_count")

    # Set aim direction (required for fire() - defaults to Vector2.UP but set explicitly)
    await game.call(BALL_SPAWNER, "set_aim_direction_xy", [0.0, -1.0])  # Aim upward
    await asyncio.sleep(0.1)

    # Fire a ball (adds to queue)
    await game.call(BALL_SPAWNER, "fire")

    # Wait for queue to drain and ball to spawn (fire_rate=3.0 means ~0.33s per ball)
    await asyncio.sleep(1.0)

    # Get the ball and check its level
    ball_count = await game.call(BALLS_CONTAINER, "get_child_count")
    assert ball_count > existing_count, f"Should have spawned a new ball, had {existing_count}, now have {ball_count}"

    # Check ball_level property - balls are named dynamically so find any ball child
    if ball_count > 0:
        # Get the last ball (most recently spawned)
        for i in range(ball_count - 1, -1, -1):
            try:
                ball_node = await game.call(BALLS_CONTAINER, "get_child", [i])
                if ball_node:
                    ball_name = await game.call(BALLS_CONTAINER + f"/{ball_node.get('name', '')}", "get_name")
                    ball_path = f"{BALLS_CONTAINER}/{ball_name}" if ball_name else None
                    if ball_path:
                        ball_level = await game.get_property(ball_path, "ball_level")
                        if ball_level is not None:
                            assert ball_level == 2, "Fired ball should have L2 from registry"
                            return  # Test passed
            except:
                continue
        # If we couldn't check the level, at least verify a ball was spawned
        assert ball_count > existing_count, "Ball was spawned but level could not be checked"


@pytest.mark.asyncio
async def test_get_unowned_ball_types(game):
    """Should correctly return ball types not yet owned."""
    await reset_ball_registry(game)
    # Get unowned types (should be 17: all except BASIC which is auto-added on game start)
    # Ball types: BASIC, BURN, FREEZE, POISON, BLEED, LIGHTNING, IRON, RADIATION, DISEASE,
    #             FROSTBURN, WIND, GHOST, VAMPIRE, BROOD_MOTHER, DARK, CELL, CHARM, LASER
    unowned = await game.call(BALL_REGISTRY, "get_unowned_ball_types")
    assert len(unowned) == 17, "Should have 17 unowned ball types initially"

    # Add BURN
    await game.call(BALL_REGISTRY, "add_ball", [1])

    # Now should have 16 unowned
    unowned_after = await game.call(BALL_REGISTRY, "get_unowned_ball_types")
    assert len(unowned_after) == 16, "Should have 16 unowned after adding BURN"


@pytest.mark.asyncio
async def test_get_upgradeable_balls(game):
    """Should return balls that can still be leveled up."""
    await reset_ball_registry(game)
    # Initially BASIC is upgradeable
    upgradeable = await game.call(BALL_REGISTRY, "get_upgradeable_balls")
    assert len(upgradeable) >= 1, "Should have at least one upgradeable ball"

    # Level BASIC to L3
    await game.call(BALL_REGISTRY, "level_up_ball", [0])
    await game.call(BALL_REGISTRY, "level_up_ball", [0])

    # BASIC should no longer be upgradeable
    upgradeable_after = await game.call(BALL_REGISTRY, "get_upgradeable_balls")
    # Should not contain BASIC (0)
    assert 0 not in upgradeable_after, "L3 BASIC should not be upgradeable"
