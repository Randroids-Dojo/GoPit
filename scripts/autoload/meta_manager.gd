extends Node
## Meta-progression manager - handles Pit Coins, permanent upgrades, and cross-run persistence
## Supports multiple save slots with both meta progression and mid-run session saves

signal coins_changed(new_amount: int)
signal upgrade_purchased(upgrade_id: String, new_level: int)
signal character_unlocked(character_name: String)
signal achievement_unlocked(achievement_id: String, reward: int)
signal passive_evolution_unlocked(evolution_id: String)
signal slot_changed(new_slot: int)
signal slot_deleted(slot: int)
signal session_saved
signal session_loaded
signal session_cleared
signal matchmaker_unlocked

# Save slot system
const SLOT_COUNT := 3
const LEGACY_SAVE_PATH := "user://meta.save"
const ACTIVE_SLOT_PATH := "user://active_slot.save"

var current_slot: int = 1


func _get_meta_path(slot: int = -1) -> String:
	if slot == -1:
		slot = current_slot
	return "user://slot_%d_meta.save" % slot


func _get_session_path(slot: int = -1) -> String:
	if slot == -1:
		slot = current_slot
	return "user://slot_%d_session.save" % slot

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
var unlocked_passive_evolutions: Array = []  # List of unlocked passive evolution IDs

# Gear system - each stage×character completion = 1 gear
# Format: {stage_index: [character_name, character_name, ...]}
var stage_completions: Dictionary = {}
const GEARS_PER_STAGE: int = 2  # Need 2 unique character completions to unlock next

# Matchmaker building - enables 2-character runs (like BallxPit)
const MATCHMAKER_COST: int = 1000  # Pit coins to unlock
const MATCHMAKER_REQUIRED_CHARACTERS: int = 6  # Must unlock 6 characters first
var matchmaker_purchased: bool = false

# Difficulty completion tracking (like BallxPit's Fast+N system)
# Format: {character_name: {stage_index: highest_difficulty_beaten}}
# Cascading: beating difficulty N counts as beating 1..N
var difficulty_completions: Dictionary = {}

# Lifetime stats (accumulated across all runs)
var lifetime_kills: int = 0
var lifetime_gems: int = 0
var lifetime_damage: int = 0

# Slot metadata
var created_at: String = ""  # ISO 8601 timestamp
var last_played: String = ""  # ISO 8601 timestamp
var total_playtime: float = 0.0  # seconds
var _session_start_time: float = 0.0  # for tracking current session playtime

# Achievement system
var unlocked_achievements: Array = []  # List of achievement IDs

# Achievement definitions: id -> {name, description, condition_type, value, reward}
const ACHIEVEMENTS := {
	# First steps
	"first_run": {"name": "Baby Steps", "desc": "Complete your first run", "type": "runs", "value": 1, "reward": 50},
	"first_kill": {"name": "First Blood", "desc": "Kill your first enemy", "type": "kills", "value": 1, "reward": 25},
	# Progress milestones
	"wave_10": {"name": "Getting Warmed Up", "desc": "Reach wave 10", "type": "wave", "value": 10, "reward": 100},
	"wave_25": {"name": "Veteran", "desc": "Reach wave 25", "type": "wave", "value": 25, "reward": 250},
	"wave_50": {"name": "Pit Master", "desc": "Reach wave 50", "type": "wave", "value": 50, "reward": 500},
	"beat_stage_1": {"name": "Escape The Pit", "desc": "Clear The Pit", "type": "stage", "value": 1, "reward": 200},
	"beat_stage_2": {"name": "Thaw Out", "desc": "Clear Frozen Depths", "type": "stage", "value": 2, "reward": 300},
	"beat_stage_3": {"name": "Cool Down", "desc": "Clear Burning Sands", "type": "stage", "value": 3, "reward": 400},
	"beat_stage_4": {"name": "Conqueror", "desc": "Clear Final Descent", "type": "stage", "value": 4, "reward": 1000},
	# Grinder achievements
	"kills_100": {"name": "Centurion", "desc": "Kill 100 enemies total", "type": "kills", "value": 100, "reward": 100},
	"kills_1000": {"name": "Slayer", "desc": "Kill 1,000 enemies total", "type": "kills", "value": 1000, "reward": 500},
	"gems_500": {"name": "Gem Collector", "desc": "Collect 500 gems total", "type": "gems", "value": 500, "reward": 150},
	"gems_5000": {"name": "Treasure Hunter", "desc": "Collect 5,000 gems total", "type": "gems", "value": 5000, "reward": 750},
	"runs_10": {"name": "Persistent", "desc": "Complete 10 runs", "type": "runs", "value": 10, "reward": 200},
	"runs_50": {"name": "Dedicated", "desc": "Complete 50 runs", "type": "runs", "value": 50, "reward": 500},
}

