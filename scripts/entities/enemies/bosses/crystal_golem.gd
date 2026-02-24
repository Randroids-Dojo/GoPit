class_name CrystalGolem
extends "res://scripts/entities/enemies/boss_base.gd"
## Crystal Golem - Stage 6 boss (Crystal Caverns). A massive gem creature with shard attacks.

# Visual settings
@export var base_color: Color = Color(0.6, 0.3, 0.8)
@export var body_width: float = 70.0
@export var body_height: float = 80.0

# Attack settings
@export var slam_damage: int = 35
@export var shard_damage: int = 20
@export var reflect_damage: int = 25

# Phase colors (purple -> pink -> bright crystal)
var _phase_colors: Array[Color] = [
	Color(0.6, 0.3, 0.8),   # Phase 1: Purple crystal
	Color(0.8, 0.4, 0.7),   # Phase 2: Pink crystal
	Color(0.9, 0.7, 1.0),   # Phase 3: Bright crystal
]

# Attack state
var _slam_target: Vector2 = Vector2.ZERO
var _shards: Array[Dictionary] = []  # {pos, vel, lifetime}

# Movement
var _move_target: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0
var _player: Node2D = null


func _ready() -> void:
	boss_name = "Crystal Golem"
	max_hp = 1100
	xp_value = 300
	damage_to_player = slam_damage
	phase_thresholds = [1.0, 0.66, 0.33, 0.0]

	phase_attacks = {
		BossPhase.PHASE_1: ["slam", "shards"],
		BossPhase.PHASE_2: ["slam", "shards", "summon"],
		BossPhase.PHASE_3: ["slam", "shards", "shatter"],
	}

	attack_cooldown = 2.8
	telegraph_duration = 1.1

	_player = get_tree().get_first_node_in_group("player")

	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, 220)

	super._ready()


func _process(delta: float) -> void:
	# Update shards
	var to_remove := []
	for i in range(_shards.size()):
		var shard := _shards[i]
		shard.pos += shard.vel * delta
		shard.lifetime -= delta
		if shard.lifetime <= 0:
			to_remove.append(i)
		else:
			# Check player collision
			if _player and is_instance_valid(_player):
				var dist := shard.pos.distance_to(_player.global_position)
				if dist < 30:
					GameManager.damage_player(shard_damage)
					to_remove.append(i)

	for i in range(to_remove.size() - 1, -1, -1):
		_shards.remove_at(to_remove[i])

	queue_redraw()


func _draw() -> void:
	var current_color := _get_current_phase_color()

	# Draw main crystalline body
	_draw_crystal_body(Vector2.ZERO, current_color)

	# Draw crystal facets
	_draw_facets(current_color)

	# Draw glowing core
	_draw_core()

	# Draw eyes
	_draw_eyes()

	# Draw active shards
	for shard in _shards:
		var local_pos := to_local(shard.pos)
		_draw_shard(local_pos, current_color)

	# Draw slam telegraph
	if attack_state == AttackState.TELEGRAPH and _current_attack == "slam":
		if _slam_target != Vector2.ZERO:
			var local_target := to_local(_slam_target)
			var alpha := 0.4 + 0.2 * sin(Time.get_ticks_msec() * 0.01)
			draw_circle(local_target, 80, Color(0.8, 0.5, 1.0, alpha))


func _draw_crystal_body(center: Vector2, color: Color) -> void:
	# Main body - irregular hexagonal shape
	var points := PackedVector2Array([
		center + Vector2(0, -body_height * 0.6),
		center + Vector2(body_width * 0.5, -body_height * 0.3),
		center + Vector2(body_width * 0.6, body_height * 0.2),
		center + Vector2(body_width * 0.3, body_height * 0.5),
		center + Vector2(-body_width * 0.3, body_height * 0.5),
		center + Vector2(-body_width * 0.6, body_height * 0.2),
		center + Vector2(-body_width * 0.5, -body_height * 0.3),
	])
	draw_colored_polygon(points, color)

	# Outline
	draw_polyline(points, color.lightened(0.3), 3.0)


func _draw_facets(color: Color) -> void:
	var facet_color := color.lightened(0.2)
	facet_color.a = 0.6

	# Draw some crystal facet lines
	draw_line(Vector2(-20, -30), Vector2(10, 10), facet_color, 2.0)
	draw_line(Vector2(20, -25), Vector2(-5, 20), facet_color, 2.0)
	draw_line(Vector2(-30, 0), Vector2(25, -10), facet_color, 2.0)


func _draw_core() -> void:
	var glow_alpha := 0.5 + 0.3 * sin(Time.get_ticks_msec() * 0.003)
	var core_color := Color(1.0, 0.8, 1.0, glow_alpha)
	draw_circle(Vector2(0, 0), 20, core_color)
	draw_circle(Vector2(0, 0), 12, Color(1.0, 1.0, 1.0, glow_alpha + 0.2))


