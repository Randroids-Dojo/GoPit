class_name Player
extends CharacterBody2D
## Player character with free movement controlled by joystick

signal damaged(amount: int)
signal moved(position: Vector2)

@export var move_speed: float = 300.0
@export var player_radius: float = 35.0
@export var body_color: Color = Color(0.3, 0.7, 1.0, 0.9)
@export var outline_color: Color = Color(0.5, 0.9, 1.0, 1.0)

var movement_input: Vector2 = Vector2.ZERO
var last_aim_direction: Vector2 = Vector2.UP  # Default aim upward

# Game bounds (set by game_controller)
var bounds_min: Vector2 = Vector2(30, 280)  # Left wall + some padding, top area (below enlarged TopBar)
var bounds_max: Vector2 = Vector2(690, 1150)  # Right wall - padding, above input area


func _ready() -> void:
	add_to_group("player")
	# Set up collision - layer 16 (player), mask 4+8 (enemies + gems)
	collision_layer = 16
	collision_mask = 12  # 4 (enemies) + 8 (gems)


func _physics_process(_delta: float) -> void:
	# Apply movement with character speed multiplier
	var effective_speed := move_speed * GameManager.character_speed_mult
	velocity = movement_input * effective_speed
	move_and_slide()

	# Clamp to bounds
	position.x = clampf(position.x, bounds_min.x, bounds_max.x)
	position.y = clampf(position.y, bounds_min.y, bounds_max.y)

	# Track last direction for aiming
	if movement_input.length() > 0.1:
		last_aim_direction = movement_input.normalized()

	moved.emit(position)


func _draw() -> void:
	# Draw player body
	draw_circle(Vector2.ZERO, player_radius, body_color)
	# Draw outline
	draw_arc(Vector2.ZERO, player_radius, 0, TAU, 32, outline_color, 2.0)
	# Draw direction indicator
	var indicator_length := player_radius * 0.6
	draw_line(Vector2.ZERO, last_aim_direction * indicator_length, outline_color, 3.0)


func set_movement_input(direction: Vector2) -> void:
	movement_input = direction
	if direction.length() > 0.1:
		queue_redraw()  # Redraw to update direction indicator


func get_aim_direction() -> Vector2:
	return last_aim_direction


func take_damage(amount: int) -> void:
	damaged.emit(amount)
	GameManager.take_damage(amount)
	_flash_damage()


func _flash_damage() -> void:
	var original := modulate
	modulate = Color(1.5, 0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate", original, 0.2)


func set_bounds(min_pos: Vector2, max_pos: Vector2) -> void:
	bounds_min = min_pos
	bounds_max = max_pos
