class_name Character
extends Resource
## Character resource defining stats, starting ball, and passive ability.

@export var character_name: String
@export var portrait: Texture2D
@export_multiline var description: String

## Stat scaling grades - determines how much a stat grows per level
enum StatScaling { S, A, B, C, D, E }

## Scaling multipliers per grade (applied per level)
const SCALING_MULTIPLIERS := {
	StatScaling.S: 0.15,  # +15% per level
	StatScaling.A: 0.12,  # +12% per level
	StatScaling.B: 0.10,  # +10% per level
	StatScaling.C: 0.08,  # +8% per level
	StatScaling.D: 0.05,  # +5% per level
	StatScaling.E: 0.03,  # +3% per level
}

## Stats (relative to 1.0 baseline for multipliers, absolute for base values)
@export_group("Stats")
@export_range(0.5, 2.0, 0.1) var endurance: float = 1.0  ## HP multiplier
@export_range(5, 15, 1) var base_strength: int = 8       ## Base damage value (absolute)
@export var strength_scaling: StatScaling = StatScaling.C  ## Damage growth per level
@export_range(0.5, 2.0, 0.1) var strength: float = 1.0   ## Damage multiplier (legacy, kept for UI)
@export_range(0.5, 2.0, 0.1) var leadership: float = 1.0 ## Baby ball spawn rate
@export_range(0.5, 2.0, 0.1) var speed: float = 1.0      ## Movement speed
@export_range(1, 15, 1) var base_dexterity: int = 5       ## Base dexterity value (absolute)
@export var dexterity_scaling: StatScaling = StatScaling.C  ## Dexterity growth per level
@export_range(0.5, 2.0, 0.1) var dexterity: float = 1.0  ## Dexterity multiplier (legacy, kept for UI)
@export_range(1, 15, 1) var base_intelligence: int = 5       ## Base intelligence value (absolute)
@export var intelligence_scaling: StatScaling = StatScaling.C  ## Intelligence growth per level
@export_range(0.5, 2.0, 0.1) var intelligence: float = 1.0  ## Intelligence multiplier (legacy, kept for UI)
@export_range(1.0, 4.0, 0.5) var base_fire_rate: float = 2.0  ## Base balls per second
@export var fire_rate_scaling: StatScaling = StatScaling.C  ## Fire rate growth per level

@export_group("Abilities")
@export var starting_ball: int = 0  ## BallRegistry.BallType enum value
@export var passive_name: String
@export_multiline var passive_description: String

@export_group("Unlock")
@export var is_unlocked: bool = true
@export var unlock_requirement: String


## Get a stat value by name for UI display
func get_stat(stat_name: String) -> float:
	match stat_name:
		"endurance": return endurance
		"strength": return strength
		"leadership": return leadership
		"speed": return speed
		"dexterity": return dexterity
		"intelligence": return intelligence
		_: return 1.0


## Get all stat names and values as dictionary
func get_all_stats() -> Dictionary:
	return {
		"endurance": endurance,
		"strength": strength,
		"leadership": leadership,
		"speed": speed,
		"dexterity": dexterity,
		"intelligence": intelligence
	}


## Get the display name for a stat
static func get_stat_display_name(stat_name: String) -> String:
	match stat_name:
		"endurance": return "HP"
		"strength": return "DMG"
		"leadership": return "TEAM"
		"speed": return "SPD"
		"dexterity": return "CRIT"
		"intelligence": return "INT"
		_: return stat_name.to_upper()


## Get icon for a stat
static func get_stat_icon(stat_name: String) -> String:
	match stat_name:
		"endurance": return "HP"
		"strength": return "DMG"
		"leadership": return "TEAM"
		"speed": return "SPD"
		"dexterity": return "CRIT"
		"intelligence": return "INT"
		_: return ""


## Calculate strength at a given level based on scaling grade
func get_strength_at_level(level: int) -> int:
	if level <= 1:
		return base_strength
	var scaling_mult: float = SCALING_MULTIPLIERS.get(strength_scaling, 0.08)
	var level_bonus: float = base_strength * scaling_mult * (level - 1)
	return base_strength + int(level_bonus)


## Get the scaling grade as a display string (S/A/B/C/D/E)
func get_strength_scaling_grade() -> String:
	match strength_scaling:
		StatScaling.S: return "S"
		StatScaling.A: return "A"
		StatScaling.B: return "B"
		StatScaling.C: return "C"
		StatScaling.D: return "D"
		StatScaling.E: return "E"
		_: return "?"


