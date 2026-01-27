class_name IceWraith
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Ice Wraith - Frozen Depths mini-boss 2. Ghostly ice spirit with chill attacks.

var _float_offset: float = 0.0


func _ready() -> void:
	mini_boss_name = "Ice Wraith"
	max_hp = 180
	hp = 180
	speed = 42.0
	damage_to_player = 18
	xp_value = 50
	attack_cooldown = 2.0
	available_attacks = ["chill", "phase"]
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_float_offset += delta * 3.0
	queue_redraw()


func _draw() -> void:
	var float_y := sin(_float_offset) * 5.0
	var alpha := 0.7 + 0.2 * sin(_float_offset * 1.5)
	var color := Color(0.6, 0.8, 1.0, alpha)

	# Ghostly body
	var points := PackedVector2Array()
	for i in range(17):
		var angle := TAU * i / 16
		var r := 25.0 + sin(angle * 3 + _float_offset) * 5
		points.append(Vector2(cos(angle) * r, sin(angle) * r * 1.2 + float_y))
	draw_colored_polygon(points, color)

	# Eyes
	draw_circle(Vector2(-8, -5 + float_y), 5, Color(0.2, 0.5, 1.0))
	draw_circle(Vector2(8, -5 + float_y), 5, Color(0.2, 0.5, 1.0))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"chill":
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 120:
					GameManager.damage_player(damage_to_player)
			SoundManager.play(SoundManager.SoundType.FIRE)
			_end_attack()
		"phase":
			# Teleport near player
			if _player and is_instance_valid(_player):
				var offset := Vector2(randf_range(-80, 80), randf_range(-80, 80))
				global_position = _player.global_position + offset
			SoundManager.play(SoundManager.SoundType.LEVEL_UP)
			_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	if _player and is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * speed * 0.4 * delta
