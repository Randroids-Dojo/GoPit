class_name SandArcher
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Sand Archer - Burning Sands mini-boss 2. Elite archer with rapid fire.


func _ready() -> void:
	mini_boss_name = "Sand Archer"
	max_hp = 200
	hp = 200
	speed = 50.0
	damage_to_player = 18
	xp_value = 55
	attack_cooldown = 1.8
	available_attacks = ["volley", "retreat"]
	super._ready()


func _draw() -> void:
	var color := Color(0.7, 0.5, 0.3)
	# Body
	draw_rect(Rect2(-12, -20, 24, 40), color)
	# Head
	draw_circle(Vector2(0, -28), 10, color.lightened(0.1))
	# Bow
	draw_arc(Vector2(20, 0), 20, -PI/2, PI/2, 12, Color(0.5, 0.3, 0.2), 3.0)
	# Eyes
	draw_circle(Vector2(-4, -30), 3, Color(0.9, 0.6, 0.2))
	draw_circle(Vector2(4, -30), 3, Color(0.9, 0.6, 0.2))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"volley":
			SoundManager.play(SoundManager.SoundType.FIRE)
			# 3 shots rapid fire
			for i in 3:
				var timer := get_tree().create_timer(i * 0.2)
				timer.timeout.connect(func():
					if not is_instance_valid(self) or not _player or not is_instance_valid(_player):
						return
					var dist := global_position.distance_to(_player.global_position)
					if dist < 300:
						GameManager.damage_player(8)
				)
			var tween := create_tween()
			tween.tween_interval(0.8)
			tween.tween_callback(_end_attack)
		"retreat":
			# Jump back
			var away := Vector2.ZERO
			if _player and is_instance_valid(_player):
				away = (global_position - _player.global_position).normalized()
			global_position += away * 100
			_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	# Keep distance from player
	if _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist < 150:
			var away := (global_position - _player.global_position).normalized()
			global_position += away * speed * delta
		elif dist > 250:
			var toward := (_player.global_position - global_position).normalized()
			global_position += toward * speed * 0.5 * delta
