class_name ShadowKnight
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Shadow Knight - Void Chasm mini-boss 2. Armored void warrior.


func _ready() -> void:
	mini_boss_name = "Shadow Knight"
	max_hp = 350
	hp = 350
	speed = 55.0
	damage_to_player = 28
	xp_value = 70
	attack_cooldown = 2.0
	available_attacks = ["slash", "charge"]
	super._ready()


func _draw() -> void:
	var color := Color(0.15, 0.1, 0.2)
	# Body
	draw_rect(Rect2(-18, -35, 36, 70), color)
	# Helmet
	draw_rect(Rect2(-15, -50, 30, 20), color.darkened(0.2))
	# Sword
	draw_rect(Rect2(20, -30, 6, 60), Color(0.4, 0.3, 0.5))
	# Eyes (glowing red)
	draw_circle(Vector2(-6, -42), 4, Color(0.9, 0.2, 0.2))
	draw_circle(Vector2(6, -42), 4, Color(0.9, 0.2, 0.2))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"slash":
			SoundManager.play(SoundManager.SoundType.FIRE)
			CameraShake.shake(6.0, 3.0)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 80:
					GameManager.damage_player(damage_to_player)
			_end_attack()
		"charge":
			if _player and is_instance_valid(_player):
				var tween := create_tween()
				tween.tween_property(self, "global_position", _player.global_position, 0.3)
				tween.tween_callback(func():
					CameraShake.shake(8.0, 4.0)
					if _player and is_instance_valid(_player):
						var dist := global_position.distance_to(_player.global_position)
						if dist < 60:
							GameManager.damage_player(damage_to_player)
					_end_attack()
				)
			else:
				_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	if _player and is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * speed * 0.4 * delta
