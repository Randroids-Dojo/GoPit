class_name BossBase
extends "res://scripts/entities/enemies/enemy_base.gd"
## Base class for all bosses - extends EnemyBase with phases, attack patterns, and HP bar
##
## IMPORTANT: Path-based extends required for CI/headless mode
## ============================================================
## We use `extends "res://..."` instead of `extends EnemyBase` because Godot's
## class_name resolution has race conditions during headless/CI builds.
##
## During `--import`, Godot registers classes alphabetically by filename:
##   - BossBase registered at ~50%
##   - EnemyBase registered at ~54%
##
## Since BossBase is registered BEFORE EnemyBase, using `extends EnemyBase`
## fails with "Could not resolve class" errors. Path-based extends forces
## Godot to load the dependency explicitly, bypassing class registration order.
##
## This is NOT related to git worktrees - it affects fresh CI builds and any
## headless Godot execution where the .godot cache doesn't exist yet.
##
## All scripts in inheritance chains should use path-based extends:
##   - boss_base.gd: extends "res://scripts/entities/enemies/enemy_base.gd"
##   - slime_king.gd: extends "res://scripts/entities/enemies/boss_base.gd"

signal phase_changed(new_phase: BossPhase)
signal boss_defeated
signal boss_intro_complete
signal attack_started(attack_name: String)
signal attack_ended(attack_name: String)

enum BossPhase { INTRO, PHASE_1, PHASE_2, PHASE_3, DEFEATED }
enum AttackState { IDLE, TELEGRAPH, ATTACKING, COOLDOWN }

@export var boss_name: String = "Boss"
@export var phase_thresholds: Array[float] = [1.0, 0.66, 0.33, 0.0]
@export var intro_duration: float = 2.0
@export var phase_transition_duration: float = 1.5
@export var telegraph_duration: float = 1.0
@export var attack_cooldown: float = 2.0

var current_phase: BossPhase = BossPhase.INTRO
var attack_state: AttackState = AttackState.IDLE
var is_invulnerable: bool = false

# Attack pattern system
var phase_attacks: Dictionary = {
	BossPhase.PHASE_1: ["basic"],
	BossPhase.PHASE_2: ["basic", "special"],
	BossPhase.PHASE_3: ["basic", "special", "rage"]
}
var _attack_timer: float = 0.0
var _current_attack: String = ""
var _telegraph_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _intro_timer: float = 0.0
var _transition_timer: float = 0.0
var _pending_phase: BossPhase = BossPhase.INTRO

# Visual elements
var _hp_bar: Control = null
var _telegraph_indicator: Node2D = null


func _ready() -> void:
	# Don't call super._ready() to avoid wave scaling for bosses
	# Bosses have fixed stats per boss type
	hp = max_hp
	_base_speed = speed
	_setup_collision()
	add_to_group("boss")
	# Enable auto-magnet during boss fights (QoL from BallxPit)
	GameManager.is_boss_fight = true
	_start_intro()


func _physics_process(delta: float) -> void:
	# Skip EnemyBase movement/attack logic - bosses have their own
	_process_status_effects(delta)

	match current_phase:
		BossPhase.INTRO:
			_process_intro(delta)
		BossPhase.PHASE_1, BossPhase.PHASE_2, BossPhase.PHASE_3:
			_process_combat(delta)
		BossPhase.DEFEATED:
			pass


func _start_intro() -> void:
	current_phase = BossPhase.INTRO
	is_invulnerable = true
	_intro_timer = intro_duration
	_on_intro_start()


func _process_intro(delta: float) -> void:
	_intro_timer -= delta
	if _intro_timer <= 0:
		_complete_intro()


func _complete_intro() -> void:
	is_invulnerable = false
	current_phase = BossPhase.PHASE_1
	phase_changed.emit(current_phase)
	boss_intro_complete.emit()
	_on_phase_enter(current_phase)


func _on_intro_start() -> void:
	# Override in subclass for intro animation/effects
	pass


func _on_phase_enter(_phase: BossPhase) -> void:
	# Override in subclass for phase-specific setup
	pass


# === DAMAGE & PHASE TRANSITIONS ===

func take_damage(amount: int, is_crit: bool = false) -> void:
	if is_invulnerable:
		# Visual feedback for invulnerable hit
		_flash_invulnerable()
		return

	super.take_damage(amount, is_crit)
	_check_phase_transition()


func take_damage_at_position(amount: int, hit_position: Vector2, is_crit: bool = false) -> void:
	## Called when damage is dealt at a specific position (e.g., from a ball hit).
	## Override in subclasses to implement weak point systems.
	## Default behavior: ignore position and call regular take_damage.
	take_damage(amount, is_crit)


func _flash_invulnerable() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(0.5, 0.5, 1.0), 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func _check_phase_transition() -> void:
	var hp_percent: float = float(hp) / float(max_hp)
	var target_phase := _get_phase_for_hp(hp_percent)

	if target_phase != current_phase and target_phase != BossPhase.INTRO:
		_start_phase_transition(target_phase)


