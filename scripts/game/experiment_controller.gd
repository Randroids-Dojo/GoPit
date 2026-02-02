extends Node2D
## Experiment Mode Controller
## A simplified test environment to replicate BallxPit's first 5 minutes.
## Focus: sizing, enemy formation, speed, upgrade path, complexity, core mechanics.

# Child node references
@onready var ball_spawner: Node2D = $GameArea/BallSpawner
@onready var balls_container: Node2D = $GameArea/Balls
@onready var enemies_container: Node2D = $GameArea/Enemies
@onready var enemy_spawner: Node2D = $GameArea/Enemies/EnemySpawner
@onready var player: CharacterBody2D = $GameArea/Player
@onready var player_zone: Area2D = $GameArea/PlayerZone
@onready var aim_line: Line2D = $GameArea/AimLine
@onready var move_joystick: Control = $UI/HUD/InputContainer/HBoxContainer/MoveJoystickContainer/VirtualJoystick
@onready var aim_joystick: Control = $UI/HUD/InputContainer/HBoxContainer/AimJoystickContainer/VirtualJoystick
@onready var fire_button: Control = $UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton
@onready var back_button: Button = $UI/BackButton
@onready var debug_panel: Panel = $UI/DebugPanel
@onready var debug_label: Label = $UI/DebugPanel/DebugLabel

# Experiment settings (tune these to match BallxPit)
var exp_settings := {
	# Sizing
	"game_width": 720,
	"game_height": 1280,
	"player_size": 80,
	"ball_size": 20,
	"enemy_base_size": 40,

	# Speed
	"ball_speed": 800.0,
	"enemy_descent_speed": 50.0,
	"player_move_speed": 400.0,

	# Spawning
	"spawn_interval": 3.0,
	"enemies_per_wave": 5,
	"formation_chance": 0.4,

	# Difficulty curve (first 5 minutes)
	"wave_duration": 60.0,  # seconds per wave
	"max_test_waves": 5,
}

# State tracking
var _game_active := false
var _current_wave := 1
var _enemies_killed := 0
var _elapsed_time := 0.0
var _keyboard_aim_direction := Vector2.ZERO


func _ready() -> void:
	# Set up basic connections
	if move_joystick:
		move_joystick.direction_changed.connect(_on_move_direction_changed)
		move_joystick.released.connect(_on_move_released)

	if aim_joystick:
		aim_joystick.direction_changed.connect(_on_aim_direction_changed)
		aim_joystick.released.connect(_on_aim_released)

	if fire_button:
		fire_button.fired.connect(_on_fire_pressed)

	if ball_spawner:
		ball_spawner.balls_container = balls_container
		ball_spawner.ball_caught.connect(_on_ball_caught)

	if player:
		player.position = Vector2(360, 900)
		player.moved.connect(_on_player_moved)

	if enemy_spawner and enemy_spawner.has_signal("enemy_spawned"):
		enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)

	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	# Apply experiment settings to spawner
	_apply_experiment_settings()

	# Start experiment
	_start_experiment()


func _apply_experiment_settings() -> void:
	"""Apply experimental tuning values to game systems."""
	if ball_spawner:
		# Set ball parameters
		ball_spawner.ball_damage = 10
		ball_spawner.crit_chance = 0.0

	if enemy_spawner and enemy_spawner.has_method("set_spawn_interval"):
		enemy_spawner.set_spawn_interval(exp_settings["spawn_interval"])


func _start_experiment() -> void:
	"""Start the experiment mode."""
	_game_active = true
	_current_wave = 1
	_enemies_killed = 0
	_elapsed_time = 0.0

	# Start spawning
	if enemy_spawner and enemy_spawner.has_method("start_spawning"):
		enemy_spawner.start_spawning()

	# Reset GameManager state for experiment
	GameManager.current_state = GameManager.GameState.PLAYING
	GameManager.current_wave = 1
	GameManager.player_hp = GameManager.max_hp

	_update_debug_display()


func _process(delta: float) -> void:
	if not _game_active:
		return

	_elapsed_time += delta
	_handle_keyboard_input()
	_update_debug_display()
	_cleanup_offscreen_balls()


