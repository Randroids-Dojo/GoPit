class_name PermanentUpgrades
extends RefCounted
## Static data for permanent upgrades purchasable with Pit Coins

class UpgradeData:
	var id: String
	var name: String
	var description: String
	var icon: String  # Emoji or icon path
	var base_cost: int
	var cost_multiplier: float  # Cost scales: base_cost * (multiplier ^ level)
	var max_level: int
	var effect_per_level: String

	func _init(
		p_id: String,
		p_name: String,
		p_desc: String,
		p_icon: String,
		p_base: int,
		p_mult: float,
		p_max: int,
		p_effect: String
	) -> void:
		id = p_id
		name = p_name
		description = p_desc
		icon = p_icon
		base_cost = p_base
		cost_multiplier = p_mult
		max_level = p_max
		effect_per_level = p_effect

	func get_cost(current_level: int) -> int:
		if current_level >= max_level:
			return -1  # Maxed out
		return int(base_cost * pow(cost_multiplier, current_level))

	func get_effect_text(current_level: int) -> String:
		return effect_per_level % [current_level]


# All available upgrades
static var UPGRADES: Dictionary = {
	"hp": UpgradeData.new(
		"hp",
		"Pit Armor",
		"Increase starting HP",
		"🛡️",
		100,
		2.0,  # 100, 200, 400, 800, 1600
		5,
		"+%d0 HP"
	),
	"damage": UpgradeData.new(
		"damage",
		"Ball Power",
		"Increase ball damage",
		"💥",
		150,
		2.0,  # 150, 300, 600, 1200, 2400
		5,
		"+%d damage per hit"
	),
	"fire_rate": UpgradeData.new(
		"fire_rate",
		"Rapid Fire",
		"Decrease fire cooldown",
		"⚡",
		200,
		2.0,  # 200, 400, 800, 1600, 3200
		5,
		"-%d.0%ds cooldown"
	),
	"coin_bonus": UpgradeData.new(
		"coin_bonus",
		"Coin Magnet",
		"Earn more Pit Coins per run",
		"🪙",
		250,
		2.5,  # 250, 625, 1562, 3906
		4,
		"+%d0%% coins"
	),
	"starting_level": UpgradeData.new(
		"starting_level",
		"Head Start",
		"Start at higher level",
		"🚀",
		500,
		3.0,  # 500, 1500, 4500
		3,
		"Start at level %d"
	),
	"xp_gain": UpgradeData.new(
		"xp_gain",
		"Veteran's Hut",
		"Increase XP from all sources",
		"📚",
		200,
		2.0,  # 200, 400, 800, 1600, 3200
		5,
		"+5%% XP per level"
	),
	"early_xp": UpgradeData.new(
		"early_xp",
		"Abbey",
		"Bonus XP for early levels",
		"⛪",
		300,
		2.5,  # 300, 750, 1875
		3,
		"+10%% XP (lvl 1-5)"
	),
	# Stat buildings (BallxPit style: +1 flat stat per level)
	"strength": UpgradeData.new(
		"strength",
		"Barracks",
		"Train soldiers to hit harder",
		"⚔️",
		150,
		2.0,  # 150, 300, 600, 1200, 2400
		5,
		"+%d Strength"
	),
	"dexterity": UpgradeData.new(
		"dexterity",
		"Gunsmith",
		"Precision tools for faster firing",
		"🎯",
		150,
		2.0,  # 150, 300, 600, 1200, 2400
		5,
		"+%d Dexterity"
	),
	"intelligence": UpgradeData.new(
		"intelligence",
		"Schoolhouse",
		"Knowledge amplifies your effects",
		"📖",
		150,
		2.0,  # 150, 300, 600, 1200, 2400
		5,
		"+%d Intelligence"
	),
	"leadership": UpgradeData.new(
		"leadership",
		"Consulate",
		"Command a larger baby ball army",
		"👑",
		150,
		2.0,  # 150, 300, 600, 1200, 2400
		5,
		"+%d Leadership"
	)
}


static func get_upgrade(upgrade_id: String) -> UpgradeData:
	return UPGRADES.get(upgrade_id)


static func get_all_upgrades() -> Array[UpgradeData]:
	var result: Array[UpgradeData] = []
	for data in UPGRADES.values():
		result.append(data)
	return result


static func get_upgrade_ids() -> Array[String]:
	var result: Array[String] = []
	for key in UPGRADES.keys():
		result.append(key)
	return result
