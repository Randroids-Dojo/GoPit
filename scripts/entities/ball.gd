extends CharacterBody2D
## Ball entity - moves in a direction and bounces off walls

const StatusEffect := preload("res://scripts/effects/status_effect.gd")

signal hit_enemy(enemy: Node2D)
signal hit_gem(gem: Node2D)
signal despawned
signal returned  # Emitted when ball returns to player (bottom of screen)
signal caught  # Emitted when ball is caught by player (active play bonus)

enum BallType { NORMAL, FIRE, ICE, LIGHTNING, POISON, BLEED, IRON, RADIATION, DISEASE, FROSTBURN, WIND, GHOST, VAMPIRE, BROOD_MOTHER, DARK }

@export var speed: float = 800.0
@export var ball_color: Color = Color(0.3, 0.7, 1.0)
@export var radius: float = 14.0
@export var damage: int = 10

var direction: Vector2 = Vector2.UP
var pierce_count: int = 0
var max_bounces: int = 30  # supports diagonal shot strategies (20-30 bounces)
var crit_chance: float = 0.0
var _bounce_count: int = 0

# Ball type, level, and effects
var ball_type: BallType = BallType.NORMAL
var ball_level: int = 1  # 1-3, affects visuals
var registry_type: int = -1  # BallRegistry.BallType if set from registry
var _trail_points: Array[Vector2] = []
const MAX_TRAIL_POINTS: int = 8
var _particle_trail: GPUParticles2D = null

# Ball return mechanic - balls return when crossing bottom of screen
const RETURN_Y_THRESHOLD: float = 1150.0  # Below player position - start return
const RETURN_COMPLETE_Y: float = 350.0  # Near player position - complete return
const CATCH_ZONE_Y: float = 600.0  # Ball is catchable when y < this (in catch zone)
var is_returning: bool = false  # True when ball is flying back to player
var is_catchable: bool = false  # True when ball can be caught (returning and in catch zone)

# Trail particle scenes per ball type (preloaded for performance)
const TRAIL_SCENE_FIRE: PackedScene = preload("res://scenes/effects/fire_trail.tscn")
const TRAIL_SCENE_ICE: PackedScene = preload("res://scenes/effects/ice_trail.tscn")
const TRAIL_SCENE_LIGHTNING: PackedScene = preload("res://scenes/effects/lightning_trail.tscn")
const TRAIL_SCENE_POISON: PackedScene = preload("res://scenes/effects/poison_trail.tscn")
const TRAIL_SCENE_BLEED: PackedScene = preload("res://scenes/effects/bleed_trail.tscn")
const TRAIL_SCENE_IRON: PackedScene = preload("res://scenes/effects/iron_trail.tscn")
const TRAIL_SCENE_VAMPIRE: PackedScene = preload("res://scenes/effects/vampire_trail.tscn")

# Baby ball properties (auto-spawned, smaller, less damage)
var is_baby_ball: bool = false

# Evolved/Fused ball properties
var is_evolved: bool = false
var evolved_type: int = 0  # FusionRegistry.EvolvedBallType
var is_fused: bool = false
var fused_id: String = ""
var fused_effects: Array = []  # Array of effect strings for fused balls


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
		BallType.POISON:
			ball_color = Color(0.4, 0.9, 0.2)  # Green
		BallType.BLEED:
			ball_color = Color(0.9, 0.2, 0.3)  # Dark red
		BallType.IRON:
			ball_color = Color(0.7, 0.7, 0.75)  # Metallic gray
		BallType.RADIATION:
			ball_color = Color(0.5, 1.0, 0.2)  # Toxic yellow-green
		BallType.DISEASE:
			ball_color = Color(0.6, 0.3, 0.8)  # Sickly purple
		BallType.FROSTBURN:
			ball_color = Color(0.3, 0.6, 1.0)  # Pale frost blue
		BallType.WIND:
			ball_color = Color(0.8, 1.0, 0.8)  # Light green-white (airy)
		BallType.GHOST:
			ball_color = Color(0.7, 0.7, 0.9, 0.6)  # Semi-transparent purple
			modulate.a = 0.6  # Make ball semi-transparent
		BallType.VAMPIRE:
			ball_color = Color(0.5, 0.1, 0.3)  # Dark crimson
		BallType.BROOD_MOTHER:
			ball_color = Color(0.8, 0.5, 0.9)  # Lavender/pink
		BallType.DARK:
			ball_color = Color(0.15, 0.05, 0.2)  # Very dark purple

	# Spawn particle trail for special ball types
	_spawn_particle_trail()


