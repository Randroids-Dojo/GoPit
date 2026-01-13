class_name VoidLord
extends "res://scripts/entities/enemies/boss_base.gd"
## Void Lord - Final boss. An ethereal cosmic entity with devastating attacks.

const VOID_PROJECTILE_SCENE: PackedScene = preload("res://scenes/entities/enemies/enemy_projectile.tscn")

# Visual settings
@export var base_color: Color = Color(0.2, 0.1, 0.3)
@export var glow_color: Color = Color(0.6, 0.2, 0.8)
@export var body_radius: float = 70.0

# Attack settings
@export var beam_damage: int = 40
@export var orb_damage: int = 20
@export var nova_damage: int = 50

# Phase colors (dark purple -> violet -> bright violet)
var _phase_colors: Array[Color] = [
	Color(0.2, 0.1, 0.3),  # Phase 1: Dark purple
	Color(0.4, 0.15, 0.5), # Phase 2: Violet
	Color(0.6, 0.2, 0.7),  # Phase 3: Bright violet
]

# Animation
var _pulse_offset: float = 0.0
var _tentacle_offsets: Array[float] = []
const TENTACLE_COUNT: int = 8

# Beam attack tracking
var _beam_target: Vector2 = Vector2.ZERO
var _beam_active: bool = false

# Movement
var _move_target: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0
var _float_offset: float = 0.0

# Player reference
var _player: Node2D = null


func _ready() -> void:
	boss_name = "Void Lord"
	max_hp = 1000
	xp_value = 300
	damage_to_player = beam_damage
	phase_thresholds = [1.0, 0.66, 0.33, 0.0]

	# Set up attack patterns per phase
	phase_attacks = {
		BossPhase.PHASE_1: ["beam", "orbs"],
		BossPhase.PHASE_2: ["beam", "orbs", "tentacles"],
		BossPhase.PHASE_3: ["beam", "orbs", "nova"],
	}

	attack_cooldown = 3.0
	telegraph_duration = 1.3

	# Find player
	_player = get_tree().get_first_node_in_group("player")

	# Set initial position
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 300)

	# Initialize tentacle offsets
	_tentacle_offsets.clear()
	for i in TENTACLE_COUNT:
		_tentacle_offsets.append(randf() * TAU)

	super._ready()


func _process(delta: float) -> void:
	_pulse_offset += delta * 2.0
	_float_offset += delta * 1.5
	queue_redraw()


func _draw() -> void:
	var current_color := _get_current_phase_color()

	# Draw void aura
	_draw_void_aura(current_color)

	# Draw tentacles
	_draw_tentacles(current_color)

	# Draw core body
	_draw_body(current_color)

	# Draw eye
	_draw_eye()

	# Draw beam telegraph
	if attack_state == AttackState.TELEGRAPH and _current_attack == "beam":
		_draw_beam_telegraph()

	# Draw active beam
	if _beam_active:
		_draw_active_beam()


func _draw_void_aura(color: Color) -> void:
	# Pulsing aura rings
	var pulse := sin(_pulse_offset) * 0.3 + 0.7
	var aura_color := glow_color
	aura_color.a = 0.2 * pulse

	for i in range(3):
		var radius: float = body_radius * (1.3 + i * 0.2) * pulse
		_draw_ring(Vector2.ZERO, radius, aura_color, 2.0)


func _draw_ring(center: Vector2, radius: float, color: Color, thickness: float) -> void:
	var segments := 32
	var prev_point := center + Vector2(radius, 0)
	for i in range(1, segments + 1):
		var angle := TAU * i / segments
		var point := center + Vector2(cos(angle) * radius, sin(angle) * radius)
		draw_line(prev_point, point, color, thickness)
		prev_point = point


func _draw_tentacles(color: Color) -> void:
	for i in TENTACLE_COUNT:
		var base_angle := (TAU / TENTACLE_COUNT) * i
		var wave := sin(_pulse_offset * 2.0 + _tentacle_offsets[i]) * 0.3
		var angle := base_angle + wave

		var start := Vector2(cos(angle), sin(angle)) * body_radius * 0.8
		var length: float = 80.0 + sin(_pulse_offset + i) * 20.0

		_draw_tentacle(start, angle, length, color)


func _draw_tentacle(start: Vector2, angle: float, length: float, color: Color) -> void:
	var segments := 5
	var prev_pos := start
	var width: float = 12.0

	for i in range(segments):
		var t := float(i + 1) / segments
		var wave := sin(_pulse_offset * 3.0 + i * 0.5) * 10.0 * t
		var dir := Vector2(cos(angle), sin(angle))
		var perp := Vector2(-dir.y, dir.x)

		var pos := start + dir * length * t + perp * wave
		var seg_width: float = width * (1.0 - t * 0.7)

		draw_line(prev_pos, pos, color, seg_width)
		prev_pos = pos

	# Tentacle tip
	draw_circle(prev_pos, 4, glow_color)


