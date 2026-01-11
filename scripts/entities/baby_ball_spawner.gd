class_name BabyBallSpawner
extends Node2D
## Spawns baby balls automatically toward enemies - provides passive DPS

signal baby_ball_spawned(ball: Node2D)

@export var ball_scene: PackedScene
@export var base_spawn_interval: float = 2.0
@export var baby_ball_damage_multiplier: float = 0.5
@export var baby_ball_scale: float = 0.6

var balls_container: Node2D
var _spawn_timer: Timer
var _player: Node2D

# Leadership stat affects spawn rate (from GameManager)
var _leadership_bonus: float = 0.0

# Slot cycling - baby balls rotate through active ball slots
var _slot_cycle_index: int = 0


func _ready() -> void:
	add_to_group("baby_ball_spawner")
	if ball_scene == null:
		ball_scene = preload("res://scenes/entities/ball.tscn")
	_setup_timer()


func _setup_timer() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(_spawn_baby_ball)
	add_child(_spawn_timer)


func start() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_update_spawn_rate()
	_spawn_timer.start()


func stop() -> void:
	_spawn_timer.stop()


func set_leadership(value: float) -> void:
	_leadership_bonus = value
	_update_spawn_rate()


func _update_spawn_rate() -> void:
	# Higher leadership = faster spawns
	# leadership_bonus of 1.0 = 2x spawn rate
	# Also apply character's leadership multiplier, Squad Leader passive, and speed
	var char_mult: float = GameManager.character_leadership_mult
	var speed_mult: float = GameManager.character_speed_mult
	var passive_bonus: float = GameManager.get_baby_ball_rate_bonus()  # Squad Leader: +30%
	var total_bonus: float = (_leadership_bonus * char_mult) + passive_bonus
	var rate: float = base_spawn_interval / ((1.0 + total_bonus) * speed_mult)
	_spawn_timer.wait_time = maxf(0.3, rate)


func _spawn_baby_ball() -> void:
	if not _player:
		return

	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Get ball from pool if available, otherwise instantiate
	var ball: Node
	if PoolManager:
		ball = PoolManager.get_ball()
	else:
		ball = ball_scene.instantiate()
	ball.position = _player.global_position
	ball.scale = Vector2(baby_ball_scale, baby_ball_scale)
	ball.is_baby_ball = true

	# Inherit ball type from active slots (cycles through slots)
	_apply_slot_inheritance(ball)

	# Baby balls deal reduced damage based on inherited type
	var base_damage: int = 10
	if BallRegistry and ball.registry_type >= 0:
		base_damage = BallRegistry.get_damage(ball.registry_type)
	else:
		var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
		if ball_spawner and "ball_damage" in ball_spawner:
			base_damage = ball_spawner.ball_damage
	ball.damage = int(base_damage * baby_ball_damage_multiplier)

	# Set direction toward nearest enemy
	var direction := _get_target_direction()
	ball.set_direction(direction)

	if balls_container:
		balls_container.add_child(ball)
	else:
		get_parent().add_child(ball)

	# Baby balls fire silently to avoid audio spam
	# (main ball fire sound is loud enough)

	baby_ball_spawned.emit(ball)


func _apply_slot_inheritance(ball: Node) -> void:
	"""Apply ball type inheritance from active slots (cycles through slots)"""
	if not BallRegistry:
		return

	var active_slots := BallRegistry.get_filled_slots()
	if active_slots.is_empty():
		return

	# Cycle through active slots
	var slot_type: int = active_slots[_slot_cycle_index % active_slots.size()]
	_slot_cycle_index += 1

	# Set registry type and ball level
	ball.registry_type = slot_type
	ball.ball_level = BallRegistry.get_ball_level(slot_type)

	# Map registry type to ball.gd BallType enum
	var ball_type: int = _registry_to_ball_type(slot_type)
	ball.set_ball_type(ball_type)

	# TODO: Copy evolved_type, is_fused, fused_effects when ball fusion is tracked per-slot


func _registry_to_ball_type(registry_type: int) -> int:
	"""Map BallRegistry.BallType to ball.gd BallType enum"""
	# BallRegistry: BASIC=0, BURN=1, FREEZE=2, POISON=3, BLEED=4, LIGHTNING=5, IRON=6
	# ball.gd: NORMAL=0, FIRE=1, ICE=2, LIGHTNING=3, POISON=4, BLEED=5, IRON=6
	match registry_type:
		0: return 0  # BASIC -> NORMAL
		1: return 1  # BURN -> FIRE
		2: return 2  # FREEZE -> ICE
		3: return 4  # POISON -> POISON
		4: return 5  # BLEED -> BLEED
		5: return 3  # LIGHTNING -> LIGHTNING
		6: return 6  # IRON -> IRON
	return 0


func _get_target_direction() -> Vector2:
	var nearest := _find_nearest_enemy()
	if nearest:
		return _player.global_position.direction_to(nearest.global_position)
	# Fallback: random upward direction
	return Vector2(randf_range(-0.3, 0.3), -1.0).normalized()


func _find_nearest_enemy() -> Node2D:
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return null

	var nearest: Node2D = null
	var nearest_dist: float = INF

	for enemy in enemies_container.get_children():
		if enemy is EnemyBase:
			var dist: float = _player.global_position.distance_to(enemy.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = enemy

	return nearest