func _spawn_particle_trail() -> void:
	"""Spawn particle trail if ball type has one"""
	# Remove existing trail
	if _particle_trail:
		_particle_trail.queue_free()
		_particle_trail = null

	# No trail for normal balls
	if ball_type == BallType.NORMAL:
		return

	# Get preloaded trail scene for this type
	var trail_scene: PackedScene = null
	match ball_type:
		BallType.FIRE:
			trail_scene = TRAIL_SCENE_FIRE
		BallType.ICE:
			trail_scene = TRAIL_SCENE_ICE
		BallType.LIGHTNING:
			trail_scene = TRAIL_SCENE_LIGHTNING
		BallType.POISON:
			trail_scene = TRAIL_SCENE_POISON
		BallType.BLEED:
			trail_scene = TRAIL_SCENE_BLEED
		BallType.IRON:
			trail_scene = TRAIL_SCENE_IRON
		BallType.VAMPIRE:
			trail_scene = TRAIL_SCENE_VAMPIRE

	if trail_scene:
		_particle_trail = trail_scene.instantiate()
		add_child(_particle_trail)


func _draw() -> void:
	# Baby balls are smaller and have a subtle glow
	if is_baby_ball:
		var baby_radius := radius * 0.5
		# Outer glow
		draw_circle(Vector2.ZERO, baby_radius + 3, Color(ball_color.r, ball_color.g, ball_color.b, 0.3))
		# Main ball (slightly lighter)
		draw_circle(Vector2.ZERO, baby_radius, ball_color.lightened(0.2))
		# Sparkle highlight
		draw_circle(Vector2(-baby_radius * 0.3, -baby_radius * 0.3), baby_radius * 0.25, Color(1.0, 1.0, 1.0, 0.6))
		return

	# Level affects size: L1=1.0x, L2=1.1x, L3=1.2x
	var level_size_mult := 1.0 + (ball_level - 1) * 0.1
	var actual_radius := radius * level_size_mult

	# Draw trail for special ball types
	if ball_type != BallType.NORMAL and _trail_points.size() > 1:
		for i in range(_trail_points.size() - 1):
			var alpha: float = float(i) / _trail_points.size() * 0.5
			var trail_color := ball_color
			trail_color.a = alpha
			var width: float = actual_radius * 0.5 * (float(i) / _trail_points.size())
			draw_line(_trail_points[i] - global_position, _trail_points[i + 1] - global_position, trail_color, width)

	# Draw main ball
	draw_circle(Vector2.ZERO, actual_radius, ball_color)

	# Level indicator rings
	if ball_level >= 2:
		# L2: single white ring
		draw_arc(Vector2.ZERO, actual_radius + 2, 0, TAU, 24, Color(1.0, 1.0, 1.0, 0.7), 1.5)
	if ball_level >= 3:
		# L3: gold outer ring (fusion-ready)
		draw_arc(Vector2.ZERO, actual_radius + 5, 0, TAU, 24, Color(1.0, 0.85, 0.0, 0.9), 2.0)

	# Type-specific effects
	match ball_type:
		BallType.FIRE:
			# Inner glow
			draw_circle(Vector2.ZERO, actual_radius * 0.6, Color(1.0, 0.8, 0.2))
		BallType.ICE:
			# Crystal effect
			for i in range(6):
				var angle: float = TAU * i / 6.0
				var point := Vector2.from_angle(angle) * actual_radius * 0.7
				draw_line(Vector2.ZERO, point, Color.WHITE, 1.5)
		BallType.LIGHTNING:
			# Spark effect
			for i in range(4):
				var angle: float = TAU * i / 4.0 + randf() * 0.3
				var len: float = actual_radius * (0.8 + randf() * 0.4)
				var point := Vector2.from_angle(angle) * len
				draw_line(Vector2.ZERO, point, Color.WHITE, 1.0)
		BallType.POISON:
			# Bubble effect
			for i in range(3):
				var angle: float = TAU * i / 3.0 + randf() * 0.2
				var bubble_pos := Vector2.from_angle(angle) * actual_radius * 0.5
				draw_circle(bubble_pos, 3.0, Color(0.2, 0.7, 0.1, 0.6))
		BallType.BLEED:
			# Drip effect
			draw_circle(Vector2(0, actual_radius * 0.4), 4.0, Color(0.7, 0.1, 0.1))
		BallType.IRON:
			# Metallic shine
			draw_arc(Vector2(-actual_radius * 0.3, -actual_radius * 0.3), actual_radius * 0.4, -0.5, 1.0, 8, Color(1.0, 1.0, 1.0, 0.5), 2.0)
		BallType.VAMPIRE:
			# Fang marks effect
			draw_circle(Vector2(-3, actual_radius * 0.3), 2.5, Color(0.8, 0.0, 0.2))
			draw_circle(Vector2(3, actual_radius * 0.3), 2.5, Color(0.8, 0.0, 0.2))


