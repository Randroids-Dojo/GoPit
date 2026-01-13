class_name PassiveEvolutions
extends RefCounted
## Static data for passive evolutions - permanent unlocks earned by maxing passives during runs

class EvolutionData:
	var id: String
	var name: String
	var description: String
	var icon: String
	var source_passive: int  # FusionRegistry.PassiveType value
	var effect_type: String  # What stat it affects
	var effect_value: float  # How much bonus it provides

	func _init(
		p_id: String,
		p_name: String,
		p_desc: String,
		p_icon: String,
		p_source: int,
		p_effect_type: String,
		p_effect_value: float
	) -> void:
		id = p_id
		name = p_name
		description = p_desc
		icon = p_icon
		source_passive = p_source
		effect_type = p_effect_type
		effect_value = p_effect_value


# All passive evolutions - unlocked by maxing the corresponding passive during a run
# Using int values for PassiveType since we can't reference enum directly in static data
static var EVOLUTIONS: Dictionary = {
	# Original 8 passive evolutions (from first 8 passives)
	"power_mastery": EvolutionData.new(
		"power_mastery",
		"Power Mastery",
		"+1 base damage",
		"💪",
		0,  # PassiveType.DAMAGE
		"damage",
		1.0
	),
	"rapid_mastery": EvolutionData.new(
		"rapid_mastery",
		"Rapid Mastery",
		"-0.02s fire cooldown",
		"⚡",
		1,  # PassiveType.FIRE_RATE
		"fire_rate",
		0.02
	),
	"vitality_mastery": EvolutionData.new(
		"vitality_mastery",
		"Vitality Mastery",
		"+5 max HP",
		"❤️",
		2,  # PassiveType.MAX_HP
		"max_hp",
		5.0
	),
	"multishot_mastery": EvolutionData.new(
		"multishot_mastery",
		"Multishot Mastery",
		"+1 ball per shot",
		"🎯",
		3,  # PassiveType.MULTI_SHOT
		"multi_shot",
		1.0
	),
	"velocity_mastery": EvolutionData.new(
		"velocity_mastery",
		"Velocity Mastery",
		"+20 ball speed",
		"💨",
		4,  # PassiveType.BALL_SPEED
		"ball_speed",
		20.0
	),
	"pierce_mastery": EvolutionData.new(
		"pierce_mastery",
		"Pierce Mastery",
		"+1 enemy pierce",
		"🗡️",
		5,  # PassiveType.PIERCING
		"piercing",
		1.0
	),
	"bounce_mastery": EvolutionData.new(
		"bounce_mastery",
		"Bounce Mastery",
		"+1 wall bounce",
		"↩️",
		6,  # PassiveType.RICOCHET
		"ricochet",
		1.0
	),
	"critical_mastery": EvolutionData.new(
		"critical_mastery",
		"Critical Mastery",
		"+2% crit chance",
		"💀",
		7,  # PassiveType.CRITICAL
		"critical",
		0.02
	)
}


static func get_evolution(evolution_id: String) -> EvolutionData:
	return EVOLUTIONS.get(evolution_id)


static func get_all_evolutions() -> Array[EvolutionData]:
	var result: Array[EvolutionData] = []
	for data in EVOLUTIONS.values():
		result.append(data)
	return result


static func get_evolution_ids() -> Array[String]:
	var result: Array[String] = []
	for key in EVOLUTIONS.keys():
		result.append(key)
	return result


static func get_evolution_for_passive(passive_type: int) -> EvolutionData:
	## Find the evolution that corresponds to a given passive type
	for evolution in EVOLUTIONS.values():
		if evolution.source_passive == passive_type:
			return evolution
	return null


static func get_evolution_id_for_passive(passive_type: int) -> String:
	## Get evolution ID for a given passive type, or empty string if none
	for id in EVOLUTIONS:
		var evolution: EvolutionData = EVOLUTIONS[id]
		if evolution.source_passive == passive_type:
			return id
	return ""
