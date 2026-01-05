class_name EnemyBase
extends CharacterBody2D
## Base class for all enemies - handles HP, movement, damage, and death

signal died(enemy: EnemyBase)
signal took_damage(enemy: EnemyBase, amount: int)
signal entered_danger_zone
signal left_danger_zone

const DANGER_ZONE_Y: float = 1000.0  # 200px above player zone at 1200
var in_danger_zone: bool = false

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
	_move(delta)
	_check_danger_zone()


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
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)
	died.emit(self)
	queue_free()
