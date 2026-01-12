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
var golem_scene: PackedScene = preload("res://scenes/entities/enemies/golem.tscn")
var swarm_scene: PackedScene = preload("res://scenes/entities/enemies/swarm.tscn")
var archer_scene: PackedScene = preload("res://scenes/entities/enemies/archer.tscn")
var bomber_scene: PackedScene = preload("res://scenes/entities/enemies/bomber.tscn")

# Swarm spawn settings
const SWARM_GROUP_SIZE_MIN: int = 3
const SWARM_GROUP_SIZE_MAX: int = 5

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

	# Swarms spawn in groups
	if scene == swarm_scene:
		return _spawn_swarm_group()

	var enemy: EnemyBase = scene.instantiate()
	var spawn_x := randf_range(spawn_margin, _screen_width - spawn_margin)
	enemy.global_position = Vector2(spawn_x, spawn_y_offset)
	enemy.died.connect(_on_enemy_died)

	get_parent().add_child(enemy)
	enemy_spawned.emit(enemy)
	return enemy


func _spawn_swarm_group() -> EnemyBase:
	"""Spawn a group of swarm enemies close together."""
	var group_size := randi_range(SWARM_GROUP_SIZE_MIN, SWARM_GROUP_SIZE_MAX)
	var center_x := randf_range(spawn_margin + 50, _screen_width - spawn_margin - 50)
	var first_enemy: EnemyBase = null

	for i in range(group_size):
		var enemy: EnemyBase = swarm_scene.instantiate()
		# Spread them in a small cluster
		var offset_x := randf_range(-40, 40)
		var offset_y := randf_range(-30, 30)
		enemy.global_position = Vector2(center_x + offset_x, spawn_y_offset + offset_y)
		enemy.died.connect(_on_enemy_died)

		get_parent().add_child(enemy)
		enemy_spawned.emit(enemy)

		if i == 0:
			first_enemy = enemy

	return first_enemy


func _choose_enemy_type() -> PackedScene:
	# Get enemy types from current biome
	var biome: Biome = StageManager.current_biome
	if biome and biome.enemy_scenes.size() > 0:
		# Pick randomly from biome's enemy list
		var idx: int = randi() % biome.enemy_scenes.size()
		return biome.enemy_scenes[idx]

	# Fallback: wave-based logic if biome has no enemy list
	return _fallback_enemy_choice()


func _fallback_enemy_choice() -> PackedScene:
	"""Fallback wave-based enemy selection (used if biome.enemy_scenes is empty)"""
	var wave: int = GameManager.current_wave

	# Wave 1: Only slimes
	if wave <= 1:
		return slime_scene

	# Wave 2-3: Introduce bats (30% chance)
	if wave <= 3:
		if randf() < 0.3:
			return bat_scene
		return slime_scene

	# Wave 4-5: Add crabs and swarms
	if wave <= 5:
		var roll: float = randf()
		if roll < 0.4:
			return slime_scene
		elif roll < 0.65:
			return bat_scene
		elif roll < 0.85:
			return crab_scene
		else:
			return swarm_scene

	# Wave 6+: All types
	var roll: float = randf()
	if roll < 0.2:
		return slime_scene
	elif roll < 0.35:
		return bat_scene
	elif roll < 0.48:
		return crab_scene
	elif roll < 0.6:
		return swarm_scene
	elif roll < 0.72:
		return archer_scene
	elif roll < 0.85:
		return bomber_scene
	else:
		return golem_scene


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
