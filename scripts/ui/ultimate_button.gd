extends Control
## Ultimate ability button with charge ring visualization
## Shows charge progress and pulses when ready to use

signal ultimate_activated

@export var button_radius: float = 35.0
@export var ring_width: float = 6.0
@export var empty_color: Color = Color(0.3, 0.3, 0.3, 0.6)
@export var charging_color: Color = Color(0.8, 0.6, 0.2, 0.9)
@export var ready_color: Color = Color(1.0, 0.9, 0.3, 1.0)
@export var inner_color: Color = Color(0.2, 0.2, 0.2, 0.7)

var _pulse_tween: Tween
var _is_pulsing: bool = false
var _pulse_scale: float = 1.0


func _ready() -> void:
	custom_minimum_size = Vector2(button_radius * 2 + 10, button_radius * 2 + 10)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Connect to GameManager signals
	GameManager.ultimate_charge_changed.connect(_on_charge_changed)
	GameManager.ultimate_ready.connect(_on_ultimate_ready)
	GameManager.ultimate_used.connect(_on_ultimate_used)
	GameManager.game_started.connect(_on_game_started)

	# Initial draw
	queue_redraw()


func _on_game_started() -> void:
	# Reset pulse state on new game
	_stop_pulse()
	queue_redraw()


func _on_charge_changed(_current: float, _max_val: float) -> void:
	queue_redraw()


func _on_ultimate_ready() -> void:
	_start_pulse()


func _on_ultimate_used() -> void:
	_stop_pulse()
	queue_redraw()


func _start_pulse() -> void:
	if _is_pulsing:
		return

	_is_pulsing = true

	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_method(_set_pulse_scale, 1.0, 1.15, 0.4).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_method(_set_pulse_scale, 1.15, 1.0, 0.4).set_ease(Tween.EASE_IN_OUT)


func _stop_pulse() -> void:
	_is_pulsing = false
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_scale = 1.0


func _set_pulse_scale(value: float) -> void:
	_pulse_scale = value
	queue_redraw()


func _draw() -> void:
	var center := size / 2
	var progress := GameManager.ultimate_charge / GameManager.ULTIMATE_CHARGE_MAX
	var is_ready := GameManager.is_ultimate_ready()

	# Apply pulse scale when ready
	var current_radius := button_radius * _pulse_scale

	# Draw inner circle (dark background)
	draw_circle(center, current_radius - ring_width / 2, inner_color)

	# Draw empty ring background
	draw_arc(center, current_radius, 0, TAU, 32, empty_color, ring_width)

	# Draw progress arc
	if progress > 0:
		var color := ready_color if is_ready else charging_color
		var start_angle := -PI / 2  # Start from top
		var end_angle := start_angle + TAU * progress
		draw_arc(center, current_radius, start_angle, end_angle, 32, color, ring_width)

	# Draw ready glow effect when pulsing
	if is_ready and _is_pulsing:
		var glow_color := Color(ready_color.r, ready_color.g, ready_color.b, 0.3 * (_pulse_scale - 1.0) * 6.67)
		draw_circle(center, current_radius + 5, glow_color)

	# Draw "!" indicator in center when ready
	if is_ready:
		# Simple visual cue - a small bright dot
		draw_circle(center, 5, ready_color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_try_activate()

	elif event is InputEventScreenTouch:
		if event.pressed:
			_try_activate()


func _try_activate() -> void:
	if GameManager.use_ultimate():
		ultimate_activated.emit()
