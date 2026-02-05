extends Node2D
## Experiment Mode Controller
## A simplified test environment to replicate BallxPit's first 5 minutes.
## Focus: sizing, enemy formation, speed, upgrade path, complexity, core mechanics.
##
## TUNING CONTROLS (keyboard):
## 1/2 - Decrease/Increase Ball Speed
## 3/4 - Decrease/Increase Spawn Interval
## 5/6 - Decrease/Increase Ball Size (radius)
## 7/8 - Decrease/Increase Formation Chance
## 9/0 - Decrease/Increase Enemy Speed
## R - Reset settings to defaults
## Backspace - Instant restart (clear all, reset stats)
## P - Pause/Unpause
## M - Save metrics to file

# Child node references
@onready var ball_spawner: Node2D = $GameArea/BallSpawner
@onready var balls_container: Node2D = $GameArea/Balls
@onready var gems_container: Node2D = $GameArea/Gems
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
@onready var level_up_overlay: Control = $UI/LevelUpOverlay

# Gem scene for spawning
var gem_scene: PackedScene

# Default settings (based on research)
const DEFAULT_SETTINGS := {
	# Sizing (based on ballxpit-sizing-scaling.md)
	"ball_radius": 12.0,        # Smaller than current 14
	"player_radius": 35.0,      # Current is good
	"enemy_base_radius": 22.0,  # Slightly larger

	# Speed (based on ballxpit-ball-mechanics.md)
	"ball_speed": 900.0,        # Slightly faster
	"enemy_speed": 50.0,        # Slower enemy descent for first level

	# Spawning (based on ballxpit-complexity.md)
	"spawn_interval": 3.5,      # Slower for first level
	"formation_chance": 0.3,    # Lower for simplicity
	"max_enemies": 8,           # Cap enemies on screen

	# Complexity limits
	"max_balls": 3,             # Limit active balls
	"baby_balls": false,        # No baby balls
}

# Current tunable settings
var exp_settings := {
	"ball_radius": 12.0,
	"ball_speed": 900.0,
	"spawn_interval": 3.5,
	"formation_chance": 0.3,
	"max_enemies": 8,
	"max_balls": 3,
	"enemy_speed": 50.0,  # Slower for first level (BallxPit style)
}

# State tracking
var _game_active := false
var _paused := false
var _current_wave := 1
var _enemies_killed := 0
var _elapsed_time := 0.0
var _keyboard_aim_direction := Vector2.ZERO
var _selected_setting := 0  # Currently selected setting for tuning

# Metrics for side-by-side comparison with BallxPit
var _metrics := {
	# Timing metrics
	"time_to_first_kill": 0.0,
	"time_to_level_2": 0.0,
	"time_to_level_3": 0.0,
	"kills_per_minute": [],  # Array of minute-by-minute kill counts

	# Combat metrics
	"total_balls_fired": 0,
	"total_hits": 0,
	"accuracy": 0.0,
	"avg_time_per_kill": 0.0,

	# Complexity metrics
	"max_balls_on_screen": 0,
	"max_enemies_on_screen": 0,
	"avg_enemies_on_screen": 0.0,
	"enemy_samples": [],  # Samples of enemy count over time

	# Feel metrics (player-perceived)
	"damage_taken_count": 0,
	"close_calls": 0,  # Enemies that got within danger zone
}
var _first_kill_recorded := false
var _last_minute_kills := 0
var _sample_interval := 1.0
var _sample_timer := 0.0


func _ready() -> void:
	# CRITICAL: Unpause tree immediately on scene load
	get_tree().paused = false

	# Connect UI signals immediately (these don't depend on autoloads)
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

	# Defer autoload-dependent initialization to ensure they're ready
	# This is critical for web builds where autoload timing can differ
	call_deferred("_initialize_game_state")


