class_name EnemyBase
extends CharacterBody2D
## Base class for all enemies - handles HP, movement, damage, and death

const StatusEffect := preload("res://scripts/effects/status_effect.gd")

signal died(enemy: EnemyBase)
signal took_damage(enemy: EnemyBase, amount: int)
signal entered_danger_zone
signal left_danger_zone
signal status_effect_applied(enemy: EnemyBase, effect_type: int)
signal hemorrhage_triggered(enemy: EnemyBase, damage: int)
signal executed(enemy: EnemyBase)  # Emitted when execute mechanic kills the enemy

enum State { DESCENDING, WARNING, ATTACKING, DEAD }

const DANGER_ZONE_Y: float = 1000.0  # 200px above player zone at 1200
const ATTACK_RANGE_Y: float = 950.0  # When to start warning (before danger zone)
const WARNING_DURATION: float = 1.0  # Seconds to show warning
const ATTACK_SPEED: float = 600.0  # Speed when lunging at player
const ATTACK_SELF_DAMAGE: int = 3  # HP lost per attack attempt
const ATTACK_COOLDOWN: float = 0.5  # Seconds before enemy can attack again after completing an attack
const POST_ATTACK_SNAP_OFFSET: float = 100.0  # How far above player to snap after attack

# Hemorrhage: Triggers at 12+ bleed stacks, deals 20% of current HP
const HEMORRHAGE_THRESHOLD: int = 12  # Bleed stacks required to trigger
const HEMORRHAGE_DAMAGE_PERCENT: float = 0.20  # Damage as percent of current HP

var in_danger_zone: bool = false
var current_state: State = State.DESCENDING
var _warning_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0  # Cooldown after attack to prevent immediate re-attack
var _attack_target: Vector2 = Vector2.ZERO
var _pre_attack_position: Vector2 = Vector2.ZERO  # Position before attack, to snap back to
var _shake_offset: Vector2 = Vector2.ZERO
var _exclamation_label: Label
var _pulse_tween: Tween

# Status effect tracking
var _active_effects: Dictionary = {}  # StatusEffect.Type -> StatusEffect
var _base_speed: float = 0.0  # Original speed before slow effects
var _effect_tint: Color = Color.WHITE  # Combined tint from active effects
var _effect_particles: Dictionary = {}  # StatusEffect.Type -> GPUParticles2D

# Particle scenes for status effects (preloaded for performance)
const BURN_PARTICLES_SCENE: PackedScene = preload("res://scenes/effects/burn_particles.tscn")
const FREEZE_PARTICLES_SCENE: PackedScene = preload("res://scenes/effects/freeze_particles.tscn")
const POISON_PARTICLES_SCENE: PackedScene = preload("res://scenes/effects/poison_particles.tscn")
const BLEED_PARTICLES_SCENE: PackedScene = preload("res://scenes/effects/bleed_particles.tscn")

@export var max_hp: int = 10
@export var speed: float = 100.0
@export var damage_to_player: int = 10
@export var xp_value: int = 10

var hp: int:
	set(value):
		hp = clampi(value, 0, max_hp)
		if hp <= 0:
			_die()

var _flash_tween: Tween


func _ready() -> void:
	_scale_with_wave()
	hp = max_hp
	_base_speed = speed  # Store original speed for slow calculations
	_setup_collision()
	queue_redraw()


func _scale_with_wave() -> void:
	var wave := GameManager.current_wave
	# Scale HP: +10% per wave
	max_hp = int(max_hp * (1.0 + (wave - 1) * 0.1))
	# Apply post-boss HP spike (~3x per boss defeated)
	max_hp = int(max_hp * StageManager.get_post_boss_hp_multiplier())
	# Scale speed: +5% per wave (capped at 2x)
	speed = speed * min(2.0, 1.0 + (wave - 1) * 0.05)
	# Scale XP: +5% per wave
	xp_value = int(xp_value * (1.0 + (wave - 1) * 0.05))