func _get_phase_for_hp(hp_percent: float) -> BossPhase:
	if hp_percent <= 0:
		return BossPhase.DEFEATED
	elif hp_percent <= phase_thresholds[3]:
		return BossPhase.DEFEATED
	elif hp_percent <= phase_thresholds[2]:
		return BossPhase.PHASE_3
	elif hp_percent <= phase_thresholds[1]:
		return BossPhase.PHASE_2
	else:
		return BossPhase.PHASE_1


func _start_phase_transition(new_phase: BossPhase) -> void:
	if new_phase == BossPhase.DEFEATED:
		_defeat()
		return

	# Become invulnerable during transition
	is_invulnerable = true
	attack_state = AttackState.IDLE
	_pending_phase = new_phase
	_transition_timer = phase_transition_duration

	# Visual feedback
	_on_phase_transition_start(new_phase)


func _on_phase_transition_start(_new_phase: BossPhase) -> void:
	# Override for transition effects (screen shake, flash, etc.)
	CameraShake.shake(10.0, 5.0)
	var tween := create_tween().set_loops(3)
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 2.0), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func _complete_phase_transition() -> void:
	is_invulnerable = false
	current_phase = _pending_phase
	phase_changed.emit(current_phase)
	_on_phase_enter(current_phase)


func _defeat() -> void:
	current_phase = BossPhase.DEFEATED
	is_invulnerable = true
	attack_state = AttackState.IDLE
	phase_changed.emit(current_phase)

	# Big shake and effects
	CameraShake.shake(20.0, 10.0)
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)

	boss_defeated.emit()
	# Disable auto-magnet after boss fight ends
	GameManager.is_boss_fight = false

	# Death animation then cleanup
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)


func _die() -> void:
	# Override EnemyBase._die() to use our defeat logic
	_defeat()


# === COMBAT / ATTACK SYSTEM ===

func _process_combat(delta: float) -> void:
	# Handle phase transition
	if _transition_timer > 0:
		_transition_timer -= delta
		if _transition_timer <= 0:
			_complete_phase_transition()
		return

	# Movement
	_boss_movement(delta)

	# Attack state machine
	match attack_state:
		AttackState.IDLE:
			_attack_timer -= delta
			if _attack_timer <= 0:
				_select_next_attack()
		AttackState.TELEGRAPH:
			_telegraph_timer -= delta
			if _telegraph_timer <= 0:
				_execute_attack()
		AttackState.ATTACKING:
			_update_attack(delta)
		AttackState.COOLDOWN:
			_cooldown_timer -= delta
			if _cooldown_timer <= 0:
				attack_state = AttackState.IDLE
				_attack_timer = randf_range(0.5, 1.5)


func _boss_movement(_delta: float) -> void:
	# Override in subclass for boss-specific movement
	pass


func _select_next_attack() -> void:
	var available_attacks: Array = phase_attacks.get(current_phase, ["basic"])
	if available_attacks.is_empty():
		return

	_current_attack = available_attacks[randi() % available_attacks.size()]
	attack_state = AttackState.TELEGRAPH
	_telegraph_timer = telegraph_duration
	_show_attack_telegraph(_current_attack)


func _show_attack_telegraph(attack_name: String) -> void:
	# Override in subclass for attack-specific telegraphs
	attack_started.emit(attack_name)

	# Default: flash warning color
	var tween := create_tween().set_loops(int(telegraph_duration / 0.3))
	tween.tween_property(self, "modulate", Color(1.5, 0.5, 0.5), 0.15)
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)


func _execute_attack() -> void:
	attack_state = AttackState.ATTACKING
	_perform_attack(_current_attack)


func _perform_attack(attack_name: String) -> void:
	# Override in subclass with actual attack implementations
	# Default implementation just ends the attack immediately
	match attack_name:
		"basic":
			_do_basic_attack()
		"special":
			_do_special_attack()
		"rage":
			_do_rage_attack()
		_:
			_end_attack()


func _do_basic_attack() -> void:
	# Override in subclass
	_end_attack()


func _do_special_attack() -> void:
	# Override in subclass
	_end_attack()


func _do_rage_attack() -> void:
	# Override in subclass
	_end_attack()


func _update_attack(_delta: float) -> void:
	# Override in subclass for attacks that need per-frame updates
	pass


func _end_attack() -> void:
	attack_ended.emit(_current_attack)
	attack_state = AttackState.COOLDOWN
	_cooldown_timer = attack_cooldown
	_current_attack = ""


# === ADD SPAWNING ===

func spawn_adds(enemy_scene: PackedScene, count: int, spread: float = 100.0) -> Array[EnemyBase]:
	var spawned: Array[EnemyBase] = []
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return spawned

	for i in count:
		var enemy := enemy_scene.instantiate() as EnemyBase
		var offset := Vector2(randf_range(-spread, spread), randf_range(-spread, spread))
		enemy.global_position = global_position + offset
		enemies_container.add_child(enemy)
		spawned.append(enemy)

	return spawned


# === HP BAR INTEGRATION ===

func get_hp_percent() -> float:
	return float(hp) / float(max_hp)


func get_phase_count() -> int:
	return phase_thresholds.size() - 1  # Exclude the 0.0 threshold


func get_current_phase_index() -> int:
	match current_phase:
		BossPhase.PHASE_1:
			return 0
		BossPhase.PHASE_2:
			return 1
		BossPhase.PHASE_3:
			return 2
		_:
			return -1