func _initialize_game_state() -> void:
	"""Initialize game state after autoloads are ready (deferred from _ready).
	This separation is critical for web builds where autoload timing differs."""

	# Load gem scene for spawning
	gem_scene = load("res://scenes/entities/gem.tscn")

	# Set game state to PLAYING so Player and EnemySpawner can work
	if GameManager:
		GameManager.current_state = GameManager.GameState.PLAYING

		# Reset GameManager XP for fresh level-up progression
		GameManager.current_xp = 0
		GameManager.player_level = 1
		GameManager.xp_to_next_level = GameManager._calculate_xp_requirement(1)

	# Reset registries for fresh experiment (clean slate like BallxPit first level)
	if BallRegistry:
		BallRegistry.reset()
	if FusionRegistry:
		FusionRegistry.reset()

	# Apply experiment settings to spawner
	_apply_experiment_settings()

	# Start experiment
	_start_experiment()


func _apply_experiment_settings() -> void:
	"""Apply all experimental tuning values to game systems."""
	if ball_spawner:
		# Set ball parameters
		ball_spawner.ball_damage = 10
		ball_spawner.crit_chance = 0.0
		ball_spawner.ball_speed = exp_settings["ball_speed"]
		ball_spawner.ball_radius = exp_settings["ball_radius"]
		# Limit max balls for clarity
		ball_spawner.max_balls = exp_settings["max_balls"]

	if enemy_spawner:
		if enemy_spawner.has_method("set_spawn_interval"):
			enemy_spawner.set_spawn_interval(exp_settings["spawn_interval"])
		enemy_spawner.formation_chance = exp_settings["formation_chance"]
		# Limit to simple formations for first level
		enemy_spawner.burst_chance = 0.0  # No bursts


func _start_experiment() -> void:
	"""Start the experiment mode."""
	# Ensure tree is not paused (may have been paused in previous scene)
	get_tree().paused = false

	# Set GameManager state to PLAYING first, before any game logic
	# This ensures Player._physics_process() and EnemySpawner work immediately
	if GameManager:
		GameManager.current_state = GameManager.GameState.PLAYING
		GameManager.current_wave = 1
		GameManager.player_hp = GameManager.max_hp

	# Set experiment controller state
	_game_active = true
	_current_wave = 1
	_enemies_killed = 0
	_elapsed_time = 0.0

	# Start spawning (now GameManager.current_state is already PLAYING)
	if enemy_spawner and enemy_spawner.has_method("start_spawning"):
		enemy_spawner.start_spawning()

	_update_debug_display()


func _process(delta: float) -> void:
	if not _game_active:
		return

	if _paused:
		_update_debug_display()
		return

	_elapsed_time += delta
	_handle_keyboard_input()
	_update_debug_display()
	_cleanup_offscreen_balls()
	_sample_metrics(delta)


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
		if _game_active and not _paused and fire_button and fire_button.can_fire():
			if ball_spawner and _keyboard_aim_direction.length() > 0:
				ball_spawner.set_aim_direction(_keyboard_aim_direction)
			fire_button._try_fire()

	# Escape to go back
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

	# Handle tuning controls
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			# Ball Speed: 1/2
			KEY_1:
				_adjust_setting("ball_speed", -50.0, 400.0, 1500.0)
			KEY_2:
				_adjust_setting("ball_speed", 50.0, 400.0, 1500.0)
			# Spawn Interval: 3/4
			KEY_3:
				_adjust_setting("spawn_interval", -0.5, 1.0, 6.0)
			KEY_4:
				_adjust_setting("spawn_interval", 0.5, 1.0, 6.0)
			# Ball Radius: 5/6
			KEY_5:
				_adjust_setting("ball_radius", -2.0, 8.0, 20.0)
			KEY_6:
				_adjust_setting("ball_radius", 2.0, 8.0, 20.0)
			# Formation Chance: 7/8
			KEY_7:
				_adjust_setting("formation_chance", -0.1, 0.0, 1.0)
			KEY_8:
				_adjust_setting("formation_chance", 0.1, 0.0, 1.0)
			# Enemy Speed: 9/0
			KEY_9:
				_adjust_setting("enemy_speed", -10.0, 20.0, 150.0)
			KEY_0:
				_adjust_setting("enemy_speed", 10.0, 20.0, 150.0)
			# Reset settings: R
			KEY_R:
				_reset_settings()
			# Restart experiment: Backspace
			KEY_BACKSPACE:
				_restart_experiment()
			# Pause: P
			KEY_P:
				_toggle_pause()
			# Save Metrics: M
			KEY_M:
				_save_metrics_to_file()
				SoundManager.play(SoundManager.SoundType.GEM_COLLECT)


