extends CharacterBody2D
## Ball entity - moves in a direction and bounces off walls

signal hit_enemy(enemy: Node2D)
signal hit_gem(gem: Node2D)
signal despawned

@export var speed: float = 800.0
@export var ball_color: Color = Color(0.3, 0.7, 1.0)
@export var radius: float = 12.0
@export var damage: int = 10

var direction: Vector2 = Vector2.UP


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, ball_color)


func _physics_process(delta: float) -> void:
	velocity = direction * speed

	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider := collision.get_collider()

		# Bounce off walls
		if collider.collision_layer & 1:  # walls layer
			direction = direction.bounce(collision.get_normal())

		# Hit enemy
		elif collider.collision_layer & 4:  # enemies layer
			direction = direction.bounce(collision.get_normal())
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
			hit_enemy.emit(collider)

		# Hit gem
		elif collider.collision_layer & 8:  # gems layer
			hit_gem.emit(collider)


func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()


func despawn() -> void:
	despawned.emit()
	queue_free()