func _draw_eyes() -> void:
	var look_dir := Vector2.DOWN
	if _player and is_instance_valid(_player):
		look_dir = (to_local(_player.global_position)).normalized()

	var eye_color := Color(1.0, 0.8, 1.0)
	draw_circle(Vector2(-18, -20), 8, eye_color)
	draw_circle(Vector2(-18, -20) + look_dir * 3, 4, Color(0.4, 0.1, 0.5))
	draw_circle(Vector2(18, -20), 8, eye_color)
	draw_circle(Vector2(18, -20) + look_dir * 3, 4, Color(0.4, 0.1, 0.5))


func _draw_shard(center: Vector2, color: Color) -> void:
	var shard_points := PackedVector2Array([
		center + Vector2(0, -15),
		center + Vector2(8, 0),
		center + Vector2(0, 15),
		center + Vector2(-8, 0),
	])
	draw_colored_polygon(shard_points, color.lightened(0.2))


func _get_current_phase_color() -> Color:
	var phase_idx := get_current_phase_index()
	if phase_idx >= 0 and phase_idx < _phase_colors.size():
		return _phase_colors[phase_idx]
	return base_color


func _on_intro_start() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x / 2, viewport_size.y + 100)

	var tween := create_tween()
	tween.tween_property(self, "position:y", 220.0, intro_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(func():
		CameraShake.shake(18.0, 8.0)
		SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)
	)


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
		_move_timer = randf_range(2.5, 4.5)

	var dir := (_move_target - global_position).normalized()
	var move_speed := 20.0
	global_position += dir * move_speed * delta

	var viewport_size := get_viewport().get_visible_rect().size
	global_position.x = clampf(global_position.x, 120, viewport_size.x - 120)
	global_position.y = clampf(global_position.y, 180, 400)


func _pick_new_move_target() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_move_target = Vector2(
		randf_range(150, viewport_size.x - 150),
		randf_range(200, 350)
	)


func _show_attack_telegraph(attack_name: String) -> void:
	super._show_attack_telegraph(attack_name)

	match attack_name:
		"slam":
			if _player and is_instance_valid(_player):
				_slam_target = _player.global_position
			queue_redraw()
		"shards":
			var tween := create_tween().set_loops(int(telegraph_duration / 0.15))
			tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.075)
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.075)


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"slam":
			_do_slam_attack()
		"shards":
			_do_shards_attack()
		"summon":
			_do_summon_attack()
		"shatter":
			_do_shatter_attack()
		_:
			_end_attack()


func _do_slam_attack() -> void:
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)

	var original_pos := global_position

	var tween := create_tween()
	tween.tween_property(self, "global_position", _slam_target, 0.3).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		CameraShake.shake(15.0, 8.0)
		if _player and is_instance_valid(_player):
			var dist := global_position.distance_to(_player.global_position)
			if dist < 100:
				GameManager.damage_player(slam_damage)
	)
	tween.tween_interval(0.3)
	tween.tween_property(self, "global_position:y", 220.0, 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		_slam_target = Vector2.ZERO
		queue_redraw()
		_end_attack()
	)


func _do_shards_attack() -> void:
	SoundManager.play(SoundManager.SoundType.FIRE)

	# Shoot 6 shards in a spread
	var base_dir := Vector2.DOWN
	if _player and is_instance_valid(_player):
		base_dir = (_player.global_position - global_position).normalized()

	for i in 6:
		var angle_offset := (i - 2.5) * 0.3
		var dir := base_dir.rotated(angle_offset)
		var shard := {
			"pos": global_position,
			"vel": dir * 300,
			"lifetime": 3.0
		}
		_shards.append(shard)

	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(_end_attack)


func _do_summon_attack() -> void:
	var golem_scene: PackedScene = load("res://scenes/entities/enemies/golem.tscn")
	spawn_adds(golem_scene, 2, 100.0)
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	_end_attack()


func _do_shatter_attack() -> void:
	# Massive shard explosion in all directions
	SoundManager.play(SoundManager.SoundType.FIRE)
	CameraShake.shake(20.0, 10.0)

	for i in 16:
		var angle := TAU * i / 16
		var dir := Vector2(cos(angle), sin(angle))
		var shard := {
			"pos": global_position,
			"vel": dir * 250,
			"lifetime": 4.0
		}
		_shards.append(shard)

	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(_end_attack)


func _update_attack(_delta: float) -> void:
	queue_redraw()


func _defeat() -> void:
	_shards.clear()

	var game_controller := get_tree().get_first_node_in_group("game")
	if game_controller and game_controller.has_method("_spawn_fusion_reactor"):
		game_controller._spawn_fusion_reactor(global_position)

	for i in 18:
		var offset := Vector2(randf_range(-60, 60), randf_range(-60, 60))
		if game_controller and game_controller.has_method("_spawn_gem"):
			game_controller._spawn_gem(global_position + offset, 10)

	super._defeat()
