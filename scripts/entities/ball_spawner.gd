extends Node2D
## Spawns balls in the aimed direction when fire is triggered
## Now integrates with BallRegistry for ball types and levels
## Ball Return Mechanic: Balls return when reaching bottom of screen
## Queue System: Balls queue up and fire in sequence at fire_rate

signal ball_spawned(ball: Node2D)
signal ball_returned  # Emitted when a ball returns to player
signal ball_caught  # Emitted when a ball is caught (active play bonus)
signal balls_available_changed(available: bool)  # For fire button UI
signal queue_changed(queue_size: int, max_size: int)  # For queue UI
signal cooldown_changed(ball_type: int, remaining: float)  # For cooldown UI

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

# Queue-based firing system (like BallxPit)
# Balls enter a queue and fire one at a time at fire_rate speed
# Each entry is {type: BallType, spread: float}
var _fire_queue: Array[Dictionary] = []
var fire_rate: float = 2.0  # Base balls per second (overridden by character stat)
var max_queue_size: int = 20  # Prevent infinite stacking
var _fire_timer: float = 0.0  # Timer for queue drain

# Ball-specific cooldowns (per-type, not global)
# Tracks game time when each ball type was last fired
var _last_fired: Dictionary = {}  # BallType -> timestamp (in seconds)


func _ready() -> void:
	add_to_group("ball_spawner")
	if ball_scene == null:
		ball_scene = preload("res://scenes/entities/ball.tscn")


func _process(delta: float) -> void:
	# Drain the fire queue at fire_rate speed
	if _fire_queue.is_empty():
		return

	_fire_timer += delta
	# Use character fire rate if available, otherwise fall back to base rate
	var effective_fire_rate: float = _get_effective_fire_rate()
	var fire_interval: float = 1.0 / effective_fire_rate

	while _fire_timer >= fire_interval and not _fire_queue.is_empty():
		_fire_timer -= fire_interval
		_fire_from_queue()


func _get_effective_fire_rate() -> float:
	"""Get the effective fire rate based on character stats."""
	if GameManager:
		return GameManager.get_character_fire_rate()
	return fire_rate


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

	# Add all ball types to the queue (they'll fire in sequence)
	# Skip balls that are on cooldown
	var added_any: bool = false
	for slot_ball_type in slot_balls:
		# Skip this ball type if on cooldown
		if is_on_cooldown(slot_ball_type):
			continue

		# Each slot fires ball_count balls (multi-shot)
		for i in range(ball_count):
			# Calculate spread offset for multi-shot
			var spread_offset: float = 0.0
			if ball_count > 1:
				spread_offset = (i - (ball_count - 1) / 2.0) * ball_spread
			if _add_to_queue(slot_ball_type, spread_offset):
				added_any = true

	if added_any:
		SoundManager.play(SoundManager.SoundType.FIRE)


func _add_to_queue(ball_type: int, spread: float = 0.0, is_baby: bool = false) -> bool:
	"""Add a ball to the fire queue. Returns false if queue is full."""
	if _fire_queue.size() >= max_queue_size:
		return false

	_fire_queue.append({"type": ball_type, "spread": spread, "is_baby": is_baby})
	queue_changed.emit(_fire_queue.size(), max_queue_size)
	return true


func add_baby_balls_to_queue(count: int, ball_types: Array[int]) -> int:
	"""Add baby balls to the queue. Returns number actually added.
	Baby balls cycle through the provided ball types (from slots)."""
	var added: int = 0
	for i in range(count):
		if _fire_queue.size() >= max_queue_size:
			break
		var type_index: int = i % ball_types.size() if not ball_types.is_empty() else 0
		var ball_type: int = ball_types[type_index] if not ball_types.is_empty() else 0
		# Baby balls fire with slight random spread for variety
		var spread: float = randf_range(-0.2, 0.2)
		if _add_to_queue(ball_type, spread, true):
			added += 1
	return added


func _fire_from_queue() -> void:
	"""Fire one ball from the queue."""
	if _fire_queue.is_empty():
		return

	# Check ball availability (return mechanic)
	if not can_fire():
		return

	var entry: Dictionary = _fire_queue.pop_front()
	queue_changed.emit(_fire_queue.size(), max_queue_size)

	var ball_type: int = entry.get("type", 0)
	var spread: float = entry.get("spread", 0.0)
	var is_baby: bool = entry.get("is_baby", false)

	# Record fire time for cooldown tracking (skip for baby balls)
	if not is_baby:
		_record_fire_time(ball_type)

	# Apply spread offset to current aim direction
	var dir := current_aim_direction.rotated(spread)

	# Enforce ball limit before spawning
	_enforce_ball_limit(1)

	if is_baby:
		_spawn_baby_ball_from_queue(dir, ball_type)
	else:
		_spawn_ball_typed(dir, ball_type)


