extends Control
## Fire button with cooldown timer visualization

signal fired
signal cooldown_started
signal cooldown_finished

@export var button_radius: float = 50.0
@export var cooldown_duration: float = 0.5
@export var base_color: Color = Color(0.8, 0.3, 0.3, 0.8)
@export var cooldown_color: Color = Color(0.4, 0.2, 0.2, 0.5)
@export var ready_color: Color = Color(0.3, 0.8, 0.3, 0.8)

var is_ready: bool = true
var cooldown_timer: float = 0.0


func _ready() -> void:
	add_to_group("fire_button")
	custom_minimum_size = Vector2(button_radius * 2, button_radius * 2)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(delta: float) -> void:
	if not is_ready:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			is_ready = true
			cooldown_timer = 0.0
			cooldown_finished.emit()
		queue_redraw()


func _draw() -> void:
	var center := size / 2

	if is_ready:
		# Draw ready button
		draw_circle(center, button_radius, ready_color)
	else:
		# Draw cooldown background
		draw_circle(center, button_radius, cooldown_color)

		# Draw cooldown arc
		var progress := 1.0 - (cooldown_timer / cooldown_duration)
		var start_angle := -PI / 2
		var end_angle := start_angle + (TAU * progress)
		_draw_arc_filled(center, button_radius * 0.9, start_angle, end_angle, base_color)


func _draw_arc_filled(center: Vector2, radius: float, start_angle: float, end_angle: float, color: Color) -> void:
	var points := PackedVector2Array()
	points.append(center)

	var segments := 32
	var angle_step := (end_angle - start_angle) / segments

	for i in range(segments + 1):
		var angle := start_angle + angle_step * i
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)

	if points.size() > 2:
		draw_polygon(points, PackedColorArray([color]))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_try_fire()

	elif event is InputEventScreenTouch:
		if event.pressed:
			_try_fire()


func _try_fire() -> void:
	if is_ready:
		is_ready = false
		cooldown_timer = cooldown_duration
		cooldown_started.emit()
		fired.emit()
		queue_redraw()


func can_fire() -> bool:
	return is_ready


func get_cooldown_progress() -> float:
	if is_ready:
		return 1.0
	return 1.0 - (cooldown_timer / cooldown_duration)
