class_name HazardBase
extends Area2D
## Base class for environmental hazards that affect the player

signal player_affected(effect_type: String)
signal player_left()

## Effect type identifier for this hazard
@export var effect_type: String = "none"

## Damage dealt per tick (0 = no damage, just status effect)
@export var damage_per_tick: int = 0

## Seconds between damage ticks
@export var tick_interval: float = 1.0

## Visual warning duration before becoming active (0 = instant)
@export var warning_duration: float = 1.0

## Size of the hazard area
@export var hazard_radius: float = 60.0

var _player_in_hazard: bool = false
var _is_active: bool = false
var _tick_timer: Timer


func _ready() -> void:
	# Set up collision
	collision_layer = 0
	collision_mask = 2  # Player layer

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Set up tick timer
	_tick_timer = Timer.new()
	_tick_timer.one_shot = false
	_tick_timer.wait_time = tick_interval
	_tick_timer.timeout.connect(_on_tick)
	add_child(_tick_timer)

	# Set up collision shape
	_setup_collision()

	# Start with warning phase
	if warning_duration > 0:
		_start_warning()
	else:
		_activate()


func _setup_collision() -> void:
	# Create collision shape if not present
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not collision:
		collision = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		add_child(collision)

	# Set up circle shape
	var shape := CircleShape2D.new()
	shape.radius = hazard_radius
	collision.shape = shape


func _start_warning() -> void:
	"""Show warning visual before hazard becomes active."""
	_is_active = false
	_show_warning_visual()

	# Wait for warning duration then activate
	var tween := create_tween()
	tween.tween_interval(warning_duration)
	tween.tween_callback(_activate)


func _activate() -> void:
	"""Make the hazard active and dangerous."""
	_is_active = true
	_show_active_visual()

	# Start tick timer if player already inside
	if _player_in_hazard:
		_start_effect()


func _show_warning_visual() -> void:
	"""Override in subclass to show warning effect."""
	modulate.a = 0.3


func _show_active_visual() -> void:
	"""Override in subclass to show active effect."""
	modulate.a = 1.0


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_hazard = true

	if _is_active:
		_start_effect()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_player_in_hazard = false
	_stop_effect()


func _start_effect() -> void:
	"""Start applying the hazard effect to the player."""
	player_affected.emit(effect_type)
	_apply_effect()

	if damage_per_tick > 0:
		_tick_timer.start()


func _stop_effect() -> void:
	"""Stop applying the hazard effect."""
	_tick_timer.stop()
	_remove_effect()
	player_left.emit()


func _apply_effect() -> void:
	"""Override in subclass to apply status effect."""
	pass


func _remove_effect() -> void:
	"""Override in subclass to remove status effect."""
	pass


func _on_tick() -> void:
	"""Called each tick interval while player is in hazard."""
	if not _player_in_hazard or not _is_active:
		return

	# Deal damage
	if damage_per_tick > 0:
		GameManager.damage_player(damage_per_tick)