# Permanent upgrade bonuses (applied at run start)
var bonus_hp: int = 0
var bonus_damage: float = 0.0
var bonus_fire_rate: float = 0.0
var bonus_xp_percent: float = 0.0  # +X% XP from Veteran's Hut
var bonus_early_xp_percent: float = 0.0  # +X% XP for first N levels from Abbey

# Stat bonuses from buildings (BallxPit style: +1 flat stat per level)
var bonus_strength: int = 0
var bonus_dexterity: int = 0
var bonus_intelligence: int = 0
var bonus_leadership: int = 0
const EARLY_XP_LEVEL_CAP: int = 5  # Abbey bonus applies to first 5 levels

# Passive evolution bonuses (from unlocked passive evolutions)
var evo_bonus_damage: float = 0.0  # +1 per Power Mastery
var evo_bonus_fire_rate: float = 0.0  # -0.02s per Rapid Mastery
var evo_bonus_max_hp: int = 0  # +5 per Vitality Mastery
var evo_bonus_multi_shot: int = 0  # +1 per Multishot Mastery
var evo_bonus_ball_speed: float = 0.0  # +20 per Velocity Mastery
var evo_bonus_piercing: int = 0  # +1 per Pierce Mastery
var evo_bonus_ricochet: int = 0  # +1 per Bounce Mastery
var evo_bonus_critical: float = 0.0  # +0.02 per Critical Mastery


func _ready() -> void:
	_migrate_legacy_save()
	_load_active_slot()
	load_data()
	_calculate_bonuses()
	_session_start_time = Time.get_unix_time_from_system()


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


func record_run_end(wave: int, _level: int, kills: int = 0, gems: int = 0, damage: int = 0) -> void:
	total_runs += 1
	if wave > best_wave:
		best_wave = wave
	# Accumulate lifetime stats
	lifetime_kills += kills
	lifetime_gems += gems
	lifetime_damage += damage
	save_data()
	# Check if any new characters can be unlocked
	check_unlock_conditions()
	# Check for new achievements
	check_achievements()


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


# =============================================================================
# DIFFICULTY COMPLETION TRACKING
# =============================================================================

func record_difficulty_completion(character_name: String, stage_index: int, difficulty_level: int) -> bool:
	"""Record a stage completion at a specific difficulty level.
	Returns true if this is a new highest difficulty for this character/stage.
	Cascading: beating level N counts as beating 1..N."""
	# Initialize character dict if needed
	if character_name not in difficulty_completions:
		difficulty_completions[character_name] = {}

	var char_data: Dictionary = difficulty_completions[character_name]

	# Convert stage_index to string for JSON compatibility
	var stage_key := str(stage_index)

	# Check if this is a new high
	var current_highest: int = char_data.get(stage_key, 0)
	if difficulty_level <= current_highest:
		return false  # Already beaten this or higher

	# New record!
	char_data[stage_key] = difficulty_level
	difficulty_completions[character_name] = char_data

	# Also record stage completion for gear system if first time
	record_stage_completion(stage_index, character_name)

	save_data()
	return true


func get_highest_difficulty_beaten(character_name: String, stage_index: int) -> int:
	"""Get the highest difficulty level beaten by a character on a stage.
	Returns 0 if never beaten."""
	if character_name not in difficulty_completions:
		return 0

	var char_data: Dictionary = difficulty_completions[character_name]
	var stage_key := str(stage_index)
	return char_data.get(stage_key, 0)


func has_beaten_difficulty(stage_index: int, difficulty_level: int) -> bool:
	"""Check if ANY character has beaten a specific difficulty on a stage.
	Used for unlocking higher difficulty levels."""
	for character_name in difficulty_completions:
		var highest := get_highest_difficulty_beaten(character_name, stage_index)
		if highest >= difficulty_level:
			return true
	return false


func get_highest_difficulty_for_stage(stage_index: int) -> int:
	"""Get the highest difficulty beaten by ANY character on a stage."""
	var highest: int = 0
	for character_name in difficulty_completions:
		var char_highest := get_highest_difficulty_beaten(character_name, stage_index)
		if char_highest > highest:
			highest = char_highest
	return highest


