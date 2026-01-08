extends Area2D
## Gem entity - spawned from enemies, collected when player touches them

signal collected(gem: Node2D)

@export var xp_value: int = 10
@export var gem_color: Color = Color(0.2, 0.9, 0.5)
@export var radius: float = 14.0
@export var fall_speed: float = 150.0
@export var sparkle_speed: float = 3.0
@export var despawn_time: float = 10.0

const MAGNETISM_SPEED: float = 400.0
const COLLECTION_RADIUS: float = 40.0
const HEALTH_GEM_HEAL: int = 10  # HP restored by health gems

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
	_time += delta

	# Check for player proximity and collect
	if _player and global_position.distance_to(_player.global_position) < COLLECTION_RADIUS:
		_collect()
		return

	# Check for magnetism toward player
	_being_attracted = false
	var magnetism_range := GameManager.gem_magnetism_range
	if magnetism_range > 0 and _player:
		var distance_to_player := global_position.distance_to(_player.global_position)
		if distance_to_player < magnetism_range:
			_being_attracted = true
			# Move toward player
			var direction := (_player.global_position - global_position).normalized()
			# Speed increases as gem gets closer
			var pull_strength := 1.0 - (distance_to_player / magnetism_range)
			var current_speed := lerpf(fall_speed, MAGNETISM_SPEED, pull_strength)
			global_position += direction * current_speed * delta
		else:
			# Normal falling
			position.y += fall_speed * delta
	else:
		# No magnetism, just fall
		position.y += fall_speed * delta

	queue_redraw()

	# Despawn after timeout or if off screen
	if _time > despawn_time or position.y > 1400:
		queue_free()


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


func _on_body_entered(body: Node2D) -> void:
	# Only collect if it's the player
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	collected.emit(self)
	if is_health_gem:
		GameManager.heal(HEALTH_GEM_HEAL)
	SoundManager.play(SoundManager.SoundType.GEM_COLLECT)
	queue_free()


func get_xp_value() -> int:
	if is_health_gem:
		return 0  # Health gems give no XP
	return xp_value
