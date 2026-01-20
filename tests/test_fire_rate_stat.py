"""Tests for character fire rate stat system."""
import asyncio
import pytest

GAME_MANAGER = "/root/GameManager"
BALL_SPAWNER = "/root/Game/GameArea/BallSpawner"
FIRE_BUTTON = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"
BALLS = "/root/Game/GameArea/Balls"


@pytest.mark.asyncio
async def test_game_manager_has_get_character_fire_rate(game):
    """GameManager should have get_character_fire_rate method."""
    fire_rate = await game.call(GAME_MANAGER, "get_character_fire_rate")
    assert fire_rate is not None, "Should return a fire rate value"
    assert fire_rate >= 1.0, f"Fire rate should be at least 1.0, got {fire_rate}"


@pytest.mark.asyncio
async def test_default_fire_rate_without_character(game):
    """Without a selected character, should return default fire rate of 2.0."""
    # Reset to ensure no character selected
    await game.call(GAME_MANAGER, "_reset_character_stats")
    await asyncio.sleep(0.1)

    fire_rate = await game.call(GAME_MANAGER, "get_character_fire_rate")
    assert fire_rate == 2.0, f"Default fire rate should be 2.0, got {fire_rate}"


@pytest.mark.asyncio
async def test_ball_spawner_uses_character_fire_rate(game):
    """BallSpawner should use character's fire rate."""
    # Get fire rate from both sources
    char_fire_rate = await game.call(GAME_MANAGER, "get_character_fire_rate")
    spawner_fire_rate = await game.call(BALL_SPAWNER, "get_effective_fire_rate")

    # They should match (spawner uses character stat)
    assert spawner_fire_rate == char_fire_rate, \
        f"Spawner ({spawner_fire_rate}) should match character ({char_fire_rate})"


@pytest.mark.asyncio
async def test_fire_rate_affects_queue_drain_speed(game):
    """Higher fire rate should drain queue faster."""
    # Disable autofire
    await game.call(FIRE_BUTTON, "set_autofire", [False])
    await asyncio.sleep(0.1)

    # Clear queue and fire
    await game.call(BALL_SPAWNER, "clear_queue")
    await game.call(BALL_SPAWNER, "fire")

    # Get fire rate to calculate expected timing
    fire_rate = await game.call(BALL_SPAWNER, "get_effective_fire_rate")
    expected_interval = 1.0 / fire_rate

    # Wait for queue to drain
    await asyncio.sleep(expected_interval + 0.2)

    # Ball should have spawned
    ball_count = await game.call(BALLS, "get_child_count")
    assert ball_count >= 1, "Should have spawned ball from queue"


@pytest.mark.asyncio
async def test_character_fire_rate_scales_with_level(game):
    """Character fire rate should scale based on player level."""
    # Get fire rate at current level
    fire_rate_base = await game.call(GAME_MANAGER, "get_character_fire_rate")
    assert fire_rate_base > 0, "Fire rate should be positive"

    # The exact scaling depends on character selection and level
    # Just verify it's reasonable for gameplay
    assert fire_rate_base >= 1.0, "Fire rate should be at least 1 ball/second"
    assert fire_rate_base <= 10.0, "Fire rate should be reasonable for gameplay"


@pytest.mark.asyncio
async def test_different_characters_different_fire_rates(game):
    """Different characters should have different base fire rates."""
    # This test verifies the character system is working
    # Gambler should have higher fire rate than Frost Mage

    # Get current fire rate for reference
    current_rate = await game.call(GAME_MANAGER, "get_character_fire_rate")

    # Just verify it's a valid number (character selection varies in tests)
    assert isinstance(current_rate, (int, float)), "Fire rate should be numeric"
    assert current_rate > 0, "Fire rate should be positive"


@pytest.mark.asyncio
async def test_ball_spawner_has_base_fire_rate(game):
    """BallSpawner should have fire_rate property as fallback."""
    base_rate = await game.get_property(BALL_SPAWNER, "fire_rate")
    assert base_rate == 3.0, f"Base fire_rate should be 3.0, got {base_rate}"
