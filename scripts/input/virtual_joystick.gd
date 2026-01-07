extends Control
## Virtual joystick for aiming - drag to set direction, supports touch and mouse

signal direction_changed(direction: Vector2)
signal released

@export var base_radius: float = 80.0
@export var knob_radius: float = 30.0
@export var dead_zone: float = 0.05  # 5% dead zone for responsive controls
@export var base_color: Color = Color(0.3, 0.3, 0.4, 0.5)
@export var knob_color: Color = Color(0.5, 0.7, 1.0, 0.8)

var is_dragging: bool = false
var current_direction: Vector2 = Vector2.ZERO
var knob_position: Vector2 = Vector2.ZERO
var touch_index: int = -1


func _ready() -> void:
	custom_minimum_size = Vector2(base_radius * 2, base_radius * 2)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _draw() -> void:
	var center := size / 2

	# Draw base circle
	draw_circle(center, base_radius, base_color)

	# Draw knob at current position
	draw_circle(center + knob_position, knob_radius, knob_color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_end_drag()

	elif event is InputEventMouseMotion:
		if is_dragging:
			_update_drag(event.position)

	elif event is InputEventScreenTouch:
		if event.pressed:
			if not is_dragging:
				touch_index = event.index
				_start_drag(event.position)
		else:
			if event.index == touch_index:
				_end_drag()

	elif event is InputEventScreenDrag:
		if event.index == touch_index and is_dragging:
			_update_drag(event.position)


func _start_drag(pos: Vector2) -> void:
	is_dragging = true
	_update_drag(pos)


func _update_drag(pos: Vector2) -> void:
	var center := size / 2
	var offset := pos - center
	var distance := offset.length()

	# Clamp to base radius
	if distance > base_radius:
		offset = offset.normalized() * base_radius

	knob_position = offset

	# Calculate direction with dead zone
	var normalized_distance := distance / base_radius
	if normalized_distance > dead_zone:
		current_direction = offset.normalized()
	else:
		current_direction = Vector2.ZERO

	direction_changed.emit(current_direction)
	queue_redraw()


func _end_drag() -> void:
	is_dragging = false
	touch_index = -1
	knob_position = Vector2.ZERO
	current_direction = Vector2.ZERO
	released.emit()
	queue_redraw()


func get_direction() -> Vector2:
	return current_direction
