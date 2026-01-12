class_name EnemyProjectile
extends Area2D
## Projectile shot by ranged enemies. Damages player on contact.

@export var speed: float = 300.0
@export var damage: int = 5
@export var projectile_color: Color = Color(0.8, 0.2, 0.3)
@export var projectile_radius: float = 6.0

var direction: Vector2 = Vector2.DOWN
var _lifetime: float = 5.0


func _ready() -> void:
	collision_layer = 4  # enemies layer
	collision_mask = 16  # player_zone
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	# Check lifetime
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()

	# Remove if off screen
	if position.y > 1400 or position.y < -100 or position.x < -100 or position.x > 820:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		else:
			GameManager.take_damage(damage)
		CameraShake.shake(5.0, 10.0)
		queue_free()


func _draw() -> void:
	# Draw arrow/bolt shape
	var tip := direction * projectile_radius * 2
	var back := -direction * projectile_radius
	var side1 := Vector2(-direction.y, direction.x) * projectile_radius * 0.6
	var side2 := Vector2(direction.y, -direction.x) * projectile_radius * 0.6

	# Arrow head
	var head_points := PackedVector2Array([
		tip,
		back + side1,
		back + side2
	])
	draw_colored_polygon(head_points, projectile_color)

	# Arrow shaft
	draw_line(back, back - direction * projectile_radius * 1.5, projectile_color.darkened(0.2), 3)