func get_queue_size() -> int:
	"""Get current queue size."""
	return _fire_queue.size()


func get_max_queue_size() -> int:
	"""Get maximum queue size."""
	return max_queue_size


func get_effective_fire_rate() -> float:
	"""Get effective fire rate (for UI and tests)."""
	return _get_effective_fire_rate()


func clear_queue() -> void:
	"""Clear the fire queue."""
	_fire_queue.clear()
	_fire_timer = 0.0
	queue_changed.emit(0, max_queue_size)


func is_on_cooldown(ball_type: int) -> float:
	"""Check if a ball type is on cooldown. Returns 1.0 (on cooldown) or 0.0 (ready)."""
	if not BallRegistry:
		return 0.0
	var cooldown: float = BallRegistry.get_cooldown(ball_type)
	if cooldown <= 0.0:
		return 0.0
	# Use string key for consistent dictionary lookup across remote calls
	var key := str(ball_type)
	var last_time: float = _last_fired.get(key, -999.0)
	var current_time: float = Time.get_ticks_msec() / 1000.0
	if (current_time - last_time) < cooldown:
		return 1.0
	return 0.0


func get_remaining_cooldown(ball_type: int) -> float:
	"""Get remaining cooldown time for a ball type (0.0 if ready)."""
	if not BallRegistry:
		return 0.0
	var cooldown: float = BallRegistry.get_cooldown(ball_type)
	if cooldown <= 0.0:
		return 0.0
	# Use string key for consistent dictionary lookup across remote calls
	var key := str(ball_type)
	var last_time: float = _last_fired.get(key, -999.0)
	var current_time: float = Time.get_ticks_msec() / 1000.0
	var elapsed: float = current_time - last_time
	return maxf(0.0, cooldown - elapsed)


func _record_fire_time(ball_type: int) -> void:
	"""Record the fire timestamp for a ball type."""
	# Use string key for consistent dictionary lookup across remote calls
	var key := str(ball_type)
	_last_fired[key] = Time.get_ticks_msec() / 1000.0
	if BallRegistry:
		var cooldown: float = BallRegistry.get_cooldown(ball_type)
		if cooldown > 0.0:
			cooldown_changed.emit(ball_type, cooldown)


func reset_cooldowns() -> void:
	"""Reset all cooldowns (for new game/run)."""
	_last_fired.clear()


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

	# Track ball return/catch (connect signals)
	ball.returned.connect(_on_ball_returned.bind(ball), CONNECT_ONE_SHOT)
	ball.caught.connect(_on_ball_caught.bind(ball), CONNECT_ONE_SHOT)
	ball.despawned.connect(_on_ball_returned.bind(ball), CONNECT_ONE_SHOT)
	balls_in_flight += 1
	_check_availability_changed()

	ball_spawned.emit(ball)


# Baby ball configuration (used when spawning from queue)
const BABY_BALL_SCALE: float = 0.6
const BABY_BALL_DAMAGE_MULT: float = 0.5


