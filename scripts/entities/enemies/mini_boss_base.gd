class_name MiniBossBase
extends "res://scripts/entities/enemies/enemy_base.gd"
## Mini-boss base class - simplified boss with single phase, used for mid-wave challenges

signal mini_boss_defeated

# Mini-boss properties
@export var mini_boss_name: String = "Mini-Boss"
@export var attack_cooldown: float = 2.0
@export var telegraph_duration: float = 0.8

# Attack state
enum AttackState { IDLE, TELEGRAPH, ATTACKING, COOLDOWN }
var attack_state: AttackState = AttackState.IDLE
var _attack_timer: float = 0.0
var _current_attack: String = ""

# Available attacks for this mini-boss (override in subclass)
var available_attacks: Array[String] = []

# Player reference
var _player: Node2D = null


func _ready() -> void:
	super._ready()
	add_to_group("mini_boss")
	_player = get_tree().get_first_node_in_group("player")
	_attack_timer = attack_cooldown


func _process(delta: float) -> void:
	# Stop processing when game is paused (level up, game over, etc.)
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	if hp <= 0:
		return

	match attack_state:
		AttackState.IDLE:
			_attack_timer -= delta
			if _attack_timer <= 0:
				_start_attack()
		AttackState.TELEGRAPH:
			_attack_timer -= delta
			if _attack_timer <= 0:
				_execute_attack()
		AttackState.ATTACKING:
			_update_attack(delta)
		AttackState.COOLDOWN:
			_attack_timer -= delta
			if _attack_timer <= 0:
				attack_state = AttackState.IDLE
				_attack_timer = attack_cooldown

	_mini_boss_movement(delta)


func _start_attack() -> void:
	if available_attacks.is_empty():
		return

	_current_attack = available_attacks[randi() % available_attacks.size()]
	attack_state = AttackState.TELEGRAPH
	_attack_timer = telegraph_duration
	_show_attack_telegraph(_current_attack)


func _show_attack_telegraph(_attack_name: String) -> void:
	# Override in subclass for custom telegraph visuals
	var tween := create_tween().set_loops(int(telegraph_duration / 0.15))
	tween.tween_property(self, "modulate", Color(1.5, 1.0, 1.0), 0.075)
	tween.tween_property(self, "modulate", Color.WHITE, 0.075)


func _execute_attack() -> void:
	attack_state = AttackState.ATTACKING
	_perform_attack(_current_attack)


func _perform_attack(_attack_name: String) -> void:
	# Override in subclass
	_end_attack()


func _update_attack(_delta: float) -> void:
	# Override in subclass for continuous attacks
	pass


func _end_attack() -> void:
	attack_state = AttackState.COOLDOWN
	_attack_timer = attack_cooldown
	_current_attack = ""


func _mini_boss_movement(_delta: float) -> void:
	# Override in subclass for custom movement
	pass


func _defeat() -> void:
	mini_boss_defeated.emit()

	# Screen shake on defeat
	CameraShake.shake(10.0, 5.0)
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)

	# Spawn bonus gems
	var game_controller := get_tree().get_first_node_in_group("game")
	for i in 5:
		var offset := Vector2(randf_range(-30, 30), randf_range(-30, 30))
		if game_controller and game_controller.has_method("_spawn_gem"):
			game_controller._spawn_gem(global_position + offset, 8)

	queue_free()


func die() -> void:
	if hp <= 0:
		_defeat()
