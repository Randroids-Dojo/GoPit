extends CharacterBody2D
## Ball entity - moves in a direction and bounces off walls

signal hit_enemy(enemy: Node2D)
signal hit_gem(gem: Node2D)
signal despawned

enum BallType { NORMAL, FIRE, ICE, LIGHTNING }

@export var speed: float = 800.0
@export var ball_color: Color = Color(0.3, 0.7, 1.0)
@export var radius: float = 12.0
@export var damage: int = 10

var direction: Vector2 = Vector2.UP
var pierce_count: int = 0
var max_bounces: int = 10
var crit_chance: float = 0.0
var _bounce_count: int = 0

# Ball type and effects
var ball_type: BallType = BallType.NORMAL
var _trail_points: Array[Vector2] = []
const MAX_TRAIL_POINTS: int = 8


func _ready() -> void:
	_apply_ball_type_visuals()
	queue_redraw()


func set_ball_type(new_type: BallType) -> void:
	ball_type = new_type
	_apply_ball_type_visuals()


func _apply_ball_type_visuals() -> void:
	match ball_type:
		BallType.NORMAL:
			ball_color = Color(0.3, 0.7, 1.0)  # Blue
		BallType.FIRE:
			ball_color = Color(1.0, 0.5, 0.1)  # Orange
		BallType.ICE:
			ball_color = Color(0.5, 0.9, 1.0)  # Cyan
		BallType.LIGHTNING:
			ball_color = Color(1.0, 1.0, 0.3)  # Yellow


func _draw() -> void:
	# Draw trail for special ball types
	if ball_type != BallType.NORMAL and _trail_points.size() > 1:
		for i in range(_trail_points.size() - 1):
			var alpha: float = float(i) / _trail_points.size() * 0.5
			var trail_color := ball_color
			trail_color.a = alpha
			var width: float = radius * 0.5 * (float(i) / _trail_points.size())
			draw_line(_trail_points[i] - global_position, _trail_points[i + 1] - global_position, trail_color, width)

	# Draw main ball
	draw_circle(Vector2.ZERO, radius, ball_color)

	# Type-specific effects
	match ball_type:
		BallType.FIRE:
			# Inner glow
			draw_circle(Vector2.ZERO, radius * 0.6, Color(1.0, 0.8, 0.2))
		BallType.ICE:
			# Crystal effect
			for i in range(6):
				var angle: float = TAU * i / 6.0
				var point := Vector2.from_angle(angle) * radius * 0.7
				draw_line(Vector2.ZERO, point, Color.WHITE, 1.5)
		BallType.LIGHTNING:
			# Spark effect
			for i in range(4):
				var angle: float = TAU * i / 4.0 + randf() * 0.3
				var len: float = radius * (0.8 + randf() * 0.4)
				var point := Vector2.from_angle(angle) * len
				draw_line(Vector2.ZERO, point, Color.WHITE, 1.0)


func _physics_process(delta: float) -> void:
	velocity = direction * speed

	# Update trail
	if ball_type != BallType.NORMAL:
		_trail_points.append(global_position)
		while _trail_points.size() > MAX_TRAIL_POINTS:
			_trail_points.remove_at(0)
		queue_redraw()

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

			# Ball type bonus damage/effects
			_apply_ball_type_effect(collider, actual_damage)

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


func _apply_ball_type_effect(enemy: Node2D, _base_damage: int) -> void:
	match ball_type:
		BallType.FIRE:
			# Fire: Apply burn tint (visual effect)
			if enemy.has_method("_apply_burn_effect"):
				enemy._apply_burn_effect()
			else:
				# Fallback visual tint
				enemy.modulate = Color(1.5, 0.7, 0.5)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 0.5)

		BallType.ICE:
			# Ice: Slow enemy temporarily
			if enemy is EnemyBase:
				var original_speed: float = enemy.speed
				enemy.speed *= 0.5
				enemy.modulate = Color(0.7, 0.9, 1.2)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "speed", original_speed, 1.5)
				tween.parallel().tween_property(enemy, "modulate", Color.WHITE, 1.5)

		BallType.LIGHTNING:
			# Lightning: Chain to nearby enemies
			_chain_lightning(enemy)


func _chain_lightning(hit_enemy: Node2D) -> void:
	var chain_range: float = 150.0
	var chain_damage: int = int(damage * 0.5)

	# Find nearby enemies
	var enemies_container := get_tree().current_scene.get_node_or_null("GameArea/Enemies")
	if not enemies_container:
		return

	for child in enemies_container.get_children():
		if child is EnemyBase and child != hit_enemy:
			var dist: float = child.global_position.distance_to(hit_enemy.global_position)
			if dist < chain_range:
				# Chain hit
				if child.has_method("take_damage"):
					child.take_damage(chain_damage)
				# Visual lightning arc
				_draw_lightning_arc(hit_enemy.global_position, child.global_position)
				break  # Only chain to one enemy


func _draw_lightning_arc(from: Vector2, to: Vector2) -> void:
	# Create a temporary line for lightning visual
	var line := Line2D.new()
	line.width = 2.0
	line.default_color = Color(1.0, 1.0, 0.5, 0.8)

	# Add jagged points
	var points: int = 5
	for i in range(points + 1):
		var t: float = float(i) / points
		var base_pos := from.lerp(to, t)
		var offset := Vector2(randf_range(-10, 10), randf_range(-10, 10)) if i > 0 and i < points else Vector2.ZERO
		line.add_point(base_pos + offset)

	get_tree().current_scene.add_child(line)

	# Fade out and remove
	var tween := line.create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.15)
	tween.tween_callback(line.queue_free)