func _adjust_setting(key: String, delta: float, min_val: float, max_val: float) -> void:
	"""Adjust a setting value within bounds."""
	exp_settings[key] = clampf(exp_settings[key] + delta, min_val, max_val)
	_apply_setting(key)
	SoundManager.play(SoundManager.SoundType.BUTTON_CLICK)


func _apply_setting(key: String) -> void:
	"""Apply a single setting change to game systems."""
	match key:
		"ball_speed":
			if ball_spawner:
				ball_spawner.ball_speed = exp_settings["ball_speed"]
		"spawn_interval":
			if enemy_spawner and enemy_spawner.has_method("set_spawn_interval"):
				enemy_spawner.set_spawn_interval(exp_settings["spawn_interval"])
		"formation_chance":
			if enemy_spawner:
				enemy_spawner.formation_chance = exp_settings["formation_chance"]
		"ball_radius":
			# Apply ball radius to ball spawner (affects new balls)
			if ball_spawner:
				ball_spawner.ball_radius = exp_settings["ball_radius"]


func _reset_settings() -> void:
	"""Reset all settings to defaults."""
	for key in DEFAULT_SETTINGS:
		if exp_settings.has(key):
			exp_settings[key] = DEFAULT_SETTINGS[key]
	_apply_experiment_settings()
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)


func _restart_experiment() -> void:
	"""Instant restart - clear everything and start fresh."""
	# Unpause if paused
	if _paused:
		_paused = false
		get_tree().paused = false

	# Stop spawning temporarily
	if enemy_spawner and enemy_spawner.has_method("stop_spawning"):
		enemy_spawner.stop_spawning()

	# Clear all enemies
	if enemies_container:
		for enemy in enemies_container.get_children():
			if enemy != enemy_spawner:
				enemy.queue_free()

	# Clear all balls
	if balls_container:
		for ball in balls_container.get_children():
			ball.queue_free()

	# Clear all gems
	if gems_container:
		for gem in gems_container.get_children():
			gem.queue_free()

	# Reset player position
	if player:
		player.position = Vector2(360, 900)

	# Reset GameManager state
	GameManager.current_xp = 0
	GameManager.player_level = 1
	GameManager.xp_to_next_level = GameManager._calculate_xp_requirement(1)
	GameManager.player_hp = GameManager.max_hp
	GameManager.current_wave = 1

	# Reset registries
	if BallRegistry:
		BallRegistry.reset()
	if FusionRegistry:
		FusionRegistry.reset()

	# Reset experiment state
	_game_active = true
	_current_wave = 1
	_enemies_killed = 0
	_elapsed_time = 0.0
	_first_kill_recorded = false

	# Reset metrics
	_metrics = {
		"time_to_first_kill": 0.0,
		"time_to_level_2": 0.0,
		"time_to_level_3": 0.0,
		"kills_per_minute": [],
		"total_balls_fired": 0,
		"total_hits": 0,
		"accuracy": 0.0,
		"avg_time_per_kill": 0.0,
		"max_balls_on_screen": 0,
		"max_enemies_on_screen": 0,
		"avg_enemies_on_screen": 0.0,
		"enemy_samples": [],
		"damage_taken_count": 0,
		"close_calls": 0,
	}

	# Re-apply settings and restart spawning
	_apply_experiment_settings()
	if enemy_spawner and enemy_spawner.has_method("start_spawning"):
		enemy_spawner.start_spawning()

	SoundManager.play(SoundManager.SoundType.WAVE_COMPLETE)
	_update_debug_display()


func _toggle_pause() -> void:
	"""Toggle pause state."""
	_paused = not _paused
	get_tree().paused = _paused
	if _paused:
		SoundManager.play(SoundManager.SoundType.PAUSE)
	else:
		SoundManager.play(SoundManager.SoundType.UNPAUSE)


