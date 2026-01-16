class_name AbyssalHorror
extends "res://scripts/entities/enemies/boss_base.gd"
## Abyssal Horror - Stage 7 final boss (The Abyss). The ultimate nightmare from the depths.

# Visual settings
@export var base_color: Color = Color(0.1, 0.05, 0.15)
@export var body_radius: float = 70.0

# Attack settings
@export var tentacle_damage: int = 30
@export var void_damage: int = 40
@export var devour_damage: int = 50
@export var chaos_damage: int = 25

# Phase colors (dark -> darker -> void black with glow)
var _phase_colors: Array[Color] = [
	Color(0.1, 0.05, 0.15),   # Phase 1: Dark purple
	Color(0.05, 0.02, 0.1),   # Phase 2: Darker
	Color(0.02, 0.01, 0.05),  # Phase 3: Near black
]

# Tentacles
var _tentacles: Array[Dictionary] = []  # {angle, length, wave_offset}
const NUM_TENTACLES := 8

# Attack state
var _void_zones: Array[Vector2] = []
var _devour_target: Vector2 = Vector2.ZERO

# Movement
var _move_target: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0
var _player: Node2D = null
var _pulse: float = 0.0


func _ready() -> void:
	boss_name = "Abyssal Horror"
	max_hp = 1500
	xp_value = 500
	damage_to_player = tentacle_damage
	phase_thresholds = [1.0, 0.66, 0.33, 0.0]

	phase_attacks = {
		BossPhase.PHASE_1: ["tentacles", "void"],
		BossPhase.PHASE_2: ["tentacles", "void", "summon"],
		BossPhase.PHASE_3: ["tentacles", "void", "devour", "chaos"],
	}

	attack_cooldown = 2.0
	telegraph_duration = 1.2

	# Initialize tentacles
	for i in NUM_TENTACLES:
		_tentacles.append({
			"angle": TAU * i / NUM_TENTACLES,
			"length": body_radius + 40 + randf() * 30,
			"wave_offset": randf() * TAU
		})

	_player = get_tree().get_first_node_in_group("player")

	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 200)

	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_pulse += delta * 2.0

	# Update tentacle animation
	for tentacle in _tentacles:
		tentacle.angle += delta * 0.2
		tentacle.wave_offset += delta * 3.0

	# Check void zone damage
	if _void_zones.size() > 0 and _player and is_instance_valid(_player):
		for zone in _void_zones:
			var dist := zone.distance_to(_player.global_position)
			if dist < 60:
				GameManager.damage_player(2)  # Tick damage
				break

	queue_redraw()


func _draw() -> void:
	var current_color := _get_current_phase_color()

	# Draw void aura
	_draw_void_aura()

	# Draw tentacles
	for tentacle in _tentacles:
		_draw_tentacle(tentacle, current_color)

	# Draw main body (dark sphere with eye)
	_draw_body(current_color)

	# Draw the eye
	_draw_eye()

	# Draw void zones
	for zone in _void_zones:
		_draw_void_zone(to_local(zone))

	# Draw devour telegraph
	if attack_state == AttackState.TELEGRAPH and _current_attack == "devour":
		if _devour_target != Vector2.ZERO:
			var local_target := to_local(_devour_target)
			var alpha := 0.6 + 0.3 * sin(Time.get_ticks_msec() * 0.015)
			draw_circle(local_target, 100, Color(0.1, 0.0, 0.15, alpha))
			# Spiral inward effect
			for i in 3:
				var spiral_angle := Time.get_ticks_msec() * 0.01 + i * TAU / 3
				var spiral_dist := 80 - (Time.get_ticks_msec() % 1000) * 0.05
				var spiral_pos := local_target + Vector2(cos(spiral_angle), sin(spiral_angle)) * spiral_dist
				draw_circle(spiral_pos, 5, Color(0.3, 0.1, 0.4, alpha))


func _draw_void_aura() -> void:
	var aura_alpha := 0.15 + 0.1 * sin(_pulse)
	for i in 5:
		var radius := body_radius + 30 + i * 20
		var aura_color := Color(0.2, 0.1, 0.3, aura_alpha - i * 0.02)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 48, aura_color, 8.0 - i)


