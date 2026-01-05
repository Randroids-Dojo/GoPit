extends Line2D
## Trajectory preview line for aiming

@export var max_length: float = 400.0
@export var line_color: Color = Color(1.0, 1.0, 1.0, 0.4)
@export var line_width_value: float = 3.0
@export var dash_length: float = 20.0
@export var gap_length: float = 10.0

var current_direction: Vector2 = Vector2.ZERO
var is_visible_line: bool = false


func _ready() -> void:
	width = line_width_value
	default_color = line_color
	visible = false


func show_line(direction: Vector2, start_pos: Vector2) -> void:
	if direction == Vector2.ZERO:
		hide_line()
		return

	current_direction = direction.normalized()
	is_visible_line = true
	visible = true

	_update_line(start_pos)


func hide_line() -> void:
	is_visible_line = false
	visible = false
	clear_points()


func _update_line(start_pos: Vector2) -> void:
	clear_points()

	if not is_visible_line:
		return

	# Create dashed line effect
	var current_pos := start_pos
	var remaining := max_length
	var is_dash := true

	while remaining > 0:
		var segment_length := dash_length if is_dash else gap_length
		segment_length = min(segment_length, remaining)

		if is_dash:
			add_point(current_pos)
			add_point(current_pos + current_direction * segment_length)

		current_pos += current_direction * segment_length
		remaining -= segment_length
		is_dash = not is_dash


func update_position(start_pos: Vector2) -> void:
	if is_visible_line:
		_update_line(start_pos)


func set_direction(direction: Vector2) -> void:
	current_direction = direction.normalized()
