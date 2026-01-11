class_name SlimeKing
extends "res://scripts/entities/enemies/boss_base.gd"
## Slime King - First boss. A massive slime with slam, summon, and split attacks.

const SLIME_SCENE: PackedScene = preload("res://scenes/entities/enemies/slime.tscn")
const EnemyBaseScript = preload("res://scripts/entities/enemies/enemy_base.gd")

# Visual settings
@export var base_color: Color = Color(0.2, 0.8, 0.3)
@export var body_radius: float = 60.0
@export var crown_color: Color = Color(1.0, 0.85, 0.1)

# Attack settings
@export var slam_damage: int = 30
@export var slam_radius: float = 120.0
@export var slam_height: float = -200.0  # How high to jump

# Phase colors (green -> yellow -> red)
var _phase_colors: Array[Color] = [
	Color(0.2, 0.8, 0.3),  # Phase 1: Green
	Color(0.8, 0.7, 0.2),  # Phase 2: Yellow
	Color(0.9, 0.2, 0.2),  # Phase 3: Red/enraged
]

# Attack state tracking
var _slam_target: Vector2 = Vector2.ZERO
var _slam_phase: int = 0  # 0=idle, 1=rising, 2=falling
var _slam_tween: Tween = null
var _original_position: Vector2 = Vector2.ZERO
var _attack_finished: bool = true
var _medium_slimes: Array[Node] = []  # Track split slimes

# Movement
var _move_target: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0

# Player reference
var _player: Node2D = null


func _ready() -> void:
	boss_name = "Slime King"
	max_hp = 500
	xp_value = 100
	damage_to_player = slam_damage
	phase_thresholds = [1.0, 0.66, 0.33, 0.0]

	# Set up attack patterns per phase
	phase_attacks = {
		BossPhase.PHASE_1: ["slam", "summon"],
		BossPhase.PHASE_2: ["slam", "summon", "split"],
		BossPhase.PHASE_3: ["slam", "summon", "rage"],
	}

	attack_cooldown = 2.5
	telegraph_duration = 1.0

	# Find player
	_player = get_tree().get_first_node_in_group("player")

	# Set initial position (center top of screen)
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 200)
	_original_position = position

	super._ready()


func _draw() -> void:
	var current_color := _get_current_phase_color()

	# Draw main slime body (slightly squashed ellipse)
	var body_height := body_radius * 0.7
	_draw_ellipse(Vector2.ZERO, body_radius, body_height, current_color)

	# Draw highlight
	var highlight_color := current_color.lightened(0.3)
	_draw_ellipse(Vector2(-15, -15), 18, 12, highlight_color)

	# Draw crown
	_draw_crown()

	# Draw eyes that track player
	_draw_eyes()

	# Draw slam shadow indicator during telegraph
	if attack_state == AttackState.TELEGRAPH and _current_attack == "slam":
		_draw_slam_telegraph()


func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var points := PackedVector2Array()
	var segments := 32
	for i in range(segments + 1):
		var angle := TAU * i / segments
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(points, color)


func _draw_crown() -> void:
	# Simple crown shape on top
	var crown_points := PackedVector2Array([
		Vector2(-30, -body_radius * 0.5),
		Vector2(-20, -body_radius * 0.5 - 25),
		Vector2(-10, -body_radius * 0.5 - 10),
		Vector2(0, -body_radius * 0.5 - 30),
		Vector2(10, -body_radius * 0.5 - 10),
		Vector2(20, -body_radius * 0.5 - 25),
		Vector2(30, -body_radius * 0.5),
	])
	draw_colored_polygon(crown_points, crown_color)


func _draw_eyes() -> void:
	# Calculate eye direction toward player
	var look_dir := Vector2.DOWN
	if _player and is_instance_valid(_player):
		look_dir = (to_local(_player.global_position)).normalized()

	# Left eye
	var left_eye_base := Vector2(-18, -5)
	draw_circle(left_eye_base, 10, Color.WHITE)
	draw_circle(left_eye_base + look_dir * 4, 5, Color.BLACK)

	# Right eye
	var right_eye_base := Vector2(18, -5)
	draw_circle(right_eye_base, 10, Color.WHITE)
	draw_circle(right_eye_base + look_dir * 4, 5, Color.BLACK)