func _update_debug_display() -> void:
	"""Update the debug overlay with current experiment state."""
	if not debug_label:
		return

	var mins := int(_elapsed_time) / 60
	var secs := int(_elapsed_time) % 60

	# Count current entities
	var ball_count := balls_container.get_child_count() if balls_container else 0
	var enemy_count := (enemies_container.get_child_count() - 1) if enemies_container else 0  # -1 for spawner

	var text := "=== EXPERIMENT MODE ===\n"
	if _paused:
		text += ">>> PAUSED <<<\n"
	text += "Time: %02d:%02d  Wave: %d  Lv: %d\n" % [mins, secs, _current_wave, GameManager.player_level]
	text += "Kills: %d  Balls: %d  Enemies: %d\n" % [_enemies_killed, ball_count, enemy_count]
	text += "XP: %d/%d\n" % [GameManager.current_xp, GameManager.xp_to_next_level]
	text += "\n--- TUNING (use keys) ---\n"
	text += "[1/2] Ball Speed: %.0f\n" % exp_settings["ball_speed"]
	text += "[3/4] Spawn Int: %.1fs\n" % exp_settings["spawn_interval"]
	text += "[5/6] Ball Size: %.0f\n" % exp_settings["ball_radius"]
	text += "[7/8] Formation: %.0f%%\n" % (exp_settings["formation_chance"] * 100)
	text += "[9/0] Enemy Spd: %.0f\n" % exp_settings["enemy_speed"]
	text += "\n[R] Reset  [Bksp] Restart  [P] Pause\n"
	text += "[ESC] Return to Menu\n"
	text += "\n--- METRICS ---\n"
	text += "Avg Kill: %.2fs  Hit%%: %.0f\n" % [_metrics["avg_time_per_kill"], _metrics["accuracy"]]
	text += "Max Balls: %d  Max Enemies: %d" % [_metrics["max_balls_on_screen"], _metrics["max_enemies_on_screen"]]

	debug_label.text = text


func _cleanup_offscreen_balls() -> void:
	"""Clean up balls that went off screen."""
	if not balls_container:
		return

	for ball in balls_container.get_children():
		if ball.global_position.y < -50 or ball.global_position.y > 1330:
			ball.despawn()


func _sample_metrics(delta: float) -> void:
	"""Sample metrics periodically for comparison analysis."""
	_sample_timer += delta
	if _sample_timer < _sample_interval:
		return
	_sample_timer = 0.0

	# Sample entity counts
	var ball_count := balls_container.get_child_count() if balls_container else 0
	var enemy_count := (enemies_container.get_child_count() - 1) if enemies_container else 0

	_metrics["max_balls_on_screen"] = maxi(_metrics["max_balls_on_screen"], ball_count)
	_metrics["max_enemies_on_screen"] = maxi(_metrics["max_enemies_on_screen"], enemy_count)
	_metrics["enemy_samples"].append(enemy_count)

	# Calculate running average
	if _metrics["enemy_samples"].size() > 0:
		var total := 0.0
		for sample in _metrics["enemy_samples"]:
			total += sample
		_metrics["avg_enemies_on_screen"] = total / _metrics["enemy_samples"].size()

	# Track kills per minute
	var current_minute := int(_elapsed_time / 60)
	while _metrics["kills_per_minute"].size() <= current_minute:
		_metrics["kills_per_minute"].append(0)

	# Update accuracy
	if _metrics["total_balls_fired"] > 0:
		_metrics["accuracy"] = float(_metrics["total_hits"]) / float(_metrics["total_balls_fired"]) * 100.0

	# Update avg time per kill
	if _enemies_killed > 0:
		_metrics["avg_time_per_kill"] = _elapsed_time / _enemies_killed


func _record_kill() -> void:
	"""Record a kill for metrics."""
	# First kill timing
	if not _first_kill_recorded:
		_metrics["time_to_first_kill"] = _elapsed_time
		_first_kill_recorded = true

	# Track kills per minute
	var current_minute := int(_elapsed_time / 60)
	while _metrics["kills_per_minute"].size() <= current_minute:
		_metrics["kills_per_minute"].append(0)
	_metrics["kills_per_minute"][current_minute] += 1


