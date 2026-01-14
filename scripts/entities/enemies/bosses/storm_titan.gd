class_name StormTitan
extends "res://scripts/entities/enemies/boss_base.gd"
## Storm Titan - Stage 5 boss (Storm Spire). A lightning elemental with electric attacks.

# Visual settings
@export var base_color: Color = Color(0.2, 0.4, 0.8)
@export var body_radius: float = 50.0

# Attack settings
@export var bolt_damage: int = 30
@export var chain_damage: int = 15
@export var surge_damage: int = 40

# Phase colors (blue -> electric blue -> bright white-blue)
var _phase_colors: Array[Color] = [
	Color(0.2, 0.4, 0.8),   # Phase 1: Deep blue
	Color(0.3, 0.6, 1.0),   # Phase 2: Electric blue
	Color(0.7, 0.9, 1.0),   # Phase 3: Bright electric
]

# Attack state
var _bolt_target: Vector2 = Vector2.ZERO
var _lightning_active: bool = false
var _chain_targets: Array[Vector2] = []

# Movement
var _move_target: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0
var _player: Node2D = null
var _float_offset: float = 0.0


func _ready() -> void:
	boss_name = "Storm Titan"
	max_hp = 1000
	xp_value = 280
	damage_to_player = bolt_damage
	phase_thresholds = [1.0, 0.66, 0.33, 0.0]

	phase_attacks = {
		BossPhase.PHASE_1: ["bolt", "chain"],
		BossPhase.PHASE_2: ["bolt", "chain", "storm"],
		BossPhase.PHASE_3: ["bolt", "chain", "surge"],
	}

	attack_cooldown = 2.3
	telegraph_duration = 0.9

	_player = get_tree().get_first_node_in_group("player")

	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 180)

	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_float_offset += delta * 2.0
	queue_redraw()


func _draw() -> void:
	var current_color := _get_current_phase_color()
	var float_y := sin(_float_offset) * 8.0

	# Draw electric aura
	_draw_aura(Vector2(0, float_y), current_color)

	# Draw main body (angular/crystalline shape)
	_draw_body(Vector2(0, float_y), current_color)

	# Draw crackling electricity
	_draw_electricity(Vector2(0, float_y))

	# Draw eyes
	_draw_eyes(Vector2(0, float_y))

	# Draw bolt telegraph
	if attack_state == AttackState.TELEGRAPH and _current_attack == "bolt":
		if _bolt_target != Vector2.ZERO:
			var local_target := to_local(_bolt_target)
			var alpha := 0.5 + 0.3 * sin(Time.get_ticks_msec() * 0.02)
			draw_circle(local_target, 30, Color(0.8, 0.9, 1.0, alpha))
			# Draw line to target
			draw_line(Vector2(0, float_y), local_target, Color(0.5, 0.7, 1.0, 0.5), 3.0)


func _draw_aura(center: Vector2, color: Color) -> void:
	var aura_color := color
	aura_color.a = 0.2 + 0.1 * sin(Time.get_ticks_msec() * 0.005)
	for i in 3:
		var radius := body_radius + 20 + i * 15
		draw_arc(center, radius, 0, TAU, 32, aura_color, 2.0)


func _draw_body(center: Vector2, color: Color) -> void:
	# Angular/geometric body
	var points := PackedVector2Array([
		center + Vector2(0, -body_radius),
		center + Vector2(body_radius * 0.7, -body_radius * 0.3),
		center + Vector2(body_radius, body_radius * 0.2),
		center + Vector2(body_radius * 0.5, body_radius * 0.7),
		center + Vector2(0, body_radius),
		center + Vector2(-body_radius * 0.5, body_radius * 0.7),
		center + Vector2(-body_radius, body_radius * 0.2),
		center + Vector2(-body_radius * 0.7, -body_radius * 0.3),
	])
	draw_colored_polygon(points, color)

	# Inner glow
	var inner_color := color.lightened(0.4)
	var inner_points := PackedVector2Array()
	for p in points:
		inner_points.append(center + (p - center) * 0.6)
	draw_colored_polygon(inner_points, inner_color)


func _draw_electricity(center: Vector2) -> void:
	var bolt_color := Color(0.9, 0.95, 1.0)
	for i in 4:
		var angle := TAU * i / 4 + Time.get_ticks_msec() * 0.001
		var start := center + Vector2(cos(angle), sin(angle)) * body_radius * 0.8
		var end := center + Vector2(cos(angle), sin(angle)) * (body_radius + 30 + randf() * 20)
		_draw_lightning_bolt(start, end, bolt_color)


func _draw_lightning_bolt(start: Vector2, end: Vector2, color: Color) -> void:
	var points := [start]
	var segments := 4
	for i in range(1, segments):
		var t := float(i) / segments
		var mid := start.lerp(end, t)
		mid += Vector2(randf_range(-10, 10), randf_range(-10, 10))
		points.append(mid)
	points.append(end)

	for i in range(len(points) - 1):
		draw_line(points[i], points[i + 1], color, 2.0)


