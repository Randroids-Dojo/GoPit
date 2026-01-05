class_name Crab
extends EnemyBase
## Crab enemy - sideways movement with more HP

@export var crab_color: Color = Color(0.9, 0.3, 0.2)
@export var claw_color: Color = Color(1.0, 0.4, 0.3)
@export var body_width: float = 28.0
@export var body_height: float = 18.0

# Side movement
var _move_direction: int = 1
var _side_speed: float = 80.0
var _down_speed_factor: float = 0.3  # Slower downward
var _screen_margin: float = 50.0


func _ready() -> void:
	# Crabs are tankier but slower
	max_hp = int(max_hp * 1.5)
	hp = max_hp
	speed *= 0.6
	xp_value = int(xp_value * 1.3)
	# Random starting direction
	_move_direction = 1 if randf() > 0.5 else -1
	super._ready()


func _move(delta: float) -> void:
	# Side-to-side movement with slower descent
	var horizontal := _side_speed * _move_direction
	var vertical := speed * _down_speed_factor

	# Bounce off screen edges
	var viewport_width: float = 720.0  # Hardcoded for now
	if global_position.x < _screen_margin:
		_move_direction = 1
	elif global_position.x > viewport_width - _screen_margin:
		_move_direction = -1

	velocity = Vector2(horizontal, vertical)
	move_and_slide()


func _draw() -> void:
	# Draw body (wider oval)
	_draw_ellipse(Vector2.ZERO, body_width, body_height, crab_color)

	# Draw claws
	_draw_claw(Vector2(-body_width + 5, 0), -1)
	_draw_claw(Vector2(body_width - 5, 0), 1)

	# Draw legs
	for i in range(3):
		var leg_x: float = -body_width * 0.5 + i * body_width * 0.3
		_draw_leg(Vector2(leg_x, body_height * 0.5), -1)
		_draw_leg(Vector2(-leg_x, body_height * 0.5), 1)

	# Draw eyes on stalks
	var eye_color := Color.BLACK
	draw_line(Vector2(-8, -body_height), Vector2(-8, -body_height - 10), crab_color, 3)
	draw_line(Vector2(8, -body_height), Vector2(8, -body_height - 10), crab_color, 3)
	draw_circle(Vector2(-8, -body_height - 12), 4, eye_color)
	draw_circle(Vector2(8, -body_height - 12), 4, eye_color)


func _draw_claw(pos: Vector2, direction: int) -> void:
	# Main claw arm
	var arm_end := pos + Vector2(15 * direction, -5)
	draw_line(pos, arm_end, claw_color, 6)

	# Claw pincer
	var pincer_top := arm_end + Vector2(10 * direction, -8)
	var pincer_bottom := arm_end + Vector2(10 * direction, 4)
	draw_line(arm_end, pincer_top, claw_color, 4)
	draw_line(arm_end, pincer_bottom, claw_color, 4)


func _draw_leg(pos: Vector2, direction: int) -> void:
	var leg_end := pos + Vector2(8 * direction, 10)
	draw_line(pos, leg_end, crab_color, 2)


func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var points := PackedVector2Array()
	var segments := 20
	for i in range(segments + 1):
		var angle := TAU * i / segments
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(points, color)