## Get scaling description for UI
func get_scaling_description() -> String:
	var grade := get_strength_scaling_grade()
	var mult: float = SCALING_MULTIPLIERS.get(strength_scaling, 0.08)
	var percent := int(mult * 100)
	return "%s (+%d%%/lvl)" % [grade, percent]


## Calculate fire rate at a given level based on scaling grade
func get_fire_rate_at_level(level: int) -> float:
	if level <= 1:
		return base_fire_rate
	var scaling_mult: float = SCALING_MULTIPLIERS.get(fire_rate_scaling, 0.08)
	var level_bonus: float = base_fire_rate * scaling_mult * (level - 1)
	return base_fire_rate + level_bonus


## Get the fire rate scaling grade as a display string (S/A/B/C/D/E)
func get_fire_rate_scaling_grade() -> String:
	match fire_rate_scaling:
		StatScaling.S: return "S"
		StatScaling.A: return "A"
		StatScaling.B: return "B"
		StatScaling.C: return "C"
		StatScaling.D: return "D"
		StatScaling.E: return "E"
		_: return "?"


## Get fire rate scaling description for UI
func get_fire_rate_scaling_description() -> String:
	var grade := get_fire_rate_scaling_grade()
	var mult: float = SCALING_MULTIPLIERS.get(fire_rate_scaling, 0.08)
	var percent := int(mult * 100)
	return "%s (+%d%%/lvl)" % [grade, percent]


## Calculate dexterity at a given level based on scaling grade
func get_dexterity_at_level(level: int) -> int:
	if level <= 1:
		return base_dexterity
	var scaling_mult: float = SCALING_MULTIPLIERS.get(dexterity_scaling, 0.08)
	var level_bonus: float = base_dexterity * scaling_mult * (level - 1)
	return base_dexterity + int(level_bonus)


## Get the dexterity scaling grade as a display string (S/A/B/C/D/E)
func get_dexterity_scaling_grade() -> String:
	match dexterity_scaling:
		StatScaling.S: return "S"
		StatScaling.A: return "A"
		StatScaling.B: return "B"
		StatScaling.C: return "C"
		StatScaling.D: return "D"
		StatScaling.E: return "E"
		_: return "?"


## Get dexterity scaling description for UI
func get_dexterity_scaling_description() -> String:
	var grade := get_dexterity_scaling_grade()
	var mult: float = SCALING_MULTIPLIERS.get(dexterity_scaling, 0.08)
	var percent := int(mult * 100)
	return "%s (+%d%%/lvl)" % [grade, percent]


## Get crit chance from dexterity (2% per point)
func get_crit_chance_from_dexterity(level: int) -> float:
	var dex := get_dexterity_at_level(level)
	return dex * 0.02  # 2% crit chance per dexterity point


## Get fire rate multiplier from dexterity (5% per point above 5)
func get_fire_rate_mult_from_dexterity(level: int) -> float:
	var dex := get_dexterity_at_level(level)
	# Base fire rate is at dexterity 5, each point above adds 5%
	return 1.0 + (dex - 5) * 0.05


## Calculate intelligence at a given level based on scaling grade
func get_intelligence_at_level(level: int) -> int:
	if level <= 1:
		return base_intelligence
	var scaling_mult: float = SCALING_MULTIPLIERS.get(intelligence_scaling, 0.08)
	var level_bonus: float = base_intelligence * scaling_mult * (level - 1)
	return base_intelligence + int(level_bonus)


## Get the intelligence scaling grade as a display string (S/A/B/C/D/E)
func get_intelligence_scaling_grade() -> String:
	match intelligence_scaling:
		StatScaling.S: return "S"
		StatScaling.A: return "A"
		StatScaling.B: return "B"
		StatScaling.C: return "C"
		StatScaling.D: return "D"
		StatScaling.E: return "E"
		_: return "?"


## Get intelligence scaling description for UI
func get_intelligence_scaling_description() -> String:
	var grade := get_intelligence_scaling_grade()
	var mult: float = SCALING_MULTIPLIERS.get(intelligence_scaling, 0.08)
	var percent := int(mult * 100)
	return "%s (+%d%%/lvl)" % [grade, percent]


## Get status effect duration multiplier from intelligence (10% per point)
func get_status_duration_mult_from_intelligence(level: int) -> float:
	var intel := get_intelligence_at_level(level)
	# Base duration at intelligence 5, each point adds 10%
	return 1.0 + (intel - 5) * 0.10


## Get status effect damage multiplier from intelligence (5% per point)
func get_status_damage_mult_from_intelligence(level: int) -> float:
	var intel := get_intelligence_at_level(level)
	# Base damage at intelligence 5, each point adds 5%
	return 1.0 + (intel - 5) * 0.05