func _physics_process(delta: float) -> void:
	velocity = direction * speed

	# Update trail
	if ball_type != BallType.NORMAL:
		_trail_points.append(global_position)
		while _trail_points.size() > MAX_TRAIL_POINTS:
			_trail_points.remove_at(0)
		queue_redraw()

	# Ball return mechanic with return path damage
	if not is_returning:
		# Check if ball should start returning (crossed bottom threshold)
		if global_position.y > RETURN_Y_THRESHOLD:
			_start_return()
	else:
		# Check if ball is in catch zone (can be caught by player)
		is_catchable = global_position.y < CATCH_ZONE_Y
		# Check if ball has returned to player area
		if global_position.y < RETURN_COMPLETE_Y:
			return_to_player()
			return

	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider := collision.get_collider()

		# Bounce off walls
		if collider.collision_layer & 1:  # walls layer
			_bounce_count += 1
			# Removed despawn on max_bounces - balls now return at bottom of screen
			direction = direction.bounce(collision.get_normal())
			SoundManager.play(SoundManager.SoundType.HIT_WALL)

		# Hit enemy
		elif collider.collision_layer & 4:  # enemies layer
			var actual_damage := damage
			var is_crit := false

			# Bounce damage scaling (Bounce Master passive: +5% per bounce)
			var bounce_mult := GameManager.get_bounce_damage_multiplier()
			if bounce_mult > 0 and _bounce_count > 0:
				actual_damage = int(actual_damage * (1.0 + _bounce_count * bounce_mult))

			# Check for critical hit (dexterity base + Jackpot bonus + upgrade crit chance)
			var total_crit_chance := crit_chance + GameManager.get_total_crit_chance()
			if total_crit_chance > 0 and randf() < total_crit_chance:
				actual_damage = int(actual_damage * GameManager.get_crit_damage_multiplier())
				is_crit = true

			# Inferno passive: +20% fire damage
			if ball_type == BallType.FIRE:
				actual_damage = int(actual_damage * GameManager.get_fire_damage_multiplier())

			# Dark ball: 3x damage (high risk, high reward - self-destructs on hit)
			if ball_type == BallType.DARK:
				actual_damage = actual_damage * 3

			# Check for status-based damage bonuses
			if collider.has_method("has_status_effect"):
				# Shatter: +50% damage vs frozen (base +25%)
				if collider.has_status_effect(StatusEffect.Type.FREEZE):
					actual_damage = int(actual_damage * GameManager.get_damage_vs_frozen())
				# Inferno: +25% damage vs burning
				if collider.has_status_effect(StatusEffect.Type.BURN):
					actual_damage = int(actual_damage * GameManager.get_damage_vs_burning())
				# Bleed: +15% damage vs bleeding
				if collider.has_status_effect(StatusEffect.Type.BLEED):
					actual_damage = int(actual_damage * GameManager.get_damage_vs_bleeding())

			# Apply evolved/fused/normal ball effects
			if is_evolved:
				_apply_evolved_effect(collider, actual_damage)
			elif is_fused:
				_apply_fused_effects(collider, actual_damage)
			else:
				# Ball type bonus damage/effects
				_apply_ball_type_effect(collider, actual_damage)

			# Use position-based damage for weak point detection (e.g., boss crowns)
			# Pass is_crit flag for execute mechanic
			if collider.has_method("take_damage_at_position"):
				collider.take_damage_at_position(actual_damage, collision.get_position(), is_crit)
			elif collider.has_method("take_damage"):
				collider.take_damage(actual_damage, is_crit)

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
	# Return to pool if pooled, otherwise free
	if has_meta("pooled") and PoolManager:
		reset()
		PoolManager.release_ball(self)
	else:
		queue_free()


func _start_return() -> void:
	"""Start returning to player - ball reverses direction and flies back"""
	is_returning = true
	# Reverse direction to fly back toward player (mostly upward)
	direction = Vector2.UP
	# Visual feedback - slight tint to show returning state
	modulate = Color(0.8, 0.8, 1.0, 0.9)


func return_to_player() -> void:
	"""Ball has completed return to player area - return to pool"""
	returned.emit()
	# Return to pool if pooled, otherwise free
	if has_meta("pooled") and PoolManager:
		reset()
		PoolManager.release_ball(self)
	else:
		queue_free()


func catch() -> bool:
	"""Attempt to catch the ball - returns true if successful (ball was catchable)"""
	if not is_catchable:
		return false

	caught.emit()
	# Visual catch effect
	_show_catch_effect()
	# Return to pool
	if has_meta("pooled") and PoolManager:
		reset()
		PoolManager.release_ball(self)
	else:
		queue_free()
	return true


