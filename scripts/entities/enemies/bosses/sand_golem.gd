class_name SandGolem
extends "res://scripts/entities/enemies/boss_base.gd"
## Sand Golem - Third boss. A massive stone creature with slam, boulder, and sandstorm attacks.

const BOULDER_SCENE: PackedScene = preload("res://scenes/entities/enemies/enemy_projectile.tscn")

# Visual settings
@export var base_color: Color = Color(0.8, 0.65, 0.4)
@export var body_width: float = 80.0
@export var body_height: float = 100.0

# Attack settings
@export var slam_damage: int = 35
@export var slam_radius: float = 150.0
@export var boulder_damage: int = 25
@export var boulder_count: int = 3

# Phase colors (tan -> orange -> red-orange)
var _phase_colors: Array[Color] = [
	Color(0.8, 0.65, 0.4),  # Phase 1: Tan
	Color(0.9, 0.5, 0.3),   # Phase 2: Orange
	Color(0.95, 0.35, 0.2), # Phase 3: Red-orange
]

# Animation state
var _arm_swing: float = 0.0
var _is_slamming: bool = false
var _slam_target: Vector2 = Vector2.ZERO

# Movement
var _move_target: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0

# Player reference
var _player: Node2D = null


func _ready() -> void:
	boss_name = "Sand Golem"
	max_hp = 800
	xp_value = 200
	damage_to_player = slam_damage
	phase_thresholds = [1.0, 0.66, 0.33, 0.0]

	# Set up attack patterns per phase
	phase_attacks = {
		BossPhase.PHASE_1: ["slam", "boulder"],
		BossPhase.PHASE_2: ["slam", "boulder", "eruption"],
		BossPhase.PHASE_3: ["slam", "boulder", "sandstorm"],
	}

	attack_cooldown = 3.5
	telegraph_duration = 1.5

	# Find player
	_player = get_tree().get_first_node_in_group("player")

	# Set initial position
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 280)

	super._ready()


func _process(delta: float) -> void:
	# Animate arms
	_arm_swing = sin(Time.get_ticks_msec() * 0.003) * 0.2
	queue_redraw()


func _draw() -> void:
	var current_color := _get_current_phase_color()

	# Draw body
	_draw_body(current_color)

	# Draw arms
	_draw_arms(current_color)

	# Draw head
	_draw_head(current_color)

	# Draw slam telegraph
	if attack_state == AttackState.TELEGRAPH and _current_attack == "slam":
		_draw_slam_telegraph()


func _draw_body(color: Color) -> void:
	# Massive rocky body
	var body_points := PackedVector2Array([
		Vector2(-body_width * 0.6, -body_height * 0.3),
		Vector2(-body_width * 0.8, body_height * 0.1),
		Vector2(-body_width * 0.7, body_height * 0.5),
		Vector2(-body_width * 0.3, body_height * 0.6),
		Vector2(body_width * 0.3, body_height * 0.6),
		Vector2(body_width * 0.7, body_height * 0.5),
		Vector2(body_width * 0.8, body_height * 0.1),
		Vector2(body_width * 0.6, -body_height * 0.3),
	])
	draw_colored_polygon(body_points, color)

	# Rock texture details
	var dark_color := color.darkened(0.2)
	draw_circle(Vector2(-30, 10), 15, dark_color)
	draw_circle(Vector2(25, -5), 12, dark_color)
	draw_circle(Vector2(0, 35), 18, dark_color)

	# Cracks
	var crack_color := color.darkened(0.4)
	draw_line(Vector2(-40, -20), Vector2(-20, 20), crack_color, 3)
	draw_line(Vector2(30, -10), Vector2(40, 30), crack_color, 3)


func _draw_arms(color: Color) -> void:
	# Left arm
	var left_arm_angle := -0.3 + _arm_swing
	if _is_slamming:
		left_arm_angle = 0.8
	_draw_arm(Vector2(-body_width * 0.7, 0), left_arm_angle, color, -1)

	# Right arm
	var right_arm_angle := 0.3 - _arm_swing
	if _is_slamming:
		right_arm_angle = -0.8
	_draw_arm(Vector2(body_width * 0.7, 0), right_arm_angle, color, 1)


