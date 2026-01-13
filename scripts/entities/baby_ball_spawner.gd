class_name BabyBallSpawner
extends Node2D
## Queue-based baby ball spawner - adds baby balls to the firing queue
## Baby balls are added when parent balls are fired, based on Leadership stat

signal baby_balls_queued(count: int)

## Base number of baby balls to queue per fire action
@export var base_baby_count: int = 1
## Extra baby balls per point of Leadership bonus
@export var leadership_baby_multiplier: float = 2.0
## Damage multiplier for baby balls (applied by ball_spawner)
@export var baby_ball_damage_multiplier: float = 0.5
## Damage bonus per point of Leadership (0.15 = +15% per point)
@export var leadership_damage_per_point: float = 0.15

var _ball_spawner: Node2D
var _player: Node2D

# Leadership stat affects baby ball count and damage
var _leadership_bonus: float = 0.0


func _ready() -> void:
	add_to_group("baby_ball_spawner")
	# Defer connection to ensure ball_spawner is ready
	call_deferred("_connect_to_ball_spawner")


func _connect_to_ball_spawner() -> void:
	_ball_spawner = get_tree().get_first_node_in_group("ball_spawner")
	if _ball_spawner and _ball_spawner.has_signal("ball_spawned"):
		# Connect to ball_spawned to add baby balls after each parent fires
		_ball_spawner.ball_spawned.connect(_on_parent_ball_fired)


func start() -> void:
	_player = get_tree().get_first_node_in_group("player")
	# Reconnect to ball_spawner signal if not connected
	if _ball_spawner and _ball_spawner.has_signal("ball_spawned"):
		if not _ball_spawner.ball_spawned.is_connected(_on_parent_ball_fired):
			_ball_spawner.ball_spawned.connect(_on_parent_ball_fired)


func stop() -> void:
	# Disconnect from ball_spawner signal to stop queueing baby balls
	if _ball_spawner and _ball_spawner.has_signal("ball_spawned"):
		if _ball_spawner.ball_spawned.is_connected(_on_parent_ball_fired):
			_ball_spawner.ball_spawned.disconnect(_on_parent_ball_fired)


func set_leadership(value: float) -> void:
	_leadership_bonus = value


func get_max_baby_balls() -> int:
	"""Returns max baby balls that can be queued per fire action"""
	var char_mult: float = GameManager.character_leadership_mult
	var extra_from_passive: int = GameManager.get_extra_baby_balls()  # Squad Leader: +2
	var leadership_extra: int = int(_leadership_bonus * char_mult * leadership_baby_multiplier)
	return base_baby_count + leadership_extra + extra_from_passive


func get_current_baby_count() -> int:
	"""Returns count of active baby balls on screen"""
	if not _ball_spawner or not "balls_container" in _ball_spawner:
		return 0
	var container: Node = _ball_spawner.balls_container
	if not container:
		return 0
	var count: int = 0
	for child in container.get_children():
		if child.get("is_baby_ball") == true:
			count += 1
	return count


func get_leadership_damage_bonus() -> float:
	"""Returns the Leadership damage bonus multiplier (1.0 = no bonus)"""
	var char_mult: float = GameManager.character_leadership_mult
	return 1.0 + (_leadership_bonus * char_mult * leadership_damage_per_point)


func _on_parent_ball_fired(_ball: Node) -> void:
	"""Called when a parent ball is fired - add baby balls to queue"""
	if not _ball_spawner:
		return

	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Empty Nester passive disables baby ball spawning entirely
	if GameManager.has_no_baby_balls():
		return

	# Skip if the fired ball is already a baby ball (avoid recursion)
	if _ball and _ball.get("is_baby_ball") == true:
		return

	# Calculate how many baby balls to add
	var baby_count: int = get_max_baby_balls()
	if baby_count <= 0:
		return

	# Get ball types from active slots (baby balls cycle through them)
	var ball_types: Array[int] = []
	if BallRegistry:
		ball_types = BallRegistry.get_filled_slots()
	if ball_types.is_empty():
		ball_types = [0]  # Fallback to basic

	# Add baby balls to the queue
	var added: int = _ball_spawner.add_baby_balls_to_queue(baby_count, ball_types)
	if added > 0:
		baby_balls_queued.emit(added)


# Legacy methods for compatibility with existing tests

func get_baby_ball_damage_multiplier() -> float:
	"""Returns the base damage multiplier for baby balls"""
	return baby_ball_damage_multiplier


func get_leadership_baby_multiplier() -> float:
	"""Returns how many extra babies per Leadership point"""
	return leadership_baby_multiplier
