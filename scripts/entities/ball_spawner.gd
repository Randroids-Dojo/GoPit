extends Node2D
## Spawns balls in the aimed direction when fire is triggered
## Now integrates with BallRegistry for ball types and levels
## Ball Return Mechanic: Balls return when reaching bottom of screen

signal ball_spawned(ball: Node2D)
signal ball_returned  # Emitted when a ball returns to player
signal balls_available_changed(available: bool)  # For fire button UI

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

# Ball Return Mechanic - track balls in flight
var balls_in_flight: int = 0
var _previous_available: bool = true


func _ready() -> void:
	add_to_group("ball_spawner")
	if ball_scene == null:
		ball_scene = preload("res://scenes/entities/ball.tscn")


func set_aim_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		current_aim_direction = direction.normalized()


func set_aim_direction_xy(x: float, y: float) -> void:
	"""Set aim direction using separate x, y components (for automation tests)"""
	set_aim_direction(Vector2(x, y))


func can_fire() -> bool:
	"""Check if player has balls available to fire (return mechanic)"""
	return balls_in_flight < max_balls


func get_balls_in_flight() -> int:
	return balls_in_flight


func fire() -> void:
	if current_aim_direction == Vector2.ZERO:
		return

	# Check ball availability (return mechanic)
	if not can_fire():
		return

	# Get all active ball types from slots
	var slot_balls: Array[int] = []
	if BallRegistry:
		slot_balls = BallRegistry.get_filled_slots()

	# Fallback to legacy single ball if no registry or no slots filled
	if slot_balls.is_empty():
		slot_balls = [BallRegistry.active_ball_type if BallRegistry else 0]

	# Enforce ball limit by despawning oldest balls
	# Total balls = slot_balls.size() * ball_count (multi-shot per slot)
	var total_balls_to_spawn: int = slot_balls.size() * ball_count
	_enforce_ball_limit(total_balls_to_spawn)

	# Fire all slot ball types simultaneously
	for slot_ball_type in slot_balls:
		# Each slot fires ball_count balls (multi-shot)
		for i in range(ball_count):
			# Calculate spread offset for multi-shot
			var spread_offset: float = 0.0
			if ball_count > 1:
				spread_offset = (i - (ball_count - 1) / 2.0) * ball_spread

			var dir := current_aim_direction.rotated(spread_offset)
			_spawn_ball_typed(dir, slot_ball_type)

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


func _spawn_ball(direction: Vector2) -> void:
	"""Legacy spawn using active_ball_type. Kept for backward compatibility."""
	var active_type: int = BallRegistry.active_ball_type if BallRegistry else 0
	_spawn_ball_typed(direction, active_type)


func _spawn_ball_typed(direction: Vector2, registry_ball_type: int) -> void:
	"""Spawn a ball of a specific type from the registry"""
	# Get ball from pool if available, otherwise instantiate
	var ball: Node
	if PoolManager:
		ball = PoolManager.get_ball()
	else:
		ball = ball_scene.instantiate()
	ball.position = global_position + direction * spawn_offset
	ball.set_direction(direction)

	# Get stats from BallRegistry for the specific ball type
	var use_registry := BallRegistry != null and BallRegistry.owned_balls.size() > 0
	var speed_mult: float = GameManager.character_speed_mult
	if use_registry:
		var registry_damage: int = BallRegistry.get_damage(registry_ball_type)
		var registry_speed: float = BallRegistry.get_speed(registry_ball_type)
		var ball_level: int = BallRegistry.get_ball_level(registry_ball_type)

		ball.damage = registry_damage + _damage_bonus
		ball.speed = (registry_speed + _speed_bonus) * speed_mult
		ball.ball_level = ball_level
		ball.registry_type = registry_ball_type

		# Map registry type to ball.gd BallType enum
		ball.set_ball_type(_registry_to_ball_type(registry_ball_type))
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

	# Track ball return (connect to returned signal)
	ball.returned.connect(_on_ball_returned.bind(ball), CONNECT_ONE_SHOT)
	ball.despawned.connect(_on_ball_returned.bind(ball), CONNECT_ONE_SHOT)
	balls_in_flight += 1
	_check_availability_changed()

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


func _on_ball_returned(_ball: Node) -> void:
	"""Called when a ball returns to player (reaches bottom of screen)"""
	balls_in_flight = maxi(0, balls_in_flight - 1)
	ball_returned.emit()
	_check_availability_changed()


func _check_availability_changed() -> void:
	"""Emit signal if ball availability changed"""
	var now_available := can_fire()
	if now_available != _previous_available:
		_previous_available = now_available
		balls_available_changed.emit(now_available)


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
