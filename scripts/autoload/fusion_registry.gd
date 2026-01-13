extends Node
## Fusion Registry - handles ball fusion and evolution recipes
## Evolution: Specific recipe -> unique named ball (can further evolve)
## Fusion: Any two L3 balls -> combined ball (cannot further evolve)

signal evolution_completed(evolved_type: EvolvedBallType)
signal fusion_completed(fused_ball_id: String)

# Evolved ball types from specific recipes
enum EvolvedBallType {
	NONE,
	BOMB,      # Burn + Iron
	BLIZZARD,  # Freeze + Lightning
	VIRUS,     # Poison + Bleed
	MAGMA,     # Burn + Poison
	VOID,      # Burn + Freeze
	# New evolutions (added to reach 10 total)
	GLACIER,   # Freeze + Iron - Heavy ice shards that pierce
	STORM,     # Lightning + Poison - Chains spread poison
	PLASMA,    # Lightning + Bleed - Chains cause bleed
	CLEAVER,   # Bleed + Iron - Massive bleed on heavy hits
	FROSTBITE  # Freeze + Bleed - Frozen enemies bleed when thawed
}

# Recipe definitions: sorted [BallType, BallType] -> EvolvedBallType
const EVOLUTION_RECIPES := {
	# Key format: alphabetically sorted [Name_Name] to ensure consistent lookup
	"BURN_IRON": EvolvedBallType.BOMB,
	"FREEZE_LIGHTNING": EvolvedBallType.BLIZZARD,
	"BLEED_POISON": EvolvedBallType.VIRUS,  # Alphabetically: BLEED < POISON
	"BURN_POISON": EvolvedBallType.MAGMA,
	"BURN_FREEZE": EvolvedBallType.VOID,
	# New recipes (5 more to reach 10 total)
	"FREEZE_IRON": EvolvedBallType.GLACIER,
	"LIGHTNING_POISON": EvolvedBallType.STORM,
	"BLEED_LIGHTNING": EvolvedBallType.PLASMA,
	"BLEED_IRON": EvolvedBallType.CLEAVER,
	"BLEED_FREEZE": EvolvedBallType.FROSTBITE
}

# Evolved ball stats and effects
const EVOLVED_BALL_DATA := {
	EvolvedBallType.BOMB: {
		"name": "Bomb",
		"description": "Explodes on hit, dealing AoE damage",
		"base_damage": 20,
		"base_speed": 700.0,
		"color": Color(1.0, 0.3, 0.0),  # Bright orange-red
		"effect": "explosion",
		"aoe_radius": 100.0,
		"aoe_damage_mult": 1.5
	},
	EvolvedBallType.BLIZZARD: {
		"name": "Blizzard",
		"description": "Freezes and chains to nearby enemies",
		"base_damage": 15,
		"base_speed": 850.0,
		"color": Color(0.7, 0.9, 1.0),  # Ice blue
		"effect": "blizzard",
		"chain_count": 3,
		"freeze_duration": 2.0
	},
	EvolvedBallType.VIRUS: {
		"name": "Virus",
		"description": "Spreading DoT with lifesteal",
		"base_damage": 12,
		"base_speed": 800.0,
		"color": Color(0.6, 0.1, 0.6),  # Dark purple
		"effect": "virus",
		"spread_radius": 80.0,
		"lifesteal": 0.2
	},
	EvolvedBallType.MAGMA: {
		"name": "Magma",
		"description": "Leaves burning pools on the ground",
		"base_damage": 14,
		"base_speed": 750.0,
		"color": Color(1.0, 0.4, 0.0),  # Magma orange
		"effect": "magma_pool",
		"pool_duration": 3.0,
		"pool_dps": 5
	},
	EvolvedBallType.VOID: {
		"name": "Void",
		"description": "Alternates between burn and freeze",
		"base_damage": 16,
		"base_speed": 850.0,
		"color": Color(0.3, 0.0, 0.5),  # Deep purple
		"effect": "void",
		"alternating_effects": ["burn", "freeze"]
	},
	# New evolved balls (5 more to reach 10 total)
	EvolvedBallType.GLACIER: {
		"name": "Glacier",
		"description": "Heavy ice shards that pierce and slow",
		"base_damage": 22,
		"base_speed": 600.0,  # Slower but hits harder
		"color": Color(0.5, 0.7, 0.9),  # Steel blue
		"effect": "glacier",
		"pierce_count": 3,
		"slow_duration": 2.5
	},
	EvolvedBallType.STORM: {
		"name": "Storm",
		"description": "Lightning chains spread poison to all hit",
		"base_damage": 14,
		"base_speed": 900.0,
		"color": Color(0.4, 0.8, 0.3),  # Electric green
		"effect": "storm",
		"chain_count": 4,
		"poison_duration": 3.0
	},
	EvolvedBallType.PLASMA: {
		"name": "Plasma",
		"description": "Chains to enemies and applies bleed stacks",
		"base_damage": 13,
		"base_speed": 950.0,
		"color": Color(1.0, 0.2, 0.5),  # Hot pink
		"effect": "plasma",
		"chain_count": 3,
		"bleed_stacks": 2
	},
	EvolvedBallType.CLEAVER: {
		"name": "Cleaver",
		"description": "Heavy hits that cause massive bleed",
		"base_damage": 25,
		"base_speed": 550.0,  # Slow but devastating
		"color": Color(0.5, 0.1, 0.1),  # Dark red
		"effect": "cleaver",
		"bleed_stacks": 5,
		"knockback": 60.0
	},
	EvolvedBallType.FROSTBITE: {
		"name": "Frostbite",
		"description": "Freezes enemies; they bleed when thawed",
		"base_damage": 15,
		"base_speed": 800.0,
		"color": Color(0.6, 0.2, 0.4),  # Frozen purple
		"effect": "frostbite",
		"freeze_duration": 1.5,
		"thaw_bleed_stacks": 3
	}
}

