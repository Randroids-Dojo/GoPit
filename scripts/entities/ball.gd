extends CharacterBody2D
## Ball entity - moves in a direction and bounces off walls

const StatusEffect := preload("res://scripts/effects/status_effect.gd")

signal hit_enemy(enemy: Node2D)
signal hit_gem(gem: Node2D)
signal despawned

enum BallType { NORMAL, FIRE, ICE, LIGHTNING, POISON, BLEED, IRON }

@export var speed: float = 800.0
@export var ball_color: Color = Color(0.3, 0.7, 1.0)
@export var radius: float = 14.0
@export var damage: int = 10

var direction: Vector2 = Vector2.UP
var pierce_count: int = 0
var max_bounces: int = 10
var crit_chance: float = 0.0
var _bounce_count: int = 0

# Ball type, level, and effects
var ball_type: BallType = BallType.NORMAL
var ball_level: int = 1  # 1-3, affects visuals
var registry_type: int = -1  # BallRegistry.BallType if set from registry
var _trail_points: Array[Vector2] = []
const MAX_TRAIL_POINTS: int = 8
var _particle_trail: GPUParticles2D = null

# Trail particle scenes per ball type
const TRAIL_PARTICLES := {
	BallType.FIRE: "res://scenes/effects/fire_trail.tscn",
	BallType.ICE: "res://scenes/effects/ice_trail.tscn",
	BallType.LIGHTNING: "res://scenes/effects/lightning_trail.tscn",
	BallType.POISON: "res://scenes/effects/poison_trail.tscn",
	BallType.BLEED: "res://scenes/effects/bleed_trail.tscn",
	BallType.IRON: "res://scenes/effects/iron_trail.tscn"
}

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

	# Spawn particle trail for special ball types
	_spawn_particle_trail()


func _spawn_particle_trail() -> void:
	"""Spawn particle trail if ball type has one"""
	# Remove existing trail
	if _particle_trail:
		_particle_trail.queue_free()
		_particle_trail = null

	# No trail for normal balls or baby balls
	if ball_type == BallType.NORMAL or is_baby_ball:
		return

	# Check if we have a trail scene for this type
	if not TRAIL_PARTICLES.has(ball_type):
		return

	var scene_path: String = TRAIL_PARTICLES[ball_type]
	var trail_scene: PackedScene = load(scene_path)
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

			# Check for critical hit (includes Jackpot bonus crit chance)
			var total_crit_chance := crit_chance + GameManager.get_bonus_crit_chance()
			if total_crit_chance > 0 and randf() < total_crit_chance:
				actual_damage = int(actual_damage * GameManager.get_crit_damage_multiplier())
				is_crit = true

			# Inferno passive: +20% fire damage
			if ball_type == BallType.FIRE:
				actual_damage = int(actual_damage * GameManager.get_fire_damage_multiplier())

			# Check for status-based damage bonuses
			if collider.has_method("has_status_effect"):
				# Shatter: +50% damage vs frozen
				if collider.has_status_effect(StatusEffect.Type.FREEZE):
					actual_damage = int(actual_damage * GameManager.get_damage_vs_frozen())
				# Inferno: +25% damage vs burning
				if collider.has_status_effect(StatusEffect.Type.BURN):
					actual_damage = int(actual_damage * GameManager.get_damage_vs_burning())

			# Apply evolved/fused/normal ball effects
			if is_evolved:
				_apply_evolved_effect(collider, actual_damage)
			elif is_fused:
				_apply_fused_effects(collider, actual_damage)
			else:
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


func _chain_lightning(hit_enemy: Node2D) -> void:
	var chain_range: float = 150.0
	var chain_damage: int = int(damage * 0.5)

	# Find nearby enemies
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
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
