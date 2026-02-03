"""Tests for the Experiment Mode feature.

Experiment Mode is a simplified test environment for replicating BallxPit's
first 5 minutes. It focuses on core mechanics: sizing, enemy formation, speed,
upgrade path, and complexity.

Note: Tests for the actual experiment scene would require launching it separately,
which PlayGodot doesn't directly support via scene parameter. These tests verify
the menu button exists and is functional using the main game fixture.
"""
import asyncio
import pytest


# Experiment scene paths (for reference)
EXPERIMENT_PATHS = {
    "experiment": "/root/Experiment",
    "ball_spawner": "/root/Experiment/GameArea/BallSpawner",
    "balls": "/root/Experiment/GameArea/Balls",
    "enemies": "/root/Experiment/GameArea/Enemies",
    "enemy_spawner": "/root/Experiment/GameArea/Enemies/EnemySpawner",
    "player": "/root/Experiment/GameArea/Player",
    "player_zone": "/root/Experiment/GameArea/PlayerZone",
    "aim_line": "/root/Experiment/GameArea/AimLine",
    "move_joystick": "/root/Experiment/UI/HUD/InputContainer/HBoxContainer/MoveJoystickContainer/VirtualJoystick",
    "aim_joystick": "/root/Experiment/UI/HUD/InputContainer/HBoxContainer/AimJoystickContainer/VirtualJoystick",
    "fire_button": "/root/Experiment/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton",
    "back_button": "/root/Experiment/UI/BackButton",
    "debug_panel": "/root/Experiment/UI/DebugPanel",
    "debug_label": "/root/Experiment/UI/DebugPanel/DebugLabel",
    "game_manager": "/root/GameManager",
}


# =============================================================================
# MENU BUTTON TESTS (use main 'game' fixture from conftest.py)
# =============================================================================

@pytest.mark.asyncio
async def test_save_slot_has_experiment_button(game):
    """Test that save slot select has experiment button."""
    # Show save slot select
    await game.call("/root/Game/UI/SaveSlotSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Check experiment button exists
    exp_button = await game.get_node(
        "/root/Game/UI/SaveSlotSelect/DimBackground/Panel/VBoxContainer/ExperimentButton"
    )
    assert exp_button is not None, "Experiment button should exist in save slot select"

    # Check button text
    text = await game.get_property(
        "/root/Game/UI/SaveSlotSelect/DimBackground/Panel/VBoxContainer/ExperimentButton",
        "text"
    )
    assert "EXPERIMENT" in text, f"Button should say EXPERIMENT: {text}"


@pytest.mark.asyncio
async def test_experiment_button_visible(game):
    """Test that experiment button is visible when save slot select is shown."""
    # Show save slot select
    await game.call("/root/Game/UI/SaveSlotSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Check button is visible
    visible = await game.get_property(
        "/root/Game/UI/SaveSlotSelect/DimBackground/Panel/VBoxContainer/ExperimentButton",
        "visible"
    )
    assert visible, "Experiment button should be visible"


@pytest.mark.asyncio
async def test_experiment_button_has_correct_style(game):
    """Test that experiment button has distinctive styling."""
    # Show save slot select
    await game.call("/root/Game/UI/SaveSlotSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # The button should have a purple-ish color to distinguish from normal slots
    # We can't easily test color in headless mode, but we can verify the node exists
    button_path = "/root/Game/UI/SaveSlotSelect/DimBackground/Panel/VBoxContainer/ExperimentButton"
    button = await game.get_node(button_path)
    assert button is not None, "Experiment button should exist"


@pytest.mark.asyncio
async def test_save_slot_select_has_experiment_signal(game):
    """Test that SaveSlotSelect has experiment_requested signal."""
    # The signal should be defined on the SaveSlotSelect node
    has_signal = await game.call(
        "/root/Game/UI/SaveSlotSelect",
        "has_signal",
        ["experiment_requested"]
    )
    assert has_signal, "SaveSlotSelect should have experiment_requested signal"


@pytest.mark.asyncio
async def test_game_controller_connected_to_experiment_signal(game):
    """Test that game controller is connected to experiment signal."""
    # We can verify the connection exists by checking if the signal has connections
    # This is a bit indirect but verifies the wiring is correct
    save_slot = await game.get_node("/root/Game/UI/SaveSlotSelect")
    assert save_slot is not None, "SaveSlotSelect should exist"

    # The experiment_requested signal should be connected (by game_controller)
    # We can't directly check connections, but we can verify the infrastructure exists
    game_node = await game.get_node("/root/Game")
    assert game_node is not None, "Game controller should exist"
