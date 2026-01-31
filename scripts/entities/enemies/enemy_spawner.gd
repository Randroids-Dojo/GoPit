class_name EnemySpawner
extends Node2D
## Spawns enemies at random X positions at the top of the screen
## Supports BallxPit-style spawn formations for organized wave patterns

signal enemy_spawned(enemy: EnemyBase)
signal enemy_died(enemy: EnemyBase)

## Spawn formation types (BallxPit-style)
enum Formation {
	SINGLE,         # Single enemy (default)
	LINE,           # Horizontal line - most common in BallxPit
	V_SHAPE,        # V-shaped arrow pattern pointing up (wings lead)
	ARROW,          # Arrow pointing down at player (leader at front)
	CLUSTER,        # Tight cluster group
	DIAGONAL,       # Diagonal line
	STAGGERED_ROWS, # Two offset rows (checkerboard pattern)
	WALL,           # Dense horizontal barrier (2-3 rows)
}

@export var slime_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_margin: float = 40.0  # Margin from screen edges
@export var spawn_y_offset: float = -50.0  # Spawn above screen
@export var spawn_variance: float = 0.5  # ±0.5 seconds random variance
@export var burst_chance: float = 0.05  # 5% chance for burst spawn (reduced - formations handle groups)
@export var burst_count_min: int = 2
@export var burst_count_max: int = 3
@export var formation_chance: float = 0.60  # 60% chance for formation spawn (BallxPit-style)

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
	add_to_group("enemy_spawner")
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
	var base_interval := spawn_interval + variance
	# Apply difficulty spawn rate multiplier (faster spawns = shorter interval)
	var spawn_mult := GameManager.get_difficulty_spawn_rate_multiplier()
	var next_spawn := maxf(0.3, base_interval / spawn_mult)
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
	# Don't spawn when game is paused (level up, game over, etc.)
	if GameManager.current_state != GameManager.GameState.PLAYING:
		_start_spawn_timer()  # Restart timer but don't spawn
		return

	# Check for formation spawn (higher priority than burst)
	if randf() < formation_chance:
		_formation_spawn()
	# Check for burst spawn
	elif randf() < burst_chance:
		_burst_spawn()
	else:
		spawn_enemy()

	# Restart timer with new random interval
	_start_spawn_timer()


func _burst_spawn() -> void:
	var count := randi_range(burst_count_min, burst_count_max)
	for i in range(count):
		spawn_enemy()


func _formation_spawn() -> void:
	"""Spawn enemies in a formation pattern based on current wave."""
	var wave: int = GameManager.current_wave
	var formation: Formation = _choose_formation_for_wave(wave)
	spawn_formation(formation)


func _choose_formation_for_wave(wave: int) -> Formation:
	"""Choose appropriate formation based on wave progression (BallxPit-style)."""
	# Wave 1-3: Simple patterns - lines and basic arrows
	if wave <= 3:
		var formations: Array[Formation] = [Formation.LINE, Formation.LINE, Formation.ARROW]
		return formations[randi() % formations.size()]

	# Wave 4-6: Introduce V-shapes and diagonals
	if wave <= 6:
		var formations: Array[Formation] = [
			Formation.LINE, Formation.LINE,
			Formation.ARROW, Formation.V_SHAPE,
			Formation.DIAGONAL
		]
		return formations[randi() % formations.size()]

	# Wave 7-10: Add staggered rows
	if wave <= 10:
		var formations: Array[Formation] = [
			Formation.LINE, Formation.ARROW,
			Formation.V_SHAPE, Formation.DIAGONAL,
			Formation.STAGGERED_ROWS, Formation.STAGGERED_ROWS
		]
		return formations[randi() % formations.size()]

	# Wave 11+: Full variety including walls
	var formations: Array[Formation] = [
		Formation.LINE, Formation.ARROW,
		Formation.V_SHAPE, Formation.DIAGONAL,
		Formation.STAGGERED_ROWS, Formation.WALL,
		Formation.CLUSTER
	]
	return formations[randi() % formations.size()]


func spawn_formation(formation: Formation, count: int = 0) -> Array:
	"""Spawn enemies in the specified formation. Returns array of spawned enemies."""
	match formation:
		Formation.SINGLE:
			var enemy := spawn_enemy()
			return [enemy] if enemy else []
		Formation.LINE:
			return _spawn_line_formation(count if count > 0 else randi_range(3, 5))
		Formation.V_SHAPE:
			return _spawn_v_formation(count if count > 0 else randi_range(5, 7))
		Formation.ARROW:
			return _spawn_arrow_formation(count if count > 0 else randi_range(5, 7))
		Formation.CLUSTER:
			return _spawn_cluster_formation(count if count > 0 else randi_range(3, 5))
		Formation.DIAGONAL:
			return _spawn_diagonal_formation(count if count > 0 else randi_range(3, 5))
		Formation.STAGGERED_ROWS:
			return _spawn_staggered_formation(count if count > 0 else randi_range(6, 8))
		Formation.WALL:
			return _spawn_wall_formation(count if count > 0 else randi_range(8, 12))
	return []


