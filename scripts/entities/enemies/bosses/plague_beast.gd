class_name PlagueBeast
extends "res://scripts/entities/enemies/boss_base.gd"
## Plague Beast - Stage 4 boss (Toxic Marsh). A festering creature with poison attacks.

# Visual settings
@export var base_color: Color = Color(0.3, 0.5, 0.15)
@export var body_radius: float = 55.0

# Attack settings
@export var spit_damage: int = 25
@export var cloud_damage: int = 8
@export var cloud_radius: float = 100.0

# Phase colors (sickly green -> yellow-green -> bright toxic)
var _phase_colors: Array[Color] = [
	Color(0.3, 0.5, 0.15),  # Phase 1: Dark green
	Color(0.5, 0.6, 0.1),   # Phase 2: Yellow-green
	Color(0.6, 0.8, 0.1),   # Phase 3: Bright toxic
]

# Attack state
var _spit_targets: Array[Vector2] = []
var _cloud_positions: Array[Vector2] = []
var _cloud_timer: float = 0.0

# Movement
var _move_target: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0
var _player: Node2D = null


func _ready() -> void:
	boss_name = "Plague Beast"
	max_hp = 900
	xp_value = 250
	damage_to_player = spit_damage
	phase_thresholds = [1.0, 0.66, 0.33, 0.0]

	phase_attacks = {
		BossPhase.PHASE_1: ["spit", "cloud"],
		BossPhase.PHASE_2: ["spit", "cloud", "swarm"],
		BossPhase.PHASE_3: ["spit", "cloud", "pandemic"],
	}

	attack_cooldown = 2.5
	telegraph_duration = 1.0

	_player = get_tree().get_first_node_in_group("player")

	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 200)

	super._ready()


func _process(delta: float) -> void:
	# Update poison clouds
	_cloud_timer += delta
	if _cloud_timer >= 0.5 and _cloud_positions.size() > 0:
		_cloud_timer = 0.0
		_check_cloud_damage()


func _draw() -> void:
	var current_color := _get_current_phase_color()

	# Draw blobby body
	_draw_blob(Vector2.ZERO, body_radius, current_color)

	# Draw pustules
	_draw_pustules(current_color)

	# Draw eyes
	_draw_eyes()

	# Draw poison clouds
	for cloud_pos in _cloud_positions:
		_draw_poison_cloud(to_local(cloud_pos))

	# Draw spit telegraph
	if attack_state == AttackState.TELEGRAPH and _current_attack == "spit":
		for target in _spit_targets:
			var local_target := to_local(target)
			var alpha := 0.3 + 0.2 * sin(Time.get_ticks_msec() * 0.01)
			draw_circle(local_target, 40, Color(0.5, 0.7, 0.1, alpha))


func _draw_blob(center: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	var segments := 24
	for i in range(segments + 1):
		var angle := TAU * i / segments
		var r := radius * (1.0 + 0.1 * sin(angle * 3 + Time.get_ticks_msec() * 0.002))
		points.append(center + Vector2(cos(angle) * r, sin(angle) * r * 0.7))
	draw_colored_polygon(points, color)


func _draw_pustules(base_color: Color) -> void:
	var pustule_color := Color(0.7, 0.8, 0.2)
	draw_circle(Vector2(-25, -10), 12, pustule_color)
	draw_circle(Vector2(30, 5), 10, pustule_color)
	draw_circle(Vector2(-10, 20), 8, pustule_color)
	draw_circle(Vector2(20, -20), 9, pustule_color)


func _draw_eyes() -> void:
	var look_dir := Vector2.DOWN
	if _player and is_instance_valid(_player):
		look_dir = (to_local(_player.global_position)).normalized()

	# Sickly yellow eyes
	var eye_color := Color(0.8, 0.9, 0.2)
	draw_circle(Vector2(-15, -15), 10, eye_color)
	draw_circle(Vector2(-15, -15) + look_dir * 4, 5, Color(0.1, 0.1, 0.0))
	draw_circle(Vector2(15, -15), 10, eye_color)
	draw_circle(Vector2(15, -15) + look_dir * 4, 5, Color(0.1, 0.1, 0.0))


func _draw_poison_cloud(center: Vector2) -> void:
	var alpha := 0.3 + 0.1 * sin(Time.get_ticks_msec() * 0.003)
	var cloud_color := Color(0.4, 0.6, 0.1, alpha)
	for i in 5:
		var offset := Vector2(randf_range(-30, 30), randf_range(-30, 30))
		draw_circle(center + offset, randf_range(20, 40), cloud_color)


func _get_current_phase_color() -> Color:
	var phase_idx := get_current_phase_index()
	if phase_idx >= 0 and phase_idx < _phase_colors.size():
		return _phase_colors[phase_idx]
	return base_color


func _on_intro_start() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, -100)

	var tween := create_tween()
	tween.tween_property(self, "position:y", 200.0, intro_duration).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): CameraShake.shake(10.0, 6.0))