func _draw_body(color: Color) -> void:
	# Main body (dark sphere with glow)
	draw_circle(Vector2.ZERO, body_radius, color)

	# Inner glow
	var glow_pulse := sin(_pulse_offset) * 0.2 + 0.8
	draw_circle(Vector2.ZERO, body_radius * 0.7, glow_color.darkened(0.3 * glow_pulse))

	# Surface details
	var detail_color := color.lightened(0.2)
	for i in range(5):
		var angle := (TAU / 5) * i + _pulse_offset * 0.2
		var pos := Vector2(cos(angle), sin(angle)) * body_radius * 0.5
		draw_circle(pos, 8, detail_color)


func _draw_eye() -> void:
	# Central eye
	var float_y := sin(_float_offset) * 5

	# Eye socket
	draw_circle(Vector2(0, float_y), 30, Color.BLACK)

	# Eye white
	var eye_color := Color(0.8, 0.2, 0.5)
	draw_circle(Vector2(0, float_y), 25, eye_color)

	# Pupil that tracks player
	var look_dir := Vector2.DOWN
	if _player and is_instance_valid(_player):
		look_dir = (to_local(_player.global_position)).normalized()

	draw_circle(Vector2(0, float_y) + look_dir * 10, 12, Color.BLACK)

	# Eye highlight
	draw_circle(Vector2(-5, float_y - 5), 5, Color(1.0, 0.8, 0.9))


func _draw_beam_telegraph() -> void:
	if not _player:
		return

	var to_player := (_player.global_position - global_position).normalized()
	var beam_end := to_player * 800

	var alpha: float = 0.3 + 0.2 * sin(Time.get_ticks_msec() * 0.015)
	var beam_color := glow_color
	beam_color.a = alpha

	draw_line(Vector2.ZERO, beam_end, beam_color, 20.0)


func _draw_active_beam() -> void:
	var to_target := (_beam_target - global_position).normalized()
	var beam_end := to_target * 900

	# Multiple beam layers for effect
	draw_line(Vector2.ZERO, beam_end, glow_color, 30.0)
	draw_line(Vector2.ZERO, beam_end, Color.WHITE, 15.0)
	draw_line(Vector2.ZERO, beam_end, glow_color.lightened(0.5), 8.0)


func _get_current_phase_color() -> Color:
	var phase_idx := get_current_phase_index()
	if phase_idx >= 0 and phase_idx < _phase_colors.size():
		return _phase_colors[phase_idx]
	return base_color


func _on_intro_start() -> void:
	# Void Lord materializes from darkness
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 300)
	modulate.a = 0.0
	scale = Vector2(0.3, 0.3)

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, intro_duration * 0.6)
	tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), intro_duration).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		CameraShake.shake(20.0, 10.0)
		SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	)


func _on_phase_enter(phase: BossPhase) -> void:
	queue_redraw()

	if phase == BossPhase.PHASE_3:
		attack_cooldown = 2.0
		telegraph_duration = 1.0
		# Permanent screen shake in final phase
		CameraShake.shake(3.0, 60.0)


func _boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE and attack_state != AttackState.COOLDOWN:
		return

	_move_timer -= delta
	if _move_timer <= 0:
		_pick_new_move_target()
		_move_timer = randf_range(2.0, 3.5)

	# Ethereal floating movement
	var dir := (_move_target - global_position).normalized()
	var move_speed: float = 35.0 if current_phase != BossPhase.PHASE_3 else 55.0
	global_position += dir * move_speed * delta

	# Floating bob effect
	position.y += sin(_float_offset) * 0.5

	# Clamp to arena
	var viewport_size := get_viewport().get_visible_rect().size
	global_position.x = clampf(global_position.x, 100, viewport_size.x - 100)
	global_position.y = clampf(global_position.y, 180, 420)


func _pick_new_move_target() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_move_target = Vector2(
		randf_range(150, viewport_size.x - 150),
		randf_range(200, 380)
	)


# === ATTACK IMPLEMENTATIONS ===

func _show_attack_telegraph(attack_name: String) -> void:
	super._show_attack_telegraph(attack_name)

	match attack_name:
		"beam":
			if _player and is_instance_valid(_player):
				_beam_target = _player.global_position
			queue_redraw()
		"orbs":
			var tween := create_tween().set_loops(int(telegraph_duration / 0.15))
			tween.tween_property(self, "modulate", glow_color.lightened(0.5), 0.075)
			tween.tween_property(self, "modulate", Color.WHITE, 0.075)
		"tentacles":
			CameraShake.shake(5.0, telegraph_duration)
		"nova":
			# Dramatic buildup
			var tween := create_tween()
			tween.tween_property(self, "scale", Vector2(1.2, 1.2), telegraph_duration * 0.5)
			CameraShake.shake(10.0, telegraph_duration)


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"beam":
			_do_beam_attack()
		"orbs":
			_do_orbs_attack()
		"tentacles":
			_do_tentacles_attack()
		"nova":
			_do_nova_attack()
		_:
			_end_attack()


