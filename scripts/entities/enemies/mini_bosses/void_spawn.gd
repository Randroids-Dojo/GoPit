class_name VoidSpawn
extends "res://scripts/entities/enemies/mini_boss_base.gd"
## Void Spawn - Void Chasm mini-boss 1. Dark creature from the void.

var _pulse: float = 0.0


func _ready() -> void:
	mini_boss_name = "Void Spawn"
	max_hp = 300
	hp = 300
	speed = 27.0
	damage_to_player = 25
	xp_value = 65
	attack_cooldown = 2.2
	available_attacks = ["pulse", "summon"]
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_pulse += delta * 2.0
	queue_redraw()


func _draw() -> void:
	var alpha := 0.6 + 0.3 * sin(_pulse)
	var color := Color(0.2, 0.1, 0.3, alpha)
	# Shadowy form
	draw_circle(Vector2.ZERO, 30, color)
	draw_circle(Vector2.ZERO, 20, Color(0.1, 0.05, 0.15))
	# Eye
	draw_circle(Vector2(0, -5), 8, Color(0.8, 0.2, 0.4, alpha + 0.2))


func _perform_attack(attack_name: String) -> void:
	match attack_name:
		"pulse":
			SoundManager.play(SoundManager.SoundType.FIRE)
			CameraShake.shake(6.0, 3.0)
			if _player and is_instance_valid(_player):
				var dist := global_position.distance_to(_player.global_position)
				if dist < 120:
					GameManager.damage_player(damage_to_player)
			_end_attack()
		"summon":
			var swarm_scene := load("res://scenes/entities/enemies/swarm.tscn")
			var enemies := get_tree().get_first_node_in_group("enemies_container")
			if enemies:
				var swarm := swarm_scene.instantiate()
				swarm.global_position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
				enemies.add_child(swarm)
			SoundManager.play(SoundManager.SoundType.LEVEL_UP)
			_end_attack()
		_:
			_end_attack()


func _mini_boss_movement(delta: float) -> void:
	if attack_state != AttackState.IDLE:
		return
	if _player and is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * speed * 0.3 * delta