func _draw_eyes(center: Vector2) -> void:
	var look_dir := Vector2.DOWN
	if _player and is_instance_valid(_player):
		look_dir = (to_local(_player.global_position) - center).normalized()

	var eye_color := Color(1.0, 1.0, 0.8)
	draw_circle(center + Vector2(-12, -10), 8, eye_color)
	draw_circle(center + Vector2(-12, -10) + look_dir * 3, 4, Color(0.1, 0.2, 0.5))
	draw_circle(center + Vector2(12, -10), 8, eye_color)
	draw_circle(center + Vector2(12, -10) + look_dir * 3, 4, Color(0.1, 0.2, 0.5))


func _get_current_phase_color() -> Color:
	var phase_idx := get_current_phase_index()
	if phase_idx >= 0 and phase_idx < _phase_colors.size():
		return _phase_colors[phase_idx]
	return base_color


func _on_intro_start() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, -100)
	modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(self, "position:y", 180.0, intro_duration * 0.7)
	tween.parallel().tween_property(self, "modulate:a", 1.0, intro_duration * 0.5)
	tween.tween_callback(func():
		CameraShake.shake(12.0, 6.0)
		SoundManager.play(SoundManager.SoundType.FIRE)
	)


func _on_phase_enter(phase: BossPhase) -> void:
	queue_redraw()
	if phase == BossPhase.PHASE_3:
		attack_cooldown = 1.5
		telegraph_duration = 0.6


func _boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE and attack_state != AttackState.COOLDOWN:
		return

	_move_timer -= delta
	if _move_timer <= 0:
		_pick_new_move_target()
		_move_timer = randf_range(1.5, 3.0)

	var dir := (_move_target - global_position).normalized()
	var move_speed := 40.0
	global_position += dir * move_speed * delta

	var viewport_size := get_viewport().get_visible_rect().size
	global_position.x = clampf(global_position.x, 100, viewport_size.x - 100)
	global_position.y = clampf(global_position.y, 130, 350)


func _pick_new_move_target() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_move_target = Vector2(
		randf_range(150, viewport_size.x - 150),
		randf_range(150, 300)
	)


func _show_attack_telegraph(attack_name: String) -> void:
	super._show_attack_telegraph(attack_name)

	match attack_name:
		"bolt":
			if _player and is_instance_valid(_player):
				_bolt_target = _player.global_position
			queue_redraw()
		"chain":
			var tween := create_tween().set_loops(int(telegraph_duration / 0.1))
			tween.tween_property(self, "modulate", Color(1.5, 1.5, 2.0), 0.05)
			tween.tween_property(self, "modulate", Color.WHITE, 0.05)


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"bolt":
			_do_bolt_attack()
		"chain":
			_do_chain_attack()
		"storm":
			_do_storm_attack()
		"surge":
			_do_surge_attack()
		_:
			_end_attack()


func _do_bolt_attack() -> void:
	SoundManager.play(SoundManager.SoundType.FIRE)
	CameraShake.shake(8.0, 4.0)

	if _player and is_instance_valid(_player):
		var dist := _bolt_target.distance_to(_player.global_position)
		if dist < 60:
			GameManager.damage_player(bolt_damage)

	_bolt_target = Vector2.ZERO
	queue_redraw()

	var tween := create_tween()
	tween.tween_interval(0.2)
	tween.tween_callback(_end_attack)


func _do_chain_attack() -> void:
	SoundManager.play(SoundManager.SoundType.FIRE)

	# Chain lightning hits 3 times with delays
	for i in 3:
		var timer := get_tree().create_timer(i * 0.3)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 300:
					GameManager.damage_player(chain_damage)
					CameraShake.shake(4.0, 2.0)
		)

	var tween := create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(_end_attack)


func _do_storm_attack() -> void:
	var bat_scene := load("res://scenes/entities/enemies/bat.tscn")
	spawn_adds(bat_scene, 3, 100.0)
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)

	# Also do a bolt attack
	if _player and is_instance_valid(_player):
		_bolt_target = _player.global_position
		_do_bolt_attack()


func _do_surge_attack() -> void:
	# Massive lightning surge covering arena
	SoundManager.play(SoundManager.SoundType.FIRE)
	CameraShake.shake(20.0, 10.0)

	# 5 rapid bolts
	for i in 5:
		var timer := get_tree().create_timer(i * 0.2)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			CameraShake.shake(6.0, 3.0)
			if _player and is_instance_valid(_player):
				# Random chance to hit
				if randf() < 0.6:
					GameManager.damage_player(surge_damage / 3)
		)

	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(_end_attack)


func _update_attack(_delta: float) -> void:
	queue_redraw()


func _defeat() -> void:
	var game_controller := get_tree().get_first_node_in_group("game")
	if game_controller and game_controller.has_method("_spawn_fusion_reactor"):
		game_controller._spawn_fusion_reactor(global_position)

	for i in 16:
		var offset := Vector2(randf_range(-50, 50), randf_range(-50, 50))
		if game_controller and game_controller.has_method("_spawn_gem"):
			game_controller._spawn_gem(global_position + offset, 10)

	super._defeat()
