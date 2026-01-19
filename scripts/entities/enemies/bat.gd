class_name Bat
extends "res://scripts/entities/enemies/enemy_base.gd"
## Bat enemy - flies in zigzag pattern and is faster

@export var bat_color: Color = Color(0.3, 0.2, 0.4)
@export var wing_color: Color = Color(0.4, 0.3, 0.5)
@export var body_radius: float = 12.0

# Zigzag movement
var _zigzag_time: float = 0.0
var _zigzag_amplitude: float = 100.0
var _zigzag_frequency: float = 2.0
var _base_x: float = 0.0


func _ready() -> void:
	# Bats are faster and worth more XP
	speed *= 1.3
	xp_value = int(xp_value * 1.2)
	_base_x = global_position.x
	super._ready()


func _move(delta: float) -> void:
	_zigzag_time += delta

	# Zigzag movement
	var target_x: float = _base_x + sin(_zigzag_time * _zigzag_frequency * TAU) * _zigzag_amplitude
	var dx: float = (target_x - global_position.x) * 5.0 * delta

	velocity = Vector2(dx / delta if delta > 0 else 0, speed)
	move_and_slide()


func _draw() -> void:
	# Draw body (oval)
	_draw_ellipse(Vector2.ZERO, body_radius, body_radius * 0.7, bat_color)

	# Draw wings
	_draw_wing(Vector2(-body_radius, -2), -1)
	_draw_wing(Vector2(body_radius, -2), 1)

	# Draw ears
	var ear_points_l := PackedVector2Array([
		Vector2(-6, -10),
		Vector2(-10, -20),
		Vector2(-2, -12)
	])
	draw_colored_polygon(ear_points_l, bat_color)

	var ear_points_r := PackedVector2Array([
		Vector2(6, -10),
		Vector2(10, -20),
		Vector2(2, -12)
	])
	draw_colored_polygon(ear_points_r, bat_color)

	# Draw eyes
	draw_circle(Vector2(-4, -2), 3, Color.RED)
	draw_circle(Vector2(4, -2), 3, Color.RED)


func _draw_wing(pos: Vector2, direction: int) -> void:
	# Animated wing flap
	var flap: float = sin(_zigzag_time * 10.0) * 0.3 + 0.7
	var wing_width: float = 18.0 * flap

	var points := PackedVector2Array([
		pos,
		pos + Vector2(wing_width * direction, -8),
		pos + Vector2(wing_width * direction * 0.7, 0),
		pos + Vector2(wing_width * direction, 8),
	])
	draw_colored_polygon(points, wing_color)


func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var points := PackedVector2Array()
	var segments := 16
	for i in range(segments + 1):
		var angle := TAU * i / segments
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(points, color)


func _process(_delta: float) -> void:
	queue_redraw()  # Redraw for wing animation