# Owned evolved balls for current run
var owned_evolved_balls: Dictionary = {}  # EvolvedBallType -> true

# Owned fused balls for current run (generic fusions)
# Key: "TYPE1_TYPE2" (sorted), Value: { "name": "...", "effects": [...], ... }
var owned_fused_balls: Dictionary = {}

# Currently active evolved/fused ball (if any)
var active_evolved_type: EvolvedBallType = EvolvedBallType.NONE
var active_fused_id: String = ""


func _ready() -> void:
	_init_passive_slots()  # Initialize slots on startup
	GameManager.game_started.connect(_reset_for_new_run)


func _reset_for_new_run() -> void:
	reset()


func reset() -> void:
	"""Reset the registry to initial state (for new runs and tests)"""
	owned_evolved_balls.clear()
	owned_fused_balls.clear()
	active_evolved_type = EvolvedBallType.NONE
	active_fused_id = ""
	_init_passive_slots()


# ===== EVOLUTION (Specific Recipes) =====

func get_recipe_key(ball_a: BallRegistry.BallType, ball_b: BallRegistry.BallType) -> String:
	"""Generate consistent recipe key from two ball types"""
	var name_a: String = BallRegistry.BallType.keys()[ball_a]
	var name_b: String = BallRegistry.BallType.keys()[ball_b]
	# Sort alphabetically for consistent key
	if name_a > name_b:
		var temp: String = name_a
		name_a = name_b
		name_b = temp
	return name_a + "_" + name_b


func has_evolution_recipe(ball_a: BallRegistry.BallType, ball_b: BallRegistry.BallType) -> bool:
	"""Check if two ball types have a specific evolution recipe"""
	var key := get_recipe_key(ball_a, ball_b)
	return key in EVOLUTION_RECIPES


func get_evolution_result(ball_a: BallRegistry.BallType, ball_b: BallRegistry.BallType) -> EvolvedBallType:
	"""Get the evolved ball type from a recipe (NONE if no recipe)"""
	var key := get_recipe_key(ball_a, ball_b)
	return EVOLUTION_RECIPES.get(key, EvolvedBallType.NONE)


func get_available_evolutions() -> Array[Dictionary]:
	"""Get all evolutions that can be created with current L3 balls"""
	var available: Array[Dictionary] = []
	var fusion_ready := BallRegistry.get_fusion_ready_balls()

	for key in EVOLUTION_RECIPES:
		var parts: PackedStringArray = key.split("_")
		if parts.size() != 2:
			continue

		var type_a: int = -1
		var type_b: int = -1

		# Convert string names back to enum values
		for ball_type in BallRegistry.BallType.values():
			var type_name: String = BallRegistry.BallType.keys()[ball_type]
			if type_name == parts[0]:
				type_a = ball_type
			elif type_name == parts[1]:
				type_b = ball_type

		if type_a == -1 or type_b == -1:
			continue

		# Check if both balls are fusion-ready
		var has_a := type_a in fusion_ready
		var has_b := type_b in fusion_ready

		available.append({
			"recipe_key": key,
			"ball_a": type_a,
			"ball_b": type_b,
			"result": EVOLUTION_RECIPES[key],
			"can_create": has_a and has_b,
			"has_ball_a": has_a,
			"has_ball_b": has_b
		})

	return available