func _draw_arm(shoulder: Vector2, angle: float, color: Color, direction: int) -> void:
	var arm_length: float = 60.0
	var elbow := shoulder + Vector2(cos(angle) * arm_length * direction, sin(angle) * arm_length)
	var hand := elbow + Vector2(cos(angle + 0.3 * direction) * arm_length * 0.8 * direction, sin(angle + 0.3) * arm_length * 0.8)

	# Upper arm
	draw_line(shoulder, elbow, color, 20)
	# Lower arm
	draw_line(elbow, hand, color, 16)
	# Hand/fist
	draw_circle(hand, 18, color.darkened(0.1))


func _draw_head(color: Color) -> void:
	# Head position
	var head_pos := Vector2(0, -body_height * 0.4)

	# Head shape (angular rock)
	var head_points := PackedVector2Array([
		head_pos + Vector2(-35, 15),
		head_pos + Vector2(-40, -10),
		head_pos + Vector2(-25, -35),
		head_pos + Vector2(25, -35),
		head_pos + Vector2(40, -10),
		head_pos + Vector2(35, 15),
	])
	draw_colored_polygon(head_points, color.lightened(0.1))

	# Eyes (glowing orange)
	var eye_color := Color(1.0, 0.6, 0.2)
	draw_circle(head_pos + Vector2(-15, -10), 8, eye_color)
	draw_circle(head_pos + Vector2(15, -10), 8, eye_color)

	# Inner eye glow
	draw_circle(head_pos + Vector2(-15, -10), 4, Color(1.0, 0.9, 0.5))
	draw_circle(head_pos + Vector2(15, -10), 4, Color(1.0, 0.9, 0.5))


func _draw_slam_telegraph() -> void:
	if _slam_target != Vector2.ZERO:
		var local_target := to_local(_slam_target)
		var alpha: float = 0.3 + 0.2 * sin(Time.get_ticks_msec() * 0.01)
		draw_circle(local_target, slam_radius, Color(0.8, 0.4, 0.2, alpha))


func _get_current_phase_color() -> Color:
	var phase_idx := get_current_phase_index()
	if phase_idx >= 0 and phase_idx < _phase_colors.size():
		return _phase_colors[phase_idx]
	return base_color


func _on_intro_start() -> void:
	# Golem rises from ground
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 500)
	scale = Vector2(0.5, 0.5)

	var tween := create_tween()
	tween.tween_property(self, "position:y", 280.0, intro_duration).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), intro_duration)
	tween.tween_callback(func():
		CameraShake.shake(18.0, 8.0)
		SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)
	)


func _on_phase_enter(phase: BossPhase) -> void:
	queue_redraw()

	if phase == BossPhase.PHASE_3:
		attack_cooldown = 2.5
		telegraph_duration = 1.0


func _boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE and attack_state != AttackState.COOLDOWN:
		return

	_move_timer -= delta
	if _move_timer <= 0:
		_pick_new_move_target()
		_move_timer = randf_range(3.0, 5.0)

	# Slow, heavy movement
	var dir := (_move_target - global_position).normalized()
	var move_speed: float = 25.0 if current_phase != BossPhase.PHASE_3 else 40.0
	global_position += dir * move_speed * delta

	# Clamp to arena
	var viewport_size := get_viewport().get_visible_rect().size
	global_position.x = clampf(global_position.x, 100, viewport_size.x - 100)
	global_position.y = clampf(global_position.y, 200, 400)


func _pick_new_move_target() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_move_target = Vector2(
		randf_range(150, viewport_size.x - 150),
		randf_range(230, 380)
	)


# === ATTACK IMPLEMENTATIONS ===

func _show_attack_telegraph(attack_name: String) -> void:
	super._show_attack_telegraph(attack_name)

	match attack_name:
		"slam":
			if _player and is_instance_valid(_player):
				_slam_target = _player.global_position
			queue_redraw()
		"boulder":
			# Raise arms telegraph
			_arm_swing = 1.0
		"eruption":
			# Ground tremor
			CameraShake.shake(8.0, telegraph_duration)
		"sandstorm":
			# Building wind effect
			CameraShake.shake(5.0, telegraph_duration)


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"slam":
			_do_slam_attack()
		"boulder":
			_do_boulder_attack()
		"eruption":
			_do_eruption_attack()
		"sandstorm":
			_do_sandstorm_attack()
		_:
			_end_attack()


