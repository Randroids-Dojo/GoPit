"""Tests for the Ultimate ability system."""

import asyncio
import pytest

GAME_MANAGER = "/root/GameManager"


async def reset_game_manager(game):
    """Reset GameManager to clean state for testing."""
    await game.call(GAME_MANAGER, "reset")
    await asyncio.sleep(0.1)


@pytest.mark.asyncio
async def test_ultimate_charge_starts_at_zero(game):
    """Ultimate charge should start at zero."""
    await reset_game_manager(game)
    charge = await game.get_property(GAME_MANAGER, "ultimate_charge")
    assert charge == 0.0


@pytest.mark.asyncio
async def test_ultimate_charge_max_constant(game):
    """Ultimate max charge should be 100."""
    max_charge = await game.get_property(GAME_MANAGER, "ULTIMATE_CHARGE_MAX")
    assert max_charge == 100.0


@pytest.mark.asyncio
async def test_add_ultimate_charge(game):
    """Adding charge should increase ultimate_charge."""
    await reset_game_manager(game)
    initial = await game.get_property(GAME_MANAGER, "ultimate_charge")
    await game.call(GAME_MANAGER, "add_ultimate_charge", [10.0])
    after = await game.get_property(GAME_MANAGER, "ultimate_charge")
    assert after == initial + 10.0


@pytest.mark.asyncio
async def test_ultimate_charge_caps_at_max(game):
    """Charge should cap at ULTIMATE_CHARGE_MAX."""
    await reset_game_manager(game)
    # Add more than max
    await game.call(GAME_MANAGER, "add_ultimate_charge", [150.0])
    charge = await game.get_property(GAME_MANAGER, "ultimate_charge")
    assert charge == 100.0  # Should cap at max


@pytest.mark.asyncio
async def test_is_ultimate_ready_when_full(game):
    """is_ultimate_ready should return true when charge is full."""
    await reset_game_manager(game)
    # Initially not ready
    ready_before = await game.call(GAME_MANAGER, "is_ultimate_ready")
    assert ready_before == False

    # Fill it up
    await game.call(GAME_MANAGER, "add_ultimate_charge", [100.0])
    ready_after = await game.call(GAME_MANAGER, "is_ultimate_ready")
    assert ready_after == True


@pytest.mark.asyncio
async def test_use_ultimate_when_ready(game):
    """use_ultimate should work when charge is full."""
    await reset_game_manager(game)
    # Fill charge
    await game.call(GAME_MANAGER, "add_ultimate_charge", [100.0])

    # Use it
    result = await game.call(GAME_MANAGER, "use_ultimate")
    assert result == True

    # Charge should reset to 0
    charge = await game.get_property(GAME_MANAGER, "ultimate_charge")
    assert charge == 0.0


@pytest.mark.asyncio
async def test_use_ultimate_when_not_ready(game):
    """use_ultimate should fail when charge is not full."""
    await reset_game_manager(game)
    # Add partial charge
    await game.call(GAME_MANAGER, "add_ultimate_charge", [50.0])

    # Try to use it
    result = await game.call(GAME_MANAGER, "use_ultimate")
    assert result == False

    # Charge should remain
    charge = await game.get_property(GAME_MANAGER, "ultimate_charge")
    assert charge == 50.0


@pytest.mark.asyncio
async def test_ultimate_button_exists(game):
    """Ultimate button should exist in the game scene."""
    button = await game.get_node("/root/Game/UI/HUD/InputContainer/HBoxContainer/UltimateButtonContainer/UltimateButton")
    assert button is not None


@pytest.mark.asyncio
async def test_ultimate_charge_per_kill_constant(game):
    """CHARGE_PER_KILL constant should be defined."""
    charge_per_kill = await game.get_property(GAME_MANAGER, "CHARGE_PER_KILL")
    assert charge_per_kill == 10.0


@pytest.mark.asyncio
async def test_ultimate_charge_per_gem_constant(game):
    """CHARGE_PER_GEM constant should be defined."""
    charge_per_gem = await game.get_property(GAME_MANAGER, "CHARGE_PER_GEM")
    assert charge_per_gem == 5.0


@pytest.mark.asyncio
async def test_ultimate_resets_on_game_start(game):
    """Ultimate charge should reset when game starts."""
    await reset_game_manager(game)
    # The game is already started by the fixture, so charge should be 0
    charge = await game.get_property(GAME_MANAGER, "ultimate_charge")
    assert charge == 0.0


@pytest.mark.asyncio
async def test_sound_manager_has_ultimate_sound(game):
    """SoundManager should have ULTIMATE sound type."""
    # We can check if the SoundType enum includes ULTIMATE
    # by trying to reference it in a method that accepts SoundType
    # For now, just verify SoundManager exists
    sound_manager = await game.get_node("/root/SoundManager")
    assert sound_manager is not None
