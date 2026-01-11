extends Node2D
## Spawns balls in the aimed direction when fire is triggered
## Now integrates with BallRegistry for ball types and levels

signal ball_spawned(ball: Node2D)

@export var ball_scene: PackedScene
@export var spawn_offset: float = 30.0
@export var balls_container: Node2D
@export var max_balls: int = 30  ## Maximum simultaneous balls (0 = unlimited)

var current_aim_direction: Vector2 = Vector2.UP
var ball_damage: int = 10  # Base damage, can be modified by upgrades
var ball_speed: float = 800.0  # Base speed, can be modified by upgrades
var ball_count: int = 1
var ball_spread: float = 0.15  # radians between balls
var pierce_count: int = 0
var max_bounces: int = 10  # default wall bounces
var crit_chance: float = 0.0
var ball_type: int = 0  # Legacy: 0=NORMAL, 1=FIRE, 2=ICE, 3=LIGHTNING

# Bonus stats from upgrades (added on top of registry stats)
var _damage_bonus: int = 0
var _speed_bonus: float = 0.0


func _ready() -> void:
	add_to_group("ball_spawner")
	if ball_scene == null:
		ball_scene = preload("res://scenes/entities/ball.tscn")


func set_aim_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		current_aim_direction = direction.normalized()


func fire() -> void:
	if current_aim_direction == Vector2.ZERO:
		return

	# Get all equipped ball slots
	var equipped_slots := BallRegistry.get_equipped_slots() if BallRegistry else []
	if equipped_slots.is_empty():
		# Fallback to legacy single-ball behavior
		_fire_legacy()
		return

	# Calculate total balls to spawn: slots × multi-shot
	var total_balls := equipped_slots.size() * ball_count
	_enforce_ball_limit(total_balls)

	# Fire ALL equipped types simultaneously (core slot mechanic)
	for slot in equipped_slots:
		for i in range(ball_count):
			# Calculate spread offset for multi-shot
			var spread_offset: float = 0.0
			if ball_count > 1:
				spread_offset = (i - (ball_count - 1) / 2.0) * ball_spread

			var dir := current_aim_direction.rotated(spread_offset)
			_spawn_ball_from_slot(dir, slot)

	SoundManager.play(SoundManager.SoundType.FIRE)


func _fire_legacy() -> void:
	"""Legacy single-ball firing (fallback)"""
	_enforce_ball_limit(ball_count)

	for i in range(ball_count):
		var spread_offset: float = 0.0
		if ball_count > 1:
			spread_offset = (i - (ball_count - 1) / 2.0) * ball_spread

		var dir := current_aim_direction.rotated(spread_offset)
		_spawn_ball(dir)

	SoundManager.play(SoundManager.SoundType.FIRE)


func _enforce_ball_limit(balls_to_add: int) -> void:
	"""Despawn oldest balls to make room for new ones"""
	if max_balls <= 0 or not balls_container:
		return

	var current_count := balls_container.get_child_count()
	var available_slots := max_balls - current_count
	var need_to_remove := balls_to_add - available_slots

	if need_to_remove <= 0:
		return

	# Despawn oldest balls first (they're at the front of the child list)
	for i in range(need_to_remove):
		if balls_container.get_child_count() > 0:
			var oldest := balls_container.get_child(0)
			if oldest.has_method("despawn"):
				oldest.despawn()
			else:
				oldest.queue_free()


func _spawn_ball_from_slot(direction: Vector2, slot: Dictionary) -> void:
	"""Spawn a ball with stats from a specific slot"""
	var ball := ball_scene.instantiate()
	ball.position = global_position + direction * spawn_offset
	ball.set_direction(direction)

	var registry_type: int = slot.ball_type
	var ball_level: int = slot.level
	var speed_mult: float = GameManager.character_speed_mult

	# Get damage/speed from registry using slot's ball type and level
	var registry_damage: int = BallRegistry.get_damage(registry_type)
	var registry_speed: float = BallRegistry.get_speed(registry_type)

	ball.damage = registry_damage + _damage_bonus
	ball.speed = (registry_speed + _speed_bonus) * speed_mult
	ball.ball_level = ball_level
	ball.registry_type = registry_type

	# Map registry type to ball.gd BallType enum
	ball.set_ball_type(_registry_to_ball_type(registry_type))

	ball.pierce_count = pierce_count
	ball.max_bounces = max_bounces
	ball.crit_chance = crit_chance

	if balls_container:
		balls_container.add_child(ball)
	else:
		get_parent().add_child(ball)

	ball_spawned.emit(ball)


func _spawn_ball(direction: Vector2) -> void:
	"""Legacy spawn using active ball type (for fallback)"""
	var ball := ball_scene.instantiate()
	ball.position = global_position + direction * spawn_offset
	ball.set_direction(direction)

	# Get stats from BallRegistry if available
	var use_registry := BallRegistry != null and BallRegistry.owned_balls.size() > 0
	var speed_mult: float = GameManager.character_speed_mult
	if use_registry:
		var active_type: int = BallRegistry.active_ball_type
		var registry_damage: int = BallRegistry.get_damage(active_type)
		var registry_speed: float = BallRegistry.get_speed(active_type)
		var ball_level: int = BallRegistry.get_ball_level(active_type)

		ball.damage = registry_damage + _damage_bonus
		ball.speed = (registry_speed + _speed_bonus) * speed_mult
		ball.ball_level = ball_level
		ball.registry_type = active_type

		# Map registry type to ball.gd BallType enum
		ball.set_ball_type(_registry_to_ball_type(active_type))
	else:
		# Fallback to legacy behavior
		ball.damage = ball_damage + _damage_bonus
		ball.speed = (ball_speed + _speed_bonus) * speed_mult
		if ball_type > 0 and ball.has_method("set_ball_type"):
			ball.set_ball_type(ball_type)

	ball.pierce_count = pierce_count
	ball.max_bounces = max_bounces
	ball.crit_chance = crit_chance

	if balls_container:
		balls_container.add_child(ball)
	else:
		get_parent().add_child(ball)

	ball_spawned.emit(ball)


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


func increase_damage(amount: int) -> void:
	ball_damage += amount
	_damage_bonus += amount


func increase_speed(amount: float) -> void:
	ball_speed += amount
	_speed_bonus += amount


func add_multi_shot() -> void:
	ball_count += 1


func add_piercing(amount: int) -> void:
	pierce_count += amount


func add_ricochet(amount: int) -> void:
	max_bounces += amount


func add_crit_chance(amount: float) -> void:
	crit_chance = minf(1.0, crit_chance + amount)


func set_ball_type(new_type: int) -> void:
	ball_type = new_type


func set_active_ball_from_registry(registry_type: int) -> void:
	"""Set active ball type using BallRegistry.BallType enum"""
	if BallRegistry:
		BallRegistry.set_active_ball(registry_type)


func get_spawn_position() -> Vector2:
	return global_position + current_aim_direction * spawn_offset


func get_aim_direction() -> Vector2:
	return current_aim_direction