func _physics_process(delta: float) -> void:
	# Process status effects first
	_process_status_effects(delta)

	# Process attack cooldown
	if _attack_cooldown_timer > 0:
		_attack_cooldown_timer -= delta

	# Charmed enemies attack other enemies instead of the player
	if is_charmed():
		_do_charmed_behavior(delta)
		return

	match current_state:
		State.DESCENDING:
			_move(delta)
			_check_danger_zone()
			# Check if we should enter warning state (when at or below player's Y level)
			if _should_attack():
				_enter_warning_state()
		State.WARNING:
			_do_warning(delta)
			_check_danger_zone()
			# Cancel attack if player moved above us
			if not _should_attack():
				_cancel_warning()
		State.ATTACKING:
			_do_attack(delta)
		State.DEAD:
			pass  # Do nothing, waiting for queue_free


func _should_attack() -> bool:
	# Don't attack if still on cooldown from previous attack
	if _attack_cooldown_timer > 0:
		return false
	# Attack when enemy is at or below player's Y position
	var player := _get_player_node()
	if player:
		return global_position.y >= player.global_position.y
	# Fallback: use old threshold if no player found
	return global_position.y >= ATTACK_RANGE_Y


func _setup_collision() -> void:
	collision_layer = 4  # enemies layer
	collision_mask = 2 | 16  # balls + player_zone


func _move(_delta: float) -> void:
	# Override in subclasses for specific movement patterns
	velocity = Vector2.DOWN * speed
	move_and_slide()


func _check_danger_zone() -> void:
	var now_in_danger := global_position.y >= DANGER_ZONE_Y
	if now_in_danger and not in_danger_zone:
		in_danger_zone = true
		entered_danger_zone.emit()
		_on_enter_danger_zone()
	elif not now_in_danger and in_danger_zone:
		in_danger_zone = false
		left_danger_zone.emit()
		_on_exit_danger_zone()


func _on_enter_danger_zone() -> void:
	# Tint enemy red to indicate danger
	modulate = Color(1.5, 0.5, 0.5)


func _on_exit_danger_zone() -> void:
	modulate = Color.WHITE


func _draw() -> void:
	# Override in subclasses for specific visuals
	pass


func take_damage(amount: int, is_crit: bool = false) -> void:
	# Apply damage amplification from status effects (Radiation, Frostburn)
	var amplified_amount := _apply_damage_amplification(amount)

	# Execute mechanic: Crits on low-HP enemies = instant kill
	if is_crit:
		var execute_threshold := GameManager.get_execute_threshold()
		if execute_threshold > 0:
			var hp_percent := float(hp) / float(max_hp)
			if hp_percent < execute_threshold:
				_execute_kill()
				return

	hp -= amplified_amount
	took_damage.emit(self, amplified_amount)
	GameManager.record_damage_dealt(amplified_amount)
	_flash_hit()
	_spawn_hit_effects(amplified_amount)


func _apply_damage_amplification(base_damage: int) -> int:
	"""Apply damage amplification from active status effects"""
	var amp_mult: float = 1.0
	for effect_type in _active_effects:
		var effect: StatusEffect = _active_effects[effect_type]
		amp_mult += effect.get_damage_amplification()
	return int(base_damage * amp_mult)


func _flash_hit() -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	modulate = Color.WHITE
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", Color(1, 0.3, 0.3), 0.05)
	_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func _spawn_hit_effects(damage: int) -> void:
	# Small screen shake
	CameraShake.shake(3.0, 8.0)

	var scene_root := get_tree().current_scene

	# Spawn hit particles
	var particles_scene := preload("res://scenes/effects/hit_particles.tscn")
	var particles := particles_scene.instantiate()
	particles.position = global_position
	scene_root.add_child(particles)

	# Spawn floating damage number
	var DamageNumber := preload("res://scripts/effects/damage_number.gd")
	DamageNumber.spawn(scene_root, global_position, damage, Color(1, 0.9, 0.3))


