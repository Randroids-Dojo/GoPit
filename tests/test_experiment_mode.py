"""Tests for the Experiment Mode scene.

Experiment Mode is a simplified test environment for replicating BallxPit's
first 5 minutes. It focuses on core mechanics: sizing, enemy formation, speed,
upgrade path, and complexity.
"""
import asyncio
import pytest
import pytest_asyncio
from pathlib import Path
from playgodot import Godot
from conftest import GODOT_PATH, get_playgodot_port

GODOT_PROJECT = Path(__file__).parent.parent

# Experiment scene paths
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

WAIT_TIMEOUT = 5.0


@pytest_asyncio.fixture
async def experiment():
    """Launch the experiment scene and yield the Godot connection."""
    port = get_playgodot_port()

    async with Godot.launch(
        str(GODOT_PROJECT),
        headless=True,
        resolution=(720, 1280),
        timeout=15.0,
        godot_path=GODOT_PATH,
        port=port,
        scene="res://scenes/experiment.tscn",
    ) as g:
        # Wait for the experiment scene to be ready
        await g.wait_for_node("/root/Experiment")
        await asyncio.sleep(0.3)  # Let state settle
        yield g


async def wait_for_enemy(game, timeout=WAIT_TIMEOUT):
    """Wait for at least one enemy to spawn."""
    elapsed = 0
    while elapsed < timeout:
        count = await game.call(EXPERIMENT_PATHS["enemies"], "get_child_count")
        if count > 1:  # Subtract 1 for spawner node
            return True
        await asyncio.sleep(0.1)
        elapsed += 0.1
    return False


# =============================================================================
# SCENE STRUCTURE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_experiment_scene_loads(experiment):
    """Test that the experiment scene loads correctly."""
    exp_node = await experiment.get_node(EXPERIMENT_PATHS["experiment"])
    assert exp_node is not None, "Experiment scene root should exist"


@pytest.mark.asyncio
async def test_experiment_has_game_area(experiment):
    """Test that experiment has the GameArea with essential nodes."""
    # Check Balls container
    balls = await experiment.get_node(EXPERIMENT_PATHS["balls"])
    assert balls is not None, "Balls container should exist"

    # Check Enemies container
    enemies = await experiment.get_node(EXPERIMENT_PATHS["enemies"])
    assert enemies is not None, "Enemies container should exist"

    # Check EnemySpawner
    spawner = await experiment.get_node(EXPERIMENT_PATHS["enemy_spawner"])
    assert spawner is not None, "EnemySpawner should exist"


@pytest.mark.asyncio
async def test_experiment_has_player(experiment):
    """Test that experiment has a player node."""
    player = await experiment.get_node(EXPERIMENT_PATHS["player"])
    assert player is not None, "Player should exist in experiment"

    # Check player position
    position = await experiment.get_property(EXPERIMENT_PATHS["player"], "position")
    assert position is not None, "Player should have position"
    # Player should be at bottom center (360, 900)
    assert abs(position["x"] - 360) < 10, f"Player X should be ~360, got {position['x']}"


@pytest.mark.asyncio
async def test_experiment_has_input_controls(experiment):
    """Test that experiment has input controls (joysticks, fire button)."""
    move_joystick = await experiment.get_node(EXPERIMENT_PATHS["move_joystick"])
    assert move_joystick is not None, "Move joystick should exist"

    aim_joystick = await experiment.get_node(EXPERIMENT_PATHS["aim_joystick"])
    assert aim_joystick is not None, "Aim joystick should exist"

    fire_button = await experiment.get_node(EXPERIMENT_PATHS["fire_button"])
    assert fire_button is not None, "Fire button should exist"


@pytest.mark.asyncio
async def test_experiment_has_debug_ui(experiment):
    """Test that experiment has debug overlay."""
    debug_panel = await experiment.get_node(EXPERIMENT_PATHS["debug_panel"])
    assert debug_panel is not None, "Debug panel should exist"

    debug_label = await experiment.get_node(EXPERIMENT_PATHS["debug_label"])
    assert debug_label is not None, "Debug label should exist"

    # Check debug label has text
    text = await experiment.get_property(EXPERIMENT_PATHS["debug_label"], "text")
    assert "EXPERIMENT MODE" in text, f"Debug label should show EXPERIMENT MODE: {text}"


@pytest.mark.asyncio
async def test_experiment_has_back_button(experiment):
    """Test that experiment has a back button to return to menu."""
    back_button = await experiment.get_node(EXPERIMENT_PATHS["back_button"])
    assert back_button is not None, "Back button should exist"

    text = await experiment.get_property(EXPERIMENT_PATHS["back_button"], "text")
    assert "BACK" in text, f"Back button should say BACK: {text}"