func _show_catch_effect() -> void:
	"""Visual effect when ball is caught"""
	# Spawn a brief burst effect at catch position
	var burst := Control.new()
	burst.global_position = global_position
	burst.z_index = 10

	var circle := ColorRect.new()
	var size := 40.0
	circle.size = Vector2(size, size)
	circle.position = Vector2(-size / 2, -size / 2)
	circle.color = Color(0.3, 1.0, 0.5, 0.8)  # Green for catch
	burst.add_child(circle)

	get_tree().current_scene.add_child(burst)

	var tween := burst.create_tween()
	tween.tween_property(circle, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(circle, "scale", Vector2(2.0, 2.0), 0.2)
	tween.tween_callback(burst.queue_free)


func reset() -> void:
	"""Reset ball state for object pool reuse"""
	# Disconnect signals to prevent "already connected" errors
	for conn in returned.get_connections():
		returned.disconnect(conn.callable)
	for conn in caught.get_connections():
		caught.disconnect(conn.callable)
	for conn in despawned.get_connections():
		despawned.disconnect(conn.callable)

	# Reset position and physics
	direction = Vector2.UP
	velocity = Vector2.ZERO
	_bounce_count = 0

	# Reset stats to defaults
	speed = 800.0
	damage = 10
	pierce_count = 0
	max_bounces = 30
	crit_chance = 0.0

	# Reset type/level
	ball_type = BallType.NORMAL
	ball_level = 1
	registry_type = -1

	# Clear trail
	_trail_points.clear()
	if _particle_trail:
		_particle_trail.queue_free()
		_particle_trail = null

	# Reset flags
	is_baby_ball = false
	is_evolved = false
	evolved_type = 0
	is_fused = false
	fused_id = ""
	fused_effects.clear()
	is_returning = false
	is_catchable = false

	# Reset visual state
	modulate = Color.WHITE
	scale = Vector2.ONE
	ball_color = Color(0.3, 0.7, 1.0)

	# Reset collision shape to default radius
	var collision := get_node_or_null("CollisionShape2D")
	if collision and collision.shape is CircleShape2D:
		collision.shape.radius = radius

	queue_redraw()


func _apply_ball_type_effect(enemy: Node2D, _base_damage: int) -> void:
	match ball_type:
		BallType.FIRE:
			# Fire: Apply burn status effect
			if enemy.has_method("apply_status_effect"):
				var burn = StatusEffect.new(StatusEffect.Type.BURN)
				enemy.apply_status_effect(burn)
			else:
				# Fallback visual tint for non-EnemyBase
				enemy.modulate = Color(1.5, 0.7, 0.5)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 0.5)

		BallType.ICE:
			# Ice: Apply freeze status effect (slows enemy)
			if enemy.has_method("apply_status_effect"):
				var freeze = StatusEffect.new(StatusEffect.Type.FREEZE)
				enemy.apply_status_effect(freeze)
			else:
				# Fallback direct slow for non-EnemyBase
				enemy.modulate = Color(0.7, 0.9, 1.2)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 1.5)

		BallType.LIGHTNING:
			# Lightning: Chain to nearby enemies (instant effect)
			_chain_lightning(enemy)

		BallType.POISON:
			# Poison: Apply poison status effect (DoT + spreads on death)
			if enemy.has_method("apply_status_effect"):
				var poison = StatusEffect.new(StatusEffect.Type.POISON)
				enemy.apply_status_effect(poison)
			else:
				# Fallback visual tint
				enemy.modulate = Color(0.6, 1.0, 0.5)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 2.0)

		BallType.BLEED:
			# Bleed: Apply bleed status effect (stacking DoT)
			if enemy.has_method("apply_status_effect"):
				var bleed = StatusEffect.new(StatusEffect.Type.BLEED)
				enemy.apply_status_effect(bleed)
			else:
				# Fallback visual tint
				enemy.modulate = Color(1.0, 0.5, 0.5)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 1.0)

		BallType.IRON:
			# Iron: Knockback effect (instant)
			if enemy is EnemyBase:
				var knockback_dir := (enemy.global_position - global_position).normalized()
				var knockback_strength := 50.0
				enemy.global_position += knockback_dir * knockback_strength
				# Metallic impact visual
				enemy.modulate = Color(0.8, 0.8, 0.9)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 0.2)

		BallType.RADIATION:
			# Radiation: Apply radiation status (damage amplification)
			if enemy.has_method("apply_status_effect"):
				var radiation = StatusEffect.new(StatusEffect.Type.RADIATION)
				enemy.apply_status_effect(radiation)
			else:
				# Fallback visual tint
				enemy.modulate = Color(0.5, 1.0, 0.2)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 1.0)

		BallType.DISEASE:
			# Disease: Apply disease status (stacking DoT)
			if enemy.has_method("apply_status_effect"):
				var disease = StatusEffect.new(StatusEffect.Type.DISEASE)
				enemy.apply_status_effect(disease)
			else:
				# Fallback visual tint
				enemy.modulate = Color(0.6, 0.3, 0.8)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 1.5)

		BallType.FROSTBURN:
			# Frostburn: Apply frostburn status (slow + damage amp)
			if enemy.has_method("apply_status_effect"):
				var frostburn = StatusEffect.new(StatusEffect.Type.FROSTBURN)
				enemy.apply_status_effect(frostburn)
			else:
				# Fallback visual tint
				enemy.modulate = Color(0.3, 0.6, 1.0)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 1.0)

		BallType.WIND:
			# Wind: Pass-through + light slow effect
			if enemy.has_method("apply_status_effect"):
				var wind = StatusEffect.new(StatusEffect.Type.WIND)
				enemy.apply_status_effect(wind)
			else:
				# Fallback visual tint
				enemy.modulate = Color(0.8, 1.0, 0.8)
				var tween := enemy.create_tween()
				tween.tween_property(enemy, "modulate", Color.WHITE, 0.5)
			# Wind balls pass through enemies
			pierce_count = max(pierce_count, 2)

		BallType.GHOST:
			# Ghost: Full pass-through, no status effect
			# Ghostly visual effect on enemy
			enemy.modulate = Color(0.7, 0.7, 0.9, 0.5)
			var tween := enemy.create_tween()
			tween.tween_property(enemy, "modulate", Color.WHITE, 0.3)
			# Ghost balls pass through all enemies (very high pierce)
			pierce_count = 999

		BallType.VAMPIRE:
			# Vampire: Lifesteal on hit (heal 20% of damage dealt)
			var lifesteal_amount := int(_base_damage * 0.2)
			if lifesteal_amount > 0:
				GameManager.heal(lifesteal_amount)
			# Vampiric visual effect
			enemy.modulate = Color(0.5, 0.1, 0.3)
			var tween := enemy.create_tween()
			tween.tween_property(enemy, "modulate", Color.WHITE, 0.3)

		BallType.BROOD_MOTHER:
			# Brood Mother: Spawn a baby ball on hit
			_spawn_brood_baby(enemy.global_position)
			# Visual brood spawn effect
			enemy.modulate = Color(0.8, 0.5, 0.9)
			var brood_tween := enemy.create_tween()
			brood_tween.tween_property(enemy, "modulate", Color.WHITE, 0.3)

		BallType.DARK:
			# Dark: Self-destruct on hit (damage multiplier applied elsewhere)
			# Dark explosion visual effect
			enemy.modulate = Color(0.3, 0.0, 0.4)
			var tween := enemy.create_tween()
			tween.tween_property(enemy, "modulate", Color.WHITE, 0.2)
			# Self-destruct after hit
			call_deferred("despawn")


