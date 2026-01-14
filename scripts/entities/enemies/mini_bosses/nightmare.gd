class_name Nightmare
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Nightmare - The Abyss mini-boss 2. Ultimate mini-boss.

var _shift: float = 0.0


func _ready() -> void:
	mini_boss_name = "Nightmare"
	max_hp = 450
	hp = 450
	speed = 60.0
	damage_to_player = 32
	xp_value = 90
	attack_cooldown = 1.8
	available_attacks = ["terror", "consume"]
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_shift += delta * 2.0
	queue_redraw()


func _draw() -> void:
	var alpha := 0.5 + 0.3 * sin(_shift)
	# Shifting form
	for i in 5:
		var offset := Vector2(sin(_shift + i), cos(_shift * 1.3 + i)) * (10 + i * 5)
		var size := 25 - i * 3
		draw_circle(offset, size, Color(0.15 - i * 0.02, 0.05, 0.2 - i * 0.03, alpha))
	# Core eye
	draw_circle(Vector2.ZERO, 12, Color(0.9, 0.1, 0.2, alpha + 0.3))
	draw_circle(Vector2.ZERO, 6, Color(0.1, 0.0, 0.1))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"terror":
			SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)
			CameraShake.shake(10.0, 5.0)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 120:
					GameManager.damage_player(damage_to_player)
			_end_attack()
		"consume":
			if _player and is_instance_valid(_player):
				var tween := create_tween()
				tween.tween_property(self, "global_position", _player.global_position, 0.3)
				tween.tween_callback(func():
					CameraShake.shake(12.0, 6.0)
					SoundManager.play(SoundManager.SoundType.FIRE)
					if _player and is_instance_valid(_player):
						var dist := global_position.distance_to(_player.global_position)
						if dist < 70:
							GameManager.damage_player(damage_to_player + 10)
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
		global_position += dir * speed * 0.45 * delta