func evolve_balls(ball_a: BallRegistry.BallType, ball_b: BallRegistry.BallType) -> EvolvedBallType:
	"""Evolve two L3 balls into an evolved ball. Returns NONE if invalid."""
	var result := get_evolution_result(ball_a, ball_b)
	if result == EvolvedBallType.NONE:
		return EvolvedBallType.NONE

	# Check both balls are L3
	if not BallRegistry.is_fusion_ready(ball_a) or not BallRegistry.is_fusion_ready(ball_b):
		return EvolvedBallType.NONE

	# Consume the balls from registry
	BallRegistry.owned_balls.erase(ball_a)
	BallRegistry.owned_balls.erase(ball_b)

	# Add evolved ball
	owned_evolved_balls[result] = true
	active_evolved_type = result

	evolution_completed.emit(result)
	return result


# ===== GENERIC FUSION (Any Two L3 Balls) =====

func get_fused_ball_id(ball_a: BallRegistry.BallType, ball_b: BallRegistry.BallType) -> String:
	"""Generate consistent ID for a fused ball"""
	return get_recipe_key(ball_a, ball_b)


func create_fused_ball_data(ball_a: BallRegistry.BallType, ball_b: BallRegistry.BallType) -> Dictionary:
	"""Create data for a generic fused ball (not a recipe evolution)"""
	var data_a: Dictionary = BallRegistry.BALL_DATA.get(ball_a, {})
	var data_b: Dictionary = BallRegistry.BALL_DATA.get(ball_b, {})

	var name_a: String = data_a.get("name", "Unknown")
	var name_b: String = data_b.get("name", "Unknown")

	# Combine colors
	var color_a: Color = data_a.get("color", Color.WHITE)
	var color_b: Color = data_b.get("color", Color.WHITE)
	var combined_color := color_a.lerp(color_b, 0.5)

	# Average stats with small bonus
	var damage_a: int = data_a.get("base_damage", 10)
	var damage_b: int = data_b.get("base_damage", 10)
	var speed_a: float = data_a.get("base_speed", 800.0)
	var speed_b: float = data_b.get("base_speed", 800.0)

	return {
		"name": name_a + " " + name_b,
		"description": "Combined " + name_a.to_lower() + " and " + name_b.to_lower() + " effects",
		"base_damage": int((damage_a + damage_b) / 2.0 * 1.1),  # 10% bonus
		"base_speed": (speed_a + speed_b) / 2.0,
		"color": combined_color,
		"effects": [data_a.get("effect", "none"), data_b.get("effect", "none")],
		"source_balls": [ball_a, ball_b],
		"is_fused": true,
		"can_evolve": false  # Fused balls cannot further evolve
	}


func fuse_balls(ball_a: BallRegistry.BallType, ball_b: BallRegistry.BallType) -> String:
	"""Fuse two L3 balls into a combined ball. Returns fused ball ID or empty string."""
	# Don't allow fusion if there's a specific recipe
	if has_evolution_recipe(ball_a, ball_b):
		return ""

	# Check both balls are L3
	if not BallRegistry.is_fusion_ready(ball_a) or not BallRegistry.is_fusion_ready(ball_b):
		return ""

	var fused_id := get_fused_ball_id(ball_a, ball_b)

	# Consume the balls from registry
	BallRegistry.owned_balls.erase(ball_a)
	BallRegistry.owned_balls.erase(ball_b)

	# Create and store fused ball data
	owned_fused_balls[fused_id] = create_fused_ball_data(ball_a, ball_b)
	active_fused_id = fused_id

	fusion_completed.emit(fused_id)
	return fused_id


# ===== ACCESSORS =====

func get_evolved_ball_data(evolved_type: EvolvedBallType) -> Dictionary:
	"""Get data for an evolved ball type"""
	return EVOLVED_BALL_DATA.get(evolved_type, {})


