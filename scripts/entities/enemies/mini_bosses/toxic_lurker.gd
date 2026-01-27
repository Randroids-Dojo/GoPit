class_name ToxicLurker
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Toxic Lurker - Toxic Marsh mini-boss 1.


func _ready() -> void:
	mini_boss_name = "Toxic Lurker"
	max_hp = 320
	hp = 320
	speed = 24.0
	damage_to_player = 22
	xp_value = 70
	attack_cooldown = 2.3
	available_attacks = ["spit", "cloud"]
	super._ready()


func _draw() -> void:
	var color := Color(0.3, 0.5, 0.2)
	draw_circle(Vector2.ZERO, 28, color)
	draw_circle(Vector2(-8, -8), 8, Color(0.6, 0.7, 0.2))
	draw_circle(Vector2(10, 5), 6, Color(0.6, 0.7, 0.2))
	draw_circle(Vector2(-8, -10), 5, Color(0.8, 0.9, 0.2))
	draw_circle(Vector2(8, -10), 5, Color(0.8, 0.9, 0.2))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"spit", "cloud":
			SoundManager.play(SoundManager.SoundType.FIRE)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 130:
					GameManager.damage_player(damage_to_player)
			_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	if _player and is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * speed * 0.3 * delta
