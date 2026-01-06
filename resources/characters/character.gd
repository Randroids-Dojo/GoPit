class_name Character
extends Resource
## Character resource defining stats, starting ball, and passive ability.

@export var character_name: String
@export var portrait: Texture2D
@export_multiline var description: String

## Stats (relative to 1.0 baseline)
@export_group("Stats")
@export_range(0.5, 2.0, 0.1) var endurance: float = 1.0  ## HP multiplier
@export_range(0.5, 2.0, 0.1) var strength: float = 1.0   ## Damage multiplier
@export_range(0.5, 2.0, 0.1) var leadership: float = 1.0 ## Baby ball spawn rate
@export_range(0.5, 2.0, 0.1) var speed: float = 1.0      ## Movement speed
@export_range(0.5, 2.0, 0.1) var dexterity: float = 1.0  ## Crit chance multiplier
@export_range(0.5, 2.0, 0.1) var intelligence: float = 1.0  ## Effect duration multiplier

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
