extends Line2D
## Trajectory preview line for aiming with ghost state when released

@export var max_length: float = 400.0
@export var line_color: Color = Color(1.0, 1.0, 1.0, 0.4)
@export var ghost_color: Color = Color(0.5, 0.5, 0.5, 0.3)
@export var line_width_value: float = 3.0
@export var dash_length: float = 20.0
@export var gap_length: float = 10.0

var current_direction: Vector2 = Vector2.UP
var is_active: bool = false
var _last_origin: Vector2 = Vector2.ZERO
var _fade_tween: Tween


func _ready() -> void:
	width = line_width_value
	default_color = line_color
	visible = false


func show_line(direction: Vector2, start_pos: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	current_direction = direction.normalized()
	is_active = true
	visible = true
	_last_origin = start_pos

	# Cancel any fade animation
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	default_color = line_color
	_update_line(start_pos)


func hide_line() -> void:
	is_active = false
	# Don't hide - fade to ghost state
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "default_color", ghost_color, 0.2)


func _update_line(start_pos: Vector2) -> void:
	clear_points()
	_last_origin = start_pos

	# Create dashed line effect
	var current_pos := start_pos
	var remaining := max_length
	var is_dash := true

	while remaining > 0:
		var segment_length := dash_length if is_dash else gap_length
		segment_length = minf(segment_length, remaining)

		if is_dash:
			add_point(current_pos)
			add_point(current_pos + current_direction * segment_length)

		current_pos += current_direction * segment_length
		remaining -= segment_length
		is_dash = not is_dash


func update_position(start_pos: Vector2) -> void:
	if visible:
		_update_line(start_pos)


func set_direction(direction: Vector2) -> void:
	current_direction = direction.normalized()
