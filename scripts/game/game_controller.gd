extends Node2D
## Main game controller - wires together input, spawner, and aim line

@onready var ball_spawner: Node2D = $GameArea/BallSpawner
@onready var balls_container: Node2D = $GameArea/Balls
@onready var enemies_container: Node2D = $GameArea/Enemies
@onready var enemy_spawner: EnemySpawner = $GameArea/Enemies/EnemySpawner
@onready var joystick: Control = $UI/HUD/InputContainer/HBoxContainer/JoystickContainer/VirtualJoystick
@onready var fire_button: Control = $UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton
@onready var aim_line: Line2D = $GameArea/AimLine

# Viewport bounds for ball cleanup
var viewport_height: float = 1280.0


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

	# Connect to game state for enemy spawning
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)


func _on_game_started() -> void:
	if enemy_spawner:
		enemy_spawner.start_spawning()


func _on_game_over() -> void:
	if enemy_spawner:
		enemy_spawner.stop_spawning()


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