func _draw_slam_telegraph() -> void:
	# Draw shadow at target position
	if _slam_target != Vector2.ZERO:
		var local_target := to_local(_slam_target)
		var alpha := 0.3 + 0.2 * sin(Time.get_ticks_msec() * 0.01)
		draw_circle(local_target, slam_radius, Color(0, 0, 0, alpha))


func _get_current_phase_color() -> Color:
	var phase_idx := get_current_phase_index()
	if phase_idx >= 0 and phase_idx < _phase_colors.size():
		return _phase_colors[phase_idx]
	return base_color


func _on_intro_start() -> void:
	# Boss descends into view with shake
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, -100)  # Start above screen

	var tween := create_tween()
	tween.tween_property(self, "position:y", 200.0, intro_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(func(): CameraShake.shake(15.0, 8.0))


func _on_phase_enter(phase: BossPhase) -> void:
	# Update visuals on phase change
	queue_redraw()

	# Phase 3: Rage mode - faster attacks
	if phase == BossPhase.PHASE_3:
		attack_cooldown = 1.5
		telegraph_duration = 0.7


func _boss_movement(delta: float) -> void:
	# Skip movement during attacks
	if attack_state != AttackState.IDLE and attack_state != AttackState.COOLDOWN:
		return

	_move_timer -= delta
	if _move_timer <= 0:
		_pick_new_move_target()
		_move_timer = randf_range(2.0, 4.0)

	# Slowly drift toward target
	var dir := (_move_target - global_position).normalized()
	var move_speed := 30.0 if current_phase != BossPhase.PHASE_3 else 50.0
	global_position += dir * move_speed * delta

	# Clamp to arena bounds
	var viewport_size := get_viewport().get_visible_rect().size
	global_position.x = clampf(global_position.x, 100, viewport_size.x - 100)
	global_position.y = clampf(global_position.y, 150, 400)


func _pick_new_move_target() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_move_target = Vector2(
		randf_range(150, viewport_size.x - 150),
		randf_range(180, 350)
	)


# === ATTACK IMPLEMENTATIONS ===

func _show_attack_telegraph(attack_name: String) -> void:
	super._show_attack_telegraph(attack_name)

	match attack_name:
		"slam":
			# Store player position as target
			if _player and is_instance_valid(_player):
				_slam_target = _player.global_position
			queue_redraw()  # Show shadow telegraph
		"summon":
			# Flash darker
			var tween := create_tween().set_loops(int(telegraph_duration / 0.2))
			tween.tween_property(self, "modulate", Color(0.5, 1.5, 0.5), 0.1)
			tween.tween_property(self, "modulate", Color.WHITE, 0.1)
		"split":
			# Shake/vibrate
			var shake_tween := create_tween().set_loops(int(telegraph_duration / 0.05))
			shake_tween.tween_property(self, "position:x", position.x + 5, 0.025)
			shake_tween.tween_property(self, "position:x", position.x - 5, 0.025)
		"rage":
			# Red flash
			var rage_tween := create_tween().set_loops(int(telegraph_duration / 0.1))
			rage_tween.tween_property(self, "modulate", Color(2.0, 0.5, 0.5), 0.05)
			rage_tween.tween_property(self, "modulate", Color.WHITE, 0.05)


func _perform_attack(attack_name: String) -> void:
	_attack_finished = false

	match attack_name:
		"slam":
			_do_slam_attack()
		"summon":
			_do_summon_attack()
		"split":
			_do_split_attack()
		"rage":
			_do_rage_attack()
		_:
			_end_attack()


func _do_slam_attack() -> void:
	"""Jump up, then slam down at player's position"""
	SoundManager.play(SoundManager.SoundType.FIRE)  # Woosh sound

	_original_position = global_position
	_slam_phase = 1  # Rising

	# Rise up
	_slam_tween = create_tween()
	_slam_tween.tween_property(self, "global_position:y", slam_height, 0.3).set_ease(Tween.EASE_OUT)
	_slam_tween.tween_callback(_slam_fall)


func _slam_fall() -> void:
	_slam_phase = 2  # Falling

	# Fall to target position
	_slam_tween = create_tween()
	_slam_tween.tween_property(self, "global_position", _slam_target, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_slam_tween.tween_callback(_slam_impact)


func _slam_impact() -> void:
	_slam_phase = 0

	# Screen shake
	CameraShake.shake(12.0, 6.0)
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)

	# Check for player hit
	if _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist < slam_radius:
			GameManager.damage_player(slam_damage)

	# Return to arena position
	var return_tween := create_tween()
	return_tween.tween_property(self, "global_position:y", 250.0, 0.5).set_ease(Tween.EASE_OUT)
	return_tween.tween_callback(_end_attack)

	queue_redraw()


func _do_summon_attack() -> void:
	"""Spawn 2-3 regular slimes"""
	var count := randi_range(2, 3)
	spawn_adds(SLIME_SCENE, count, 150.0)

	SoundManager.play(SoundManager.SoundType.LEVEL_UP)  # Spawn sound

	# Brief invulnerability during summon
	is_invulnerable = true
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(func():
		is_invulnerable = false
		_end_attack()
	)


func _do_split_attack() -> void:
	"""Create 2 medium slimes that must be killed"""
	# Only split if we don't already have medium slimes alive
	_medium_slimes = _medium_slimes.filter(func(s): return is_instance_valid(s) and not s.is_queued_for_deletion())
	if _medium_slimes.size() >= 2:
		_end_attack()
		return

	# Spawn medium slimes
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		enemies_container = get_parent()

	for i in 2:
		var medium := MediumSlime.new()
		medium.global_position = global_position + Vector2((i * 2 - 1) * 80, 0)
		enemies_container.add_child(medium)
		_medium_slimes.append(medium)

	# Visual: boss shrinks temporarily
	var shrink_tween := create_tween()
	shrink_tween.tween_property(self, "scale", Vector2(0.7, 0.7), 0.2)
	shrink_tween.tween_interval(1.0)
	shrink_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
	shrink_tween.tween_callback(_end_attack)


func _do_rage_attack() -> void:
	"""Rapid multi-slam attack (Phase 3 only)"""
	# Do 3 quick slams in succession
	var slam_count := 3
	var slam_delay := 0.4

	for i in slam_count:
		var timer := get_tree().create_timer(i * slam_delay)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			if _player and is_instance_valid(_player):
				_slam_target = _player.global_position
			_quick_slam()
		)

	# End attack after all slams
	var end_timer := get_tree().create_timer(slam_count * slam_delay + 0.5)
	end_timer.timeout.connect(func():
		if is_instance_valid(self):
			_end_attack()
	)


