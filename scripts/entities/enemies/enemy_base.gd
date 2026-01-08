class_name EnemyBase
extends CharacterBody2D
## Base class for all enemies - handles HP, movement, damage, and death

const StatusEffect := preload("res://scripts/effects/status_effect.gd")

signal died(enemy: EnemyBase)
signal took_damage(enemy: EnemyBase, amount: int)
signal entered_danger_zone
signal left_danger_zone
signal status_effect_applied(enemy: EnemyBase, effect_type: int)

enum State { DESCENDING, WARNING, ATTACKING, DEAD }

const DANGER_ZONE_Y: float = 1000.0  # 200px above player zone at 1200
const ATTACK_RANGE_Y: float = 950.0  # When to start warning (before danger zone)
const WARNING_DURATION: float = 1.0  # Seconds to show warning
const ATTACK_SPEED: float = 600.0  # Speed when lunging at player

var in_danger_zone: bool = false
var current_state: State = State.DESCENDING
var _warning_timer: float = 0.0
var _attack_target: Vector2 = Vector2.ZERO
var _shake_offset: Vector2 = Vector2.ZERO
var _exclamation_label: Label
var _pulse_tween: Tween

# Status effect tracking
var _active_effects: Dictionary = {}  # StatusEffect.Type -> StatusEffect
var _base_speed: float = 0.0  # Original speed before slow effects
var _effect_tint: Color = Color.WHITE  # Combined tint from active effects

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
	# Scale speed: +5% per wave (capped at 2x)
	speed = speed * min(2.0, 1.0 + (wave - 1) * 0.05)
	# Scale XP: +5% per wave
	xp_value = int(xp_value * (1.0 + (wave - 1) * 0.05))


func _physics_process(delta: float) -> void:
	# Process status effects first
	_process_status_effects(delta)

	match current_state:
		State.DESCENDING:
			_move(delta)
			_check_danger_zone()
			# Check if we should enter warning state
			if global_position.y >= ATTACK_RANGE_Y:
				_enter_warning_state()
		State.WARNING:
			_do_warning(delta)
			_check_danger_zone()
		State.ATTACKING:
			_do_attack(delta)
		State.DEAD:
			pass  # Do nothing, waiting for queue_free


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


func take_damage(amount: int) -> void:
	hp -= amount
	took_damage.emit(self, amount)
	GameManager.record_damage_dealt(amount)
	_flash_hit()
	_spawn_hit_effects(amount)


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
	# Lifesteal passive: chance to drop health gem on kill
	var health_gem_chance := GameManager.get_health_gem_chance()
	if health_gem_chance > 0 and randf() < health_gem_chance:
		_spawn_health_gem()
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)
	died.emit(self)
	queue_free()


func _spawn_health_gem() -> void:
	# Spawn a healing gem at death location
	var gem_scene := preload("res://scenes/entities/gem.tscn")
	var gem := gem_scene.instantiate()
	gem.global_position = global_position
	gem.xp_value = 0  # No XP, just healing
	gem.is_health_gem = true  # Mark as health gem for special effect
	get_tree().current_scene.get_node("GameArea/Gems").add_child(gem)


# === WARNING STATE ===

func _enter_warning_state() -> void:
	current_state = State.WARNING
	_warning_timer = WARNING_DURATION
	_show_exclamation()
	SoundManager.play(SoundManager.SoundType.BLOCKED)  # Use blocked sound for warning


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
	# Check if we hit the player FIRST (before movement might get blocked)
	var player := _get_player_node()
	if player and global_position.distance_to(player.global_position) < 50:
		_deal_damage_to_player()
		queue_free()
		return

	# Move toward attack target
	var direction := (_attack_target - global_position).normalized()
	if direction.length() < 0.1:
		# Already at target, despawn
		queue_free()
		return

	velocity = direction * ATTACK_SPEED
	move_and_slide()

	# Despawn if off-screen or past target
	if global_position.y > 1400 or global_position.y < -50:
		queue_free()
		return

	# Also despawn if we've overshot the target significantly
	var to_target := _attack_target - global_position
	var was_moving_toward := to_target.dot(direction) > 0
	if not was_moving_toward and global_position.distance_to(_attack_target) > 30:
		queue_free()


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
		else:
			existing.refresh()
	else:
		# New effect
		effect.apply()
		_active_effects[effect_type] = effect
		status_effect_applied.emit(self, effect_type)

	# Update speed for freeze effects
	_update_speed_from_effects()
	# Update visuals
	_update_effect_visuals()


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
	"""Take damage from DoT effects (doesn't trigger hit effects)"""
	hp -= amount
	# Spawn smaller damage number for DoT
	var scene_root := get_tree().current_scene
	var DamageNumber := preload("res://scripts/effects/damage_number.gd")
	DamageNumber.spawn(scene_root, global_position + Vector2(randf_range(-20, 20), -10), amount, Color(1, 0.5, 0.2))


func _update_speed_from_effects() -> void:
	"""Recalculate speed based on active slow effects"""
	var slow_mult: float = 1.0

	for effect_type in _active_effects:
		var effect: StatusEffect = _active_effects[effect_type]
		if effect.slow_multiplier < slow_mult:
			slow_mult = effect.slow_multiplier

	speed = _base_speed * slow_mult


func _update_effect_visuals() -> void:
	"""Update visual tint based on active effects"""
	if _active_effects.is_empty():
		_effect_tint = Color.WHITE
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

		_effect_tint = Color(r, g, b)

	# Apply tint if not in danger zone (danger zone has its own tint)
	if not in_danger_zone and current_state != State.ATTACKING:
		modulate = _effect_tint


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


func get_status_effect(effect_type: StatusEffect.Type) -> StatusEffect:
	"""Get a specific status effect if active, null otherwise"""
	return _active_effects.get(effect_type)


func clear_status_effects() -> void:
	"""Remove all status effects"""
	_active_effects.clear()
	_update_speed_from_effects()
	_update_effect_visuals()