func _chain_lightning(hit_enemy: Node2D) -> void:
	var chain_range: float = 150.0
	var chain_damage: int = int(damage * 0.5)
	var max_chains: int = 3  # Chain to up to 3 enemies
	var chains_done: int = 0

	# Find nearby enemies
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return

	for child in enemies_container.get_children():
		if chains_done >= max_chains:
			break
		if child is EnemyBase and child != hit_enemy:
			var dist: float = child.global_position.distance_to(hit_enemy.global_position)
			if dist < chain_range:
				# Chain hit
				if child.has_method("take_damage"):
					child.take_damage(chain_damage)
				# Visual lightning arc
				_draw_lightning_arc(hit_enemy.global_position, child.global_position)
				chains_done += 1


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


func _spawn_brood_baby(spawn_pos: Vector2) -> void:
	"""Spawn a small baby ball from the Brood Mother ball"""
	var ball_scene := preload("res://scenes/entities/ball.tscn")
	var baby: Node2D

	# Get from pool if available
	if PoolManager:
		baby = PoolManager.get_ball()
	else:
		baby = ball_scene.instantiate()

	baby.position = spawn_pos
	baby.scale = Vector2(0.5, 0.5)  # Smaller than regular baby balls
	baby.is_baby_ball = true
	baby.damage = int(damage * 0.3)  # 30% of parent damage

	# Inherit brood mother type
	if baby.has_method("set_ball_type"):
		baby.set_ball_type(BallType.BROOD_MOTHER)

	# Random direction (spread pattern)
	var random_angle := randf_range(0, TAU)
	baby.direction = Vector2.from_angle(random_angle)

	# Add to game
	var balls_container := get_tree().get_first_node_in_group("balls_container")
	if balls_container:
		balls_container.add_child(baby)
	else:
		get_parent().add_child(baby)


