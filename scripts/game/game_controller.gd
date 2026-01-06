extends Node2D
## Main game controller - wires together input, spawner, and aim line

@onready var ball_spawner: Node2D = $GameArea/BallSpawner
@onready var balls_container: Node2D = $GameArea/Balls
@onready var enemies_container: Node2D = $GameArea/Enemies
@onready var gems_container: Node2D = $GameArea/Gems
@onready var enemy_spawner: EnemySpawner = $GameArea/Enemies/EnemySpawner
@onready var player_zone: Area2D = $GameArea/PlayerZone
@onready var player: CharacterBody2D = $GameArea/Player
@onready var joystick: Control = $UI/HUD/InputContainer/HBoxContainer/JoystickContainer/VirtualJoystick
@onready var fire_button: Control = $UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton
@onready var auto_toggle: Button = $UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/AutoToggle
@onready var aim_line: Line2D = $GameArea/AimLine
@onready var pause_overlay: CanvasLayer = $UI/PauseOverlay
@onready var damage_vignette: ColorRect = $UI/DamageVignette
@onready var tutorial_overlay: CanvasLayer = $UI/TutorialOverlay
@onready var danger_indicator: Control = $UI/DangerIndicator

var gem_scene: PackedScene = preload("res://scenes/entities/gem.tscn")
var player_scene: PackedScene = preload("res://scenes/entities/player.tscn")

# Viewport bounds for ball cleanup
var viewport_height: float = 1280.0

# Wave tracking
var enemies_killed_this_wave: int = 0
var enemies_per_wave: int = 5


func _ready() -> void:
	viewport_height = get_viewport_rect().size.y

	# Wire up joystick - now controls player movement
	if joystick:
		joystick.direction_changed.connect(_on_joystick_direction_changed)
		joystick.released.connect(_on_joystick_released)

	# Wire up fire button
	if fire_button:
		fire_button.fired.connect(_on_fire_pressed)

	# Wire up autofire toggle
	if auto_toggle and fire_button:
		auto_toggle.toggled.connect(_on_auto_toggle_pressed)
		fire_button.autofire_toggled.connect(_on_autofire_state_changed)

	# Set up ball spawner
	if ball_spawner:
		ball_spawner.balls_container = balls_container

	# Set up player
	if player:
		# Player starts at bottom center
		player.position = Vector2(360, 1000)
		# Connect player to ball spawner so balls spawn from player position
		player.moved.connect(_on_player_moved)

	# Connect player zone to detect enemies and gems (legacy, still used for gem magnet)
	if player_zone:
		player_zone.body_entered.connect(_on_player_zone_body_entered)
		player_zone.area_entered.connect(_on_player_zone_area_entered)

	# Connect to game state for enemy spawning
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)
	GameManager.player_damaged.connect(_on_player_damaged)

	# Connect enemy spawner to spawn gems on death
	if enemy_spawner:
		enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)

	# Auto-start the game
	GameManager.start_game()


func _on_game_started() -> void:
	if enemy_spawner:
		enemy_spawner.start_spawning()
	MusicManager.start_music()


func _on_game_over() -> void:
	if enemy_spawner:
		enemy_spawner.stop_spawning()
	MusicManager.stop_music()
	# Clear all existing enemies so they stop moving
	if enemies_container:
		for enemy in enemies_container.get_children():
			if enemy is EnemyBase:
				enemy.queue_free()


func _on_player_damaged(_amount: int) -> void:
	if damage_vignette:
		damage_vignette.flash()


func _on_player_zone_body_entered(body: Node2D) -> void:
	# Check if it's an enemy
	if body is EnemyBase:
		GameManager.take_damage(body.damage_to_player)
		body.queue_free()


func _on_player_zone_area_entered(area: Area2D) -> void:
	# Check if it's a gem (collision layer 8)
	if area.collision_layer & 8:
		var xp_value: int = 10
		if area.has_method("get_xp_value"):
			xp_value = area.get_xp_value()
			GameManager.add_xp(xp_value)
		GameManager.record_gem_collected()
		SoundManager.play(SoundManager.SoundType.GEM_COLLECT)
		# Show floating XP text
		_show_xp_text(area.global_position, xp_value)
		area.queue_free()


func _show_xp_text(pos: Vector2, xp: int) -> void:
	var DamageNumber := preload("res://scripts/effects/damage_number.gd")
	DamageNumber.spawn(self, pos, xp, Color(0.3, 1.0, 0.5), "+")  # Green "+X" for XP