func _die() -> void:
	current_state = State.DEAD
	# Handle poison spread before dying
	if _active_effects.has(StatusEffect.Type.POISON):
		_spread_poison()
	# Award 1 XP per kill (multipliers applied in GameManager)
	GameManager.add_xp(1)
	# Lifesteal passive: chance to drop health gem on kill
	var health_gem_chance := GameManager.get_health_gem_chance()
	if health_gem_chance > 0 and randf() < health_gem_chance:
		_spawn_health_gem()
	# Clean up particle references (nodes will be freed with parent)
	_effect_particles.clear()
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)
	died.emit(self)
	queue_free()


func _execute_kill() -> void:
	"""Execute mechanic: Instant kill when crit hits low-HP enemy"""
	if current_state == State.DEAD:
		return

	# Record the damage (remaining HP)
	GameManager.record_damage_dealt(hp)

	# Visual and audio feedback
	_show_execute_effect()

	# Signal execution
	executed.emit(self)

	# Set HP to 0 (will trigger _die via setter)
	hp = 0


func _show_execute_effect() -> void:
	"""Dramatic visual/audio for execute kill"""
	# Big screen shake for impact
	CameraShake.shake(15.0, 8.0)

	# Play distinctive sound
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)

	# Spawn 'EXECUTE' text
	var scene_root := get_tree().current_scene
	var DamageNumber := preload("res://scripts/effects/damage_number.gd")
	DamageNumber.spawn_text(
		scene_root,
		global_position + Vector2(0, -40),
		"EXECUTE",
		Color(0.9, 0.1, 0.1)  # Dark red
	)

	# Flash enemy dark red before death
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	modulate = Color(1.5, 0.2, 0.2)


func _spawn_health_gem() -> void:
	# Spawn a healing gem at death location
	var gem: Node
	if PoolManager:
		gem = PoolManager.get_gem()
	else:
		var gem_scene := preload("res://scenes/entities/gem.tscn")
		gem = gem_scene.instantiate()
	gem.global_position = global_position
	gem.xp_value = 0  # No XP, just healing
	gem.is_health_gem = true  # Mark as health gem for special effect
	var gems_container := get_tree().get_first_node_in_group("gems_container")
	if gems_container:
		gems_container.add_child(gem)
		# Re-acquire player reference after being added to tree
		gem._player = get_tree().get_first_node_in_group("player")


# === WARNING STATE ===

func _enter_warning_state() -> void:
	current_state = State.WARNING
	_warning_timer = WARNING_DURATION
	_pre_attack_position = global_position  # Remember where we were
	_show_exclamation()
	SoundManager.play(SoundManager.SoundType.BLOCKED)  # Use blocked sound for warning


func _cancel_warning() -> void:
	# Player moved above us, cancel attack and resume descending
	_hide_exclamation()
	_stop_shake()
	current_state = State.DESCENDING


func _do_warning(delta: float) -> void:
	_warning_timer -= delta
	_update_shake()

	if _warning_timer <= 0:
		_enter_attack_state()


func _show_exclamation() -> void:
	_exclamation_label = Label.new()
	_exclamation_label.text = "!"
	_exclamation_label.add_theme_font_size_override("font_size", 32)
	_exclamation_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	_exclamation_label.position = Vector2(-8, -50)
	add_child(_exclamation_label)

	# Pulse animation
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(_exclamation_label, "scale", Vector2(1.3, 1.3), 0.15)
	_pulse_tween.tween_property(_exclamation_label, "scale", Vector2(1.0, 1.0), 0.15)


func _hide_exclamation() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	if _exclamation_label:
		_exclamation_label.queue_free()
		_exclamation_label = null


func _update_shake() -> void:
	# Remove previous shake offset
	position -= _shake_offset
	# Apply new shake
	_shake_offset = Vector2(
		randf_range(-5.0, 5.0),
		randf_range(-5.0, 5.0)
	)
	position += _shake_offset


