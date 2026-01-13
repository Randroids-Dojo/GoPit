"""Tests for aim sensitivity setting in options menu."""
import asyncio
import pytest

SOUND_MANAGER = "/root/SoundManager"
PAUSE_OVERLAY = "/root/Game/UI/PauseOverlay"
SENSITIVITY_SLIDER = "/root/Game/UI/PauseOverlay/DimBackground/Panel/VBoxContainer/SensitivityContainer/SensitivitySlider"
SENSITIVITY_VALUE = "/root/Game/UI/PauseOverlay/DimBackground/Panel/VBoxContainer/SensitivityContainer/SensitivityValue"


@pytest.mark.asyncio
async def test_aim_sensitivity_methods_exist(game):
    """SoundManager should have aim sensitivity methods."""
    has_get = await game.call(SOUND_MANAGER, "has_method", ["get_aim_sensitivity"])
    has_set = await game.call(SOUND_MANAGER, "has_method", ["set_aim_sensitivity"])
    assert has_get, "SoundManager should have get_aim_sensitivity method"
    assert has_set, "SoundManager should have set_aim_sensitivity method"


@pytest.mark.asyncio
async def test_aim_sensitivity_default_value(game):
    """Aim sensitivity should default to 1.0."""
    # Reset to default
    await game.call(SOUND_MANAGER, "set_aim_sensitivity", [1.0])
    value = await game.call(SOUND_MANAGER, "get_aim_sensitivity")
    assert value == 1.0, f"Default aim sensitivity should be 1.0, got {value}"


@pytest.mark.asyncio
async def test_aim_sensitivity_clamps_minimum(game):
    """Aim sensitivity should clamp to minimum 0.25."""
    await game.call(SOUND_MANAGER, "set_aim_sensitivity", [0.1])
    value = await game.call(SOUND_MANAGER, "get_aim_sensitivity")
    assert value == 0.25, f"Sensitivity should clamp to 0.25, got {value}"


@pytest.mark.asyncio
async def test_aim_sensitivity_clamps_maximum(game):
    """Aim sensitivity should clamp to maximum 2.0."""
    await game.call(SOUND_MANAGER, "set_aim_sensitivity", [5.0])
    value = await game.call(SOUND_MANAGER, "get_aim_sensitivity")
    assert value == 2.0, f"Sensitivity should clamp to 2.0, got {value}"


@pytest.mark.asyncio
async def test_aim_sensitivity_valid_values(game):
    """Aim sensitivity should accept valid values."""
    test_values = [0.25, 0.5, 1.0, 1.5, 2.0]
    for test_val in test_values:
        await game.call(SOUND_MANAGER, "set_aim_sensitivity", [test_val])
        value = await game.call(SOUND_MANAGER, "get_aim_sensitivity")
        assert value == test_val, f"Sensitivity should be {test_val}, got {value}"
    # Reset to default
    await game.call(SOUND_MANAGER, "set_aim_sensitivity", [1.0])


@pytest.mark.asyncio
async def test_sensitivity_slider_exists(game):
    """Sensitivity slider should exist in pause overlay."""
    node = await game.get_node(SENSITIVITY_SLIDER)
    assert node is not None, "Sensitivity slider should exist in pause overlay"


@pytest.mark.asyncio
async def test_sensitivity_value_label_exists(game):
    """Sensitivity value label should exist in pause overlay."""
    node = await game.get_node(SENSITIVITY_VALUE)
    assert node is not None, "Sensitivity value label should exist in pause overlay"


@pytest.mark.asyncio
async def test_sensitivity_slider_range(game):
    """Sensitivity slider should have correct range."""
    min_val = await game.get_property(SENSITIVITY_SLIDER, "min_value")
    max_val = await game.get_property(SENSITIVITY_SLIDER, "max_value")
    assert min_val == 0.25, f"Slider min should be 0.25, got {min_val}"
    assert max_val == 2.0, f"Slider max should be 2.0, got {max_val}"
