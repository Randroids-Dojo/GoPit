class_name CrystalGuardian
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Crystal Guardian - Crystal Caverns mini-boss 1.


func _ready() -> void:
	mini_boss_name = "Crystal Guardian"
	max_hp = 380
	hp = 380
	speed = 30.0
	damage_to_player = 28
	xp_value = 78
	attack_cooldown = 2.5
	available_attacks = ["shatter", "barrier"]
	super._ready()


func _draw() -> void:
	var color := Color(0.6, 0.4, 0.8)
	# Crystal body
	var points := PackedVector2Array([
		Vector2(0, -40), Vector2(25, -15), Vector2(25, 20),
		Vector2(0, 40), Vector2(-25, 20), Vector2(-25, -15)
	])
	draw_colored_polygon(points, color)
	draw_polyline(points, color.lightened(0.3), 2.0)
	# Core
	draw_circle(Vector2.ZERO, 12, Color(0.9, 0.7, 1.0))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"shatter", "barrier":
			SoundManager.play(SoundManager.SoundType.FIRE)
			CameraShake.shake(8.0, 4.0)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 100:
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