func get_difficulty_completion_matrix() -> Dictionary:
	"""Get the full completion matrix for UI display.
	Returns: {character_name: {stage_index: highest_difficulty}}"""
	return difficulty_completions.duplicate(true)


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

	# XP gain bonus: +5% per level (max 25%)
	bonus_xp_percent = get_upgrade_level("xp_gain") * 0.05

	# Early XP bonus: +10% per level for first 5 levels (max 30%)
	bonus_early_xp_percent = get_upgrade_level("early_xp") * 0.10

	# Stat bonuses: +1 per level (BallxPit style)
	bonus_strength = get_upgrade_level("strength")
	bonus_dexterity = get_upgrade_level("dexterity")
	bonus_intelligence = get_upgrade_level("intelligence")
	bonus_leadership = get_upgrade_level("leadership")

	# Calculate passive evolution bonuses
	_calculate_evolution_bonuses()


func get_starting_hp() -> int:
	# Bonus HP from shop upgrades + passive evolutions
	return bonus_hp + evo_bonus_max_hp


func get_damage_bonus() -> float:
	# Bonus damage from shop upgrades + passive evolutions
	return bonus_damage + evo_bonus_damage


func get_fire_rate_bonus() -> float:
	# Bonus fire rate from shop upgrades + passive evolutions
	return bonus_fire_rate + evo_bonus_fire_rate


func get_multi_shot_bonus() -> int:
	# Bonus balls per shot from passive evolutions
	return evo_bonus_multi_shot


func get_ball_speed_bonus() -> float:
	# Bonus ball speed from passive evolutions
	return evo_bonus_ball_speed


func get_piercing_bonus() -> int:
	# Bonus pierce from passive evolutions
	return evo_bonus_piercing


func get_ricochet_bonus() -> int:
	# Bonus wall bounces from passive evolutions
	return evo_bonus_ricochet


func get_critical_bonus() -> float:
	# Bonus crit chance from passive evolutions
	return evo_bonus_critical


func get_strength_bonus() -> int:
	# Bonus strength from Barracks building
	return bonus_strength


func get_dexterity_bonus() -> int:
	# Bonus dexterity from Gunsmith building
	return bonus_dexterity


func get_intelligence_bonus() -> int:
	# Bonus intelligence from Schoolhouse building
	return bonus_intelligence


func get_leadership_bonus() -> int:
	# Bonus leadership from Consulate building
	return bonus_leadership


func get_xp_gain_multiplier() -> float:
	## Returns XP gain multiplier from Veteran's Hut upgrade (1.0 to 1.25)
	return 1.0 + bonus_xp_percent


func get_early_xp_multiplier(current_level: int) -> float:
	## Returns early-level XP multiplier from Abbey upgrade
	## Only applies to levels 1 through EARLY_XP_LEVEL_CAP (5)
	if current_level <= EARLY_XP_LEVEL_CAP:
		return 1.0 + bonus_early_xp_percent
	return 1.0


# =============================================================================
# MATCHMAKER BUILDING (2-CHARACTER MODE)
# =============================================================================

func is_matchmaker_unlocked() -> bool:
	"""Check if the Matchmaker building is unlocked (enables 2-character runs)."""
	return matchmaker_purchased


func can_purchase_matchmaker() -> bool:
	"""Check if player meets requirements to purchase Matchmaker."""
	if matchmaker_purchased:
		return false  # Already purchased
	if pit_coins < MATCHMAKER_COST:
		return false  # Not enough coins
	# Check if enough characters are unlocked
	var total_unlocked := DEFAULT_UNLOCKED_CHARACTERS.size() + unlocked_characters.size()
	if total_unlocked < MATCHMAKER_REQUIRED_CHARACTERS:
		return false
	return true


func get_matchmaker_unlock_progress() -> Dictionary:
	"""Get progress toward unlocking Matchmaker.
	Returns {characters_unlocked, characters_required, coins, cost, can_purchase, is_purchased}."""
	var total_unlocked := DEFAULT_UNLOCKED_CHARACTERS.size() + unlocked_characters.size()
	return {
		"characters_unlocked": total_unlocked,
		"characters_required": MATCHMAKER_REQUIRED_CHARACTERS,
		"coins": pit_coins,
		"cost": MATCHMAKER_COST,
		"can_purchase": can_purchase_matchmaker(),
		"is_purchased": matchmaker_purchased
	}


