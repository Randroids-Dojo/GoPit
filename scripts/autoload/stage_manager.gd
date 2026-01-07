extends Node
## StageManager autoload - handles biome/stage progression

signal biome_changed(biome: Biome)
signal boss_wave_reached(stage: int)
signal stage_completed(stage: int)
signal game_won

var stages: Array[Biome] = []
var current_stage: int = 0
var wave_in_stage: int = 1

var current_biome: Biome:
	get:
		if current_stage < stages.size():
			return stages[current_stage]
		return null


func _ready() -> void:
	_load_stages()
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.game_started.connect(_on_game_started)


func _load_stages() -> void:
	stages = [
		preload("res://resources/biomes/the_pit.tres"),
		preload("res://resources/biomes/frozen_depths.tres"),
		preload("res://resources/biomes/burning_sands.tres"),
		preload("res://resources/biomes/final_descent.tres"),
	]


func _on_game_started() -> void:
	current_stage = 0
	wave_in_stage = 1
	_apply_biome()


func _on_wave_changed(global_wave: int) -> void:
	# Calculate wave within current stage
	var waves_per_stage: int = current_biome.waves_before_boss if current_biome else 10
	wave_in_stage = ((global_wave - 1) % waves_per_stage) + 1

	# Check if boss wave reached
	if wave_in_stage >= waves_per_stage:
		boss_wave_reached.emit(current_stage)


func complete_stage() -> void:
	## Call this when boss is defeated (or stage marker reached for now)
	stage_completed.emit(current_stage)
	current_stage += 1
	wave_in_stage = 1

	if current_stage >= stages.size():
		game_won.emit()
	else:
		_apply_biome()


func _apply_biome() -> void:
	if current_biome:
		biome_changed.emit(current_biome)


func get_stage_name() -> String:
	if current_biome:
		return current_biome.biome_name
	return "Unknown"


func get_total_stages() -> int:
	return stages.size()


func is_boss_wave() -> bool:
	if not current_biome:
		return false
	return wave_in_stage >= current_biome.waves_before_boss