func _apply_evolved_effect(enemy: Node2D, base_damage: int) -> void:
	"""Apply unique evolved ball effects"""
	# Access FusionRegistry for evolved ball data
	if not FusionRegistry:
		return

	match evolved_type:
		FusionRegistry.EvolvedBallType.BOMB:
			# Explosion AoE - damage all enemies in radius
			_do_explosion(enemy.global_position, base_damage)

		FusionRegistry.EvolvedBallType.BLIZZARD:
			# AoE freeze + chain
			_do_blizzard(enemy)

		FusionRegistry.EvolvedBallType.VIRUS:
			# Spreading DoT + lifesteal
			_do_virus(enemy)

		FusionRegistry.EvolvedBallType.MAGMA:
			# Spawn burning ground pool
			_do_magma_pool(enemy.global_position)

		FusionRegistry.EvolvedBallType.VOID:
			# Alternating burn/freeze
			_do_void_effect(enemy)

		# New evolved ball effects
		FusionRegistry.EvolvedBallType.GLACIER:
			# Heavy ice - pierce and slow
			_do_glacier(enemy)

		FusionRegistry.EvolvedBallType.STORM:
			# Chain lightning with poison spread
			_do_storm(enemy)

		FusionRegistry.EvolvedBallType.PLASMA:
			# Chain lightning with bleed
			_do_plasma(enemy)

		FusionRegistry.EvolvedBallType.CLEAVER:
			# Heavy bleed + knockback
			_do_cleaver(enemy)

		FusionRegistry.EvolvedBallType.FROSTBITE:
			# Freeze that causes bleed when thawed
			_do_frostbite(enemy)


func _do_explosion(pos: Vector2, base_damage: int) -> void:
	"""BOMB effect - AoE explosion damage"""
	var explosion_radius := 100.0
	var explosion_damage := int(base_damage * 1.5)

	# Find all enemies in radius
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return

	for child in enemies_container.get_children():
		if child is EnemyBase:
			var dist: float = child.global_position.distance_to(pos)
			if dist < explosion_radius:
				if child.has_method("take_damage"):
					child.take_damage(explosion_damage)

	# Visual explosion effect
	_spawn_explosion_visual(pos, explosion_radius)


func _spawn_explosion_visual(pos: Vector2, radius: float) -> void:
	"""Spawn explosion visual effect"""
	var explosion := Control.new()
	explosion.global_position = pos
	explosion.z_index = 10

	var circle := ColorRect.new()
	circle.size = Vector2(radius * 2, radius * 2)
	circle.position = Vector2(-radius, -radius)
	circle.color = Color(1.0, 0.5, 0.0, 0.7)
	explosion.add_child(circle)

	get_tree().current_scene.add_child(explosion)

	var tween := explosion.create_tween()
	tween.tween_property(circle, "modulate:a", 0.0, 0.3)
	tween.tween_callback(explosion.queue_free)


func _do_blizzard(hit_enemy: Node2D) -> void:
	"""BLIZZARD effect - AoE freeze + chain to nearby enemies"""
	var freeze_radius := 80.0
	var chain_count := 3
	var chains_done := 0

	# Apply freeze to hit enemy
	if hit_enemy.has_method("apply_status_effect"):
		var freeze = StatusEffect.new(StatusEffect.Type.FREEZE)
		hit_enemy.apply_status_effect(freeze)

	# Find and freeze nearby enemies
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return

	for child in enemies_container.get_children():
		if child is EnemyBase and child != hit_enemy and chains_done < chain_count:
			var dist: float = child.global_position.distance_to(hit_enemy.global_position)
			if dist < freeze_radius:
				if child.has_method("apply_status_effect"):
					var freeze = StatusEffect.new(StatusEffect.Type.FREEZE)
					child.apply_status_effect(freeze)
				# Visual ice chain
				_draw_ice_chain(hit_enemy.global_position, child.global_position)
				chains_done += 1


func _draw_ice_chain(from: Vector2, to: Vector2) -> void:
	"""Draw ice chain visual"""
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = Color(0.5, 0.9, 1.0, 0.8)
	line.add_point(from)
	line.add_point(to)
	get_tree().current_scene.add_child(line)

	var tween := line.create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.2)
	tween.tween_callback(line.queue_free)


func _do_virus(enemy: Node2D) -> void:
	"""VIRUS effect - Spreading DoT + lifesteal"""
	var spread_radius := 80.0
	var lifesteal_amount := 0.2

	# Apply poison and bleed to hit enemy
	if enemy.has_method("apply_status_effect"):
		var poison = StatusEffect.new(StatusEffect.Type.POISON)
		var bleed = StatusEffect.new(StatusEffect.Type.BLEED)
		enemy.apply_status_effect(poison)
		enemy.apply_status_effect(bleed)

	# Spread to nearby enemies
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if enemies_container:
		for child in enemies_container.get_children():
			if child is EnemyBase and child != enemy:
				var dist: float = child.global_position.distance_to(enemy.global_position)
				if dist < spread_radius:
					if child.has_method("apply_status_effect"):
						var poison = StatusEffect.new(StatusEffect.Type.POISON)
						child.apply_status_effect(poison)

	# Lifesteal - heal player
	var heal_amount := int(damage * lifesteal_amount)
	GameManager.heal(heal_amount)