func get_evolved_ball_name(evolved_type: EvolvedBallType) -> String:
	"""Get display name for an evolved ball"""
	var data := get_evolved_ball_data(evolved_type)
	return data.get("name", "Unknown")


func get_evolved_ball_color(evolved_type: EvolvedBallType) -> Color:
	"""Get color for an evolved ball"""
	var data := get_evolved_ball_data(evolved_type)
	return data.get("color", Color.WHITE)


func get_fused_ball_data(fused_id: String) -> Dictionary:
	"""Get data for a fused ball"""
	return owned_fused_balls.get(fused_id, {})


func has_any_evolved_or_fused() -> bool:
	"""Check if player has any evolved or fused balls"""
	return owned_evolved_balls.size() > 0 or owned_fused_balls.size() > 0


func get_all_evolved_types() -> Array[EvolvedBallType]:
	"""Get all owned evolved ball types"""
	var types: Array[EvolvedBallType] = []
	for evolved_type in owned_evolved_balls:
		types.append(evolved_type)
	return types


func get_all_fused_ids() -> Array[String]:
	"""Get all owned fused ball IDs"""
	var ids: Array[String] = []
	for fused_id in owned_fused_balls:
		ids.append(fused_id)
	return ids


# ===== FISSION (Random Upgrades) =====

func apply_fission() -> Dictionary:
	"""Apply fission effect - random upgrades (balls AND passives) or Pit Coins if all maxed"""
	var result := {
		"type": "fission",
		"upgrades": [],
		"pit_coins": 0
	}

	# Check what can be upgraded
	var upgradeable := BallRegistry.get_upgradeable_balls()
	var unowned := BallRegistry.get_unowned_ball_types()
	var available_passives := get_available_passives()

	var has_ball_upgrades := upgradeable.size() > 0 or unowned.size() > 0
	var has_passive_upgrades := available_passives.size() > 0

	if not has_ball_upgrades and not has_passive_upgrades:
		# All maxed - give Pit Coins (meta currency)
		var coin_bonus := 50 + GameManager.current_wave * 5
		MetaManager.pit_coins += coin_bonus
		MetaManager.coins_changed.emit(MetaManager.pit_coins)
		result["pit_coins"] = coin_bonus
		return result

	# Random number of upgrades (1-5, matching BallxPit)
	var num_upgrades := randi_range(1, 5)

	for i in num_upgrades:
		# Refresh available passives list each iteration
		available_passives = get_available_passives()
		has_passive_upgrades = available_passives.size() > 0

		# 40% chance for passive upgrade if available, 60% chance for ball upgrade
		var roll := randf()
		if has_passive_upgrades and (not has_ball_upgrades or roll < 0.4):
			# Apply random passive upgrade
			var passive_type: PassiveType = available_passives.pick_random()
			apply_passive(passive_type)
			result["upgrades"].append({"action": "passive", "passive_type": passive_type})
		elif upgradeable.size() > 0 and (unowned.size() == 0 or randf() < 0.6):
			# Level up owned ball
			var ball_type: BallRegistry.BallType = upgradeable.pick_random()
			BallRegistry.level_up_ball(ball_type)
			result["upgrades"].append({"action": "level_up", "ball_type": ball_type})
			# Remove from upgradeable if now maxed
			if BallRegistry.get_ball_level(ball_type) >= 3:
				upgradeable.erase(ball_type)
		elif unowned.size() > 0:
			# Add new ball
			var ball_type: BallRegistry.BallType = unowned.pick_random()
			BallRegistry.add_ball(ball_type)
			result["upgrades"].append({"action": "new_ball", "ball_type": ball_type})
			unowned.erase(ball_type)
			# Add to upgradeable since it starts at L1
			upgradeable.append(ball_type)

		# Update ball upgrade availability
		has_ball_upgrades = upgradeable.size() > 0 or unowned.size() > 0

	return result


# ===== PASSIVE UPGRADES (for Fission) =====

enum PassiveType {
	# Original 10 passives
	DAMAGE,
	FIRE_RATE,
	MAX_HP,
	MULTI_SHOT,
	BALL_SPEED,
	PIERCING,
	RICOCHET,
	CRITICAL,
	MAGNETISM,
	LEADERSHIP,
	# New 10 passives (20 total)
	ARMOR,
	THORNS,
	HEALTH_REGEN,
	DOUBLE_XP,
	KNOCKBACK,
	AREA_DAMAGE,
	STATUS_DURATION,
	DODGE,
	LIFE_STEAL,
	SPREAD_SHOT
}