# =============================================================================
# GAME STATE TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_experiment_starts_game_state(experiment):
    """Test that experiment mode starts in PLAYING state."""
    state = await experiment.get_property(EXPERIMENT_PATHS["game_manager"], "current_state")
    assert state == 1, f"Experiment should start in PLAYING state (1), got {state}"


@pytest.mark.asyncio
async def test_experiment_starts_wave_1(experiment):
    """Test that experiment starts at wave 1."""
    wave = await experiment.get_property(EXPERIMENT_PATHS["game_manager"], "current_wave")
    assert wave == 1, f"Experiment should start at wave 1, got {wave}"


@pytest.mark.asyncio
async def test_experiment_player_full_hp(experiment):
    """Test that player starts with full HP."""
    hp = await experiment.get_property(EXPERIMENT_PATHS["game_manager"], "player_hp")
    max_hp = await experiment.get_property(EXPERIMENT_PATHS["game_manager"], "max_hp")
    assert hp == max_hp, f"Player should start with full HP ({max_hp}), got {hp}"


# =============================================================================
# ENEMY SPAWNING TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_experiment_spawns_enemies(experiment):
    """Test that experiment spawns enemies after starting."""
    # Wait for first enemy to spawn
    spawned = await wait_for_enemy(experiment, timeout=5.0)
    assert spawned, "Enemies should spawn in experiment mode"


@pytest.mark.asyncio
async def test_experiment_enemy_spawner_active(experiment):
    """Test that enemy spawner is active."""
    # The spawner should have started spawning
    is_spawning = await experiment.get_property(
        EXPERIMENT_PATHS["enemy_spawner"], "_spawning"
    )
    assert is_spawning, "Enemy spawner should be active"


# =============================================================================
# BALL SPAWNER TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_experiment_ball_spawner_configured(experiment):
    """Test that ball spawner has experiment settings applied."""
    ball_spawner = await experiment.get_node(EXPERIMENT_PATHS["ball_spawner"])
    assert ball_spawner is not None, "Ball spawner should exist"

    # Check damage is set
    damage = await experiment.get_property(EXPERIMENT_PATHS["ball_spawner"], "ball_damage")
    assert damage > 0, f"Ball damage should be set, got {damage}"


@pytest.mark.asyncio
async def test_experiment_can_fire_ball(experiment):
    """Test that player can fire a ball in experiment mode."""
    # Set aim direction first
    await experiment.call(EXPERIMENT_PATHS["ball_spawner"], "set_aim_direction", [{"x": 0, "y": -1}])
    await asyncio.sleep(0.1)

    # Fire a ball
    await experiment.call(EXPERIMENT_PATHS["ball_spawner"], "fire", [])
    await asyncio.sleep(0.3)

    # Check that a ball was spawned
    ball_count = await experiment.call(EXPERIMENT_PATHS["balls"], "get_child_count")
    assert ball_count >= 1, f"Should have fired at least one ball, got {ball_count}"


# =============================================================================
# DEBUG DISPLAY TESTS
# =============================================================================

@pytest.mark.asyncio
async def test_experiment_debug_shows_time(experiment):
    """Test that debug display shows elapsed time."""
    await asyncio.sleep(1.1)  # Wait for time to pass

    text = await experiment.get_property(EXPERIMENT_PATHS["debug_label"], "text")
    # Should show Time: 00:01 or similar
    assert "Time:" in text, f"Debug should show time: {text}"


@pytest.mark.asyncio
async def test_experiment_debug_shows_settings(experiment):
    """Test that debug display shows experiment settings."""
    text = await experiment.get_property(EXPERIMENT_PATHS["debug_label"], "text")

    # Check for key settings
    assert "Ball Speed" in text, f"Debug should show Ball Speed: {text}"
    assert "Spawn Interval" in text, f"Debug should show Spawn Interval: {text}"


@pytest.mark.asyncio
async def test_experiment_tracks_kills(experiment):
    """Test that experiment tracks enemy kills."""
    # Wait for enemy to spawn
    await wait_for_enemy(experiment, timeout=5.0)

    # Get controller to check internal state
    kills_before = await experiment.get_property(
        EXPERIMENT_PATHS["experiment"], "_enemies_killed"
    )
    assert kills_before == 0, f"Should start with 0 kills, got {kills_before}"


# =============================================================================
# MENU BUTTON TEST (Experiment button on main menu)
# These tests use the main 'game' fixture from conftest.py
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