func _spawn_baby_ball_from_queue(direction: Vector2, registry_ball_type: int) -> void:
	"""Spawn a baby ball from the queue - scaled down with reduced damage"""
	# Get ball from pool if available, otherwise instantiate
	var ball: Node
	if PoolManager:
		ball = PoolManager.get_ball()
	else:
		ball = ball_scene.instantiate()
	ball.position = global_position + direction * spawn_offset
	ball.set_direction(direction)
	ball.scale = Vector2(BABY_BALL_SCALE, BABY_BALL_SCALE)
	ball.is_baby_ball = true

	# Get baby ball spawner for Leadership damage bonus
	var baby_spawner := get_tree().get_first_node_in_group("baby_ball_spawner")
	var leadership_bonus: float = 1.0
	if baby_spawner and baby_spawner.has_method("get_leadership_damage_bonus"):
		leadership_bonus = baby_spawner.get_leadership_damage_bonus()

	# Calculate damage: base damage * baby mult * leadership bonus
	var use_registry := BallRegistry != null and BallRegistry.owned_balls.size() > 0
	var speed_mult: float = GameManager.character_speed_mult
	if use_registry:
		var registry_damage: int = BallRegistry.get_damage(registry_ball_type)
		var registry_speed: float = BallRegistry.get_speed(registry_ball_type)
		var ball_level: int = BallRegistry.get_ball_level(registry_ball_type)

		ball.damage = int(registry_damage * BABY_BALL_DAMAGE_MULT * leadership_bonus)
		ball.speed = (registry_speed + _speed_bonus) * speed_mult
		ball.ball_level = ball_level
		ball.registry_type = registry_ball_type
		ball.set_ball_type(_registry_to_ball_type(registry_ball_type))
	else:
		ball.damage = int(ball_damage * BABY_BALL_DAMAGE_MULT * leadership_bonus)
		ball.speed = (ball_speed + _speed_bonus) * speed_mult

	ball.pierce_count = 0  # Baby balls don't pierce
	ball.max_bounces = max_bounces
	ball.crit_chance = crit_chance * 0.5  # Reduced crit for babies

	if balls_container:
		balls_container.add_child(ball)
	else:
		get_parent().add_child(ball)

	# Track ball return (baby balls count toward limit too)
	ball.returned.connect(_on_ball_returned.bind(ball), CONNECT_ONE_SHOT)
	ball.caught.connect(_on_ball_caught.bind(ball), CONNECT_ONE_SHOT)
	ball.despawned.connect(_on_ball_returned.bind(ball), CONNECT_ONE_SHOT)
	balls_in_flight += 1
	_check_availability_changed()

	# Don't emit ball_spawned for baby balls to avoid triggering more baby spawns
	# baby_ball_spawned signal could be added if needed


func _registry_to_ball_type(registry_type: int) -> int:
	"""Map BallRegistry.BallType to ball.gd BallType enum"""
	# BallRegistry: BASIC=0, BURN=1, FREEZE=2, POISON=3, BLEED=4, LIGHTNING=5, IRON=6,
	#               RADIATION=7, DISEASE=8, FROSTBURN=9, WIND=10, GHOST=11, VAMPIRE=12, BROOD_MOTHER=13
	# ball.gd: NORMAL=0, FIRE=1, ICE=2, LIGHTNING=3, POISON=4, BLEED=5, IRON=6,
	#          RADIATION=7, DISEASE=8, FROSTBURN=9, WIND=10, GHOST=11, VAMPIRE=12, BROOD_MOTHER=13
	match registry_type:
		0: return 0  # BASIC -> NORMAL
		1: return 1  # BURN -> FIRE
		2: return 2  # FREEZE -> ICE
		3: return 4  # POISON -> POISON
		4: return 5  # BLEED -> BLEED
		5: return 3  # LIGHTNING -> LIGHTNING
		6: return 6  # IRON -> IRON
		7: return 7  # RADIATION -> RADIATION
		8: return 8  # DISEASE -> DISEASE
		9: return 9  # FROSTBURN -> FROSTBURN
		10: return 10  # WIND -> WIND
		11: return 11  # GHOST -> GHOST
		12: return 12  # VAMPIRE -> VAMPIRE
		13: return 13  # BROOD_MOTHER -> BROOD_MOTHER
	return 0


func _on_ball_returned(_ball: Node) -> void:
	"""Called when a ball returns to player (reaches bottom of screen)"""
	balls_in_flight = maxi(0, balls_in_flight - 1)
	ball_returned.emit()
	_check_availability_changed()


func _on_ball_caught(_ball: Node) -> void:
	"""Called when a ball is caught by the player (active play bonus)"""
	balls_in_flight = maxi(0, balls_in_flight - 1)
	ball_caught.emit()
	_check_availability_changed()


func try_catch_ball() -> bool:
	"""Attempt to catch any catchable ball in flight. Returns true if caught."""
	if not balls_container:
		return false

	# Find the closest catchable ball
	for ball in balls_container.get_children():
		if ball.has_method("catch") and ball.is_catchable:
			if ball.catch():
				return true
	return false


func has_catchable_balls() -> bool:
	"""Check if any balls are currently catchable"""
	if not balls_container:
		return false

	for ball in balls_container.get_children():
		if ball.has_method("catch") and ball.is_catchable:
			return true
	return false


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
