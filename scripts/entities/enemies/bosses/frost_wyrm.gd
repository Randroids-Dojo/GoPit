class_name FrostWyrm
extends "res://scripts/entities/enemies/boss_base.gd"
## Frost Wyrm - Second boss. A serpentine ice dragon with breath, icicle, and blizzard attacks.

const ICICLE_SCENE: PackedScene = preload("res://scenes/entities/enemies/enemy_projectile.tscn")

# Visual settings
@export var base_color: Color = Color(0.3, 0.6, 0.9)
@export var body_length: float = 120.0
@export var body_width: float = 30.0

# Attack settings
@export var breath_damage: int = 20
@export var breath_cone_angle: float = 45.0
@export var breath_range: float = 250.0
@export var icicle_damage: int = 15
@export var icicle_count: int = 5

# Phase colors (blue -> cyan -> white)
var _phase_colors: Array[Color] = [
	Color(0.3, 0.6, 0.9),  # Phase 1: Blue
	Color(0.4, 0.8, 1.0),  # Phase 2: Cyan
	Color(0.9, 0.95, 1.0), # Phase 3: White/Ice
]

# Movement and animation
var _segments: Array[Vector2] = []
const SEGMENT_COUNT: int = 6
var _wave_offset: float = 0.0
var _move_target: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0

# Attack tracking
var _breath_direction: Vector2 = Vector2.DOWN
var _attack_finished: bool = true

# Player reference
var _player: Node2D = null


func _ready() -> void:
	boss_name = "Frost Wyrm"
	max_hp = 600
	xp_value = 150
	damage_to_player = breath_damage
	phase_thresholds = [1.0, 0.66, 0.33, 0.0]

	# Set up attack patterns per phase
	phase_attacks = {
		BossPhase.PHASE_1: ["breath", "icicle"],
		BossPhase.PHASE_2: ["breath", "icicle", "coil"],
		BossPhase.PHASE_3: ["breath", "icicle", "blizzard"],
	}

	attack_cooldown = 3.0
	telegraph_duration = 1.2

	# Find player
	_player = get_tree().get_first_node_in_group("player")

	# Set initial position
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 250)

	# Initialize segments
	_initialize_segments()

	super._ready()


func _initialize_segments() -> void:
	_segments.clear()
	for i in SEGMENT_COUNT:
		_segments.append(Vector2(0, i * 20))


func _process(delta: float) -> void:
	# Animate wave motion
	_wave_offset += delta * 3.0
	queue_redraw()


func _draw() -> void:
	var current_color := _get_current_phase_color()

	# Draw body segments (serpentine)
	_draw_serpent_body(current_color)

	# Draw head
	_draw_head(current_color)

	# Draw breath telegraph during breath attack
	if attack_state == AttackState.TELEGRAPH and _current_attack == "breath":
		_draw_breath_telegraph()


func _draw_serpent_body(color: Color) -> void:
	# Draw segmented serpentine body
	for i in range(SEGMENT_COUNT):
		var seg_offset := sin(_wave_offset + i * 0.5) * 15.0
		var seg_pos := Vector2(seg_offset, i * 20 + 30)
		var seg_radius: float = body_width * (1.0 - i * 0.1)

		# Main segment
		draw_circle(seg_pos, seg_radius, color.darkened(i * 0.05))

		# Ice scales
		if i % 2 == 0:
			var scale_color := color.lightened(0.3)
			draw_circle(seg_pos + Vector2(-seg_radius * 0.5, 0), 5, scale_color)
			draw_circle(seg_pos + Vector2(seg_radius * 0.5, 0), 5, scale_color)