const PASSIVE_DATA := {
	PassiveType.DAMAGE: {
		"name": "Power Up",
		"description": "+5 Ball Damage",
		"max_stacks": 10
	},
	PassiveType.FIRE_RATE: {
		"name": "Quick Fire",
		"description": "-0.1s Cooldown",
		"max_stacks": 4
	},
	PassiveType.MAX_HP: {
		"name": "Vitality",
		"description": "+25 Max HP",
		"max_stacks": 10
	},
	PassiveType.MULTI_SHOT: {
		"name": "Multi Shot",
		"description": "+1 Ball per shot",
		"max_stacks": 3
	},
	PassiveType.BALL_SPEED: {
		"name": "Velocity",
		"description": "+100 Ball Speed",
		"max_stacks": 5
	},
	PassiveType.PIERCING: {
		"name": "Piercing",
		"description": "Pierce +1 enemy",
		"max_stacks": 3
	},
	PassiveType.RICOCHET: {
		"name": "Ricochet",
		"description": "+5 wall bounces",
		"max_stacks": 4
	},
	PassiveType.CRITICAL: {
		"name": "Critical Hit",
		"description": "+10% crit chance",
		"max_stacks": 5
	},
	PassiveType.MAGNETISM: {
		"name": "Magnetism",
		"description": "Gems attracted",
		"max_stacks": 3
	},
	PassiveType.LEADERSHIP: {
		"name": "Leadership",
		"description": "+20% Baby Ball rate",
		"max_stacks": 5
	},
	# New 10 passives
	PassiveType.ARMOR: {
		"name": "Armor",
		"description": "-5% damage taken",
		"max_stacks": 5
	},
	PassiveType.THORNS: {
		"name": "Thorns",
		"description": "Reflect 10% damage",
		"max_stacks": 3
	},
	PassiveType.HEALTH_REGEN: {
		"name": "Regeneration",
		"description": "+1 HP/second",
		"max_stacks": 5
	},
	PassiveType.DOUBLE_XP: {
		"name": "Wisdom",
		"description": "+25% XP gain",
		"max_stacks": 4
	},
	PassiveType.KNOCKBACK: {
		"name": "Force",
		"description": "+50% knockback",
		"max_stacks": 3
	},
	PassiveType.AREA_DAMAGE: {
		"name": "Blast Radius",
		"description": "+20% AoE size",
		"max_stacks": 5
	},
	PassiveType.STATUS_DURATION: {
		"name": "Lingering",
		"description": "+25% status duration",
		"max_stacks": 4
	},
	PassiveType.DODGE: {
		"name": "Evasion",
		"description": "+5% dodge chance",
		"max_stacks": 5
	},
	PassiveType.LIFE_STEAL: {
		"name": "Vampirism",
		"description": "Heal 3% damage dealt",
		"max_stacks": 5
	},
	PassiveType.SPREAD_SHOT: {
		"name": "Scatter",
		"description": "+10° spread angle",
		"max_stacks": 3
	}
}

# =============================================================================
# PASSIVE SLOT SYSTEM (4 slots with levels L1-L3)
# =============================================================================

const MAX_PASSIVE_SLOTS: int = 4
const MAX_PASSIVE_LEVEL: int = 3

# Each slot: {"type": PassiveType or -1 for empty, "level": 0-3}
var passive_slots: Array[Dictionary] = []

signal passive_slots_changed()


func _init_passive_slots() -> void:
	"""Initialize empty passive slots"""
	passive_slots.clear()
	for i in MAX_PASSIVE_SLOTS:
		passive_slots.append({"type": -1, "level": 0})


func get_passive_stacks(passive_type: PassiveType) -> int:
	"""Get current level of a passive (returns 0 if not equipped)
	Note: 'stacks' is legacy naming, now represents level (1-3)"""
	for slot in passive_slots:
		if slot["type"] == passive_type:
			return slot["level"]
	return 0


func get_passive_slot_index(passive_type: PassiveType) -> int:
	"""Get the slot index where a passive is equipped, or -1 if not found"""
	for i in MAX_PASSIVE_SLOTS:
		if passive_slots[i]["type"] == passive_type:
			return i
	return -1