func _quick_slam() -> void:
	"""Quick slam without full animation - for rage mode"""
	# Instant position snap with shake
	global_position = _slam_target
	CameraShake.shake(8.0, 4.0)

	# Damage check
	if _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist < slam_radius * 0.8:
			GameManager.damage_player(slam_damage / 2)

	# Quick bounce back
	var bounce := create_tween()
	bounce.tween_property(self, "global_position:y", 250.0, 0.2)


func _update_attack(_delta: float) -> void:
	# Keep drawing updated during attacks
	queue_redraw()


func _defeat() -> void:
	# Spawn guaranteed fusion reactor
	var game_controller := get_tree().get_first_node_in_group("game")
	if game_controller and game_controller.has_method("_spawn_fusion_reactor"):
		game_controller._spawn_fusion_reactor(global_position)

	# Spawn lots of gems (100 XP total, split into smaller gems)
	for i in 10:
		var offset := Vector2(randf_range(-50, 50), randf_range(-50, 50))
		if game_controller and game_controller.has_method("_spawn_gem"):
			game_controller._spawn_gem(global_position + offset, 10)

	super._defeat()


# === HELPER CLASS: Medium Slime ===

class MediumSlime extends "res://scripts/entities/enemies/enemy_base.gd":
	"""Medium slime spawned by Split attack - 100 HP, 1.5x regular size"""

	func _init() -> void:
		max_hp = 100
		hp = 100
		speed = 80.0
		damage_to_player = 15
		xp_value = 25

	func _ready() -> void:
		super._ready()
		scale = Vector2(1.5, 1.5)
		add_to_group("enemies")

	func _draw() -> void:
		# Yellow-green slime
		var color := Color(0.6, 0.7, 0.2)
		var body_height := 14.0
		_draw_ellipse(Vector2.ZERO, 20.0, body_height, color)
		# Highlight
		_draw_ellipse(Vector2(-5, -5), 6, 4, color.lightened(0.3))

	func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
		var points := PackedVector2Array()
		var segments := 24
		for i in range(segments + 1):
			var angle := TAU * i / segments
			points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
		draw_colored_polygon(points, color)