func _handle_keyboard_input() -> void:
	"""Handle WASD movement and arrow key aiming."""
	# Movement (WASD)
	var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if move_dir.length() > 0.1:
		if player and player.has_method("set_movement_input"):
			player.set_movement_input(move_dir)
	elif move_joystick and not move_joystick.is_dragging:
		if player and player.has_method("set_movement_input"):
			player.set_movement_input(Vector2.ZERO)

	# Aiming (Arrow keys)
	var aim_dir := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_dir.length() > 0.1:
		_keyboard_aim_direction = aim_dir.normalized()
		if ball_spawner:
			ball_spawner.set_aim_direction(_keyboard_aim_direction)
		if aim_line and player:
			aim_line.show_line(_keyboard_aim_direction, player.global_position)
	elif aim_joystick and not aim_joystick.is_dragging:
		if _keyboard_aim_direction.length() > 0:
			_keyboard_aim_direction = Vector2.ZERO
			if aim_line:
				aim_line.hide_line()


func _unhandled_input(event: InputEvent) -> void:
	# Fire with Space
	if event.is_action_pressed("fire"):
		if _game_active and fire_button and fire_button.can_fire():
			if ball_spawner and _keyboard_aim_direction.length() > 0:
				ball_spawner.set_aim_direction(_keyboard_aim_direction)
			fire_button._try_fire()

	# Escape to go back
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()


func _update_debug_display() -> void:
	"""Update the debug overlay with current experiment state."""
	if not debug_label:
		return

	var mins := int(_elapsed_time) / 60
	var secs := int(_elapsed_time) % 60

	var text := "=== EXPERIMENT MODE ===\n"
	text += "Time: %02d:%02d\n" % [mins, secs]
	text += "Wave: %d\n" % _current_wave
	text += "Kills: %d\n" % _enemies_killed
	text += "\n--- Settings ---\n"
	text += "Ball Speed: %.0f\n" % exp_settings["ball_speed"]
	text += "Enemy Speed: %.0f\n" % exp_settings["enemy_descent_speed"]
	text += "Spawn Interval: %.1fs\n" % exp_settings["spawn_interval"]
	text += "Formation Chance: %.0f%%\n" % (exp_settings["formation_chance"] * 100)
	text += "\n[ESC] Return to Menu"

	debug_label.text = text


func _cleanup_offscreen_balls() -> void:
	"""Clean up balls that went off screen."""
	if not balls_container:
		return

	for ball in balls_container.get_children():
		if ball.global_position.y < -50 or ball.global_position.y > 1330:
			ball.despawn()


# Signal handlers
func _on_move_direction_changed(direction: Vector2) -> void:
	if player and player.has_method("set_movement_input"):
		player.set_movement_input(direction)


func _on_move_released() -> void:
	if player and player.has_method("set_movement_input"):
		player.set_movement_input(Vector2.ZERO)


func _on_aim_direction_changed(direction: Vector2) -> void:
	if ball_spawner and direction.length() > 0.1:
		ball_spawner.set_aim_direction(direction)
	if aim_line and player:
		if direction.length() > 0.1:
			aim_line.show_line(direction, player.global_position)
		else:
			aim_line.hide_line()


func _on_aim_released() -> void:
	if aim_line:
		aim_line.hide_line()


func _on_fire_pressed() -> void:
	if ball_spawner:
		ball_spawner.fire()


func _on_ball_caught() -> void:
	if fire_button:
		fire_button.add_catch_bonus()
	SoundManager.play(SoundManager.SoundType.GEM_COLLECT)


func _on_player_moved(pos: Vector2) -> void:
	if ball_spawner:
		ball_spawner.global_position = pos
	if player_zone:
		player_zone.global_position = pos
	if aim_line:
		aim_line.update_position(pos)


func _on_enemy_spawned(enemy: Node) -> void:
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died.bind(enemy))


func _on_enemy_died(_enemy: Node) -> void:
	_enemies_killed += 1

	# Check wave progress
	if _enemies_killed >= exp_settings["enemies_per_wave"] * _current_wave:
		_advance_wave()


func _advance_wave() -> void:
	_current_wave += 1
	GameManager.current_wave = _current_wave
	SoundManager.play(SoundManager.SoundType.WAVE_COMPLETE)

	# Increase difficulty slightly
	if enemy_spawner and enemy_spawner.has_method("set_spawn_interval"):
		var new_interval: float = max(1.0, exp_settings["spawn_interval"] - 0.3 * (_current_wave - 1))
		enemy_spawner.set_spawn_interval(new_interval)


func _on_back_pressed() -> void:
	"""Return to main menu."""
	_game_active = false

	# Stop spawning
	if enemy_spawner and enemy_spawner.has_method("stop_spawning"):
		enemy_spawner.stop_spawning()

	# Clear enemies
	if enemies_container:
		for enemy in enemies_container.get_children():
			if enemy != enemy_spawner:
				enemy.queue_free()

	# Return to main scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")