func _do_slam_attack() -> void:
	"""Ground slam at player position"""
	SoundManager.play(SoundManager.SoundType.FIRE)
	_is_slamming = true

	if _player and is_instance_valid(_player):
		_slam_target = _player.global_position

	# Slam animation
	var slam_tween := create_tween()
	slam_tween.tween_interval(0.3)
	slam_tween.tween_callback(func():
		# Impact
		CameraShake.shake(15.0, 6.0)
		SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)

		# Check hit
		if _player and is_instance_valid(_player):
			var dist := _slam_target.distance_to(_player.global_position)
			if dist < slam_radius:
				GameManager.damage_player(slam_damage)

		_is_slamming = false
		queue_redraw()
	)
	slam_tween.tween_interval(0.5)
	slam_tween.tween_callback(_end_attack)


func _do_boulder_attack() -> void:
	"""Throw boulders at player"""
	for i in boulder_count:
		var timer := get_tree().create_timer(i * 0.4)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			_throw_boulder()
		)

	var end_timer := get_tree().create_timer(boulder_count * 0.4 + 0.5)
	end_timer.timeout.connect(func():
		if is_instance_valid(self):
			_end_attack()
	)


func _throw_boulder() -> void:
	var boulder = BOULDER_SCENE.instantiate()
	boulder.global_position = global_position + Vector2(0, -50)

	if _player and is_instance_valid(_player):
		boulder.direction = (_player.global_position - boulder.global_position).normalized()
	else:
		boulder.direction = Vector2.DOWN

	boulder.speed = 300.0
	boulder.damage = boulder_damage
	boulder.projectile_color = Color(0.7, 0.5, 0.3)

	get_tree().current_scene.add_child(boulder)
	SoundManager.play(SoundManager.SoundType.FIRE)


func _do_eruption_attack() -> void:
	"""Create sand eruptions across arena"""
	var viewport_size := get_viewport().get_visible_rect().size
	var eruption_count := 5

	for i in eruption_count:
		var timer := get_tree().create_timer(i * 0.3)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			# Random position
			var x: float = randf_range(50, viewport_size.x - 50)
			if _player and is_instance_valid(_player):
				x = lerpf(_player.global_position.x, x, 0.4)
			_spawn_eruption(Vector2(x, _player.global_position.y if _player else 900))
		)

	var end_timer := get_tree().create_timer(eruption_count * 0.3 + 1.0)
	end_timer.timeout.connect(func():
		if is_instance_valid(self):
			_end_attack()
	)


func _spawn_eruption(pos: Vector2) -> void:
	CameraShake.shake(6.0, 3.0)

	# Check if player is near eruption
	if _player and is_instance_valid(_player):
		var dist := pos.distance_to(_player.global_position)
		if dist < 80:
			GameManager.damage_player(20)


func _do_sandstorm_attack() -> void:
	"""Screen-wide sandstorm with damage ticks"""
	CameraShake.shake(20.0, 4.0)

	var tick_count := 5
	var tick_damage := 10

	for i in tick_count:
		var timer := get_tree().create_timer(i * 0.6)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			CameraShake.shake(8.0, 5.0)
			GameManager.damage_player(tick_damage)

			# Throw boulders during sandstorm
			_throw_boulder()
		)

	var end_timer := get_tree().create_timer(tick_count * 0.6 + 0.5)
	end_timer.timeout.connect(func():
		if is_instance_valid(self):
			_end_attack()
	)


func _update_attack(_delta: float) -> void:
	queue_redraw()


func _defeat() -> void:
	# Spawn guaranteed fusion reactor
	var game_controller := get_tree().get_first_node_in_group("game")
	if game_controller and game_controller.has_method("_spawn_fusion_reactor"):
		game_controller._spawn_fusion_reactor(global_position)

	# Spawn lots of gems
	for i in 15:
		var offset := Vector2(randf_range(-80, 80), randf_range(-80, 80))
		if game_controller and game_controller.has_method("_spawn_gem"):
			game_controller._spawn_gem(global_position + offset, 15)

	super._defeat()
