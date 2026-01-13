class_name FireVent
extends "res://scripts/entities/hazards/hazard_base.gd"
## Burning Sands hazard - periodic fire damage

const FIRE_DAMAGE: int = 5

var _fire_particles: CPUParticles2D


func _ready() -> void:
	effect_type = "fire"
	damage_per_tick = FIRE_DAMAGE
	tick_interval = 0.8
	hazard_radius = 50.0
	warning_duration = 2.0
	super._ready()
	_setup_particles()


func _setup_particles() -> void:
	_fire_particles = CPUParticles2D.new()
	_fire_particles.name = "FireParticles"
	_fire_particles.emitting = false
	_fire_particles.amount = 20
	_fire_particles.lifetime = 0.8
	_fire_particles.direction = Vector2(0, -1)
	_fire_particles.spread = 30.0
	_fire_particles.initial_velocity_min = 30.0
	_fire_particles.initial_velocity_max = 60.0
	_fire_particles.gravity = Vector2(0, -20)
	_fire_particles.scale_amount_min = 3.0
	_fire_particles.scale_amount_max = 6.0
	_fire_particles.color = Color(1.0, 0.4, 0.1, 0.8)
	add_child(_fire_particles)


func _show_warning_visual() -> void:
	queue_redraw()
	modulate = Color(1.0, 0.5, 0.2, 0.3)


func _show_active_visual() -> void:
	modulate = Color(1.0, 0.5, 0.2, 0.8)
	_fire_particles.emitting = true


func _draw() -> void:
	# Draw fire vent base
	var base_color := Color(0.3, 0.1, 0.05, 0.8) if _is_active else Color(0.3, 0.1, 0.05, 0.3)
	draw_circle(Vector2.ZERO, hazard_radius * 0.4, base_color)

	# Draw fire glow ring
	var glow_color := Color(1.0, 0.3, 0.0, 0.6) if _is_active else Color(1.0, 0.3, 0.0, 0.2)
	var ring_width := 8.0 if _is_active else 4.0
	draw_arc(Vector2.ZERO, hazard_radius * 0.6, 0, TAU, 32, glow_color, ring_width)

	# Draw outer warning ring
	if _is_active:
		var outer_color := Color(1.0, 0.5, 0.1, 0.3)
		draw_arc(Vector2.ZERO, hazard_radius, 0, TAU, 32, outer_color, 3.0)


func _on_tick() -> void:
	super._on_tick()
	# Flash effect on damage
	if _player_in_hazard and _is_active:
		var flash_tween := create_tween()
		flash_tween.tween_property(self, "modulate", Color(1.0, 1.0, 0.5, 1.0), 0.1)
		flash_tween.tween_property(self, "modulate", Color(1.0, 0.5, 0.2, 0.8), 0.2)
