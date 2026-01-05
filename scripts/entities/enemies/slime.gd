class_name Slime
extends EnemyBase
## Slime enemy - simple blob that moves straight down

@export var slime_color: Color = Color(0.2, 0.8, 0.3)
@export var body_radius: float = 20.0


func _draw() -> void:
	# Draw slime body (slightly squashed ellipse)
	var body_height := body_radius * 0.7
	_draw_ellipse(Vector2.ZERO, body_radius, body_height, slime_color)

	# Draw highlight
	var highlight_color := slime_color.lightened(0.3)
	_draw_ellipse(Vector2(-5, -5), 6, 4, highlight_color)


func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var points := PackedVector2Array()
	var segments := 24
	for i in range(segments + 1):
		var angle := TAU * i / segments
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(points, color)