func _do_magma_pool(pos: Vector2) -> void:
	"""MAGMA effect - Spawn burning ground pool"""
	var pool_duration := 3.0
	var pool_dps := 5
	var pool_radius := 50.0

	# Create magma pool visual
	var pool := Control.new()
	pool.global_position = pos
	pool.z_index = -1

	var circle := ColorRect.new()
	circle.size = Vector2(pool_radius * 2, pool_radius * 2)
	circle.position = Vector2(-pool_radius, -pool_radius)
	circle.color = Color(1.0, 0.4, 0.0, 0.6)
	pool.add_child(circle)

	get_tree().current_scene.add_child(pool)

	# Pool damages enemies over time
	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(func():
		var enemies_container := get_tree().get_first_node_in_group("enemies_container")
		if enemies_container:
			for child in enemies_container.get_children():
				if child is EnemyBase:
					var dist: float = child.global_position.distance_to(pos)
					if dist < pool_radius:
						if child.has_method("take_damage"):
							child.take_damage(pool_dps)
						# Apply burn
						if child.has_method("apply_status_effect"):
							var burn = StatusEffect.new(StatusEffect.Type.BURN)
							child.apply_status_effect(burn)
	)
	pool.add_child(timer)

	# Remove pool after duration
	var tween := pool.create_tween()
	tween.tween_interval(pool_duration - 0.5)
	tween.tween_property(circle, "modulate:a", 0.0, 0.5)
	tween.tween_callback(pool.queue_free)


# Track void alternation state (static so all void balls share state)
static var _void_use_burn: bool = true

func _do_void_effect(enemy: Node2D) -> void:
	"""VOID effect - Alternates between burn and freeze each hit"""
	if enemy.has_method("apply_status_effect"):
		if _void_use_burn:
			var burn = StatusEffect.new(StatusEffect.Type.BURN)
			enemy.apply_status_effect(burn)
		else:
			var freeze = StatusEffect.new(StatusEffect.Type.FREEZE)
			enemy.apply_status_effect(freeze)

	_void_use_burn = not _void_use_burn

	# Visual void effect
	var void_color := Color(0.3, 0.0, 0.5) if _void_use_burn else Color(0.0, 0.3, 0.5)
	enemy.modulate = void_color
	var tween := enemy.create_tween()
	tween.tween_property(enemy, "modulate", Color.WHITE, 0.3)


# ===== New Evolved Ball Effects =====

func _do_glacier(enemy: Node2D) -> void:
	"""GLACIER effect - Apply freeze and increase pierce"""
	# Apply freeze status
	if enemy.has_method("apply_status_effect"):
		var freeze = StatusEffect.new(StatusEffect.Type.FREEZE)
		enemy.apply_status_effect(freeze)

	# Glacier balls pierce through enemies
	pierce_count = max(pierce_count, 3)

	# Visual ice effect
	enemy.modulate = Color(0.5, 0.7, 0.9)
	var tween := enemy.create_tween()
	tween.tween_property(enemy, "modulate", Color.WHITE, 0.4)


func _do_storm(enemy: Node2D) -> void:
	"""STORM effect - Chain lightning that spreads poison"""
	var chain_range := 100.0
	var chain_count := 4
	var chains_done := 0

	# Apply poison to hit enemy
	if enemy.has_method("apply_status_effect"):
		var poison = StatusEffect.new(StatusEffect.Type.POISON)
		enemy.apply_status_effect(poison)

	# Find and chain to nearby enemies
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return

	for child in enemies_container.get_children():
		if chains_done >= chain_count:
			break
		if child is EnemyBase and child != enemy:
			var dist: float = child.global_position.distance_to(enemy.global_position)
			if dist < chain_range:
				# Chain damage + poison
				if child.has_method("take_damage"):
					child.take_damage(int(damage * 0.5))
				if child.has_method("apply_status_effect"):
					var poison = StatusEffect.new(StatusEffect.Type.POISON)
					child.apply_status_effect(poison)
				chains_done += 1


