extends Node
## Meta-progression manager - handles Pit Coins, permanent upgrades, and cross-run persistence

signal coins_changed(new_amount: int)
signal upgrade_purchased(upgrade_id: String, new_level: int)
signal character_unlocked(character_name: String)

const SAVE_PATH := "user://meta.save"

# Characters that start unlocked by default (no requirement)
const DEFAULT_UNLOCKED_CHARACTERS := [
	"Rookie", "Pyro", "Frost Mage", "Tactician", "Gambler"
]

# Unlock requirements mapping (character_name -> requirement check function name)
const CHARACTER_UNLOCK_REQUIREMENTS := {
	"Vampire": {"type": "wave", "value": 20}  # Survive to wave 20
}

# Persistent data
var pit_coins: int = 0
var total_runs: int = 0
var best_wave: int = 0
var highest_stage_cleared: int = 0  # 0 = none, 1 = The Pit, etc.
var unlocked_upgrades: Dictionary = {}  # upgrade_id -> level
var unlocked_characters: Array = []  # List of unlocked character names

# Gear system - each stage×character completion = 1 gear
# Format: {stage_index: [character_name, character_name, ...]}
var stage_completions: Dictionary = {}
const GEARS_PER_STAGE: int = 2  # Need 2 unique character completions to unlock next

# Permanent upgrade bonuses (applied at run start)
var bonus_hp: int = 0
var bonus_damage: float = 0.0
var bonus_fire_rate: float = 0.0


func _ready() -> void:
	load_data()
	_calculate_bonuses()


func earn_coins(wave: int, level: int) -> int:
	var earned := wave * 10 + level * 25
	pit_coins += earned
	coins_changed.emit(pit_coins)
	save_data()
	return earned


func spend_coins(amount: int) -> bool:
	if pit_coins >= amount:
		pit_coins -= amount
		coins_changed.emit(pit_coins)
		save_data()
		return true
	return false


func can_afford(amount: int) -> bool:
	return pit_coins >= amount


func record_run_end(wave: int, _level: int) -> void:
	total_runs += 1
	if wave > best_wave:
		best_wave = wave
	save_data()
	# Check if any new characters can be unlocked
	check_unlock_conditions()


func record_stage_cleared(stage_index: int) -> void:
	if stage_index > highest_stage_cleared:
		highest_stage_cleared = stage_index
		save_data()


func get_highest_stage_cleared() -> int:
	return highest_stage_cleared


# =============================================================================
# GEAR UNLOCK SYSTEM
# =============================================================================

func record_stage_completion(stage_index: int, character_name: String) -> bool:
	"""Record a stage completion with a specific character.
	Returns true if this is a new gear earned (first time this character beat this stage)."""
	# Initialize stage array if needed
	if stage_index not in stage_completions:
		stage_completions[stage_index] = []

	# Check if this character already beat this stage
	if character_name in stage_completions[stage_index]:
		return false  # Already earned this gear

	# New gear earned!
	stage_completions[stage_index].append(character_name)

	# Also update highest_stage_cleared for backwards compatibility
	if stage_index > highest_stage_cleared:
		highest_stage_cleared = stage_index

	save_data()
	return true


func get_stage_gears(stage_index: int) -> int:
	"""Get number of gears earned for a stage (unique character completions)."""
	if stage_index not in stage_completions:
		return 0
	return stage_completions[stage_index].size()


func get_total_gears() -> int:
	"""Get total gears earned across all stages."""
	var total: int = 0
	for stage_index in stage_completions:
		total += stage_completions[stage_index].size()
	return total


func is_stage_unlocked_by_gears(stage_index: int) -> bool:
	"""Check if a stage is unlocked based on gear requirements.
	Stage 0 (The Pit) is always unlocked.
	Each subsequent stage requires GEARS_PER_STAGE gears from the previous stage."""
	if stage_index == 0:
		return true  # First stage always unlocked

	var prev_stage_gears := get_stage_gears(stage_index - 1)
	return prev_stage_gears >= GEARS_PER_STAGE


func get_characters_who_cleared_stage(stage_index: int) -> Array:
	"""Get list of characters who have cleared a specific stage."""
	if stage_index not in stage_completions:
		return []
	return stage_completions[stage_index].duplicate()


