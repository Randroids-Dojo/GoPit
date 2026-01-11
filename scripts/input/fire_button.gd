extends Control
## Fire button with cooldown timer visualization and autofire

signal fired
signal cooldown_started
signal cooldown_finished
signal blocked
signal autofire_toggled(enabled: bool)

@export var button_radius: float = 50.0
@export var cooldown_duration: float = 0.5
@export var base_color: Color = Color(0.8, 0.3, 0.3, 0.8)
@export var cooldown_color: Color = Color(0.4, 0.2, 0.2, 0.5)
@export var ready_color: Color = Color(0.3, 0.8, 0.3, 0.8)
@export var autofire_color: Color = Color(0.3, 0.8, 0.6, 0.8)

var is_ready: bool = true
var cooldown_timer: float = 0.0
var autofire_enabled: bool = true  # Default ON for smoother gameplay
var _shake_tween: Tween


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

	# Autofire: automatically fire when ready
	if autofire_enabled and is_ready and GameManager.current_state == GameManager.GameState.PLAYING:
		_try_fire()


func _draw() -> void:
	var center := size / 2

	# Choose color based on autofire state
	var active_ready_color := autofire_color if autofire_enabled else ready_color

	if is_ready:
		# Draw ready button
		draw_circle(center, button_radius, active_ready_color)
	else:
		# Draw cooldown background
		draw_circle(center, button_radius, cooldown_color)

		# Draw cooldown arc
		var progress := 1.0 - (cooldown_timer / cooldown_duration)
		var start_angle := -PI / 2
		var end_angle := start_angle + (TAU * progress)
		_draw_arc_filled(center, button_radius * 0.9, start_angle, end_angle, base_color)

	# Draw autofire indicator ring when enabled
	if autofire_enabled:
		draw_arc(center, button_radius + 3, 0, TAU, 32, Color(0.2, 1.0, 0.6, 0.8), 3.0)


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
			if is_ready:
				_try_fire()
			else:
				_on_blocked()

	elif event is InputEventScreenTouch:
		if event.pressed:
			if is_ready:
				_try_fire()
			else:
				_on_blocked()


func _try_fire() -> void:
	if is_ready:
		is_ready = false
		# Apply character speed multiplier to cooldown (higher speed = faster fire)
		cooldown_timer = cooldown_duration / GameManager.character_speed_mult
		cooldown_started.emit()
		fired.emit()
		queue_redraw()


func _on_blocked() -> void:
	blocked.emit()
	_shake_button()
	_flash_red()
	SoundManager.play(SoundManager.SoundType.BLOCKED)


func _shake_button() -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()

	# Capture current position at shake time (after container layout)
	var start_x := position.x
	_shake_tween = create_tween()
	_shake_tween.tween_property(self, "position:x", start_x + 5, 0.05)
	_shake_tween.tween_property(self, "position:x", start_x - 5, 0.05)
	_shake_tween.tween_property(self, "position:x", start_x + 3, 0.05)
	_shake_tween.tween_property(self, "position:x", start_x, 0.05)


func _flash_red() -> void:
	var original := modulate
	modulate = Color(1.5, 0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate", original, 0.1)


func can_fire() -> bool:
	return is_ready


func get_cooldown_progress() -> float:
	if is_ready:
		return 1.0
	return 1.0 - (cooldown_timer / cooldown_duration)


func toggle_autofire() -> void:
	autofire_enabled = not autofire_enabled
	autofire_toggled.emit(autofire_enabled)
	queue_redraw()


func set_autofire(enabled: bool) -> void:
	if autofire_enabled != enabled:
		autofire_enabled = enabled
		autofire_toggled.emit(autofire_enabled)
		queue_redraw()
