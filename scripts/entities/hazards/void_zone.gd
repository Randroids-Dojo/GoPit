class_name VoidZone
extends "res://scripts/entities/hazards/hazard_base.gd"
## Final Descent hazard - constant damage over time while inside

const VOID_DAMAGE: int = 3  # Lower per-tick but faster

var _pulse_tween: Tween


func _ready() -> void:
	effect_type = "void"
	damage_per_tick = VOID_DAMAGE
	tick_interval = 0.5  # Faster ticks
	hazard_radius = 80.0
	warning_duration = 1.0
	super._ready()


func _show_warning_visual() -> void:
	queue_redraw()
	modulate = Color(0.6, 0.1, 0.4, 0.2)


func _show_active_visual() -> void:
	modulate = Color(0.6, 0.1, 0.4, 0.7)
	_start_pulse()


func _start_pulse() -> void:
	"""Create pulsing effect for void zone."""
	if _pulse_tween:
		_pulse_tween.kill()

	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.tween_property(self, "modulate:a", 0.4, 0.5)
	_pulse_tween.tween_property(self, "modulate:a", 0.8, 0.5)


func _draw() -> void:
	# Draw void zone with concentric rings
	var num_rings := 4

	for i in range(num_rings):
		var ratio := float(num_rings - i) / num_rings
		var radius := hazard_radius * ratio
		var alpha := 0.7 * ratio if _is_active else 0.2 * ratio
		var color := Color(0.4, 0.0, 0.3, alpha)
		draw_circle(Vector2.ZERO, radius, color)

	# Draw outer energy ring
	if _is_active:
		var energy_color := Color(0.8, 0.2, 0.6, 0.5)
		draw_arc(Vector2.ZERO, hazard_radius, 0, TAU, 48, energy_color, 4.0)

		# Draw swirling void effect
		var time := Time.get_ticks_msec() / 1000.0
		for i in range(8):
			var angle := (i * PI / 4.0) + time * 0.5
			var inner := Vector2(cos(angle), sin(angle)) * hazard_radius * 0.3
			var outer := Vector2(cos(angle + 0.3), sin(angle + 0.3)) * hazard_radius * 0.9
			draw_line(inner, outer, Color(0.5, 0.1, 0.4, 0.4), 2.0)


func _process(_delta: float) -> void:
	# Redraw for animated swirl effect
	if _is_active:
		queue_redraw()


func _exit_tree() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