func _stop_shake() -> void:
	position -= _shake_offset
	_shake_offset = Vector2.ZERO


# === ATTACK STATE ===

func _enter_attack_state() -> void:
	current_state = State.ATTACKING
	_hide_exclamation()
	_stop_shake()

	# Target player's current position
	_attack_target = _get_player_position()

	# Flash white briefly when attacking
	modulate = Color(1.5, 1.5, 1.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func _do_attack(delta: float) -> void:
	# Move toward attack target
	var to_target := _attack_target - global_position
	var dist_to_target := to_target.length()

	# If we've reached the target area, complete this attack attempt
	if dist_to_target < 30:
		_complete_attack_attempt(false)
		return

	var direction := to_target.normalized()
	velocity = direction * ATTACK_SPEED
	move_and_slide()

	# Check for collision with player AFTER movement (uses physics collision)
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider and collider.is_in_group("player"):
			_deal_damage_to_player()
			_complete_attack_attempt(true)
			return

	# Despawn if off-screen (fell off the map)
	if global_position.y > 1400 or global_position.y < -50:
		queue_free()
		return

	# If we've overshot the target, complete this attack attempt
	var new_to_target := _attack_target - global_position
	var was_moving_toward := new_to_target.dot(direction) > 0
	if not was_moving_toward:
		_complete_attack_attempt(false)


func _complete_attack_attempt(hit_player: bool) -> void:
	# Take self-damage from the attack exertion
	hp -= ATTACK_SELF_DAMAGE

	# If still alive, snap back and continue descending
	if hp > 0:
		# Set cooldown to prevent immediate re-attack
		_attack_cooldown_timer = ATTACK_COOLDOWN

		# Snap to a position above the player (not the pre-attack position)
		# This prevents getting stuck on the player after hitting them
		var player := _get_player_node()
		if player:
			# Snap above the player, maintaining our X position
			global_position.y = player.global_position.y - POST_ATTACK_SNAP_OFFSET
		else:
			# Fallback: snap back to pre-attack position
			global_position = _pre_attack_position

		# Return to descending state - will re-trigger attack when reaching player level again
		current_state = State.DESCENDING
	# If dead, _die() is called automatically via hp setter


func _get_player_position() -> Vector2:
	var player := _get_player_node()
	if player:
		return player.global_position
	# Fallback: aim at bottom center of screen
	return Vector2(360, 1100)


func _get_player_node() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Node2D
	return null


# === CHARM BEHAVIOR (Mind Control) ===

const CHARM_ATTACK_RANGE: float = 50.0  # Distance at which charmed enemy attacks
const CHARM_DAMAGE_MULT: float = 1.5  # Charmed enemies deal 1.5x their base damage to enemies

func _do_charmed_behavior(delta: float) -> void:
	"""Charmed enemy moves toward and attacks other non-charmed enemies"""
	# Find nearest non-charmed enemy
	var target := _find_nearest_enemy_target()

	if target == null:
		# No target found - just wander randomly
		velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed * 0.5
		move_and_slide()
		return

	# Move toward target enemy
	var to_target := target.global_position - global_position
	var dist_to_target := to_target.length()

	if dist_to_target < CHARM_ATTACK_RANGE:
		# Attack the enemy
		_attack_enemy_target(target)
	else:
		# Move toward target
		var direction := to_target.normalized()
		velocity = direction * speed
		move_and_slide()


func _find_nearest_enemy_target() -> EnemyBase:
	"""Find the nearest non-charmed, alive enemy to attack"""
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return null

	var nearest: EnemyBase = null
	var nearest_dist: float = INF

	for child in enemies_container.get_children():
		if child is EnemyBase and child != self:
			# Skip charmed enemies (allies don't attack each other)
			if child.is_charmed():
				continue
			# Skip dead enemies
			if child.current_state == State.DEAD:
				continue

			var dist: float = global_position.distance_to(child.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = child

	return nearest


func _attack_enemy_target(target: EnemyBase) -> void:
	"""Deal damage to an enemy target while charmed"""
	var charm_damage := int(damage_to_player * CHARM_DAMAGE_MULT)
	target.take_damage(charm_damage)

	# Visual feedback - flash both attacker and target
	modulate = Color(1.5, 0.5, 1.0)  # Pink flash
	var tween := create_tween()
	tween.tween_property(self, "modulate", _get_charm_tint(), 0.2)

	# Knockback/separation to prevent continuous attacking
	var knockback_dir := (global_position - target.global_position).normalized()
	global_position += knockback_dir * 30


func _get_charm_tint() -> Color:
	"""Get the visual tint for charmed state"""
	return Color(1.0, 0.4, 0.8)  # Pink/magenta


func _deal_damage_to_player() -> void:
	var player := _get_player_node()
	if player and player.has_method("take_damage"):
		player.take_damage(damage_to_player)
	else:
		# Fallback: use GameManager directly
		GameManager.take_damage(damage_to_player)

	CameraShake.shake(8.0, 15.0)  # Big shake on player hit


# === STATUS EFFECTS ===

func apply_status_effect(effect: StatusEffect) -> void:
	"""Apply a status effect to this enemy"""
	if current_state == State.DEAD:
		return

	var effect_type := effect.type

	# Check for existing effect of same type
	if _active_effects.has(effect_type):
		var existing: StatusEffect = _active_effects[effect_type]
		if effect.max_stacks > 1:
			existing.add_stack()
			existing.refresh()
			# Check for hemorrhage trigger on bleed stack
			if effect_type == StatusEffect.Type.BLEED:
				_check_hemorrhage(existing)
		else:
			existing.refresh()
	else:
		# New effect
		effect.apply()
		_active_effects[effect_type] = effect
		status_effect_applied.emit(self, effect_type)

	# Apply on-hit damage (for effects like BLEED that deal instant damage on application)
	if effect.on_hit_damage > 0:
		_take_on_hit_damage(int(effect.on_hit_damage))

	# Update speed for freeze effects
	_update_speed_from_effects()
	# Update visuals
	_update_effect_visuals()


func _check_hemorrhage(bleed_effect: StatusEffect) -> void:
	"""Check if bleed stacks trigger hemorrhage (20% current HP damage at 12+ stacks)"""
	if bleed_effect.stacks >= HEMORRHAGE_THRESHOLD:
		_trigger_hemorrhage()


func _trigger_hemorrhage() -> void:
	"""Execute hemorrhage effect - deal 20% of current HP as damage"""
	if hp <= 0:
		return

	# Calculate hemorrhage damage (20% of current HP, minimum 1)
	var hemorrhage_damage := maxi(1, int(hp * HEMORRHAGE_DAMAGE_PERCENT))

	# Apply damage directly (bypasses on-hit effects to prevent loops)
	hp -= hemorrhage_damage
	GameManager.record_damage_dealt(hemorrhage_damage)

	# Visual feedback
	_show_hemorrhage_effect(hemorrhage_damage)

	# Emit signal for external systems
	hemorrhage_triggered.emit(self, hemorrhage_damage)


func _show_hemorrhage_effect(damage: int) -> void:
	"""Visual and audio feedback for hemorrhage trigger"""
	# Big screen shake for dramatic effect
	CameraShake.shake(10.0, 5.0)

	# Play sound (use a distinctive sound)
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)

	# Spawn large damage number with distinct color (dark red for hemorrhage)
	var scene_root := get_tree().current_scene
	var DamageNumber := preload("res://scripts/effects/damage_number.gd")
	DamageNumber.spawn(
		scene_root,
		global_position + Vector2(0, -30),
		damage,
		Color(0.6, 0.0, 0.1)  # Dark blood red
	)

	# Flash enemy dark red
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", Color(0.8, 0.1, 0.1), 0.1)
	_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)