func _draw_head(color: Color) -> void:
	# Head position
	var head_pos := Vector2(sin(_wave_offset) * 10, 0)

	# Main head shape
	var head_points := PackedVector2Array([
		head_pos + Vector2(-25, 10),
		head_pos + Vector2(-30, -15),
		head_pos + Vector2(-15, -30),
		head_pos + Vector2(15, -30),
		head_pos + Vector2(30, -15),
		head_pos + Vector2(25, 10),
	])
	draw_colored_polygon(head_points, color)

	# Eyes (icy blue glow)
	var eye_color := Color(0.5, 0.9, 1.0)
	draw_circle(head_pos + Vector2(-12, -15), 6, Color.WHITE)
	draw_circle(head_pos + Vector2(-12, -15), 4, eye_color)
	draw_circle(head_pos + Vector2(12, -15), 6, Color.WHITE)
	draw_circle(head_pos + Vector2(12, -15), 4, eye_color)

	# Horns
	var horn_color := color.lightened(0.4)
	# Left horn
	draw_line(head_pos + Vector2(-20, -25), head_pos + Vector2(-35, -50), horn_color, 4)
	# Right horn
	draw_line(head_pos + Vector2(20, -25), head_pos + Vector2(35, -50), horn_color, 4)

	# Snout/jaw
	var jaw_points := PackedVector2Array([
		head_pos + Vector2(-15, 10),
		head_pos + Vector2(0, 25),
		head_pos + Vector2(15, 10),
	])
	draw_colored_polygon(jaw_points, color.darkened(0.2))


func _draw_breath_telegraph() -> void:
	if not _player:
		return

	var head_pos := Vector2(sin(_wave_offset) * 10, 0)
	var to_player := (_player.global_position - global_position).normalized()

	# Draw cone indicator
	var cone_left := to_player.rotated(deg_to_rad(-breath_cone_angle / 2))
	var cone_right := to_player.rotated(deg_to_rad(breath_cone_angle / 2))

	var alpha: float = 0.3 + 0.2 * sin(Time.get_ticks_msec() * 0.01)
	var cone_color := Color(0.5, 0.8, 1.0, alpha)

	var cone_points := PackedVector2Array([
		head_pos,
		head_pos + cone_left * breath_range,
		head_pos + cone_right * breath_range,
	])
	draw_colored_polygon(cone_points, cone_color)


func _get_current_phase_color() -> Color:
	var phase_idx := get_current_phase_index()
	if phase_idx >= 0 and phase_idx < _phase_colors.size():
		return _phase_colors[phase_idx]
	return base_color


func _on_intro_start() -> void:
	# Wyrm descends from above with ice particles
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, -150)

	var tween := create_tween()
	tween.tween_property(self, "position:y", 250.0, intro_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): CameraShake.shake(12.0, 6.0))


func _on_phase_enter(phase: BossPhase) -> void:
	queue_redraw()

	if phase == BossPhase.PHASE_3:
		attack_cooldown = 2.0
		telegraph_duration = 0.8


func _boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE and attack_state != AttackState.COOLDOWN:
		return

	_move_timer -= delta
	if _move_timer <= 0:
		_pick_new_move_target()
		_move_timer = randf_range(2.0, 4.0)

	# Serpentine movement
	var dir := (_move_target - global_position).normalized()
	var move_speed: float = 40.0 if current_phase != BossPhase.PHASE_3 else 60.0
	global_position += dir * move_speed * delta

	# Clamp to arena
	var viewport_size := get_viewport().get_visible_rect().size
	global_position.x = clampf(global_position.x, 80, viewport_size.x - 80)
	global_position.y = clampf(global_position.y, 150, 400)


func _pick_new_move_target() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_move_target = Vector2(
		randf_range(120, viewport_size.x - 120),
		randf_range(180, 350)
	)


# === ATTACK IMPLEMENTATIONS ===

func _show_attack_telegraph(attack_name: String) -> void:
	super._show_attack_telegraph(attack_name)

	match attack_name:
		"breath":
			if _player and is_instance_valid(_player):
				_breath_direction = (_player.global_position - global_position).normalized()
			queue_redraw()
		"icicle":
			# Flash with ice color
			var tween := create_tween().set_loops(int(telegraph_duration / 0.2))
			tween.tween_property(self, "modulate", Color(0.5, 0.8, 1.5), 0.1)
			tween.tween_property(self, "modulate", Color.WHITE, 0.1)
		"coil":
			# Spin telegraph
			var spin_tween := create_tween()
			spin_tween.tween_property(self, "rotation", TAU, telegraph_duration)
		"blizzard":
			# Screen-wide ice warning
			CameraShake.shake(5.0, telegraph_duration)