func _spawn_line_formation(count: int) -> Array:
	"""Spawn enemies in a horizontal line formation."""
	var enemies: Array = []
	var scene: PackedScene = _choose_enemy_type()
	if not scene or scene == swarm_scene:
		scene = slime_scene  # Don't use swarms for formations

	# Calculate spacing
	var total_width: float = _screen_width - (spawn_margin * 2)
	var spacing: float = total_width / (count + 1)
	var start_x: float = spawn_margin + spacing

	for i in range(count):
		var enemy: EnemyBase = scene.instantiate()
		var x_pos: float = start_x + (spacing * i)
		enemy.global_position = Vector2(x_pos, spawn_y_offset)
		enemy.died.connect(_on_enemy_died)

		get_parent().add_child(enemy)
		enemy_spawned.emit(enemy)
		enemies.append(enemy)

	return enemies


func _spawn_v_formation(count: int) -> Array:
	"""Spawn enemies in a V-shape (arrow) formation."""
	var enemies: Array = []
	var scene: PackedScene = _choose_enemy_type()
	if not scene or scene == swarm_scene:
		scene = slime_scene

	# V-formation parameters
	var center_x: float = _screen_width / 2.0
	var spacing_x: float = 50.0
	var spacing_y: float = 30.0

	# Calculate positions - leader at front, wings behind
	var positions: Array[Vector2] = []
	var half: int = count / 2

	# Leader position (front of V)
	positions.append(Vector2(center_x, spawn_y_offset))

	# Left and right wings
	for i in range(1, half + 1):
		# Left wing
		positions.append(Vector2(center_x - spacing_x * i, spawn_y_offset - spacing_y * i))
		# Right wing
		if positions.size() < count:
			positions.append(Vector2(center_x + spacing_x * i, spawn_y_offset - spacing_y * i))

	# Spawn enemies at positions
	for i in range(mini(count, positions.size())):
		var enemy: EnemyBase = scene.instantiate()
		enemy.global_position = positions[i]
		enemy.died.connect(_on_enemy_died)

		get_parent().add_child(enemy)
		enemy_spawned.emit(enemy)
		enemies.append(enemy)

	return enemies


func _spawn_cluster_formation(count: int) -> Array:
	"""Spawn enemies in a tight cluster formation."""
	var enemies: Array = []
	var scene: PackedScene = _choose_enemy_type()
	if not scene or scene == swarm_scene:
		scene = slime_scene

	var center_x: float = randf_range(spawn_margin + 60, _screen_width - spawn_margin - 60)
	var cluster_radius: float = 40.0

	for i in range(count):
		var enemy: EnemyBase = scene.instantiate()
		# Random position within cluster radius
		var offset_x: float = randf_range(-cluster_radius, cluster_radius)
		var offset_y: float = randf_range(-cluster_radius, cluster_radius)
		enemy.global_position = Vector2(center_x + offset_x, spawn_y_offset + offset_y)
		enemy.died.connect(_on_enemy_died)

		get_parent().add_child(enemy)
		enemy_spawned.emit(enemy)
		enemies.append(enemy)

	return enemies


func _spawn_diagonal_formation(count: int) -> Array:
	"""Spawn enemies in a diagonal line formation."""
	var enemies: Array = []
	var scene: PackedScene = _choose_enemy_type()
	if not scene or scene == swarm_scene:
		scene = slime_scene

	# Diagonal direction: left-to-right or right-to-left
	var left_to_right: bool = randf() < 0.5
	var spacing_x: float = 45.0
	var spacing_y: float = 25.0

	var start_x: float
	if left_to_right:
		start_x = spawn_margin + 50
	else:
		start_x = _screen_width - spawn_margin - 50

	for i in range(count):
		var enemy: EnemyBase = scene.instantiate()
		var x_offset: float = spacing_x * i * (1 if left_to_right else -1)
		var y_offset: float = spacing_y * i
		enemy.global_position = Vector2(start_x + x_offset, spawn_y_offset - y_offset)
		enemy.died.connect(_on_enemy_died)

		get_parent().add_child(enemy)
		enemy_spawned.emit(enemy)
		enemies.append(enemy)

	return enemies