func _on_phase_enter(phase: BossPhase) -> void:
	queue_redraw()
	if phase == BossPhase.PHASE_3:
		attack_cooldown = 1.8
		telegraph_duration = 0.8


func _boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE and attack_state != AttackState.COOLDOWN:
		return

	_move_timer -= delta
	if _move_timer <= 0:
		_pick_new_move_target()
		_move_timer = randf_range(2.0, 4.0)

	var dir := (_move_target - global_position).normalized()
	var move_speed := 25.0
	global_position += dir * move_speed * delta

	var viewport_size := get_viewport().get_visible_rect().size
	global_position.x = clampf(global_position.x, 100, viewport_size.x - 100)
	global_position.y = clampf(global_position.y, 150, 400)


func _pick_new_move_target() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_move_target = Vector2(
		randf_range(150, viewport_size.x - 150),
		randf_range(180, 350)
	)


func _show_attack_telegraph(attack_name: String) -> void:
	super._show_attack_telegraph(attack_name)

	match attack_name:
		"spit":
			_spit_targets.clear()
			if _player and is_instance_valid(_player):
				_spit_targets.append(_player.global_position)
				_spit_targets.append(_player.global_position + Vector2(80, 0))
				_spit_targets.append(_player.global_position + Vector2(-80, 0))
			queue_redraw()
		"cloud":
			var tween := create_tween().set_loops(int(telegraph_duration / 0.2))
			tween.tween_property(self, "modulate", Color(0.5, 1.0, 0.5), 0.1)
			tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"spit":
			_do_spit_attack()
		"cloud":
			_do_cloud_attack()
		"swarm":
			_do_swarm_attack()
		"pandemic":
			_do_pandemic_attack()
		_:
			_end_attack()


func _do_spit_attack() -> void:
	SoundManager.play(SoundManager.SoundType.FIRE)

	for target in _spit_targets:
		if _player and is_instance_valid(_player):
			var dist := target.distance_to(_player.global_position)
			if dist < 50:
				GameManager.damage_player(spit_damage)

	_spit_targets.clear()
	queue_redraw()

	var tween := create_tween()
	tween.tween_interval(0.3)
	tween.tween_callback(_end_attack)


func _do_cloud_attack() -> void:
	var viewport_size := get_viewport().get_visible_rect().size

	# Spawn 2-3 poison clouds
	var count := randi_range(2, 3)
	for i in count:
		var cloud_pos := Vector2(
			randf_range(100, viewport_size.x - 100),
			randf_range(500, viewport_size.y - 200)
		)
		_cloud_positions.append(cloud_pos)

	queue_redraw()

	# Clouds last 5 seconds
	var tween := create_tween()
	tween.tween_interval(5.0)
	tween.tween_callback(func():
		_cloud_positions.clear()
		queue_redraw()
	)

	_end_attack()


func _check_cloud_damage() -> void:
	if not _player or not is_instance_valid(_player):
		return

	for cloud_pos in _cloud_positions:
		var dist := cloud_pos.distance_to(_player.global_position)
		if dist < cloud_radius:
			GameManager.damage_player(cloud_damage)
			break


func _do_swarm_attack() -> void:
	var swarm_scene: PackedScene = load("res://scenes/entities/enemies/swarm.tscn")
	spawn_adds(swarm_scene, 4, 120.0)
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	_end_attack()


func _do_pandemic_attack() -> void:
	# Massive poison cloud covering most of screen
	var viewport_size := get_viewport().get_visible_rect().size

	for i in 8:
		var cloud_pos := Vector2(
			randf_range(50, viewport_size.x - 50),
			randf_range(400, viewport_size.y - 100)
		)
		_cloud_positions.append(cloud_pos)

	queue_redraw()
	CameraShake.shake(15.0, 8.0)

	var tween := create_tween()
	tween.tween_interval(6.0)
	tween.tween_callback(func():
		_cloud_positions.clear()
		queue_redraw()
	)

	_end_attack()


func _update_attack(_delta: float) -> void:
	queue_redraw()


func _defeat() -> void:
	_cloud_positions.clear()

	var game_controller := get_tree().get_first_node_in_group("game")
	if game_controller and game_controller.has_method("_spawn_fusion_reactor"):
		game_controller._spawn_fusion_reactor(global_position)

	for i in 14:
		var offset := Vector2(randf_range(-50, 50), randf_range(-50, 50))
		if game_controller and game_controller.has_method("_spawn_gem"):
			game_controller._spawn_gem(global_position + offset, 10)

	super._defeat()