func get_passive_max_stacks(_passive_type: PassiveType) -> int:
	"""Get max level for a passive (always 3 in slot system)"""
	return MAX_PASSIVE_LEVEL


func get_passive_name(passive_type: PassiveType) -> String:
	"""Get display name for a passive"""
	return PASSIVE_DATA.get(passive_type, {}).get("name", "Unknown")


func get_passive_description(passive_type: PassiveType) -> String:
	"""Get description for a passive"""
	return PASSIVE_DATA.get(passive_type, {}).get("description", "")


func get_equipped_passives() -> Array[Dictionary]:
	"""Get all equipped passives with their slot index and level"""
	var equipped: Array[Dictionary] = []
	for i in MAX_PASSIVE_SLOTS:
		if passive_slots[i]["type"] != -1:
			equipped.append({
				"slot": i,
				"type": passive_slots[i]["type"],
				"level": passive_slots[i]["level"]
			})
	return equipped


func get_empty_slot_count() -> int:
	"""Get number of empty passive slots"""
	var count: int = 0
	for slot in passive_slots:
		if slot["type"] == -1:
			count += 1
	return count


func has_empty_slot() -> bool:
	"""Check if there's an empty passive slot"""
	for slot in passive_slots:
		if slot["type"] == -1:
			return true
	return false


func get_available_passives() -> Array[PassiveType]:
	"""Get passives that can be upgraded (not at L3) or newly equipped (if slots available)"""
	var available: Array[PassiveType] = []
	var has_empty: bool = has_empty_slot()

	for passive_type in PASSIVE_DATA:
		var current_level: int = get_passive_stacks(passive_type)

		if current_level == 0:
			# Not equipped - available only if there's an empty slot
			if has_empty:
				available.append(passive_type)
		elif current_level < MAX_PASSIVE_LEVEL:
			# Equipped but can be leveled up
			available.append(passive_type)
		# If current_level >= MAX_PASSIVE_LEVEL, not available

	return available


func apply_passive(passive_type: PassiveType) -> bool:
	"""Apply a passive upgrade. Either equips to empty slot at L1 or levels up existing."""
	var current_level: int = get_passive_stacks(passive_type)

	if current_level == 0:
		# Not equipped - try to fill an empty slot
		for i in MAX_PASSIVE_SLOTS:
			if passive_slots[i]["type"] == -1:
				passive_slots[i] = {"type": passive_type, "level": 1}
				_apply_passive_effect(passive_type)
				passive_slots_changed.emit()
				return true
		return false  # No empty slots
	elif current_level < MAX_PASSIVE_LEVEL:
		# Already equipped - level it up
		var slot_idx: int = get_passive_slot_index(passive_type)
		if slot_idx >= 0:
			passive_slots[slot_idx]["level"] += 1
			var new_level: int = passive_slots[slot_idx]["level"]
			_apply_passive_effect(passive_type)
			passive_slots_changed.emit()

			# Check if passive reached L3 - trigger passive evolution unlock
			if new_level >= MAX_PASSIVE_LEVEL:
				_try_unlock_passive_evolution(passive_type)

			return true

	return false  # Already at max level


func _try_unlock_passive_evolution(passive_type: PassiveType) -> void:
	"""Try to unlock a passive evolution when a passive reaches L3."""
	var evolution_id := MetaManager.try_unlock_evolution_for_passive(passive_type)
	if not evolution_id.is_empty():
		# Emit signal for UI notification
		var evolution_data: PassiveEvolutions.EvolutionData = PassiveEvolutions.get_evolution(evolution_id)
		if evolution_data:
			print("Passive Evolution Unlocked: %s!" % evolution_data.name)