func purchase_matchmaker() -> bool:
	"""Purchase the Matchmaker building. Returns true if successful."""
	if not can_purchase_matchmaker():
		return false

	if not spend_coins(MATCHMAKER_COST):
		return false

	matchmaker_purchased = true
	matchmaker_unlocked.emit()
	save_data()
	return true


# =============================================================================
# PASSIVE EVOLUTION SYSTEM
# =============================================================================

func _calculate_evolution_bonuses() -> void:
	"""Calculate bonuses from unlocked passive evolutions."""
	# Reset all evolution bonuses
	evo_bonus_damage = 0.0
	evo_bonus_fire_rate = 0.0
	evo_bonus_max_hp = 0
	evo_bonus_multi_shot = 0
	evo_bonus_ball_speed = 0.0
	evo_bonus_piercing = 0
	evo_bonus_ricochet = 0
	evo_bonus_critical = 0.0

	# Apply each unlocked evolution's bonus
	for evolution_id in unlocked_passive_evolutions:
		var evolution: PassiveEvolutions.EvolutionData = PassiveEvolutions.get_evolution(evolution_id)
		if not evolution:
			continue

		match evolution.effect_type:
			"damage":
				evo_bonus_damage += evolution.effect_value
			"fire_rate":
				evo_bonus_fire_rate += evolution.effect_value
			"max_hp":
				evo_bonus_max_hp += int(evolution.effect_value)
			"multi_shot":
				evo_bonus_multi_shot += int(evolution.effect_value)
			"ball_speed":
				evo_bonus_ball_speed += evolution.effect_value
			"piercing":
				evo_bonus_piercing += int(evolution.effect_value)
			"ricochet":
				evo_bonus_ricochet += int(evolution.effect_value)
			"critical":
				evo_bonus_critical += evolution.effect_value


func is_passive_evolution_unlocked(evolution_id: String) -> bool:
	"""Check if a passive evolution is unlocked."""
	return evolution_id in unlocked_passive_evolutions


func unlock_passive_evolution(evolution_id: String) -> bool:
	"""Unlock a passive evolution. Returns true if newly unlocked."""
	if evolution_id in unlocked_passive_evolutions:
		return false  # Already unlocked

	if not PassiveEvolutions.get_evolution(evolution_id):
		return false  # Invalid evolution

	unlocked_passive_evolutions.append(evolution_id)
	_calculate_evolution_bonuses()
	passive_evolution_unlocked.emit(evolution_id)
	save_data()
	return true


func try_unlock_evolution_for_passive(passive_type: int) -> String:
	"""Try to unlock the evolution for a given passive type.
	Called when a passive reaches L3. Returns evolution_id if newly unlocked, empty string otherwise."""
	var evolution_id := PassiveEvolutions.get_evolution_id_for_passive(passive_type)
	if evolution_id.is_empty():
		return ""

	if unlock_passive_evolution(evolution_id):
		return evolution_id
	return ""


func get_passive_evolution_data(evolution_id: String) -> PassiveEvolutions.EvolutionData:
	"""Get evolution data for display."""
	return PassiveEvolutions.get_evolution(evolution_id)


func get_all_passive_evolution_ids() -> Array[String]:
	"""Get all possible passive evolution IDs."""
	return PassiveEvolutions.get_evolution_ids()


func get_unlocked_passive_evolutions() -> Array:
	"""Get list of unlocked passive evolution IDs."""
	return unlocked_passive_evolutions.duplicate()


func get_evolution_unlock_progress() -> Dictionary:
	"""Get progress toward all evolutions for UI display.
	Returns: {evolution_id: {unlocked: bool, source_passive_name: String}}"""
	var progress := {}
	for evolution_id in PassiveEvolutions.get_evolution_ids():
		var evolution: PassiveEvolutions.EvolutionData = PassiveEvolutions.get_evolution(evolution_id)
		if evolution:
			progress[evolution_id] = {
				"unlocked": evolution_id in unlocked_passive_evolutions,
				"name": evolution.name,
				"description": evolution.description,
				"icon": evolution.icon
			}
	return progress


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


# =============================================================================
# ACHIEVEMENT SYSTEM
# =============================================================================

func add_lifetime_stats(kills: int, gems: int, damage: int) -> void:
	"""Add session stats to lifetime totals. Called at end of each run."""
	lifetime_kills += kills
	lifetime_gems += gems
	lifetime_damage += damage
	save_data()