func _export_metrics() -> String:
	"""Export metrics as formatted string for comparison."""
	var report := "=== EXPERIMENT METRICS ===\n"
	report += "Session Duration: %.1fs\n\n" % _elapsed_time

	report += "--- TIMING ---\n"
	report += "First Kill: %.1fs\n" % _metrics["time_to_first_kill"]
	report += "Avg Time/Kill: %.2fs\n" % _metrics["avg_time_per_kill"]
	report += "\n"

	report += "--- COMBAT ---\n"
	report += "Total Kills: %d\n" % _enemies_killed
	report += "Balls Fired: %d\n" % _metrics["total_balls_fired"]
	report += "Hit Rate: %.1f%%\n" % _metrics["accuracy"]
	report += "\n"

	report += "--- COMPLEXITY ---\n"
	report += "Max Balls: %d\n" % _metrics["max_balls_on_screen"]
	report += "Max Enemies: %d\n" % _metrics["max_enemies_on_screen"]
	report += "Avg Enemies: %.1f\n" % _metrics["avg_enemies_on_screen"]
	report += "\n"

	report += "--- KILLS PER MINUTE ---\n"
	for i in range(_metrics["kills_per_minute"].size()):
		report += "Minute %d: %d kills\n" % [i + 1, _metrics["kills_per_minute"][i]]

	report += "\n--- CURRENT SETTINGS ---\n"
	for key in exp_settings:
		report += "%s: %s\n" % [key, str(exp_settings[key])]

	return report


func _save_metrics_to_file() -> void:
	"""Save metrics to a file for comparison."""
	var report := _export_metrics()
	var timestamp := Time.get_datetime_string_from_system().replace(":", "-")
	var path := "user://experiment_metrics_%s.txt" % timestamp

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(report)
		file.close()
		print("Metrics saved to: ", path)


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
		_metrics["total_balls_fired"] += 1


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
	# Apply experiment mode enemy speed
	if enemy.has_method("set") or "speed" in enemy:
		enemy.speed = exp_settings["enemy_speed"]

	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died.bind(enemy))


func _on_enemy_died(enemy: Node) -> void:
	_enemies_killed += 1
	_metrics["total_hits"] += 1
	_record_kill()

	# Spawn gem at enemy position (XP is already added by enemy_base.gd)
	if enemy and gems_container:
		_spawn_gem(enemy.global_position, enemy.xp_value if enemy.has_method("get") else 1)

	# Check wave progress (simplified for experiment)
	if _enemies_killed > 0 and _enemies_killed % 10 == 0:
		_advance_wave()


func _spawn_gem(pos: Vector2, xp_value: int) -> void:
	"""Spawn a gem at the given position."""
	if not gems_container or not gem_scene:
		return

	var gem: Node
	if PoolManager:
		gem = PoolManager.get_gem()
	else:
		gem = gem_scene.instantiate()

	gem.position = pos
	gem.xp_value = xp_value

	# Connect collection signal
	if not gem.collected.is_connected(_on_gem_collected):
		gem.collected.connect(_on_gem_collected)

	gems_container.add_child(gem)

	# Re-acquire player reference after being added to tree
	if gem.has_method("_player"):
		gem._player = player


func _on_gem_collected(_gem: Node2D) -> void:
	"""Handle gem collection - visual feedback only (XP added on kill)."""
	GameManager.record_gem_collected()


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

	# Ensure tree is not paused so scene change works
	get_tree().paused = false

	# Stop spawning
	if enemy_spawner and enemy_spawner.has_method("stop_spawning"):
		enemy_spawner.stop_spawning()

	# Clear enemies
	if enemies_container:
		for enemy in enemies_container.get_children():
			if enemy != enemy_spawner:
				enemy.queue_free()

	# Reset GameManager state before returning to menu
	GameManager.current_state = GameManager.GameState.MENU

	# Return to main scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")
