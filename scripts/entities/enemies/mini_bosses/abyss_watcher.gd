class_name AbyssWatcher
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Abyss Watcher - The Abyss mini-boss 1.

var _eye_pulse: float = 0.0


func _ready() -> void:
	mini_boss_name = "Abyss Watcher"
	max_hp = 400
	hp = 400
	speed = 24.0
	damage_to_player = 30
	xp_value = 85
	attack_cooldown = 2.2
	available_attacks = ["gaze", "void_bolt"]
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_eye_pulse += delta * 3.0
	queue_redraw()


func _draw() -> void:
	var pulse := sin(_eye_pulse)
	var color := Color(0.1, 0.05, 0.15)
	# Shadowy form
	draw_circle(Vector2.ZERO, 35, color)
	# Multiple eyes
	var eye_color := Color(0.8, 0.2, 0.3, 0.7 + pulse * 0.3)
	draw_circle(Vector2(0, 0), 15, eye_color)
	draw_circle(Vector2(-15, -15), 8, eye_color)
	draw_circle(Vector2(15, -15), 8, eye_color)
	draw_circle(Vector2(-10, 15), 6, eye_color)
	draw_circle(Vector2(10, 15), 6, eye_color)


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"gaze", "void_bolt":
			SoundManager.play(SoundManager.SoundType.FIRE)
			CameraShake.shake(7.0, 3.0)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 140:
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
