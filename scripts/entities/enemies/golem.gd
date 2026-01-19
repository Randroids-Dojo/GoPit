class_name Golem
extends "res://scripts/entities/enemies/enemy_base.gd"
## Golem enemy - slow, tanky, deals AoE slam damage on attack

@export var body_color: Color = Color(0.5, 0.4, 0.35)
@export var eye_color: Color = Color(0.9, 0.5, 0.1)
@export var body_width: float = 35.0
@export var body_height: float = 45.0

# AoE slam properties
const SLAM_RADIUS: float = 80.0
const SLAM_VISUAL_DURATION: float = 0.3
var _showing_slam_visual: bool = false
var _slam_visual_timer: float = 0.0
var _slam_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Golems are very tanky but very slow
	max_hp = int(max_hp * 3.0)
	hp = max_hp
	speed *= 0.4
	xp_value = int(xp_value * 2.5)
	# More damage to player
	damage_to_player = int(damage_to_player * 1.5)
	super._ready()


func _process(delta: float) -> void:
	# Update slam visual timer
	if _showing_slam_visual:
		_slam_visual_timer -= delta
		if _slam_visual_timer <= 0:
			_showing_slam_visual = false
		queue_redraw()


func _deal_damage_to_player() -> void:
	# Override to add AoE slam effect
	_trigger_slam_visual()
	super._deal_damage_to_player()


func _trigger_slam_visual() -> void:
	_showing_slam_visual = true
	_slam_visual_timer = SLAM_VISUAL_DURATION
	_slam_position = global_position
	# Big camera shake for slam
	CameraShake.shake(15.0, 10.0)
	queue_redraw()


func _draw() -> void:
	# Draw AoE slam visual if active
	if _showing_slam_visual:
		_draw_slam_effect()

	# Draw body (rough rectangular boulder shape)
	_draw_boulder_body()

	# Draw face
	_draw_face()

	# Draw rocky details
	_draw_rock_details()


func _draw_slam_effect() -> void:
	# Fading shockwave circle
	var alpha: float = _slam_visual_timer / SLAM_VISUAL_DURATION
	var slam_color := Color(1.0, 0.6, 0.2, alpha * 0.5)
	var inner_color := Color(1.0, 0.8, 0.3, alpha * 0.3)

	# Expanding ring effect
	var expand_factor: float = 1.0 + (1.0 - alpha) * 0.5
	var current_radius: float = SLAM_RADIUS * expand_factor

	# Draw multiple rings for impact effect
	_draw_ring(Vector2.ZERO, current_radius, slam_color, 4.0)
	_draw_ring(Vector2.ZERO, current_radius * 0.7, inner_color, 3.0)


func _draw_ring(center: Vector2, radius: float, color: Color, thickness: float) -> void:
	var segments := 24
	var prev_point := center + Vector2(radius, 0)
	for i in range(1, segments + 1):
		var angle := TAU * i / segments
		var point := center + Vector2(cos(angle) * radius, sin(angle) * radius)
		draw_line(prev_point, point, color, thickness)
		prev_point = point


func _draw_boulder_body() -> void:
	# Draw rough boulder shape with multiple overlapping polygons
	var base_points := PackedVector2Array([
		Vector2(-body_width, -body_height * 0.2),
		Vector2(-body_width * 0.8, -body_height * 0.8),
		Vector2(-body_width * 0.3, -body_height),
		Vector2(body_width * 0.3, -body_height),
		Vector2(body_width * 0.8, -body_height * 0.8),
		Vector2(body_width, -body_height * 0.2),
		Vector2(body_width * 0.9, body_height * 0.6),
		Vector2(body_width * 0.5, body_height),
		Vector2(-body_width * 0.5, body_height),
		Vector2(-body_width * 0.9, body_height * 0.6)
	])
	draw_colored_polygon(base_points, body_color)

	# Draw darker shadow on lower portion
	var shadow_points := PackedVector2Array([
		Vector2(-body_width * 0.9, body_height * 0.3),
		Vector2(body_width * 0.9, body_height * 0.3),
		Vector2(body_width * 0.9, body_height * 0.6),
		Vector2(body_width * 0.5, body_height),
		Vector2(-body_width * 0.5, body_height),
		Vector2(-body_width * 0.9, body_height * 0.6)
	])
	draw_colored_polygon(shadow_points, body_color.darkened(0.2))


func _draw_face() -> void:
	# Draw glowing eyes
	var left_eye_pos := Vector2(-body_width * 0.35, -body_height * 0.4)
	var right_eye_pos := Vector2(body_width * 0.35, -body_height * 0.4)

	# Eye glow
	draw_circle(left_eye_pos, 8, eye_color.darkened(0.3))
	draw_circle(right_eye_pos, 8, eye_color.darkened(0.3))

	# Eye pupils
	draw_circle(left_eye_pos, 5, eye_color)
	draw_circle(right_eye_pos, 5, eye_color)

	# Bright center
	draw_circle(left_eye_pos + Vector2(-1, -1), 2, eye_color.lightened(0.5))
	draw_circle(right_eye_pos + Vector2(-1, -1), 2, eye_color.lightened(0.5))


func _draw_rock_details() -> void:
	# Draw cracks and rocky texture
	var crack_color := body_color.darkened(0.3)

	# Crack lines
	draw_line(Vector2(-body_width * 0.5, -body_height * 0.6),
			  Vector2(-body_width * 0.3, -body_height * 0.3), crack_color, 2)
	draw_line(Vector2(-body_width * 0.3, -body_height * 0.3),
			  Vector2(-body_width * 0.4, 0), crack_color, 2)

	draw_line(Vector2(body_width * 0.6, -body_height * 0.5),
			  Vector2(body_width * 0.4, -body_height * 0.1), crack_color, 2)

	# Small rock bumps
	var bump_color := body_color.lightened(0.1)
	draw_circle(Vector2(-body_width * 0.6, body_height * 0.1), 4, bump_color)
	draw_circle(Vector2(body_width * 0.5, -body_height * 0.2), 5, bump_color)
	draw_circle(Vector2(0, body_height * 0.5), 3, bump_color)
