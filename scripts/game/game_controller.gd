extends Node2D
## Main game controller - wires together input, spawner, and aim line

@onready var ball_spawner: Node2D = $GameArea/BallSpawner
@onready var balls_container: Node2D = $GameArea/Balls
@onready var enemies_container: Node2D = $GameArea/Enemies
@onready var gems_container: Node2D = $GameArea/Gems
@onready var enemy_spawner: EnemySpawner = $GameArea/Enemies/EnemySpawner
@onready var player_zone: Area2D = $GameArea/PlayerZone
@onready var joystick: Control = $UI/HUD/InputContainer/HBoxContainer/JoystickContainer/VirtualJoystick
@onready var fire_button: Control = $UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton
@onready var aim_line: Line2D = $GameArea/AimLine

var gem_scene: PackedScene = preload("res://scenes/entities/gem.tscn")

# Viewport bounds for ball cleanup
var viewport_height: float = 1280.0

# Wave tracking
var enemies_killed_this_wave: int = 0
var enemies_per_wave: int = 5


func _ready() -> void:
	viewport_height = get_viewport_rect().size.y

	# Wire up joystick
	if joystick:
		joystick.direction_changed.connect(_on_joystick_direction_changed)
		joystick.released.connect(_on_joystick_released)

	# Wire up fire button
	if fire_button:
		fire_button.fired.connect(_on_fire_pressed)

	# Set up ball spawner
	if ball_spawner:
		ball_spawner.balls_container = balls_container

	# Connect player zone to detect enemies and gems
	if player_zone:
		player_zone.body_entered.connect(_on_player_zone_body_entered)
		player_zone.area_entered.connect(_on_player_zone_area_entered)

	# Connect to game state for enemy spawning
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)

	# Connect enemy spawner to spawn gems on death
	if enemy_spawner:
		enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)

	# Auto-start the game
	GameManager.start_game()


func _on_game_started() -> void:
	if enemy_spawner:
		enemy_spawner.start_spawning()


func _on_game_over() -> void:
	if enemy_spawner:
		enemy_spawner.stop_spawning()


func _on_player_zone_body_entered(body: Node2D) -> void:
	# Check if it's an enemy
	if body is EnemyBase:
		GameManager.take_damage(body.damage_to_player)
		body.queue_free()


func _on_player_zone_area_entered(area: Area2D) -> void:
	# Check if it's a gem (collision layer 8)
	if area.collision_layer & 8:
		if area.has_method("get_xp_value"):
			GameManager.add_xp(area.get_xp_value())
		area.queue_free()


func _on_enemy_spawned(enemy: EnemyBase) -> void:
	# Connect to enemy death to spawn gems
	enemy.died.connect(_on_enemy_died)


func _on_enemy_died(enemy: EnemyBase) -> void:
	_spawn_gem(enemy.global_position, enemy.xp_value)
	_check_wave_progress()


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
	GameManager.advance_wave()

	# Increase difficulty
	if enemy_spawner:
		# Increase spawn rate
		var new_interval: float = max(0.5, enemy_spawner.spawn_interval - 0.1)
		enemy_spawner.set_spawn_interval(new_interval)


func _on_joystick_direction_changed(direction: Vector2) -> void:
	if ball_spawner:
		ball_spawner.set_aim_direction(direction)

	if aim_line and ball_spawner:
		aim_line.show_line(direction, ball_spawner.global_position)


func _on_joystick_released() -> void:
	if aim_line:
		aim_line.hide_line()


func _on_fire_pressed() -> void:
	if ball_spawner:
		ball_spawner.fire()


func _process(_delta: float) -> void:
	_cleanup_offscreen_balls()


func _cleanup_offscreen_balls() -> void:
	if not balls_container:
		return

	for ball in balls_container.get_children():
		if ball.global_position.y < -50 or ball.global_position.y > viewport_height + 50:
			ball.despawn()