func _perform_attack(attack_name: String) -> void:
	_attack_finished = false

	match attack_name:
		"breath":
			_do_breath_attack()
		"icicle":
			_do_icicle_attack()
		"coil":
			_do_coil_attack()
		"blizzard":
			_do_blizzard_attack()
		_:
			_end_attack()


func _do_breath_attack() -> void:
	"""Ice breath in a cone toward player"""
	SoundManager.play(SoundManager.SoundType.FIRE)

	if _player and is_instance_valid(_player):
		_breath_direction = (_player.global_position - global_position).normalized()

	# Check if player is in breath cone
	if _player and is_instance_valid(_player):
		var to_player := _player.global_position - global_position
		var dist := to_player.length()
		var angle := rad_to_deg(abs(_breath_direction.angle_to(to_player.normalized())))

		if dist < breath_range and angle < breath_cone_angle / 2:
			GameManager.damage_player(breath_damage)
			CameraShake.shake(8.0, 4.0)

	# Visual effect
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(_end_attack)
	queue_redraw()


func _do_icicle_attack() -> void:
	"""Drop icicles from above targeting player area"""
	var viewport_size := get_viewport().get_visible_rect().size

	for i in icicle_count:
		# Delay each icicle
		var timer := get_tree().create_timer(i * 0.2)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			_spawn_icicle(viewport_size)
		)

	# End attack after all icicles
	var end_timer := get_tree().create_timer(icicle_count * 0.2 + 1.0)
	end_timer.timeout.connect(func():
		if is_instance_valid(self):
			_end_attack()
	)


func _spawn_icicle(viewport_size: Vector2) -> void:
	var icicle = ICICLE_SCENE.instantiate()

	# Random X position, biased toward player if exists
	var target_x: float = randf_range(50, viewport_size.x - 50)
	if _player and is_instance_valid(_player):
		target_x = lerpf(_player.global_position.x, target_x, 0.3)

	icicle.global_position = Vector2(target_x, -50)
	icicle.direction = Vector2.DOWN
	icicle.speed = 400.0
	icicle.damage = icicle_damage
	icicle.projectile_color = Color(0.5, 0.8, 1.0)

	get_tree().current_scene.add_child(icicle)


func _do_coil_attack() -> void:
	"""Coil around center then lunge"""
	var center := Vector2(360, 300)
	var original_pos := global_position

	var coil_tween := create_tween()
	# Spiral inward
	coil_tween.tween_property(self, "global_position", center, 0.5).set_ease(Tween.EASE_IN)
	coil_tween.tween_callback(func():
		# Brief pause then lunge at player
		if _player and is_instance_valid(_player):
			var lunge_tween := create_tween()
			lunge_tween.tween_property(self, "global_position", _player.global_position, 0.2)
			lunge_tween.tween_callback(func():
				if _player and is_instance_valid(_player):
					var dist := global_position.distance_to(_player.global_position)
					if dist < 80:
						GameManager.damage_player(breath_damage)
						CameraShake.shake(10.0, 5.0)
				# Return to safe position
				var return_tween := create_tween()
				return_tween.tween_property(self, "global_position:y", 250.0, 0.3)
				return_tween.tween_callback(_end_attack)
			)
	)


func _do_blizzard_attack() -> void:
	"""Screen-wide blizzard - continuous damage and screen effect"""
	CameraShake.shake(15.0, 3.0)

	# Deal damage over time for 3 seconds
	var tick_count := 6
	var tick_damage := 8

	for i in tick_count:
		var timer := get_tree().create_timer(i * 0.5)
		timer.timeout.connect(func():
			if not is_instance_valid(self):
				return
			# Screen shake per tick
			CameraShake.shake(5.0, 10.0)
			# Always hits during blizzard (screen-wide)
			GameManager.damage_player(tick_damage)
			# Spawn visual icicles
			var viewport_size := get_viewport().get_visible_rect().size
			for j in 3:
				_spawn_icicle(viewport_size)
		)

	var end_timer := get_tree().create_timer(tick_count * 0.5 + 0.5)
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
	for i in 12:
		var offset := Vector2(randf_range(-60, 60), randf_range(-60, 60))
		if game_controller and game_controller.has_method("_spawn_gem"):
			game_controller._spawn_gem(global_position + offset, 12)

	super._defeat()
