class_name IcePatch
extends "res://scripts/entities/hazards/hazard_base.gd"
## Frozen Depths hazard - slows player movement

const SLOW_AMOUNT: float = 0.5  # Player moves at 50% speed

var _affected_player: Node2D = null


func _ready() -> void:
	effect_type = "ice"
	damage_per_tick = 0  # No damage, just slow
	hazard_radius = 70.0
	warning_duration = 1.5
	super._ready()


func _show_warning_visual() -> void:
	# Draw semi-transparent ice circle
	queue_redraw()
	modulate = Color(0.7, 0.9, 1.0, 0.3)


func _show_active_visual() -> void:
	# Brighter ice visual
	modulate = Color(0.7, 0.9, 1.0, 0.7)


func _draw() -> void:
	# Draw ice patch circle
	var color := Color(0.5, 0.8, 1.0, 0.6) if _is_active else Color(0.5, 0.8, 1.0, 0.2)
	draw_circle(Vector2.ZERO, hazard_radius, color)

	# Draw ice crystal pattern
	if _is_active:
		var crystal_color := Color(0.8, 0.95, 1.0, 0.8)
		for i in range(6):
			var angle := i * PI / 3.0
			var start := Vector2.ZERO
			var end := Vector2(cos(angle), sin(angle)) * hazard_radius * 0.7
			draw_line(start, end, crystal_color, 2.0)


func _apply_effect() -> void:
	_affected_player = get_tree().get_first_node_in_group("player")
	if _affected_player and _affected_player.has_method("apply_slow"):
		_affected_player.apply_slow(SLOW_AMOUNT)


func _remove_effect() -> void:
	if _affected_player and _affected_player.has_method("remove_slow"):
		_affected_player.remove_slow()
	_affected_player = null
