extends Area2D
## Gem entity - spawned from enemies, collected for XP

signal collected(gem: Node2D)

@export var xp_value: int = 10
@export var gem_color: Color = Color(0.2, 0.9, 0.5)
@export var radius: float = 8.0
@export var fall_speed: float = 150.0
@export var sparkle_speed: float = 3.0

const PLAYER_ZONE_Y: float = 1200.0
const MAGNETISM_SPEED: float = 500.0

var _time: float = 0.0


func _ready() -> void:
	collision_layer = 8  # gems layer
	collision_mask = 16  # player_zone

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	queue_redraw()


func _process(delta: float) -> void:
	_time += delta

	# Check for magnetism
	var magnetism_range := GameManager.gem_magnetism_range
	if magnetism_range > 0:
		var distance_to_zone := PLAYER_ZONE_Y - global_position.y
		if distance_to_zone > 0 and distance_to_zone < magnetism_range:
			# Accelerate toward player zone
			var pull_strength := 1.0 - (distance_to_zone / magnetism_range)
			var current_speed := lerpf(fall_speed, MAGNETISM_SPEED, pull_strength)
			position.y += current_speed * delta
		else:
			position.y += fall_speed * delta
	else:
		position.y += fall_speed * delta

	queue_redraw()

	# Despawn if off screen
	if position.y > 1400:
		queue_free()


func _draw() -> void:
	# Draw gem with sparkle effect
	var sparkle := (sin(_time * sparkle_speed) + 1.0) * 0.5
	var current_color := gem_color.lightened(sparkle * 0.3)

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


func _on_body_entered(_body: Node2D) -> void:
	_collect()


func _on_area_entered(area: Area2D) -> void:
	if area.collision_layer & 16:  # player_zone
		_collect()


func _collect() -> void:
	collected.emit(self)
	queue_free()


func get_xp_value() -> int:
	return xp_value
