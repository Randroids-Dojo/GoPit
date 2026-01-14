class_name FireCrab
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Fire Crab - Burning Sands mini-boss 1. Armored crab with fire attacks.


func _ready() -> void:
	mini_boss_name = "Fire Crab"
	max_hp = 280
	hp = 280
	speed = 35.0
	damage_to_player = 22
	xp_value = 60
	attack_cooldown = 2.5
	available_attacks = ["claw", "flame"]
	super._ready()


func _draw() -> void:
	var color := Color(0.8, 0.4, 0.2)
	# Shell
	_draw_ellipse(Vector2.ZERO, 30.0, 22.0, color)
	# Claws
	draw_rect(Rect2(-45, -5, 15, 10), color.darkened(0.2))
	draw_rect(Rect2(30, -5, 15, 10), color.darkened(0.2))
	# Eyes
	draw_circle(Vector2(-10, -12), 4, Color(1.0, 0.5, 0.1))
	draw_circle(Vector2(10, -12), 4, Color(1.0, 0.5, 0.1))


func _draw_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var angle := TAU * i / 24
		points.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(points, color)


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"claw":
			SoundManager.play(SoundManager.SoundType.FIRE)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 80:
					GameManager.damage_player(damage_to_player)
			CameraShake.shake(5.0, 2.0)
			_end_attack()
		"flame":
			SoundManager.play(SoundManager.SoundType.FIRE)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 100:
					GameManager.damage_player(15)
			_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	if _player and is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * speed * 0.4 * delta