func _do_plasma(enemy: Node2D) -> void:
	"""PLASMA effect - Chain lightning that applies bleed"""
	var chain_range := 90.0
	var chain_count := 3
	var bleed_stacks := 2
	var chains_done := 0

	# Apply bleed stacks to hit enemy
	if enemy.has_method("apply_status_effect"):
		for i in bleed_stacks:
			var bleed = StatusEffect.new(StatusEffect.Type.BLEED)
			enemy.apply_status_effect(bleed)

	# Find and chain to nearby enemies
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return

	for child in enemies_container.get_children():
		if chains_done >= chain_count:
			break
		if child is EnemyBase and child != enemy:
			var dist: float = child.global_position.distance_to(enemy.global_position)
			if dist < chain_range:
				# Chain damage + bleed
				if child.has_method("take_damage"):
					child.take_damage(int(damage * 0.4))
				if child.has_method("apply_status_effect"):
					var bleed = StatusEffect.new(StatusEffect.Type.BLEED)
					child.apply_status_effect(bleed)
				chains_done += 1

	# Visual plasma arc effect
	enemy.modulate = Color(1.0, 0.2, 0.5)
	var tween := enemy.create_tween()
	tween.tween_property(enemy, "modulate", Color.WHITE, 0.2)


func _do_cleaver(enemy: Node2D) -> void:
	"""CLEAVER effect - Heavy bleed stacks + knockback"""
	var bleed_stacks := 5
	var knockback_force := 60.0

	# Apply multiple bleed stacks
	if enemy.has_method("apply_status_effect"):
		for i in bleed_stacks:
			var bleed = StatusEffect.new(StatusEffect.Type.BLEED)
			enemy.apply_status_effect(bleed)

	# Knockback
	if enemy is EnemyBase:
		var knockback_dir := (enemy.global_position - global_position).normalized()
		enemy.global_position += knockback_dir * knockback_force

	# Visual cleaver effect
	enemy.modulate = Color(0.5, 0.1, 0.1)
	var tween := enemy.create_tween()
	tween.tween_property(enemy, "modulate", Color.WHITE, 0.3)


func _do_frostbite(enemy: Node2D) -> void:
	"""FROSTBITE effect - Freeze enemy, apply bleed when freeze ends"""
	var thaw_bleed_stacks := 3

	# Apply freeze status
	if enemy.has_method("apply_status_effect"):
		var freeze = StatusEffect.new(StatusEffect.Type.FREEZE)
		enemy.apply_status_effect(freeze)

	# Apply bleed immediately (represents frostbite damage)
	# In BallxPit, bleed triggers when freeze wears off, but we apply immediately for simplicity
	if enemy.has_method("apply_status_effect"):
		for i in thaw_bleed_stacks:
			var bleed = StatusEffect.new(StatusEffect.Type.BLEED)
			enemy.apply_status_effect(bleed)

	# Visual frostbite effect
	enemy.modulate = Color(0.6, 0.2, 0.4)
	var tween := enemy.create_tween()
	tween.tween_property(enemy, "modulate", Color.WHITE, 0.4)


func _apply_fused_effects(enemy: Node2D, base_damage: int) -> void:
	"""Apply multiple effects from a fused ball"""
	for effect in fused_effects:
		match effect:
			"burn":
				if enemy.has_method("apply_status_effect"):
					var burn = StatusEffect.new(StatusEffect.Type.BURN)
					enemy.apply_status_effect(burn)
			"freeze":
				if enemy.has_method("apply_status_effect"):
					var freeze = StatusEffect.new(StatusEffect.Type.FREEZE)
					enemy.apply_status_effect(freeze)
			"poison":
				if enemy.has_method("apply_status_effect"):
					var poison = StatusEffect.new(StatusEffect.Type.POISON)
					enemy.apply_status_effect(poison)
			"bleed":
				if enemy.has_method("apply_status_effect"):
					var bleed = StatusEffect.new(StatusEffect.Type.BLEED)
					enemy.apply_status_effect(bleed)
			"lightning":
				_chain_lightning(enemy)
			"knockback":
				if enemy is EnemyBase:
					var knockback_dir := (enemy.global_position - global_position).normalized()
					enemy.global_position += knockback_dir * 50.0
			"radiation":
				if enemy.has_method("apply_status_effect"):
					var radiation = StatusEffect.new(StatusEffect.Type.RADIATION)
					enemy.apply_status_effect(radiation)
			"disease":
				if enemy.has_method("apply_status_effect"):
					var disease = StatusEffect.new(StatusEffect.Type.DISEASE)
					enemy.apply_status_effect(disease)
			"frostburn":
				if enemy.has_method("apply_status_effect"):
					var frostburn = StatusEffect.new(StatusEffect.Type.FROSTBURN)
					enemy.apply_status_effect(frostburn)
			"wind":
				if enemy.has_method("apply_status_effect"):
					var wind = StatusEffect.new(StatusEffect.Type.WIND)
					enemy.apply_status_effect(wind)
				pierce_count = max(pierce_count, 2)
			"ghost":
				# Ghost effect - full pass-through
				pierce_count = 999
			"vampire":
				# Vampire effect - lifesteal
				var lifesteal_amount := int(base_damage * 0.2)
				if lifesteal_amount > 0:
					GameManager.heal(lifesteal_amount)
