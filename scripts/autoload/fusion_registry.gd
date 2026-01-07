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
	VOID       # Burn + Freeze
}

# Recipe definitions: sorted [BallType, BallType] -> EvolvedBallType
const EVOLUTION_RECIPES := {
	# Key format: [smaller_enum, larger_enum] to ensure consistent lookup
	"BURN_IRON": EvolvedBallType.BOMB,
	"FREEZE_LIGHTNING": EvolvedBallType.BLIZZARD,
	"POISON_BLEED": EvolvedBallType.VIRUS,
	"BURN_POISON": EvolvedBallType.MAGMA,
	"BURN_FREEZE": EvolvedBallType.VOID
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
	GameManager.game_started.connect(_reset_for_new_run)


func _reset_for_new_run() -> void:
	owned_evolved_balls.clear()
	owned_fused_balls.clear()
	active_evolved_type = EvolvedBallType.NONE
	active_fused_id = ""


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
	"""Apply fission effect - random upgrades or XP if all maxed"""
	var result := {
		"type": "fission",
		"upgrades": [],
		"xp_bonus": 0
	}

	# Check what can be upgraded
	var upgradeable := BallRegistry.get_upgradeable_balls()
	var unowned := BallRegistry.get_unowned_ball_types()

	if upgradeable.size() == 0 and unowned.size() == 0:
		# All maxed - give XP bonus
		var xp_bonus := 100 + GameManager.current_wave * 10
		GameManager.add_xp(xp_bonus)
		result["xp_bonus"] = xp_bonus
		return result

	# Random number of upgrades (1-3)
	var num_upgrades := randi_range(1, 3)

	for i in num_upgrades:
		# 60% chance to level up owned ball, 40% chance new ball
		if upgradeable.size() > 0 and (unowned.size() == 0 or randf() < 0.6):
			var ball_type: BallRegistry.BallType = upgradeable.pick_random()
			BallRegistry.level_up_ball(ball_type)
			result["upgrades"].append({"action": "level_up", "ball_type": ball_type})
			# Remove from upgradeable if now maxed
			if BallRegistry.get_ball_level(ball_type) >= 3:
				upgradeable.erase(ball_type)
		elif unowned.size() > 0:
			var ball_type: BallRegistry.BallType = unowned.pick_random()
			BallRegistry.add_ball(ball_type)
			result["upgrades"].append({"action": "new_ball", "ball_type": ball_type})
			unowned.erase(ball_type)
			# Add to upgradeable since it starts at L1
			upgradeable.append(ball_type)

	return result
