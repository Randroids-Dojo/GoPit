extends Area2D
## Gem entity - spawned from enemies, collected when player touches them

signal collected(gem: Node2D)

## Gem movement modes to simulate different collection difficulty
enum GemMovementMode {
	FALL_DOWN,   ## Default: gems fall toward player (easier)
	DRIFT_UP,    ## BallxPit-style: gems drift away from player (harder)
	STATIONARY   ## Gems stay where they spawn (hardest)
}

@export var xp_value: int = 10
@export var gem_color: Color = Color(0.2, 0.9, 0.5)
@export var radius: float = 14.0
@export var base_speed: float = 150.0  ## Base movement speed (fall or drift)
@export var sparkle_speed: float = 3.0
@export var despawn_time: float = 10.0

const MAGNETISM_SPEED: float = 400.0
const COLLECTION_RADIUS: float = 40.0
const HEALTH_GEM_HEAL: int = 10  # HP restored by health gems

## Current movement mode - defaults to DRIFT_UP for BallxPit-style feel
static var movement_mode: GemMovementMode = GemMovementMode.DRIFT_UP

var _time: float = 0.0
var is_health_gem: bool = false:
	set(value):
		is_health_gem = value
		if value:
			gem_color = Color(1.0, 0.4, 0.5)  # Pink/red for health gems
var _player: Node2D = null
var _being_attracted: bool = false


func _ready() -> void:
	collision_layer = 8  # gems layer
	collision_mask = 16  # player layer (CharacterBody2D)

	body_entered.connect(_on_body_entered)

	# Find player reference
	_player = get_tree().get_first_node_in_group("player")

	queue_redraw()


func _process(delta: float) -> void:
	# Stop processing when game is paused (level up, game over, etc.)
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_time += delta

	# Check for player proximity and collect
	if _player and global_position.distance_to(_player.global_position) < COLLECTION_RADIUS:
		_collect()
		return

	# Check for magnetism toward player (auto-magnet during boss fights or with Collector passive)
	_being_attracted = false
	var magnetism_range := GameManager.get_effective_magnetism_range()
	if magnetism_range > 0 and _player:
		var distance_to_player := global_position.distance_to(_player.global_position)
		if distance_to_player < magnetism_range:
			_being_attracted = true
			# Move toward player
			var direction := (_player.global_position - global_position).normalized()
			# Speed increases as gem gets closer
			var pull_strength := 1.0 - (distance_to_player / magnetism_range)
			var current_speed := lerpf(base_speed, MAGNETISM_SPEED, pull_strength)
			global_position += direction * current_speed * delta
		else:
			# Apply movement based on mode
			_apply_movement(delta)
	else:
		# No magnetism, apply normal movement
		_apply_movement(delta)

	queue_redraw()

	# Despawn after timeout or if off screen (check both top and bottom)
	var off_screen := position.y > 1400 or position.y < -100
	if _time > despawn_time or off_screen:
		_release_to_pool()


func _draw() -> void:
	# Draw magnetism pull line when being attracted
	if _being_attracted and _player:
		var to_player := to_local(_player.global_position)
		draw_line(Vector2.ZERO, to_player, Color(0.5, 1.0, 0.5, 0.3), 2.0)

	# Draw gem with sparkle effect
	var sparkle := (sin(_time * sparkle_speed) + 1.0) * 0.5
	var current_color := gem_color.lightened(sparkle * 0.3)

	# Glow effect when being attracted
	if _being_attracted:
		draw_circle(Vector2.ZERO, radius * 1.5, Color(0.5, 1.0, 0.5, 0.2))

	# Draw diamond shape
	var points := PackedVector2Array([
		Vector2(0, -radius),
		Vector2(radius * 0.7, 0),
		Vector2(0, radius),
		Vector2(-radius * 0.7, 0)
	])
	draw_colored_polygon(points, current_color)

	# Draw highlight
	var highlight := gem_color.lightened(0.5 + sparkle * 0.3)
	draw_circle(Vector2(-2, -2), 2, highlight)


func _apply_movement(delta: float) -> void:
	"""Apply movement based on current mode"""
	var world_scroll := GameManager.get_world_scroll_speed()

	match movement_mode:
		GemMovementMode.FALL_DOWN:
			# Classic: gems fall toward player (easier collection)
			position.y += base_speed * delta
		GemMovementMode.DRIFT_UP:
			# BallxPit-style: gems drift up, but world scroll reduces net drift
			# Higher difficulty = faster scroll = gems drift up slower = more pressure
			var net_drift := base_speed - (world_scroll * 0.5)
			position.y -= net_drift * delta
		GemMovementMode.STATIONARY:
			# Gems stay in world coords = drift down with scroll
			position.y += world_scroll * delta


func _on_body_entered(body: Node2D) -> void:
	# Only collect if it's the player
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	collected.emit(self)
	if is_health_gem:
		GameManager.heal(HEALTH_GEM_HEAL)
	SoundManager.play(SoundManager.SoundType.GEM_COLLECT)
	_release_to_pool()


func _release_to_pool() -> void:
	"""Return to pool or free"""
	if has_meta("pooled") and PoolManager:
		reset()
		PoolManager.release_gem(self)
	else:
		queue_free()


func reset() -> void:
	"""Reset gem state for object pool reuse"""
	# Reset time and state
	_time = 0.0
	_being_attracted = false
	_player = null

	# Reset properties to defaults
	xp_value = 10
	gem_color = Color(0.2, 0.9, 0.5)
	is_health_gem = false

	# Reset position
	position = Vector2.ZERO

	queue_redraw()


func get_xp_value() -> int:
	if is_health_gem:
		return 0  # Health gems give no XP
	return xp_value


## Static methods to control gem movement mode globally

static func set_movement_mode(mode: GemMovementMode) -> void:
	"""Set the movement mode for all gems"""
	movement_mode = mode


static func get_movement_mode() -> GemMovementMode:
	"""Get the current movement mode"""
	return movement_mode


static func set_drift_up_mode() -> void:
	"""Enable BallxPit-style upward drift"""
	movement_mode = GemMovementMode.DRIFT_UP


static func set_fall_down_mode() -> void:
	"""Enable classic fall-toward-player mode"""
	movement_mode = GemMovementMode.FALL_DOWN


static func set_stationary_mode() -> void:
	"""Enable stationary gems (hardest mode)"""
	movement_mode = GemMovementMode.STATIONARY
