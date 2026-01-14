class_name GemSpider
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Gem Spider - Crystal Caverns mini-boss 2.

var _leg_offset: float = 0.0


func _ready() -> void:
	mini_boss_name = "Gem Spider"
	max_hp = 300
	hp = 300
	speed = 55.0
	damage_to_player = 22
	xp_value = 75
	attack_cooldown = 2.0
	available_attacks = ["pounce", "web"]
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_leg_offset += delta * 5.0
	queue_redraw()


func _draw() -> void:
	var color := Color(0.5, 0.3, 0.6)
	# Legs
	for i in 8:
		var side := 1 if i < 4 else -1
		var idx := i % 4
		var angle := (idx - 1.5) * 0.4 + sin(_leg_offset + idx) * 0.1
		var leg_end := Vector2(side * (30 + cos(angle) * 15), sin(angle) * 20 + idx * 8 - 12)
		draw_line(Vector2(side * 10, idx * 6 - 9), leg_end, color, 3.0)
	# Body
	draw_circle(Vector2.ZERO, 18, color.lightened(0.1))
	# Gem on back
	draw_polygon(PackedVector2Array([Vector2(0, -12), Vector2(8, 0), Vector2(0, 12), Vector2(-8, 0)]), [Color(0.8, 0.5, 1.0)])
	# Eyes
	for i in 4:
		draw_circle(Vector2(-6 + i * 4, -8), 2, Color(0.9, 0.2, 0.2))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"pounce":
			if _player and is_instance_valid(_player):
				var tween := create_tween()
				tween.tween_property(self, "global_position", _player.global_position, 0.25)
				tween.tween_callback(func():
					SoundManager.play(SoundManager.SoundType.FIRE)
					if _player and is_instance_valid(_player):
						var dist := global_position.distance_to(_player.global_position)
						if dist < 50:
							GameManager.damage_player(damage_to_player)
					_end_attack()
				)
			else:
				_end_attack()
		"web":
			SoundManager.play(SoundManager.SoundType.FIRE)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 120:
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
