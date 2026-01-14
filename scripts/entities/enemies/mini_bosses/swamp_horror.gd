class_name SwampHorror
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Swamp Horror - Toxic Marsh mini-boss 2.


func _ready() -> void:
	mini_boss_name = "Swamp Horror"
	max_hp = 280
	hp = 280
	speed = 35.0
	damage_to_player = 25
	xp_value = 65
	attack_cooldown = 2.5
	available_attacks = ["grab", "slam"]
	super._ready()


func _draw() -> void:
	var color := Color(0.25, 0.4, 0.15)
	# Tentacles
	for i in 4:
		var angle := TAU * i / 4 + Time.get_ticks_msec() * 0.001
		var end := Vector2(cos(angle), sin(angle)) * 40
		draw_line(Vector2.ZERO, end, color, 8.0)
	draw_circle(Vector2.ZERO, 25, color.lightened(0.1))
	draw_circle(Vector2(0, -5), 8, Color(0.7, 0.8, 0.2))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"grab", "slam":
			SoundManager.play(SoundManager.SoundType.FIRE)
			CameraShake.shake(6.0, 3.0)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 90:
					GameManager.damage_player(damage_to_player)
			_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	if _player and is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * speed * 0.25 * delta