func _spawn_arrow_formation(count: int) -> Array:
	"""Spawn enemies in arrow formation pointing DOWN at player (leader at front).
	This is the inverse of V_SHAPE - leader descends first, wings trail behind."""
	var enemies: Array = []
	var scene: PackedScene = _choose_enemy_type()
	if not scene or scene == swarm_scene:
		scene = slime_scene

	# Arrow formation parameters
	var center_x: float = _screen_width / 2.0
	var spacing_x: float = 45.0
	var spacing_y: float = 35.0

	# Calculate positions - leader at bottom (will reach player first), wings trail above
	var positions: Array[Vector2] = []
	var half: int = count / 2

	# Leader position (front/bottom of arrow - spawns at normal Y)
	positions.append(Vector2(center_x, spawn_y_offset))

	# Left and right wings trail behind (spawn higher up, further from screen)
	for i in range(1, half + 1):
		# Left wing (higher Y = further from player)
		positions.append(Vector2(center_x - spacing_x * i, spawn_y_offset - spacing_y * i))
		# Right wing
		if positions.size() < count:
			positions.append(Vector2(center_x + spacing_x * i, spawn_y_offset - spacing_y * i))

	# Spawn enemies at positions
	for i in range(mini(count, positions.size())):
		var enemy: EnemyBase = scene.instantiate()
		enemy.global_position = positions[i]
		enemy.died.connect(_on_enemy_died)

		get_parent().add_child(enemy)
		enemy_spawned.emit(enemy)
		enemies.append(enemy)

	return enemies


func _spawn_staggered_formation(count: int) -> Array:
	"""Spawn enemies in staggered rows (checkerboard pattern).
	Two rows with offset X positions - like BallxPit's common spawn pattern."""
	var enemies: Array = []
	var scene: PackedScene = _choose_enemy_type()
	if not scene or scene == swarm_scene:
		scene = slime_scene

	# Staggered formation parameters
	var row_spacing_y: float = 40.0
	var enemies_per_row: int = (count + 1) / 2  # Split between two rows
	var total_width: float = _screen_width - (spawn_margin * 2)
	var spacing_x: float = total_width / (enemies_per_row + 1)

	# First row (front)
	var row1_start_x: float = spawn_margin + spacing_x
	for i in range(enemies_per_row):
		var enemy: EnemyBase = scene.instantiate()
		var x_pos: float = row1_start_x + (spacing_x * i)
		enemy.global_position = Vector2(x_pos, spawn_y_offset)
		enemy.died.connect(_on_enemy_died)

		get_parent().add_child(enemy)
		enemy_spawned.emit(enemy)
		enemies.append(enemy)

	# Second row (behind, offset by half spacing)
	var remaining: int = count - enemies_per_row
	if remaining > 0:
		var row2_start_x: float = spawn_margin + spacing_x + (spacing_x / 2.0)
		for i in range(remaining):
			var enemy: EnemyBase = scene.instantiate()
			var x_pos: float = row2_start_x + (spacing_x * i)
			# Clamp to screen bounds
			x_pos = clampf(x_pos, spawn_margin, _screen_width - spawn_margin)
			enemy.global_position = Vector2(x_pos, spawn_y_offset - row_spacing_y)
			enemy.died.connect(_on_enemy_died)

			get_parent().add_child(enemy)
			enemy_spawned.emit(enemy)
			enemies.append(enemy)

	return enemies


func _spawn_wall_formation(count: int) -> Array:
	"""Spawn enemies in a dense wall formation (2-3 rows filling screen width).
	Creates pressure - player must break through or be overwhelmed."""
	var enemies: Array = []
	var scene: PackedScene = _choose_enemy_type()
	if not scene or scene == swarm_scene:
		scene = slime_scene

	# Wall formation parameters
	var row_spacing_y: float = 35.0
	var num_rows: int = 2 if count <= 8 else 3
	var enemies_per_row: int = ceili(float(count) / float(num_rows))

	var total_width: float = _screen_width - (spawn_margin * 2)
	var spacing_x: float = total_width / (enemies_per_row + 1)

	var spawned: int = 0
	for row in range(num_rows):
		if spawned >= count:
			break

		var row_y: float = spawn_y_offset - (row_spacing_y * row)
		var row_start_x: float = spawn_margin + spacing_x

		for col in range(enemies_per_row):
			if spawned >= count:
				break

			var enemy: EnemyBase = scene.instantiate()
			var x_pos: float = row_start_x + (spacing_x * col)
			enemy.global_position = Vector2(x_pos, row_y)
			enemy.died.connect(_on_enemy_died)

			get_parent().add_child(enemy)
			enemy_spawned.emit(enemy)
			enemies.append(enemy)
			spawned += 1

	return enemies


func get_available_formations() -> Array[Formation]:
	"""Get list of all available spawn formations."""
	return [
		Formation.SINGLE, Formation.LINE, Formation.V_SHAPE, Formation.ARROW,
		Formation.CLUSTER, Formation.DIAGONAL, Formation.STAGGERED_ROWS, Formation.WALL
	]


func _on_enemy_died(enemy: EnemyBase) -> void:
	enemy_died.emit(enemy)