func _do_beam_attack() -> void:
	"""Fire a devastating beam at player"""
	SoundManager.play(SoundManager.SoundType.FIRE)
	_beam_active = true

	if _player and is_instance_valid(_player):
		_beam_target = _player.global_position

	# Sweep beam
	var sweep_duration := 1.0
	var start_angle: float = 0.0
	var end_angle: float = 0.0

	if _player and is_instance_valid(_player):
		start_angle = (to_local(_player.global_position)).angle() - 0.5
		end_angle = start_angle + 1.0

	# Damage ticks during sweep
	var tick_count := 5
	for i in tick_count:
		var timer := get_tree().create_timer(i * (sweep_duration / tick_count))
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			# Update beam direction
			var t: float = float(i) / tick_count
			var current_angle: float = lerpf(start_angle, end_angle, t)
			_beam_target = global_position + Vector2(cos(current_angle), sin(current_angle)) * 500

			# Check if player is in beam path
			if _player and is_instance_valid(_player):
				var to_player: Vector2 = _player.global_position - global_position
				var beam_dir: Vector2 = (_beam_target - global_position).normalized()
				var player_dir: Vector2 = to_player.normalized()
				var angle_diff: float = absf(beam_dir.angle_to(player_dir))

				if angle_diff < 0.2 and to_player.length() < 600:
					GameManager.take_damage(beam_damage / tick_count)
					CameraShake.shake(6.0, 3.0)

			queue_redraw()
		)

	var end_timer := get_tree().create_timer(sweep_duration + 0.3)
	end_timer.timeout.connect(func():
		if is_instance_valid(self):
			_beam_active = false
			_end_attack()
	)


func _do_orbs_attack() -> void:
	"""Spawn homing void orbs"""
	var orb_count := 6 if current_phase == BossPhase.PHASE_3 else 4

	for i in orb_count:
		var angle := (TAU / orb_count) * i
		var timer := get_tree().create_timer(i * 0.15)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			_spawn_void_orb(angle)
		)

	var end_timer := get_tree().create_timer(orb_count * 0.15 + 1.5)
	end_timer.timeout.connect(func():
		if is_instance_valid(self):
			_end_attack()
	)


func _spawn_void_orb(angle: float) -> void:
	var orb = VOID_PROJECTILE_SCENE.instantiate()
	orb.global_position = global_position + Vector2(cos(angle), sin(angle)) * body_radius

	# Initial direction outward, then curve toward player
	orb.direction = Vector2(cos(angle), sin(angle))
	orb.speed = 200.0
	orb.damage = orb_damage
	orb.projectile_color = glow_color

	get_tree().current_scene.add_child(orb)
	SoundManager.play(SoundManager.SoundType.FIRE)


func _do_tentacles_attack() -> void:
	"""Tentacles strike at player from multiple directions"""
	var strike_count := 4

	for i in strike_count:
		var timer := get_tree().create_timer(i * 0.4)
		timer.timeout.connect(func():
			if not is_instance_valid(self) or not _player or not is_instance_valid(_player):
				return

			# Strike from random direction
			var angle := randf() * TAU
			CameraShake.shake(8.0, 4.0)

			# Check hit
			var dist := global_position.distance_to(_player.global_position)
			if dist < 200:
				GameManager.take_damage(15)
		)

	var end_timer := get_tree().create_timer(strike_count * 0.4 + 0.5)
	end_timer.timeout.connect(func():
		if is_instance_valid(self):
			_end_attack()
	)


func _do_nova_attack() -> void:
	"""Devastating void nova - screen-wide damage"""
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)

	# Expansion
	var expand_tween := create_tween()
	expand_tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.3)
	expand_tween.tween_callback(func():
		# Nova explosion
		CameraShake.shake(25.0, 8.0)
		GameManager.take_damage(nova_damage)

		# Spawn orbs in all directions
		for i in 8:
			_spawn_void_orb((TAU / 8) * i)
	)
	expand_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
	expand_tween.tween_callback(_end_attack)


func _update_attack(_delta: float) -> void:
	queue_redraw()


func _defeat() -> void:
	# Spawn guaranteed fusion reactor
	var game_controller := get_tree().get_first_node_in_group("game")
	if game_controller and game_controller.has_method("_spawn_fusion_reactor"):
		game_controller._spawn_fusion_reactor(global_position)

	# Spawn lots of gems (final boss = big reward)
	for i in 20:
		var offset := Vector2(randf_range(-100, 100), randf_range(-100, 100))
		if game_controller and game_controller.has_method("_spawn_gem"):
			game_controller._spawn_gem(global_position + offset, 20)

	# Special victory effect
	CameraShake.shake(30.0, 15.0)

	super._defeat()
