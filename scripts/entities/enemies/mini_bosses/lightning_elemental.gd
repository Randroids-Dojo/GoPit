class_name LightningElemental
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Lightning Elemental - Storm Spire mini-boss 1.

var _spark: float = 0.0


func _ready() -> void:
	mini_boss_name = "Lightning Elemental"
	max_hp = 260
	hp = 260
	speed = 42.0
	damage_to_player = 22
	xp_value = 72
	attack_cooldown = 1.8
	available_attacks = ["bolt", "chain"]
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_spark += delta * 10.0
	queue_redraw()


func _draw() -> void:
	var color := Color(0.4, 0.6, 1.0)
	# Electric body
	for i in 6:
		var angle := TAU * i / 6 + _spark * 0.1
		var r := 20 + sin(_spark + i) * 5
		draw_circle(Vector2(cos(angle), sin(angle)) * r, 8, color)
	draw_circle(Vector2.ZERO, 15, Color(0.8, 0.9, 1.0))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"bolt", "chain":
			SoundManager.play(SoundManager.SoundType.FIRE)
			CameraShake.shake(5.0, 2.0)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 150:
					GameManager.damage_player(damage_to_player)
			_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	if _player and is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * speed * 0.5 * delta
