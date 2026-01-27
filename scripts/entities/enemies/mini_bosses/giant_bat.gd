class_name GiantBat
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Giant Bat - The Pit mini-boss 2. A large bat with dive and screech attacks.

var _dive_target: Vector2 = Vector2.ZERO
var _wing_angle: float = 0.0


func _ready() -> void:
	mini_boss_name = "Giant Bat"
	max_hp = 150
	hp = 150
	speed = 48.0
	damage_to_player = 15
	xp_value = 40
	attack_cooldown = 2.0
	available_attacks = ["dive", "screech"]
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_wing_angle += delta * 8.0
	queue_redraw()


func _draw() -> void:
	var wing_flap := sin(_wing_angle) * 0.3

	# Wings
	var wing_color := Color(0.3, 0.2, 0.4)
	var left_wing := PackedVector2Array([
		Vector2(-5, 0),
		Vector2(-40, -20 + wing_flap * 30),
		Vector2(-35, 10),
	])
	var right_wing := PackedVector2Array([
		Vector2(5, 0),
		Vector2(40, -20 + wing_flap * 30),
		Vector2(35, 10),
	])
	draw_colored_polygon(left_wing, wing_color)
	draw_colored_polygon(right_wing, wing_color)

	# Body
	draw_circle(Vector2.ZERO, 20, Color(0.25, 0.15, 0.3))

	# Eyes (red, glowing)
	var glow := 0.7 + 0.3 * sin(Time.get_ticks_msec() * 0.005)
	draw_circle(Vector2(-8, -5), 5, Color(1.0, 0.2, 0.2, glow))
	draw_circle(Vector2(8, -5), 5, Color(1.0, 0.2, 0.2, glow))

	# Ears
	draw_polygon(PackedVector2Array([Vector2(-12, -15), Vector2(-8, -30), Vector2(-4, -15)]), [Color(0.3, 0.2, 0.35)])
	draw_polygon(PackedVector2Array([Vector2(12, -15), Vector2(8, -30), Vector2(4, -15)]), [Color(0.3, 0.2, 0.35)])

	# Telegraph
	if attack_state == AttackState.TELEGRAPH and _current_attack == "dive":
		if _dive_target != Vector2.ZERO:
			var local_target := to_local(_dive_target)
			var alpha := 0.4 + 0.2 * sin(Time.get_ticks_msec() * 0.015)
			draw_circle(local_target, 40, Color(0.5, 0.2, 0.5, alpha))


func _show_attack_telegraph(attack_name: String) -> void:
	match attack_name:
		"dive":
			if _player and is_instance_valid(_player):
				_dive_target = _player.global_position
			queue_redraw()
		"screech":
			var tween := create_tween().set_loops(int(telegraph_duration / 0.1))
			tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.05)
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05)


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"dive":
			_do_dive()
		"screech":
			_do_screech()
		_:
			_end_attack()


func _do_dive() -> void:
	SoundManager.play(SoundManager.SoundType.FIRE)
	var original_pos := global_position

	var tween := create_tween()
	tween.tween_property(self, "global_position", _dive_target, 0.25).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		if _player and is_instance_valid(_player):
			var dist := global_position.distance_to(_player.global_position)
			if dist < 50:
				GameManager.damage_player(damage_to_player)
		CameraShake.shake(5.0, 3.0)
		_dive_target = Vector2.ZERO
		queue_redraw()
	)
	tween.tween_interval(0.1)
	tween.tween_property(self, "global_position", original_pos, 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_end_attack)


func _do_screech() -> void:
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)
	CameraShake.shake(6.0, 3.0)

	# Screech damages if player is close
	if _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist < 150:
			GameManager.damage_player(10)

	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_callback(_end_attack)


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE and attack_state != AttackState.COOLDOWN:
		return

	# Hover and circle
	var viewport_size := get_viewport().get_visible_rect().size
	var center := Vector2(viewport_size.x / 2, 300)
	var angle := Time.get_ticks_msec() * 0.001
	var target := center + Vector2(cos(angle), sin(angle) * 0.5) * 150

	var dir := (target - global_position).normalized()
	global_position += dir * speed * 0.3 * delta
