class_name EnemySpawner
extends Node2D
## Spawns enemies at random X positions at the top of the screen

signal enemy_spawned(enemy: EnemyBase)
signal enemy_died(enemy: EnemyBase)

@export var slime_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_margin: float = 40.0  # Margin from screen edges
@export var spawn_y_offset: float = -50.0  # Spawn above screen
@export var spawn_variance: float = 0.5  # ±0.5 seconds random variance
@export var burst_chance: float = 0.1  # 10% chance for burst spawn
@export var burst_count_min: int = 2
@export var burst_count_max: int = 3

# Enemy variety
var bat_scene: PackedScene = preload("res://scenes/entities/enemies/bat.tscn")
var crab_scene: PackedScene = preload("res://scenes/entities/enemies/crab.tscn")

var _spawn_timer: Timer
var _screen_width: float


func _ready() -> void:
	_screen_width = get_viewport().get_visible_rect().size.x
	_setup_timer()


func _setup_timer() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)


func start_spawning() -> void:
	_start_spawn_timer()


func stop_spawning() -> void:
	_spawn_timer.stop()


func _start_spawn_timer() -> void:
	var variance := randf_range(-spawn_variance, spawn_variance)
	var next_spawn := maxf(0.3, spawn_interval + variance)
	_spawn_timer.wait_time = next_spawn
	_spawn_timer.start()


func set_spawn_interval(interval: float) -> void:
	spawn_interval = interval
	# Increase burst chance as game speeds up
	burst_chance = minf(0.3, 0.1 + (2.0 - interval) * 0.1)


func spawn_enemy() -> EnemyBase:
	var scene: PackedScene = _choose_enemy_type()
	if not scene:
		push_warning("EnemySpawner: No enemy scene available")
		return null

	var enemy: EnemyBase = scene.instantiate()
	var spawn_x := randf_range(spawn_margin, _screen_width - spawn_margin)
	enemy.global_position = Vector2(spawn_x, spawn_y_offset)
	enemy.died.connect(_on_enemy_died)

	get_parent().add_child(enemy)
	enemy_spawned.emit(enemy)
	return enemy


func _choose_enemy_type() -> PackedScene:
	var wave: int = GameManager.current_wave

	# Wave 1: Only slimes
	if wave <= 1:
		return slime_scene

	# Wave 2-3: Introduce bats (30% chance)
	if wave <= 3:
		if randf() < 0.3:
			return bat_scene
		return slime_scene

	# Wave 4+: All enemy types
	var roll: float = randf()
	if roll < 0.5:
		return slime_scene
	elif roll < 0.8:
		return bat_scene
	else:
		return crab_scene


func _on_spawn_timer_timeout() -> void:
	# Check for burst spawn
	if randf() < burst_chance:
		_burst_spawn()
	else:
		spawn_enemy()

	# Restart timer with new random interval
	_start_spawn_timer()


func _burst_spawn() -> void:
	var count := randi_range(burst_count_min, burst_count_max)
	for i in range(count):
		spawn_enemy()


func _on_enemy_died(enemy: EnemyBase) -> void:
	enemy_died.emit(enemy)