func _draw_tentacle(tentacle: Dictionary, color: Color) -> void:
	var points := PackedVector2Array()
	var segments := 12
	var base_angle: float = tentacle.angle
	var length: float = tentacle.length
	var wave_offset: float = tentacle.wave_offset

	for i in range(segments + 1):
		var t := float(i) / segments
		var wave := sin(t * 4 + wave_offset) * 15 * t
		var dist := t * length
		var angle := base_angle + wave * 0.02
		var pos := Vector2(cos(angle), sin(angle)) * dist
		pos.x += wave
		points.append(pos)

	# Draw tentacle with gradient
	for i in range(points.size() - 1):
		var t := float(i) / (points.size() - 1)
		var width := 12.0 * (1.0 - t * 0.7)
		var tent_color := color.lightened(t * 0.3)
		draw_line(points[i], points[i + 1], tent_color, width)


func _draw_body(color: Color) -> void:
	# Dark sphere body
	draw_circle(Vector2.ZERO, body_radius, color)

	# Inner darker circle
	draw_circle(Vector2.ZERO, body_radius * 0.7, color.darkened(0.3))

	# Pulsing glow
	var glow_alpha := 0.3 + 0.2 * sin(_pulse)
	draw_circle(Vector2.ZERO, body_radius * 0.5, Color(0.3, 0.1, 0.4, glow_alpha))


func _draw_eye() -> void:
	var look_dir := Vector2.DOWN
	if _player and is_instance_valid(_player):
		look_dir = (to_local(_player.global_position)).normalized()

	# Outer eye
	var eye_glow := 0.7 + 0.3 * sin(_pulse * 1.5)
	draw_circle(Vector2.ZERO, 25, Color(0.8, 0.2, 0.3, eye_glow))

	# Pupil
	var pupil_pos := look_dir * 8
	draw_circle(pupil_pos, 12, Color(0.1, 0.0, 0.1))

	# Eye gleam
	draw_circle(Vector2(-5, -5), 4, Color(1.0, 0.8, 0.8, 0.8))


func _draw_void_zone(center: Vector2) -> void:
	var alpha := 0.4 + 0.2 * sin(_pulse + center.x * 0.01)
	draw_circle(center, 60, Color(0.1, 0.0, 0.15, alpha))
	draw_circle(center, 40, Color(0.05, 0.0, 0.1, alpha + 0.2))
	draw_circle(center, 20, Color(0.0, 0.0, 0.05, alpha + 0.3))


func _get_current_phase_color() -> Color:
	var phase_idx := get_current_phase_index()
	if phase_idx >= 0 and phase_idx < _phase_colors.size():
		return _phase_colors[phase_idx]
	return base_color


func _on_intro_start() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 200)
	scale = Vector2(0.1, 0.1)
	modulate = Color(0.5, 0.2, 0.5)

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), intro_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, intro_duration * 0.5)
	tween.tween_callback(func():
		CameraShake.shake(25.0, 12.0)
		SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)
	)


func _on_phase_enter(phase: BossPhase) -> void:
	queue_redraw()

	if phase == BossPhase.PHASE_2:
		attack_cooldown = 1.8

	if phase == BossPhase.PHASE_3:
		attack_cooldown = 1.5
		telegraph_duration = 0.9
		# Permanent screen shake in phase 3
		CameraShake.shake(5.0, 999.0)


func _boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE and attack_state != AttackState.COOLDOWN:
		return

	_move_timer -= delta
	if _move_timer <= 0:
		_pick_new_move_target()
		_move_timer = randf_range(1.5, 3.0)

	var dir := (_move_target - global_position).normalized()
	var move_speed := 35.0 if current_phase != BossPhase.PHASE_3 else 50.0
	global_position += dir * move_speed * delta

	var viewport_size := get_viewport().get_visible_rect().size
	global_position.x = clampf(global_position.x, 120, viewport_size.x - 120)
	global_position.y = clampf(global_position.y, 150, 380)


func _pick_new_move_target() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_move_target = Vector2(
		randf_range(150, viewport_size.x - 150),
		randf_range(170, 330)
	)


