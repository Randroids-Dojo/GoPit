class_name FrostGolem
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Frost Golem - Frozen Depths mini-boss 1. A smaller ice golem with freeze attack.

var _freeze_target: Vector2 = Vector2.ZERO


func _ready() -> void:
	mini_boss_name = "Frost Golem"
	max_hp = 250
	hp = 250
	speed = 24.0
	damage_to_player = 20
	xp_value = 55
	attack_cooldown = 2.8
	available_attacks = ["smash", "freeze"]
	super._ready()


func _draw() -> void:
	var color := Color(0.5, 0.7, 0.9)
	# Body
	draw_rect(Rect2(-25, -30, 50, 60), color)
	# Head
	draw_rect(Rect2(-15, -45, 30, 20), color.lightened(0.2))
	# Eyes
	draw_circle(Vector2(-8, -38), 4, Color(0.2, 0.4, 0.8))
	draw_circle(Vector2(8, -38), 4, Color(0.2, 0.4, 0.8))
	# Ice crystals
	draw_polygon(PackedVector2Array([Vector2(-30, -20), Vector2(-40, -35), Vector2(-25, -25)]), [Color(0.7, 0.9, 1.0)])
	draw_polygon(PackedVector2Array([Vector2(30, -20), Vector2(40, -35), Vector2(25, -25)]), [Color(0.7, 0.9, 1.0)])


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"smash":
			SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)
			CameraShake.shake(8.0, 4.0)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 100:
					GameManager.damage_player(damage_to_player)
			var tween := create_tween()
			tween.tween_interval(0.3)
			tween.tween_callback(_end_attack)
		"freeze":
			# Spawn ice patch at player
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 150:
					GameManager.damage_player(15)
			SoundManager.play(SoundManager.SoundType.FIRE)
			_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	if _player and is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * speed * 0.3 * delta
