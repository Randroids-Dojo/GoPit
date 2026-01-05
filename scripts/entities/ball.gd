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
var pierce_count: int = 0
var max_bounces: int = 10
var crit_chance: float = 0.0
var _bounce_count: int = 0


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
			_bounce_count += 1
			if _bounce_count > max_bounces:
				despawn()
				return
			direction = direction.bounce(collision.get_normal())
			SoundManager.play(SoundManager.SoundType.HIT_WALL)

		# Hit enemy
		elif collider.collision_layer & 4:  # enemies layer
			var actual_damage := damage
			var is_crit := false

			# Check for critical hit
			if crit_chance > 0 and randf() < crit_chance:
				actual_damage *= 2
				is_crit = true

			if collider.has_method("take_damage"):
				collider.take_damage(actual_damage)

			# Visual crit effect
			if is_crit:
				_show_crit_effect()

			hit_enemy.emit(collider)
			SoundManager.play(SoundManager.SoundType.HIT_ENEMY)

			# Handle piercing
			if pierce_count > 0:
				pierce_count -= 1
				# Continue through enemy - add slight offset to avoid re-collision
				position += direction * 20
			else:
				direction = direction.bounce(collision.get_normal())

		# Hit gem
		elif collider.collision_layer & 8:  # gems layer
			hit_gem.emit(collider)


func _show_crit_effect() -> void:
	# Brief flash to indicate crit
	modulate = Color(1.5, 1.5, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()


func despawn() -> void:
	despawned.emit()
	queue_free()