func _show_attack_telegraph(attack_name: String) -> void:
	super._show_attack_telegraph(attack_name)

	match attack_name:
		"tentacles":
			var tween := create_tween().set_loops(int(telegraph_duration / 0.1))
			tween.tween_property(self, "modulate", Color(1.5, 0.8, 1.5), 0.05)
			tween.tween_property(self, "modulate", Color.WHITE, 0.05)
		"devour":
			if _player and is_instance_valid(_player):
				_devour_target = _player.global_position
			queue_redraw()


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"tentacles":
			_do_tentacles_attack()
		"void":
			_do_void_attack()
		"summon":
			_do_summon_attack()
		"devour":
			_do_devour_attack()
		"chaos":
			_do_chaos_attack()
		_:
			_end_attack()


func _do_tentacles_attack() -> void:
	SoundManager.play(SoundManager.SoundType.FIRE)

	# Extend all tentacles and check for hits
	for tentacle in _tentacles:
		tentacle.length = body_radius + 120

	if _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist < body_radius + 130:
			GameManager.damage_player(tentacle_damage)

	CameraShake.shake(8.0, 4.0)

	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		for tentacle in _tentacles:
			tentacle.length = body_radius + 40 + randf() * 30
		_end_attack()
	)


func _do_void_attack() -> void:
	var viewport_size := get_viewport().get_visible_rect().size

	# Spawn 2-4 void zones
	var count := randi_range(2, 4)
	for i in count:
		var zone_pos := Vector2(
			randf_range(100, viewport_size.x - 100),
			randf_range(500, viewport_size.y - 150)
		)
		_void_zones.append(zone_pos)

	queue_redraw()

	# Zones last 6 seconds
	var tween := create_tween()
	tween.tween_interval(6.0)
	tween.tween_callback(func():
		_void_zones.clear()
		queue_redraw()
	)

	_end_attack()


func _do_summon_attack() -> void:
	# Summon a mix of enemies
	var swarm_scene := load("res://scenes/entities/enemies/swarm.tscn")
	var bat_scene := load("res://scenes/entities/enemies/bat.tscn")

	spawn_adds(swarm_scene, 2, 100.0)
	spawn_adds(bat_scene, 2, 120.0)

	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	_end_attack()


func _do_devour_attack() -> void:
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)

	# Pull toward devour target then massive damage
	var original_pos := global_position

	var tween := create_tween()
	tween.tween_property(self, "global_position", _devour_target, 0.4).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		CameraShake.shake(20.0, 10.0)
		if _player and is_instance_valid(_player):
			var dist := global_position.distance_to(_player.global_position)
			if dist < 120:
				GameManager.damage_player(devour_damage)
	)
	tween.tween_interval(0.3)
	tween.tween_property(self, "global_position", original_pos, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		_devour_target = Vector2.ZERO
		queue_redraw()
		_end_attack()
	)


func _do_chaos_attack() -> void:
	# Ultimate attack - everything at once
	SoundManager.play(SoundManager.SoundType.FIRE)
	CameraShake.shake(25.0, 12.0)

	# Extend tentacles
	for tentacle in _tentacles:
		tentacle.length = body_radius + 150

	# Spawn void zones
	var viewport_size := get_viewport().get_visible_rect().size
	for i in 6:
		var zone_pos := Vector2(
			randf_range(80, viewport_size.x - 80),
			randf_range(450, viewport_size.y - 100)
		)
		_void_zones.append(zone_pos)

	# Multiple damage checks
	for i in 5:
		var timer := get_tree().create_timer(i * 0.3)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			if _player and is_instance_valid(_player):
				if randf() < 0.5:
					GameManager.damage_player(chaos_damage)
					CameraShake.shake(6.0, 3.0)
		)

	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(func():
		for tentacle in _tentacles:
			tentacle.length = body_radius + 40 + randf() * 30
		_void_zones.clear()
		queue_redraw()
		_end_attack()
	)


func _update_attack(_delta: float) -> void:
	queue_redraw()


func _defeat() -> void:
	_void_zones.clear()

	# Stop phase 3 screen shake
	CameraShake.shake(0.0, 0.0)

	var game_controller := get_tree().get_first_node_in_group("game")
	if game_controller and game_controller.has_method("_spawn_fusion_reactor"):
		game_controller._spawn_fusion_reactor(global_position)

	# Massive gem explosion for final boss
	for i in 25:
		var offset := Vector2(randf_range(-80, 80), randf_range(-80, 80))
		if game_controller and game_controller.has_method("_spawn_gem"):
			game_controller._spawn_gem(global_position + offset, 12)

	super._defeat()