func _process_status_effects(delta: float) -> void:
	"""Process all active status effects each frame"""
	if _active_effects.is_empty():
		return

	var expired_effects: Array[int] = []
	var total_dot_damage: int = 0

	for effect_type in _active_effects:
		var effect: StatusEffect = _active_effects[effect_type]
		var damage := effect.update(delta)
		total_dot_damage += damage

		if effect.is_expired():
			expired_effects.append(effect_type)

	# Apply DoT damage
	if total_dot_damage > 0:
		_take_dot_damage(total_dot_damage)

	# Remove expired effects
	for effect_type in expired_effects:
		_active_effects.erase(effect_type)

	if expired_effects.size() > 0:
		_update_speed_from_effects()
		_update_effect_visuals()


func _take_dot_damage(amount: int) -> void:
	"""Take damage from DoT effects - subtle visual feedback"""
	hp -= amount
	GameManager.record_damage_dealt(amount)

	# Subtle flash (less intense than direct hit)
	_flash_dot()

	# Very subtle screen shake (less than direct hit)
	CameraShake.shake(1.0, 10.0)

	# Spawn smaller damage number for DoT
	var scene_root := get_tree().current_scene
	var DamageNumber := preload("res://scripts/effects/damage_number.gd")
	DamageNumber.spawn(scene_root, global_position + Vector2(randf_range(-20, 20), -10), amount, Color(1, 0.5, 0.2))


