class_name StormHarpy
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Storm Harpy - Storm Spire mini-boss 2.

var _wing_angle: float = 0.0


func _ready() -> void:
	mini_boss_name = "Storm Harpy"
	max_hp = 220
	hp = 220
	speed = 51.0
	damage_to_player = 18
	xp_value = 68
	attack_cooldown = 1.6
	available_attacks = ["dive", "gust"]
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_wing_angle += delta * 10.0
	queue_redraw()


func _draw() -> void:
	var wing_flap := sin(_wing_angle) * 0.4
	var color := Color(0.5, 0.5, 0.7)
	# Wings
	draw_polygon(PackedVector2Array([Vector2(-8, 0), Vector2(-50, -15 + wing_flap * 25), Vector2(-40, 15)]), [color])
	draw_polygon(PackedVector2Array([Vector2(8, 0), Vector2(50, -15 + wing_flap * 25), Vector2(40, 15)]), [color])
	# Body
	draw_circle(Vector2.ZERO, 18, Color(0.4, 0.4, 0.6))
	# Eyes
	draw_circle(Vector2(-6, -5), 4, Color(0.9, 0.9, 1.0))
	draw_circle(Vector2(6, -5), 4, Color(0.9, 0.9, 1.0))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"dive":
			if _player and is_instance_valid(_player):
				var tween := create_tween()
				tween.tween_property(self, "global_position", _player.global_position, 0.2)
				tween.tween_callback(func():
					if _player and is_instance_valid(_player):
						var dist := global_position.distance_to(_player.global_position)
						if dist < 50:
							GameManager.damage_player(damage_to_player)
					_end_attack()
				)
			else:
				_end_attack()
		"gust":
			SoundManager.play(SoundManager.SoundType.FIRE)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 100:
					GameManager.damage_player(12)
			_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var center := Vector2(viewport_size.x / 2, 350)
	var angle := Time.get_ticks_msec() * 0.0015
	var target := center + Vector2(cos(angle), sin(angle) * 0.6) * 180
	var dir := (target - global_position).normalized()
	global_position += dir * speed * 0.4 * delta