func check_achievements() -> Array:
	"""Check all achievements and unlock any newly earned.
	Returns array of newly unlocked achievement IDs."""
	var newly_unlocked: Array = []

	for achievement_id in ACHIEVEMENTS:
		if is_achievement_unlocked(achievement_id):
			continue  # Already unlocked

		var achievement: Dictionary = ACHIEVEMENTS[achievement_id]
		var is_met := false

		match achievement["type"]:
			"runs":
				is_met = total_runs >= achievement["value"]
			"wave":
				is_met = best_wave >= achievement["value"]
			"stage":
				is_met = highest_stage_cleared >= achievement["value"]
			"kills":
				is_met = lifetime_kills >= achievement["value"]
			"gems":
				is_met = lifetime_gems >= achievement["value"]

		if is_met:
			unlock_achievement(achievement_id)
			newly_unlocked.append(achievement_id)

	return newly_unlocked


func is_achievement_unlocked(achievement_id: String) -> bool:
	"""Check if an achievement is unlocked."""
	return achievement_id in unlocked_achievements


func unlock_achievement(achievement_id: String) -> void:
	"""Unlock an achievement and award its reward."""
	if achievement_id in unlocked_achievements:
		return  # Already unlocked

	if achievement_id not in ACHIEVEMENTS:
		return  # Invalid achievement

	unlocked_achievements.append(achievement_id)
	var reward: int = ACHIEVEMENTS[achievement_id]["reward"]
	pit_coins += reward
	coins_changed.emit(pit_coins)
	achievement_unlocked.emit(achievement_id, reward)
	save_data()


func get_achievement_data(achievement_id: String) -> Dictionary:
	"""Get achievement definition data."""
	return ACHIEVEMENTS.get(achievement_id, {})


func get_all_achievements() -> Array:
	"""Get list of all achievement IDs."""
	return ACHIEVEMENTS.keys()


func get_achievement_progress(achievement_id: String) -> Dictionary:
	"""Get progress toward an achievement.
	Returns {current: int, required: int, is_unlocked: bool}."""
	if achievement_id not in ACHIEVEMENTS:
		return {}

	var achievement: Dictionary = ACHIEVEMENTS[achievement_id]
	var current: int = 0

	match achievement["type"]:
		"runs":
			current = total_runs
		"wave":
			current = best_wave
		"stage":
			current = highest_stage_cleared
		"kills":
			current = lifetime_kills
		"gems":
			current = lifetime_gems

	return {
		"current": current,
		"required": achievement["value"],
		"is_unlocked": is_achievement_unlocked(achievement_id)
	}


