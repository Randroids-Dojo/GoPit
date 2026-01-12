class_name Archer
extends EnemyBase
## Archer enemy - ranged attacker that shoots projectiles at the player

const EnemyProjectileScene: PackedScene = preload("res://scenes/entities/enemies/enemy_projectile.tscn")

@export var body_color: Color = Color(0.4, 0.5, 0.3)
@export var hood_color: Color = Color(0.3, 0.4, 0.25)
@export var body_width: float = 16.0
@export var body_height: float = 28.0

# Shooting behavior
const SHOOT_COOLDOWN: float = 2.5
const PROJECTILE_SPEED: float = 250.0
const PROJECTILE_DAMAGE: int = 8
const HOVER_Y: float = 400.0  # Y position to hover at
const HOVER_SPEED: float = 50.0  # Side movement speed while hovering

var _shoot_timer: float = 1.0  # Start with shorter delay
var _move_direction: int = 1
var _is_hovering: bool = false


func _ready() -> void:
	# Archers are medium HP, slower
	max_hp = int(max_hp * 1.2)
	hp = max_hp
	speed *= 0.7
	xp_value = int(xp_value * 1.5)
	# Less melee damage (they prefer ranged)
	damage_to_player = int(damage_to_player * 0.5)
	# Random starting direction
	_move_direction = 1 if randf() > 0.5 else -1
	super._ready()


func _move(delta: float) -> void:
	# Descend until reaching hover position
	if not _is_hovering and global_position.y < HOVER_Y:
		velocity = Vector2.DOWN * speed
		move_and_slide()
	else:
		_is_hovering = true
		_hover_and_shoot(delta)


func _hover_and_shoot(delta: float) -> void:
	# Side-to-side movement while hovering
	var viewport_width: float = 720.0
	var margin: float = 60.0

	if global_position.x < margin:
		_move_direction = 1
	elif global_position.x > viewport_width - margin:
		_move_direction = -1

	velocity = Vector2(_move_direction * HOVER_SPEED, 0)
	move_and_slide()

	# Shooting logic
	_shoot_timer -= delta
	if _shoot_timer <= 0:
		_shoot_at_player()
		_shoot_timer = SHOOT_COOLDOWN


func _shoot_at_player() -> void:
	var player := _get_player_node()
	if not player:
		return

	var projectile: EnemyProjectile = EnemyProjectileScene.instantiate()
	projectile.global_position = global_position + Vector2(0, body_height * 0.3)

	# Aim at player
	var to_player := (player.global_position - projectile.global_position).normalized()
	projectile.direction = to_player
	projectile.speed = PROJECTILE_SPEED
	projectile.damage = PROJECTILE_DAMAGE

	# Add to scene
	get_tree().current_scene.add_child(projectile)

	# Visual feedback
	_flash_shoot()


func _flash_shoot() -> void:
	# Brief white flash when shooting
	modulate = Color(1.5, 1.5, 1.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)


func _draw() -> void:
	# Draw body (hooded figure)
	_draw_body()

	# Draw hood
	_draw_hood()

	# Draw bow
	_draw_bow()


func _draw_body() -> void:
	# Simple robe body
	var body_points := PackedVector2Array([
		Vector2(-body_width, -body_height * 0.3),
		Vector2(-body_width * 0.8, -body_height * 0.8),
		Vector2(body_width * 0.8, -body_height * 0.8),
		Vector2(body_width, -body_height * 0.3),
		Vector2(body_width * 0.8, body_height),
		Vector2(-body_width * 0.8, body_height)
	])
	draw_colored_polygon(body_points, body_color)


func _draw_hood() -> void:
	# Pointed hood
	var hood_points := PackedVector2Array([
		Vector2(-body_width * 0.9, -body_height * 0.5),
		Vector2(0, -body_height - 10),
		Vector2(body_width * 0.9, -body_height * 0.5),
		Vector2(body_width * 0.6, -body_height * 0.3),
		Vector2(-body_width * 0.6, -body_height * 0.3)
	])
	draw_colored_polygon(hood_points, hood_color)

	# Dark face area
	draw_circle(Vector2(0, -body_height * 0.5), 6, Color(0.1, 0.1, 0.1))

	# Glowing eyes
	draw_circle(Vector2(-3, -body_height * 0.5), 2, Color(0.9, 0.3, 0.2))
	draw_circle(Vector2(3, -body_height * 0.5), 2, Color(0.9, 0.3, 0.2))


func _draw_bow() -> void:
	# Bow on the side
	var bow_x := body_width + 5
	var bow_color := Color(0.6, 0.4, 0.2)

	# Bow curve
	var bow_points: Array[Vector2] = []
	for i in range(9):
		var t := float(i) / 8.0
		var y: float = lerpf(-15.0, 15.0, t)
		var x: float = bow_x + sin(t * PI) * 8
		bow_points.append(Vector2(x, y))

	for i in range(bow_points.size() - 1):
		draw_line(bow_points[i], bow_points[i + 1], bow_color, 2)

	# Bowstring
	draw_line(Vector2(bow_x, -15), Vector2(bow_x, 15), Color(0.9, 0.9, 0.9), 1)
