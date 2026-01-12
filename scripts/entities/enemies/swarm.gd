class_name Swarm
extends EnemyBase
## Swarm enemy - small, fast, fragile. Spawns in groups.

@export var body_color: Color = Color(0.3, 0.3, 0.4)
@export var wing_color: Color = Color(0.5, 0.5, 0.6, 0.6)
@export var body_radius: float = 10.0

# Erratic movement
var _wobble_offset: float = 0.0
var _wobble_speed: float = 8.0
var _wobble_amplitude: float = 30.0


func _ready() -> void:
	# Swarm creatures are fast but fragile
	max_hp = int(max_hp * 0.4)
	hp = max_hp
	speed *= 1.6
	xp_value = int(xp_value * 0.5)
	# Less damage per hit
	damage_to_player = int(damage_to_player * 0.6)
	# Randomize wobble phase so they don't all move in sync
	_wobble_offset = randf() * TAU
	super._ready()


func _move(delta: float) -> void:
	# Erratic side-to-side movement while descending
	_wobble_offset += _wobble_speed * delta

	var horizontal := sin(_wobble_offset) * _wobble_amplitude * delta * 60.0
	var vertical := speed

	velocity = Vector2(horizontal, vertical)
	move_and_slide()


func _draw() -> void:
	# Draw wings (translucent, flapping)
	var wing_offset := sin(_wobble_offset * 2) * 3.0
	_draw_wing(Vector2(-body_radius - 3, wing_offset), -1)
	_draw_wing(Vector2(body_radius + 3, wing_offset), 1)

	# Draw body (small oval)
	_draw_ellipse(Vector2.ZERO, body_radius, body_radius * 0.7, body_color)

	# Draw head
	draw_circle(Vector2(0, -body_radius * 0.5), body_radius * 0.5, body_color.lightened(0.1))

	# Draw eyes (small red dots)
	draw_circle(Vector2(-2, -body_radius * 0.5), 2, Color.RED)
	draw_circle(Vector2(2, -body_radius * 0.5), 2, Color.RED)

	# Draw stinger
	var stinger_start := Vector2(0, body_radius * 0.5)
	var stinger_end := Vector2(0, body_radius + 5)
	draw_line(stinger_start, stinger_end, body_color.darkened(0.2), 2)


func _draw_wing(pos: Vector2, direction: int) -> void:
	var wing_points := PackedVector2Array([
		pos,
		pos + Vector2(8 * direction, -6),
		pos + Vector2(12 * direction, 0),
		pos + Vector2(8 * direction, 6)
	])
	draw_colored_polygon(wing_points, wing_color)


func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var points := PackedVector2Array()
	var segments := 16
	for i in range(segments + 1):
		var angle := TAU * i / segments
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(points, color)