func save_data() -> void:
	# Update playtime before saving
	_update_playtime()

	# Update last_played timestamp
	last_played = Time.get_datetime_string_from_system(true)

	# Set created_at if this is a new slot
	if created_at.is_empty():
		created_at = last_played

	var data := {
		"coins": pit_coins,
		"runs": total_runs,
		"best_wave": best_wave,
		"highest_stage": highest_stage_cleared,
		"upgrades": unlocked_upgrades,
		"unlocked_characters": unlocked_characters,
		"unlocked_passive_evolutions": unlocked_passive_evolutions,
		"stage_completions": stage_completions,
		"difficulty_completions": difficulty_completions,
		"lifetime_kills": lifetime_kills,
		"lifetime_gems": lifetime_gems,
		"lifetime_damage": lifetime_damage,
		"unlocked_achievements": unlocked_achievements,
		"matchmaker_purchased": matchmaker_purchased,
		"created_at": created_at,
		"last_played": last_played,
		"total_playtime": total_playtime
	}

	var file := FileAccess.open(_get_meta_path(), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_data() -> void:
	var path := _get_meta_path()
	if not FileAccess.file_exists(path):
		# Reset to defaults for empty slot
		_reset_slot_data()
		return

	var file := FileAccess.open(path, FileAccess.READ)
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
		unlocked_passive_evolutions = data.get("unlocked_passive_evolutions", [])
		stage_completions = data.get("stage_completions", {})
		difficulty_completions = data.get("difficulty_completions", {})
		lifetime_kills = data.get("lifetime_kills", 0)
		lifetime_gems = data.get("lifetime_gems", 0)
		lifetime_damage = data.get("lifetime_damage", 0)
		unlocked_achievements = data.get("unlocked_achievements", [])
		matchmaker_purchased = data.get("matchmaker_purchased", false)
		created_at = data.get("created_at", "")
		last_played = data.get("last_played", "")
		total_playtime = data.get("total_playtime", 0.0)
		coins_changed.emit(pit_coins)


func _reset_slot_data() -> void:
	"""Reset all slot data to defaults (for empty/new slots)."""
	pit_coins = 0
	total_runs = 0
	best_wave = 0
	highest_stage_cleared = 0
	unlocked_upgrades = {}
	unlocked_characters = []
	unlocked_passive_evolutions = []
	stage_completions = {}
	difficulty_completions = {}
	lifetime_kills = 0
	lifetime_gems = 0
	lifetime_damage = 0
	unlocked_achievements = []
	matchmaker_purchased = false
	created_at = ""
	last_played = ""
	total_playtime = 0.0
	bonus_hp = 0
	bonus_damage = 0.0
	bonus_fire_rate = 0.0
	bonus_xp_percent = 0.0
	bonus_early_xp_percent = 0.0
	# Reset evolution bonuses
	evo_bonus_damage = 0.0
	evo_bonus_fire_rate = 0.0
	evo_bonus_max_hp = 0
	evo_bonus_multi_shot = 0
	evo_bonus_ball_speed = 0.0
	evo_bonus_piercing = 0
	evo_bonus_ricochet = 0
	evo_bonus_critical = 0.0
	coins_changed.emit(pit_coins)


func reset_data() -> void:
	"""Reset current slot data and delete save files."""
	_reset_slot_data()

	var meta_path := _get_meta_path()
	var session_path := _get_session_path()

	if FileAccess.file_exists(meta_path):
		DirAccess.remove_absolute(meta_path)
	if FileAccess.file_exists(session_path):
		DirAccess.remove_absolute(session_path)


# =============================================================================
# SAVE SLOT MANAGEMENT
# =============================================================================

func set_active_slot(slot: int) -> void:
	"""Switch to a different save slot."""
	if slot < 1 or slot > SLOT_COUNT:
		push_error("Invalid slot number: %d" % slot)
		return

	# Save current playtime before switching
	_update_playtime()
	save_data()

	current_slot = slot
	_save_active_slot()
	load_data()
	_calculate_bonuses()
	_session_start_time = Time.get_unix_time_from_system()
	slot_changed.emit(slot)


func get_slot_preview(slot: int) -> Dictionary:
	"""Get preview info for a slot without fully loading it.
	Returns empty dict if slot is empty."""
	var path := _get_meta_path(slot)
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_string := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)
	if not data is Dictionary:
		return {}

	# Check if there's an active session
	var has_session := has_active_session(slot)
	var session_preview := {}
	if has_session:
		session_preview = _get_session_preview(slot)

	return {
		"slot": slot,
		"coins": data.get("coins", 0),
		"runs": data.get("runs", 0),
		"best_wave": data.get("best_wave", 0),
		"highest_stage": data.get("highest_stage", 0),
		"total_playtime": data.get("total_playtime", 0.0),
		"last_played": data.get("last_played", ""),
		"created_at": data.get("created_at", ""),
		"has_active_session": has_session,
		"session": session_preview
	}


func _get_session_preview(slot: int) -> Dictionary:
	"""Get preview info from a session save file."""
	var path := _get_session_path(slot)
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_string := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)
	if not data is Dictionary:
		return {}

	return {
		"character_path": data.get("character_path", ""),
		"current_wave": data.get("current_wave", 1),
		"player_level": data.get("player_level", 1),
		"player_hp": data.get("player_hp", 100),
		"max_hp": data.get("max_hp", 100),
		"current_stage": data.get("current_stage", 0)
	}


func is_slot_empty(slot: int) -> bool:
	"""Check if a slot has no save data."""
	return not FileAccess.file_exists(_get_meta_path(slot))


func are_all_slots_empty() -> bool:
	"""Check if all save slots are empty (new player)."""
	for slot in range(1, SLOT_COUNT + 1):
		if not is_slot_empty(slot):
			return false
	return true


func has_active_session(slot: int = -1) -> bool:
	"""Check if a slot has a mid-run session save."""
	return FileAccess.file_exists(_get_session_path(slot))


