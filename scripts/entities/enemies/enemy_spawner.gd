class_name EnemySpawner
extends Node2D
## Spawns enemies at random X positions at the top of the screen

signal enemy_spawned(enemy: EnemyBase)
signal enemy_died(enemy: EnemyBase)

@export var slime_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_margin: float = 40.0  # Margin from screen edges
@export var spawn_y_offset: float = -50.0  # Spawn above screen

var _spawn_timer: Timer
var _screen_width: float


func _ready() -> void:
	_screen_width = get_viewport().get_visible_rect().size.x
	_setup_timer()


func _setup_timer() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = spawn_interval
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)


func start_spawning() -> void:
	_spawn_timer.start()


func stop_spawning() -> void:
	_spawn_timer.stop()


func set_spawn_interval(interval: float) -> void:
	spawn_interval = interval
	if _spawn_timer:
		_spawn_timer.wait_time = interval


func spawn_enemy() -> EnemyBase:
	if not slime_scene:
		push_warning("EnemySpawner: No slime_scene assigned")
		return null

	var enemy: EnemyBase = slime_scene.instantiate()
	var spawn_x := randf_range(spawn_margin, _screen_width - spawn_margin)
	enemy.global_position = Vector2(spawn_x, spawn_y_offset)
	enemy.died.connect(_on_enemy_died)

	get_parent().add_child(enemy)
	enemy_spawned.emit(enemy)
	return enemy


func _on_spawn_timer_timeout() -> void:
	spawn_enemy()


func _on_enemy_died(enemy: EnemyBase) -> void:
	enemy_died.emit(enemy)