func _apply_passive_effect(passive_type: PassiveType) -> void:
	"""Apply the actual effect of a passive upgrade"""
	match passive_type:
		PassiveType.DAMAGE:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("increase_damage"):
				ball_spawner.increase_damage(5)
		PassiveType.FIRE_RATE:
			var fire_button := _get_fire_button()
			if fire_button and "cooldown_duration" in fire_button:
				fire_button.cooldown_duration = maxf(0.1, fire_button.cooldown_duration - 0.1)
		PassiveType.MAX_HP:
			GameManager.max_hp += 25
			GameManager.heal(25)
		PassiveType.MULTI_SHOT:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("add_multi_shot"):
				ball_spawner.add_multi_shot()
		PassiveType.BALL_SPEED:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("increase_speed"):
				ball_spawner.increase_speed(100)
		PassiveType.PIERCING:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("add_piercing"):
				ball_spawner.add_piercing(1)
		PassiveType.RICOCHET:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("add_ricochet"):
				ball_spawner.add_ricochet(5)
		PassiveType.CRITICAL:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("add_crit_chance"):
				ball_spawner.add_crit_chance(0.1)
		PassiveType.MAGNETISM:
			GameManager.gem_magnetism_range += 200.0
		PassiveType.LEADERSHIP:
			GameManager.add_leadership(0.2)
		# New passives
		PassiveType.ARMOR:
			GameManager.armor_percent += 0.05  # 5% damage reduction per level
		PassiveType.THORNS:
			GameManager.thorns_percent += 0.10  # 10% reflect per level
		PassiveType.HEALTH_REGEN:
			GameManager.health_regen += 1.0  # 1 HP/sec per level
		PassiveType.DOUBLE_XP:
			GameManager.xp_multiplier += 0.25  # 25% more XP per level
		PassiveType.KNOCKBACK:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("add_knockback"):
				ball_spawner.add_knockback(0.5)  # 50% per level
		PassiveType.AREA_DAMAGE:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("add_aoe_size"):
				ball_spawner.add_aoe_size(0.2)  # 20% per level
		PassiveType.STATUS_DURATION:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("add_status_duration"):
				ball_spawner.add_status_duration(0.25)  # 25% per level
		PassiveType.DODGE:
			GameManager.dodge_chance += 0.05  # 5% per level
		PassiveType.LIFE_STEAL:
			GameManager.life_steal_percent += 0.03  # 3% per level
		PassiveType.SPREAD_SHOT:
			var ball_spawner := _get_ball_spawner()
			if ball_spawner and ball_spawner.has_method("add_spread_angle"):
				ball_spawner.add_spread_angle(10.0)  # 10 degrees per level


func _get_ball_spawner() -> Node:
	"""Get ball spawner node from tree"""
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		return tree.get_first_node_in_group("ball_spawner")
	return null


func _get_fire_button() -> Node:
	"""Get fire button node from tree"""
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		return tree.get_first_node_in_group("fire_button")
	return null


# =============================================================================
# SESSION STATE CAPTURE/RESTORE (for mid-run saves)
# =============================================================================

func get_session_state() -> Dictionary:
	"""Capture current fusion registry state for session save."""
	# Convert evolved balls keys to strings for JSON compatibility
	var evolved_balls_json := {}
	for evolved_type in owned_evolved_balls:
		evolved_balls_json[str(evolved_type)] = owned_evolved_balls[evolved_type]

	# Passive slots need to convert enum to int for JSON
	var passive_slots_json: Array[Dictionary] = []
	for slot in passive_slots:
		passive_slots_json.append({
			"type": slot["type"],
			"level": slot["level"]
		})

	return {
		"owned_evolved_balls": evolved_balls_json,
		"owned_fused_balls": owned_fused_balls.duplicate(true),
		"active_evolved_type": active_evolved_type,
		"active_fused_id": active_fused_id,
		"passive_slots": passive_slots_json
	}


func restore_session_state(data: Dictionary) -> void:
	"""Restore fusion registry state from session save."""
	# Clear current state
	owned_evolved_balls.clear()
	owned_fused_balls.clear()
	_init_passive_slots()

	# Restore evolved balls (convert string keys back to int)
	var saved_evolved: Dictionary = data.get("owned_evolved_balls", {})
	for evolved_type_str in saved_evolved:
		var evolved_type: int = int(evolved_type_str)
		owned_evolved_balls[evolved_type] = saved_evolved[evolved_type_str]

	# Restore fused balls
	owned_fused_balls = data.get("owned_fused_balls", {}).duplicate(true)

	# Restore active selections
	active_evolved_type = data.get("active_evolved_type", EvolvedBallType.NONE) as EvolvedBallType
	active_fused_id = data.get("active_fused_id", "")

	# Restore passive slots
	var saved_slots: Array = data.get("passive_slots", [])
	for i in range(mini(saved_slots.size(), MAX_PASSIVE_SLOTS)):
		var slot_data: Dictionary = saved_slots[i]
		passive_slots[i] = {
			"type": slot_data.get("type", -1),
			"level": slot_data.get("level", 0)
		}

	passive_slots_changed.emit()