func _on_enemy_spawned(enemy: EnemyBase) -> void:
	# Connect to enemy death to spawn gems
	enemy.died.connect(_on_enemy_died)
	# Connect to enemy damage for tutorial
	enemy.took_damage.connect(_on_enemy_took_damage)
	# Connect danger zone signals
	if danger_indicator:
		enemy.entered_danger_zone.connect(danger_indicator.add_danger)
		enemy.left_danger_zone.connect(danger_indicator.remove_danger)
		enemy.died.connect(func(_e):
			if enemy.in_danger_zone:
				danger_indicator.remove_danger()
		)


func _on_enemy_died(enemy: EnemyBase) -> void:
	_spawn_gem(enemy.global_position, enemy.xp_value)
	_check_wave_progress()
	GameManager.record_enemy_kill()


func _on_enemy_took_damage(_enemy: EnemyBase, _amount: int) -> void:
	# Notify tutorial
	if tutorial_overlay and tutorial_overlay.has_method("on_enemy_hit"):
		tutorial_overlay.on_enemy_hit()


func _spawn_gem(pos: Vector2, xp_value: int) -> void:
	if not gems_container:
		return

	var gem := gem_scene.instantiate()
	gem.position = pos
	gem.xp_value = xp_value
	gem.collected.connect(_on_gem_collected)
	gems_container.add_child(gem)


func _on_gem_collected(gem: Node2D) -> void:
	if gem.has_method("get_xp_value"):
		GameManager.add_xp(gem.get_xp_value())


func _check_wave_progress() -> void:
	enemies_killed_this_wave += 1
	if enemies_killed_this_wave >= enemies_per_wave:
		_advance_wave()


func _advance_wave() -> void:
	enemies_killed_this_wave = 0
	SoundManager.play(SoundManager.SoundType.WAVE_COMPLETE)
	GameManager.advance_wave()

	# Increase difficulty
	if enemy_spawner:
		# Increase spawn rate
		var new_interval: float = max(0.5, enemy_spawner.spawn_interval - 0.1)
		enemy_spawner.set_spawn_interval(new_interval)

	# Increase music intensity
	MusicManager.set_intensity(float(GameManager.current_wave))


func _on_player_moved(pos: Vector2) -> void:
	# Update ball spawner position to follow player
	if ball_spawner:
		ball_spawner.global_position = pos

	# Update PlayerZone position to follow player (for collision detection)
	if player_zone:
		player_zone.global_position = pos


func _on_joystick_direction_changed(direction: Vector2) -> void:
	# Control player movement
	if player and player.has_method("set_movement_input"):
		player.set_movement_input(direction)

	# Set aim direction on ball spawner (use movement direction for aiming)
	if ball_spawner:
		if direction.length() > 0.1:
			ball_spawner.set_aim_direction(direction)

	# Show aim line from player position
	if aim_line and player:
		if direction.length() > 0.1:
			aim_line.show_line(direction, player.global_position)
		else:
			aim_line.hide_line()

	# Notify tutorial
	if tutorial_overlay and tutorial_overlay.has_method("on_joystick_used"):
		tutorial_overlay.on_joystick_used()


func _on_joystick_released() -> void:
	# Stop player movement
	if player and player.has_method("set_movement_input"):
		player.set_movement_input(Vector2.ZERO)

	if aim_line:
		aim_line.hide_line()


func _on_fire_pressed() -> void:
	if ball_spawner:
		ball_spawner.fire()
		GameManager.record_ball_fired()

	# Notify tutorial
	if tutorial_overlay and tutorial_overlay.has_method("on_ball_fired"):
		tutorial_overlay.on_ball_fired()


func _on_auto_toggle_pressed(button_pressed: bool) -> void:
	if fire_button:
		fire_button.set_autofire(button_pressed)


func _on_autofire_state_changed(enabled: bool) -> void:
	# Keep toggle button in sync with fire button state
	if auto_toggle:
		auto_toggle.set_pressed_no_signal(enabled)


func _process(_delta: float) -> void:
	_cleanup_offscreen_balls()


func _notification(what: int) -> void:
	# Auto-pause when app loses focus (mobile)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if GameManager.current_state == GameManager.GameState.PLAYING:
			if pause_overlay:
				pause_overlay.show_pause()


func _cleanup_offscreen_balls() -> void:
	if not balls_container:
		return

	for ball in balls_container.get_children():
		if ball.global_position.y < -50 or ball.global_position.y > viewport_height + 50:
			ball.despawn()
