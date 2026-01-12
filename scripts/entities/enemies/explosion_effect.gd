extends Node2D
## Visual effect for bomber explosion

var explosion_radius: float = 100.0
var duration: float = 0.4
var _timer: float = 0.0


func _ready() -> void:
	_timer = duration
	queue_redraw()


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		queue_free()
	else:
		queue_redraw()


func _draw() -> void:
	var progress: float = 1.0 - (_timer / duration)

	# Expanding ring
	var current_radius: float = explosion_radius * (0.3 + progress * 0.7)
	var alpha: float = 1.0 - progress

	# Outer glow
	var outer_color := Color(1.0, 0.5, 0.1, alpha * 0.3)
	draw_circle(Vector2.ZERO, current_radius, outer_color)

	# Middle ring
	var mid_color := Color(1.0, 0.7, 0.2, alpha * 0.5)
	draw_circle(Vector2.ZERO, current_radius * 0.7, mid_color)

	# Inner bright core
	var inner_color := Color(1.0, 0.9, 0.5, alpha * 0.8)
	draw_circle(Vector2.ZERO, current_radius * 0.3, inner_color)

	# Shockwave ring
	_draw_ring(Vector2.ZERO, current_radius, Color(1.0, 0.6, 0.2, alpha), 4.0)


func _draw_ring(center: Vector2, radius: float, color: Color, thickness: float) -> void:
	var segments := 24
	var prev_point := center + Vector2(radius, 0)
	for i in range(1, segments + 1):
		var angle := TAU * i / segments
		var point := center + Vector2(cos(angle) * radius, sin(angle) * radius)
		draw_line(prev_point, point, color, thickness)
		prev_point = point
