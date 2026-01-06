"""Tests for autofire toggle system."""

import asyncio
import pytest


@pytest.mark.asyncio
async def test_autofire_initially_disabled(game):
    """Test that autofire is disabled by default."""
    fire_btn = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"

    autofire = await game.get_property(fire_btn, "autofire_enabled")
    assert autofire is False, "Autofire should be disabled by default"


@pytest.mark.asyncio
async def test_toggle_autofire_method(game):
    """Test that toggle_autofire method toggles the state."""
    fire_btn = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"

    # Initially off
    autofire = await game.get_property(fire_btn, "autofire_enabled")
    assert autofire is False

    # Toggle on
    await game.call(fire_btn, "toggle_autofire")
    autofire = await game.get_property(fire_btn, "autofire_enabled")
    assert autofire is True, "Autofire should be enabled after toggle"

    # Toggle off
    await game.call(fire_btn, "toggle_autofire")
    autofire = await game.get_property(fire_btn, "autofire_enabled")
    assert autofire is False, "Autofire should be disabled after second toggle"


@pytest.mark.asyncio
async def test_set_autofire_method(game):
    """Test that set_autofire method sets specific state."""
    fire_btn = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"

    # Set to true
    await game.call(fire_btn, "set_autofire", [True])
    autofire = await game.get_property(fire_btn, "autofire_enabled")
    assert autofire is True

    # Set to false
    await game.call(fire_btn, "set_autofire", [False])
    autofire = await game.get_property(fire_btn, "autofire_enabled")
    assert autofire is False


@pytest.mark.asyncio
async def test_autofire_fires_automatically(game):
    """Test that balls are fired automatically when autofire is enabled."""
    fire_btn = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"
    balls_container = "/root/Game/GameArea/Balls"

    # Get initial ball count
    initial_count = await game.call(balls_container, "get_child_count")

    # Enable autofire
    await game.call(fire_btn, "set_autofire", [True])

    # Wait for autofire to fire some balls (cooldown is 0.5s)
    await asyncio.sleep(1.2)

    # Check ball count increased
    final_count = await game.call(balls_container, "get_child_count")
    assert final_count > initial_count, f"Autofire should spawn balls. Initial: {initial_count}, Final: {final_count}"

    # Disable autofire for cleanup
    await game.call(fire_btn, "set_autofire", [False])


@pytest.mark.asyncio
async def test_auto_toggle_button_exists(game):
    """Test that the AUTO toggle button exists in HUD."""
    auto_btn = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/AutoToggle"

    # Check button exists by getting its text
    text = await game.get_property(auto_btn, "text")
    assert text == "AUTO", f"Button text should be 'AUTO', got '{text}'"


@pytest.mark.asyncio
async def test_fire_button_has_required_properties(game):
    """Test that fire button has all required autofire properties."""
    fire_btn = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"

    # Check autofire_enabled property exists
    autofire = await game.get_property(fire_btn, "autofire_enabled")
    assert autofire is not None, "Fire button should have autofire_enabled property"

    # Check cooldown_duration property
    cooldown = await game.get_property(fire_btn, "cooldown_duration")
    assert cooldown == 0.5, f"Cooldown should be 0.5, got {cooldown}"
