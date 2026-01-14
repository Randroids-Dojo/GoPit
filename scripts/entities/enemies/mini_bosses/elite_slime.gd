class_name EliteSlime
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Elite Slime - The Pit mini-boss. A larger, tougher slime with slam attack.

var _slam_target: Vector2 = Vector2.ZERO
var _move_target: Vector2 = Vector2.ZERO
var _move_timer: float = 0.0


func _ready() -> void:
	mini_boss_name = "Elite Slime"
	max_hp = 200
	hp = 200
	speed = 60.0
	damage_to_player = 20
	xp_value = 50
	attack_cooldown = 2.5
	available_attacks = ["slam", "split"]
	super._ready()


func _draw() -> void:
	# Large green slime
	var color := Color(0.3, 0.7, 0.3)
	_draw_ellipse(Vector2.ZERO, 35.0, 25.0, color)
	_draw_ellipse(Vector2(-8, -8), 10, 7, color.lightened(0.3))

	# Eyes
	var look_dir := Vector2.DOWN
	if _player and is_instance_valid(_player):
		look_dir = (to_local(_player.global_position)).normalized()
	draw_circle(Vector2(-10, -5) + look_dir * 3, 6, Color.WHITE)
	draw_circle(Vector2(-10, -5) + look_dir * 5, 3, Color.BLACK)
	draw_circle(Vector2(10, -5) + look_dir * 3, 6, Color.WHITE)
	draw_circle(Vector2(10, -5) + look_dir * 5, 3, Color.BLACK)

	# Telegraph
	if attack_state == AttackState.TELEGRAPH and _current_attack == "slam":
		if _slam_target != Vector2.ZERO:
			var local_target := to_local(_slam_target)
			var alpha := 0.3 + 0.2 * sin(Time.get_ticks_msec() * 0.01)
			draw_circle(local_target, 50, Color(0, 0, 0, alpha))


func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var angle := TAU * i / 24
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(points, color)


func _show_attack_telegraph(attack_name: String) -> void:
	match attack_name:
		"slam":
			if _player and is_instance_valid(_player):
				_slam_target = _player.global_position
			queue_redraw()
		_:
			super._show_attack_telegraph(attack_name)


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"slam":
			_do_slam()
		"split":
			_do_split()
		_:
			_end_attack()


func _do_slam() -> void:
	SoundManager.play(SoundManager.SoundType.FIRE)
	var original_pos := global_position

	var tween := create_tween()
	tween.tween_property(self, "global_position", _slam_target, 0.3).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		CameraShake.shake(8.0, 4.0)
		if _player and is_instance_valid(_player):
			var dist := global_position.distance_to(_player.global_position)
			if dist < 60:
				GameManager.damage_player(damage_to_player)
		_slam_target = Vector2.ZERO
		queue_redraw()
	)
	tween.tween_interval(0.2)
	tween.tween_property(self, "global_position:y", original_pos.y, 0.3)
	tween.tween_callback(_end_attack)


func _do_split() -> void:
	# Spawn 2 regular slimes
	var slime_scene := load("res://scenes/entities/enemies/slime.tscn")
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if enemies_container:
		for i in 2:
			var slime := slime_scene.instantiate()
			slime.global_position = global_position + Vector2((i * 2 - 1) * 50, 0)
			enemies_container.add_child(slime)
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE and attack_state != AttackState.COOLDOWN:
		return

	_move_timer -= delta
	if _move_timer <= 0:
		var viewport_size := get_viewport().get_visible_rect().size
		_move_target = Vector2(
			randf_range(100, viewport_size.x - 100),
			randf_range(400, viewport_size.y - 200)
		)
		_move_timer = randf_range(2.0, 4.0)

	var dir := (_move_target - global_position).normalized()
	global_position += dir * speed * 0.5 * delta