func delete_slot(slot: int) -> void:
	"""Delete all data for a slot."""
	if slot < 1 or slot > SLOT_COUNT:
		push_error("Invalid slot number: %d" % slot)
		return

	var meta_path := _get_meta_path(slot)
	var session_path := _get_session_path(slot)

	if FileAccess.file_exists(meta_path):
		DirAccess.remove_absolute(meta_path)
	if FileAccess.file_exists(session_path):
		DirAccess.remove_absolute(session_path)

	# If deleting current slot, reset in-memory data
	if slot == current_slot:
		_reset_slot_data()

	slot_deleted.emit(slot)


func _update_playtime() -> void:
	"""Update total playtime with time since session started."""
	var now := Time.get_unix_time_from_system()
	var session_time := now - _session_start_time
	total_playtime += session_time
	_session_start_time = now


func _save_active_slot() -> void:
	"""Save the currently active slot number."""
	var file := FileAccess.open(ACTIVE_SLOT_PATH, FileAccess.WRITE)
	if file:
		file.store_string(str(current_slot))
		file.close()


func _load_active_slot() -> void:
	"""Load the last used slot number."""
	if not FileAccess.file_exists(ACTIVE_SLOT_PATH):
		current_slot = 1
		return

	var file := FileAccess.open(ACTIVE_SLOT_PATH, FileAccess.READ)
	if file:
		var content := file.get_as_text().strip_edges()
		file.close()
		current_slot = clampi(content.to_int(), 1, SLOT_COUNT)
		if current_slot == 0:
			current_slot = 1


func _migrate_legacy_save() -> void:
	"""Migrate old single-file save to slot 1."""
	if not FileAccess.file_exists(LEGACY_SAVE_PATH):
		return

	# Only migrate if slot 1 is empty
	if FileAccess.file_exists(_get_meta_path(1)):
		# Slot 1 already has data, delete legacy file
		DirAccess.remove_absolute(LEGACY_SAVE_PATH)
		return

	# Copy legacy save to slot 1
	var file := FileAccess.open(LEGACY_SAVE_PATH, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()

		var new_file := FileAccess.open(_get_meta_path(1), FileAccess.WRITE)
		if new_file:
			new_file.store_string(content)
			new_file.close()

		# Delete legacy file after successful migration
		DirAccess.remove_absolute(LEGACY_SAVE_PATH)
		# Migration complete - legacy save data is now in slot 1


# =============================================================================
# SESSION SAVE/LOAD (Mid-run persistence)
# =============================================================================

func save_session(session_data: Dictionary) -> void:
	"""Save mid-run session state."""
	session_data["saved_at"] = Time.get_datetime_string_from_system(true)

	var file := FileAccess.open(_get_session_path(), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(session_data))
		file.close()
		session_saved.emit()


func load_session() -> Dictionary:
	"""Load mid-run session state. Returns empty dict if none exists."""
	var path := _get_session_path()
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_string := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)
	if data is Dictionary:
		session_loaded.emit()
		return data
	return {}


func clear_session() -> void:
	"""Delete the mid-run session save (called on run end)."""
	var path := _get_session_path()
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		session_cleared.emit()


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func format_playtime(seconds: float) -> String:
	"""Format playtime as human-readable string (e.g., '2h 15m')."""
	var total_minutes := int(seconds / 60.0)
	var hours := total_minutes / 60
	var minutes := total_minutes % 60

	if hours > 0:
		return "%dh %dm" % [hours, minutes]
	elif minutes > 0:
		return "%dm" % minutes
	else:
		return "< 1m"


func format_relative_time(iso_timestamp: String) -> String:
	"""Format timestamp as relative time (e.g., '2 days ago')."""
	if iso_timestamp.is_empty():
		return "Never"

	# Parse ISO timestamp
	var datetime := Time.get_datetime_dict_from_datetime_string(iso_timestamp, true)
	if datetime.is_empty():
		return "Unknown"

	var then := Time.get_unix_time_from_datetime_dict(datetime)
	var now := Time.get_unix_time_from_system()
	var diff := now - then

	if diff < 60:
		return "Just now"
	elif diff < 3600:
		var mins := int(diff / 60)
		return "%d min ago" % mins
	elif diff < 86400:
		var hours := int(diff / 3600)
		return "%d hour%s ago" % [hours, "s" if hours > 1 else ""]
	elif diff < 604800:
		var days := int(diff / 86400)
		return "%d day%s ago" % [days, "s" if days > 1 else ""]
	else:
		var weeks := int(diff / 604800)
		return "%d week%s ago" % [weeks, "s" if weeks > 1 else ""]