func _take_on_hit_damage(amount: int) -> void:
	"""Take instant damage from on-hit status effects (e.g., BLEED)"""
	hp -= amount
	GameManager.record_damage_dealt(amount)

	# Moderate flash (between DoT and direct hit)
	_flash_dot()

	# Moderate screen shake
	CameraShake.shake(2.0, 8.0)

	# Spawn damage number with bleed color
	var scene_root := get_tree().current_scene
	var DamageNumber := preload("res://scripts/effects/damage_number.gd")
	DamageNumber.spawn(scene_root, global_position + Vector2(randf_range(-15, 15), -15), amount, Color(0.9, 0.2, 0.3))


func _flash_dot() -> void:
	"""Subtle flash for DoT damage - uses effect color instead of white"""
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	# Get dominant effect color for the flash
	var flash_color := _get_dominant_effect_color()

	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", flash_color.lightened(0.3), 0.05)
	_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.15)


func _get_dominant_effect_color() -> Color:
	"""Get the color of the most damaging active effect"""
	var colors := {
		StatusEffect.Type.BURN: Color(1.0, 0.5, 0.2),    # Orange
		StatusEffect.Type.POISON: Color(0.4, 0.9, 0.2),  # Green
		StatusEffect.Type.BLEED: Color(0.9, 0.2, 0.3),   # Red
		StatusEffect.Type.RADIATION: Color(0.5, 1.0, 0.2),  # Toxic yellow-green
		StatusEffect.Type.DISEASE: Color(0.6, 0.3, 0.8),    # Sickly purple
		StatusEffect.Type.FROSTBURN: Color(0.3, 0.6, 1.0)   # Pale frost blue
	}

	# Return color of first damaging effect found
	for effect_type in _active_effects:
		if effect_type in colors:
			return colors[effect_type]

	return Color(1.0, 0.5, 0.2)  # Default orange


func _update_speed_from_effects() -> void:
	"""Recalculate speed based on active slow effects"""
	var slow_mult: float = 1.0

	for effect_type in _active_effects:
		var effect: StatusEffect = _active_effects[effect_type]
		if effect.slow_multiplier < slow_mult:
			slow_mult = effect.slow_multiplier

	speed = _base_speed * slow_mult


