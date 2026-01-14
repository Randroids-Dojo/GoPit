extends Node
## StageManager autoload - handles biome/stage progression

signal biome_changed(biome: Biome)
signal boss_wave_reached(stage: int)
signal mini_boss_wave_reached(stage: int, mini_boss_index: int)
signal stage_completed(stage: int)
signal game_won

# Mini-boss waves within each stage (waves 4 and 7 of 10)
const MINI_BOSS_WAVES: Array[int] = [4, 7]

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
		preload("res://resources/biomes/toxic_marsh.tres"),
		preload("res://resources/biomes/storm_spire.tres"),
		preload("res://resources/biomes/crystal_caverns.tres"),
		preload("res://resources/biomes/the_abyss.tres"),
	]


func _on_game_started() -> void:
	current_stage = 0
	wave_in_stage = 1
	_apply_biome()


func _on_wave_changed(global_wave: int) -> void:
	# Calculate wave within current stage
	var waves_per_stage: int = current_biome.waves_before_boss if current_biome else 10
	wave_in_stage = ((global_wave - 1) % waves_per_stage) + 1

	# Check if mini-boss wave reached (waves 4 and 7)
	var mini_boss_idx := MINI_BOSS_WAVES.find(wave_in_stage)
	if mini_boss_idx != -1:
		mini_boss_wave_reached.emit(current_stage, mini_boss_idx)

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


func get_post_boss_hp_multiplier() -> float:
	## Returns HP multiplier based on bosses defeated.
	## Each boss adds roughly 3x HP to enemies, creating distinct difficulty phases.
	const BOSS_HP_MULT: float = 3.0
	if current_stage <= 0:
		return 1.0
	return pow(BOSS_HP_MULT, current_stage)