func get_upgrade_level(upgrade_id: String) -> int:
	return unlocked_upgrades.get(upgrade_id, 0)


func purchase_upgrade(upgrade_id: String, cost: int) -> bool:
	if not spend_coins(cost):
		return false

	var current_level := get_upgrade_level(upgrade_id)
	unlocked_upgrades[upgrade_id] = current_level + 1
	_calculate_bonuses()
	upgrade_purchased.emit(upgrade_id, current_level + 1)
	save_data()
	return true


func _calculate_bonuses() -> void:
	# HP bonus: +10 per level
	bonus_hp = get_upgrade_level("hp") * 10

	# Damage bonus: +2 per level
	bonus_damage = get_upgrade_level("damage") * 2.0

	# Fire rate bonus: -0.05s per level (faster firing)
	bonus_fire_rate = get_upgrade_level("fire_rate") * 0.05


func get_starting_hp() -> int:
	# Base HP from GameManager + bonus
	return bonus_hp


func get_damage_bonus() -> float:
	return bonus_damage


func get_fire_rate_bonus() -> float:
	return bonus_fire_rate


# =============================================================================
# CHARACTER UNLOCK SYSTEM
# =============================================================================

func is_character_unlocked(character_name: String) -> bool:
	"""Check if a character is unlocked (either default or earned)"""
	if character_name in DEFAULT_UNLOCKED_CHARACTERS:
		return true
	return character_name in unlocked_characters


func unlock_character(character_name: String) -> void:
	"""Unlock a character permanently"""
	if character_name not in unlocked_characters:
		unlocked_characters.append(character_name)
		character_unlocked.emit(character_name)
		save_data()


func check_unlock_conditions() -> Array:
	"""Check all unlock conditions and unlock any newly earned characters.
	Returns array of newly unlocked character names."""
	var newly_unlocked: Array = []

	for character_name in CHARACTER_UNLOCK_REQUIREMENTS:
		if is_character_unlocked(character_name):
			continue  # Already unlocked

		var requirement: Dictionary = CHARACTER_UNLOCK_REQUIREMENTS[character_name]
		var is_met := false

		match requirement["type"]:
			"wave":
				is_met = best_wave >= requirement["value"]
			"stage":
				is_met = highest_stage_cleared >= requirement["value"]
			"runs":
				is_met = total_runs >= requirement["value"]

		if is_met:
			unlock_character(character_name)
			newly_unlocked.append(character_name)

	return newly_unlocked


func get_unlock_progress(character_name: String) -> Dictionary:
	"""Get progress toward unlocking a character.
	Returns {current: int, required: int, type: String} or empty dict if no requirement."""
	if character_name not in CHARACTER_UNLOCK_REQUIREMENTS:
		return {}

	var requirement: Dictionary = CHARACTER_UNLOCK_REQUIREMENTS[character_name]
	var current: int = 0

	match requirement["type"]:
		"wave":
			current = best_wave
		"stage":
			current = highest_stage_cleared
		"runs":
			current = total_runs

	return {
		"current": current,
		"required": requirement["value"],
		"type": requirement["type"]
	}


func save_data() -> void:
	var data := {
		"coins": pit_coins,
		"runs": total_runs,
		"best_wave": best_wave,
		"highest_stage": highest_stage_cleared,
		"upgrades": unlocked_upgrades,
		"unlocked_characters": unlocked_characters,
		"stage_completions": stage_completions
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var json_string := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)
	if data is Dictionary:
		pit_coins = data.get("coins", 0)
		total_runs = data.get("runs", 0)
		best_wave = data.get("best_wave", 0)
		highest_stage_cleared = data.get("highest_stage", 0)
		unlocked_upgrades = data.get("upgrades", {})
		unlocked_characters = data.get("unlocked_characters", [])
		stage_completions = data.get("stage_completions", {})
		coins_changed.emit(pit_coins)


func reset_data() -> void:
	pit_coins = 0
	total_runs = 0
	best_wave = 0
	highest_stage_cleared = 0
	unlocked_upgrades = {}
	unlocked_characters = []
	stage_completions = {}
	bonus_hp = 0
	bonus_damage = 0.0
	bonus_fire_rate = 0.0

	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	coins_changed.emit(pit_coins)