func _update_effect_visuals() -> void:
	"""Update visual tint and particles based on active effects"""
	if _active_effects.is_empty():
		_effect_tint = Color.WHITE
		_remove_all_effect_particles()
	else:
		# Blend colors from all active effects
		var r: float = 1.0
		var g: float = 1.0
		var b: float = 1.0

		for effect_type in _active_effects:
			var effect: StatusEffect = _active_effects[effect_type]
			var color := effect.get_color()
			r = max(r, color.r)
			g = min(g, color.g) if color.g < 1.0 else g
			b = min(b, color.b) if color.b < 1.0 else b

			# Spawn particles for this effect if not already present
			_ensure_effect_particles(effect_type)

		_effect_tint = Color(r, g, b)

	# Remove particles for expired effects
	_cleanup_expired_particles()

	# Apply tint if not in danger zone (danger zone has its own tint)
	if not in_danger_zone and current_state != State.ATTACKING:
		modulate = _effect_tint


func _ensure_effect_particles(effect_type: int) -> void:
	"""Spawn particles for an effect if not already active"""
	if _effect_particles.has(effect_type):
		return  # Already have particles for this effect

	# Get preloaded particle scene for this effect type
	var particle_scene: PackedScene = null
	match effect_type:
		StatusEffect.Type.BURN:
			particle_scene = BURN_PARTICLES_SCENE
		StatusEffect.Type.FREEZE:
			particle_scene = FREEZE_PARTICLES_SCENE
		StatusEffect.Type.POISON:
			particle_scene = POISON_PARTICLES_SCENE
		StatusEffect.Type.BLEED:
			particle_scene = BLEED_PARTICLES_SCENE

	if particle_scene:
		var particles: GPUParticles2D = particle_scene.instantiate()
		add_child(particles)
		_effect_particles[effect_type] = particles


func _cleanup_expired_particles() -> void:
	"""Remove particles for effects that are no longer active"""
	var to_remove: Array[int] = []
	for effect_type in _effect_particles:
		if not _active_effects.has(effect_type):
			to_remove.append(effect_type)

	for effect_type in to_remove:
		var particles: GPUParticles2D = _effect_particles[effect_type]
		if is_instance_valid(particles):
			particles.queue_free()
		_effect_particles.erase(effect_type)


func _remove_all_effect_particles() -> void:
	"""Remove all effect particles (called on effect clear or death)"""
	for effect_type in _effect_particles:
		var particles: GPUParticles2D = _effect_particles[effect_type]
		if is_instance_valid(particles):
			particles.queue_free()
	_effect_particles.clear()


func _spread_poison() -> void:
	"""Spread poison to nearby enemies when this enemy dies"""
	const SPREAD_RADIUS: float = 100.0

	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return

	for enemy in enemies_container.get_children():
		if enemy == self:
			continue
		if enemy is EnemyBase:
			var dist: float = global_position.distance_to(enemy.global_position)
			if dist <= SPREAD_RADIUS:
				var poison := StatusEffect.new(StatusEffect.Type.POISON)
				enemy.apply_status_effect(poison)


func has_status_effect(effect_type: StatusEffect.Type) -> bool:
	"""Check if enemy has a specific status effect"""
	return _active_effects.has(effect_type)


func is_charmed() -> bool:
	"""Check if enemy is under charm effect (mind controlled)"""
	return _active_effects.has(StatusEffect.Type.CHARM)


func get_status_effect(effect_type: StatusEffect.Type) -> StatusEffect:
	"""Get a specific status effect if active, null otherwise"""
	return _active_effects.get(effect_type)


func clear_status_effects() -> void:
	"""Remove all status effects"""
	_active_effects.clear()
	_update_speed_from_effects()
	_update_effect_visuals()


func get_bleed_stacks() -> int:
	"""Get current bleed stack count (for testing/UI)"""
	if _active_effects.has(StatusEffect.Type.BLEED):
		return _active_effects[StatusEffect.Type.BLEED].stacks
	return 0


func get_hemorrhage_threshold() -> int:
	"""Get the bleed stack threshold for hemorrhage (for testing/UI)"""
	return HEMORRHAGE_THRESHOLD
