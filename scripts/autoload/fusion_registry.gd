extends Node
## Fusion Registry - handles ball fusion and evolution recipes
## Evolution: Specific recipe -> unique named ball (can further evolve)
## Fusion: Any two L3 balls -> combined ball (cannot further evolve)

signal evolution_completed(evolved_type: EvolvedBallType)
signal evolution_upgraded(evolved_type: EvolvedBallType, new_tier: int)
signal evolved_ball_leveled_up(evolved_type: EvolvedBallType, new_level: int)
signal fusion_completed(fused_ball_id: String)
signal fission_upgrades_changed(total: int)

# Evolution tier levels (damage multipliers)
enum EvolutionTier {
	TIER_1 = 1,  # Base evolution: 1.5x damage (from L3 + L3)
	TIER_2 = 2,  # Advanced: 2.5x damage (evolved + L3)
	TIER_3 = 3,  # Ultimate: 4x damage (advanced + L3)
	TIER_4 = 4   # Legendary: 6x damage (three-way fusion)
}

# Tier damage multipliers
const TIER_DAMAGE_MULTIPLIERS := {
	EvolutionTier.TIER_1: 1.5,
	EvolutionTier.TIER_2: 2.5,
	EvolutionTier.TIER_3: 4.0,
	EvolutionTier.TIER_4: 6.0
}

# Tier name prefixes for display
const TIER_PREFIXES := {
	EvolutionTier.TIER_1: "",          # No prefix for base
	EvolutionTier.TIER_2: "Advanced ",
	EvolutionTier.TIER_3: "Ultimate ",
	EvolutionTier.TIER_4: "Legendary "
}

# Evolved ball types from specific recipes
enum EvolvedBallType {
	NONE,
	# Tier 1: Two L3 basic balls
	BOMB,      # Burn + Iron
	BLIZZARD,  # Freeze + Lightning
	VIRUS,     # Poison + Bleed
	MAGMA,     # Burn + Poison
	VOID,      # Burn + Freeze
	GLACIER,   # Freeze + Iron - Heavy ice shards that pierce
	STORM,     # Lightning + Poison - Chains spread poison
	PLASMA,    # Lightning + Bleed - Chains cause bleed
	CLEAVER,   # Bleed + Iron - Massive bleed on heavy hits
	FROSTBITE, # Freeze + Bleed - Frozen enemies bleed when thawed
	# Multi-evolution (Tier 2): Evolved L3 + L3 basic ball
	NUCLEAR_BOMB,   # Bomb + Poison - Radioactive explosions with DoT
	BLACK_HOLE,     # Blizzard + Dark - Pulls enemies in, massive damage
	PLAGUE,         # Virus + Radiation - Spreading radiation sickness
	HELLFIRE,       # Magma + Lightning - Chain lightning through fire
	ANTIMATTER,     # Void + Iron - Massive knockback + alternating damage
	AVALANCHE,      # Glacier + Burn - Shattering ice + fire damage
	HURRICANE,      # Storm + Freeze - Freezing vortex that chains
	SUPERNOVA,      # Plasma + Burn - Explosive chain reactions
	GUILLOTINE,     # Cleaver + Poison - Execute + spreading poison
	NECROSIS,       # Frostbite + Dark - Death mark on frozen enemies
	# Ultimate evolution (Tier 4): Three L3 evolved balls
	APOCALYPSE,     # Bomb + Virus + Storm - World-ending destruction
	ABSOLUTE_ZERO,  # Blizzard + Glacier + Frostbite - Complete freeze
	RAGNAROK,       # Hellfire + Supernova + Magma - Divine fire
	OBLIVION,       # Black Hole + Antimatter + Void - Reality collapse
	EXTINCTION      # Plague + Necrosis + Guillotine - Death incarnate
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

# Multi-evolution recipes: EvolvedBallType + L3 basic ball -> higher tier evolved
# Format: "EVOLVED_BALL" (base evolved type as string) + "_" + BallType name
const MULTI_EVOLUTION_RECIPES := {
	"BOMB_POISON": EvolvedBallType.NUCLEAR_BOMB,
	"BLIZZARD_DARK": EvolvedBallType.BLACK_HOLE,
	"VIRUS_RADIATION": EvolvedBallType.PLAGUE,
	"MAGMA_LIGHTNING": EvolvedBallType.HELLFIRE,
	"VOID_IRON": EvolvedBallType.ANTIMATTER,
	"GLACIER_BURN": EvolvedBallType.AVALANCHE,
	"STORM_FREEZE": EvolvedBallType.HURRICANE,
	"PLASMA_BURN": EvolvedBallType.SUPERNOVA,
	"CLEAVER_POISON": EvolvedBallType.GUILLOTINE,
	"FROSTBITE_DARK": EvolvedBallType.NECROSIS
}

# Ultimate (three-way) fusion recipes: Three L3 evolved balls -> Tier 4 legendary
# Format: Alphabetically sorted evolved type names joined with "_"
const ULTIMATE_RECIPES := {
	"BOMB_STORM_VIRUS": EvolvedBallType.APOCALYPSE,
	"BLIZZARD_FROSTBITE_GLACIER": EvolvedBallType.ABSOLUTE_ZERO,
	"HELLFIRE_MAGMA_SUPERNOVA": EvolvedBallType.RAGNAROK,
	"ANTIMATTER_BLACK_HOLE_VOID": EvolvedBallType.OBLIVION,
	"GUILLOTINE_NECROSIS_PLAGUE": EvolvedBallType.EXTINCTION
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
	},
	# Multi-evolution balls (Tier 2)
	EvolvedBallType.NUCLEAR_BOMB: {
		"name": "Nuclear Bomb",
		"description": "Radioactive explosions with spreading DoT",
		"base_damage": 35,
		"base_speed": 650.0,
		"color": Color(0.5, 1.0, 0.0),  # Radioactive green
		"effect": "nuclear",
		"aoe_radius": 150.0,
		"radiation_duration": 5.0,
		"radiation_dps": 8
	},
	EvolvedBallType.BLACK_HOLE: {
		"name": "Black Hole",
		"description": "Creates gravity well that pulls and damages",
		"base_damage": 40,
		"base_speed": 500.0,
		"color": Color(0.1, 0.0, 0.15),  # Deep void
		"effect": "black_hole",
		"pull_radius": 200.0,
		"pull_force": 500.0,
		"duration": 3.0
	},
	EvolvedBallType.PLAGUE: {
		"name": "Plague",
		"description": "Spreading radiation sickness amplifies all damage",
		"base_damage": 25,
		"base_speed": 750.0,
		"color": Color(0.3, 0.5, 0.1),  # Sickly green
		"effect": "plague",
		"spread_radius": 120.0,
		"damage_amp": 0.5,
		"duration": 6.0
	},
	EvolvedBallType.HELLFIRE: {
		"name": "Hellfire",
		"description": "Chain lightning through burning enemies",
		"base_damage": 30,
		"base_speed": 900.0,
		"color": Color(1.0, 0.2, 0.0),  # Hellish red-orange
		"effect": "hellfire",
		"chain_count": 5,
		"burn_chain_bonus": 2.0
	},
	EvolvedBallType.ANTIMATTER: {
		"name": "Antimatter",
		"description": "Annihilating impact with massive knockback",
		"base_damage": 45,
		"base_speed": 700.0,
		"color": Color(0.2, 0.0, 0.3),  # Dark purple
		"effect": "antimatter",
		"knockback": 150.0,
		"phase_damage_mult": 1.5
	},
	EvolvedBallType.AVALANCHE: {
		"name": "Avalanche",
		"description": "Shattering ice creates burning fragments",
		"base_damage": 28,
		"base_speed": 600.0,
		"color": Color(0.8, 0.5, 0.3),  # Heated ice
		"effect": "avalanche",
		"fragment_count": 4,
		"fragment_damage": 10,
		"burn_duration": 2.0
	},
	EvolvedBallType.HURRICANE: {
		"name": "Hurricane",
		"description": "Freezing vortex that chains to enemies",
		"base_damage": 22,
		"base_speed": 950.0,
		"color": Color(0.5, 0.8, 0.9),  # Icy wind
		"effect": "hurricane",
		"chain_count": 6,
		"freeze_duration": 1.0,
		"vortex_radius": 80.0
	},
	EvolvedBallType.SUPERNOVA: {
		"name": "Supernova",
		"description": "Explosive chain reactions on hit",
		"base_damage": 35,
		"base_speed": 850.0,
		"color": Color(1.0, 0.8, 0.2),  # Solar gold
		"effect": "supernova",
		"explosion_radius": 120.0,
		"chain_explosion_chance": 0.5
	},
	EvolvedBallType.GUILLOTINE: {
		"name": "Guillotine",
		"description": "Execute low HP enemies, poison spreads on kill",
		"base_damage": 38,
		"base_speed": 550.0,
		"color": Color(0.3, 0.5, 0.2),  # Venomous steel
		"effect": "guillotine",
		"execute_threshold": 0.25,
		"poison_on_kill_radius": 100.0
	},
	EvolvedBallType.NECROSIS: {
		"name": "Necrosis",
		"description": "Marks frozen enemies for death",
		"base_damage": 32,
		"base_speed": 750.0,
		"color": Color(0.3, 0.1, 0.3),  # Deathly purple
		"effect": "necrosis",
		"mark_duration": 4.0,
		"mark_damage_mult": 2.0,
		"shatter_on_death": true
	},
	# Ultimate (Tier 4) evolved balls - Three-way fusions
	EvolvedBallType.APOCALYPSE: {
		"name": "Apocalypse",
		"description": "World-ending storm of explosions, poison, and lightning",
		"base_damage": 50,
		"base_speed": 800.0,
		"color": Color(0.8, 0.2, 0.0),  # Apocalyptic red
		"effect": "apocalypse",
		"aoe_radius": 200.0,
		"chain_count": 5,
		"poison_spread": true,
		"storm_duration": 4.0
	},
	EvolvedBallType.ABSOLUTE_ZERO: {
		"name": "Absolute Zero",
		"description": "Freezes all enemies to absolute zero, shattering on touch",
		"base_damage": 45,
		"base_speed": 600.0,
		"color": Color(0.9, 0.95, 1.0),  # Pure white-blue
		"effect": "absolute_zero",
		"freeze_radius": 250.0,
		"freeze_duration": 5.0,
		"shatter_damage_mult": 3.0,
		"slow_aura": true
	},
	EvolvedBallType.RAGNAROK: {
		"name": "Ragnarok",
		"description": "Divine flames that consume everything",
		"base_damage": 55,
		"base_speed": 750.0,
		"color": Color(1.0, 0.9, 0.3),  # Divine gold
		"effect": "ragnarok",
		"explosion_chain": true,
		"burn_radius": 180.0,
		"chain_count": 8,
		"divine_damage_mult": 2.0
	},
	EvolvedBallType.OBLIVION: {
		"name": "Oblivion",
		"description": "Collapses reality, erasing enemies from existence",
		"base_damage": 60,
		"base_speed": 500.0,
		"color": Color(0.0, 0.0, 0.05),  # Pure void
		"effect": "oblivion",
		"void_radius": 300.0,
		"instant_kill_threshold": 0.3,
		"gravity_pull": 800.0,
		"phase_shift": true
	},
	EvolvedBallType.EXTINCTION: {
		"name": "Extinction",
		"description": "Death incarnate - spreading doom that cannot be stopped",
		"base_damage": 48,
		"base_speed": 700.0,
		"color": Color(0.2, 0.15, 0.1),  # Death brown
		"effect": "extinction",
		"death_spread_radius": 200.0,
		"execute_threshold": 0.4,
		"mark_all": true,
		"doom_duration": 6.0
	}
}

# Owned evolved balls for current run
var owned_evolved_balls: Dictionary = {}  # EvolvedBallType -> EvolutionTier

# Evolved ball levels (like regular ball levels L1 -> L2 -> L3)
# Evolved balls can earn XP and level up to become fusion-ready for multi-evolution
var evolved_ball_levels: Dictionary = {}  # EvolvedBallType -> level (1-3)
var evolved_ball_xp: Dictionary = {}  # EvolvedBallType -> current_xp
const EVOLVED_BALL_XP_PER_LEVEL: Array[int] = [0, 20, 50]  # XP needed for L2, L3

# Owned fused balls for current run (generic fusions)
# Key: "TYPE1_TYPE2" (sorted), Value: { "name": "...", "effects": [...], ... }
var owned_fused_balls: Dictionary = {}

# Fission upgrades tracking for current run
var fission_upgrades: int = 0

# Currently active evolved/fused ball (if any)
var active_evolved_type: EvolvedBallType = EvolvedBallType.NONE
var active_evolved_tier: EvolutionTier = EvolutionTier.TIER_1
var active_fused_id: String = ""

# Evolved ball slot system: parallel to BallRegistry's ball slots
# Allows evolved balls to be equipped and fired like regular balls
# -1 means empty slot, otherwise holds an EvolvedBallType value
const MAX_EVOLVED_SLOTS: int = 5
var unlocked_evolved_slots: int = 1  # Start with 1 evolved slot
var active_evolved_slots: Array[int] = [-1, -1, -1, -1, -1]

signal evolved_slots_changed()


func _ready() -> void:
	_init_passive_slots()  # Initialize slots on startup
	GameManager.game_started.connect(_reset_for_new_run)


func _reset_for_new_run() -> void:
	reset()


func reset() -> void:
	"""Reset the registry to initial state (for new runs and tests)"""
	owned_evolved_balls.clear()
	evolved_ball_levels.clear()
	evolved_ball_xp.clear()
	owned_fused_balls.clear()
	active_evolved_type = EvolvedBallType.NONE
	active_evolved_tier = EvolutionTier.TIER_1
	active_fused_id = ""
	fission_upgrades = 0
	# Reset evolved slots
	unlocked_evolved_slots = 1
	active_evolved_slots = [-1, -1, -1, -1, -1]
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
	"""Evolve two L3 balls into a Tier 1 evolved ball. Returns NONE if invalid."""
	var result := get_evolution_result(ball_a, ball_b)
	if result == EvolvedBallType.NONE:
		return EvolvedBallType.NONE

	# Check both balls are L3
	if not BallRegistry.is_fusion_ready(ball_a) or not BallRegistry.is_fusion_ready(ball_b):
		return EvolvedBallType.NONE

	# Consume the balls from registry
	BallRegistry.owned_balls.erase(ball_a)
	BallRegistry.owned_balls.erase(ball_b)

	# Add evolved ball at Tier 1 and Level 1
	owned_evolved_balls[result] = EvolutionTier.TIER_1
	evolved_ball_levels[result] = 1
	evolved_ball_xp[result] = 0
	active_evolved_type = result
	active_evolved_tier = EvolutionTier.TIER_1

	# Auto-assign to first empty evolved slot
	assign_evolved_to_empty_slot(result)

	evolution_completed.emit(result)
	return result


func can_upgrade_evolution(evolved_type: EvolvedBallType) -> bool:
	"""Check if an evolved ball can be upgraded to the next tier."""
	if not owned_evolved_balls.has(evolved_type):
		return false

	var current_tier: int = owned_evolved_balls[evolved_type]
	if current_tier >= EvolutionTier.TIER_3:
		return false  # Already at max tier

	# Need at least one L3 ball to upgrade
	return BallRegistry.get_fusion_ready_balls().size() > 0


func get_evolution_tier(evolved_type: EvolvedBallType) -> int:
	"""Get the current tier of an evolved ball (0 if not owned)."""
	return owned_evolved_balls.get(evolved_type, 0)


func get_tier_name(tier: int) -> String:
	"""Get display name for a tier."""
	match tier:
		EvolutionTier.TIER_1: return "Evolved"
		EvolutionTier.TIER_2: return "Advanced"
		EvolutionTier.TIER_3: return "Ultimate"
		EvolutionTier.TIER_4: return "Legendary"
		_: return "Unknown"


func get_tier_damage_multiplier(tier: int) -> float:
	"""Get the damage multiplier for a tier."""
	return TIER_DAMAGE_MULTIPLIERS.get(tier, 1.0)


func upgrade_evolution(evolved_type: EvolvedBallType, sacrifice_ball: BallRegistry.BallType) -> bool:
	"""Upgrade an evolved ball to the next tier using an L3 ball. Returns true if successful."""
	if not can_upgrade_evolution(evolved_type):
		return false

	# Check sacrifice ball is L3
	if not BallRegistry.is_fusion_ready(sacrifice_ball):
		return false

	var current_tier: int = owned_evolved_balls[evolved_type]
	var new_tier: int = current_tier + 1

	# Consume the sacrifice ball
	BallRegistry.owned_balls.erase(sacrifice_ball)

	# Upgrade tier
	owned_evolved_balls[evolved_type] = new_tier

	# Update active if this is the active evolved ball
	if active_evolved_type == evolved_type:
		active_evolved_tier = new_tier

	evolution_upgraded.emit(evolved_type, new_tier)
	return true


func get_available_upgrades() -> Array[Dictionary]:
	"""Get all evolution upgrades that can be done with current L3 balls."""
	var available: Array[Dictionary] = []
	var fusion_ready := BallRegistry.get_fusion_ready_balls()

	if fusion_ready.is_empty():
		return available

	for evolved_type in owned_evolved_balls:
		var current_tier: int = owned_evolved_balls[evolved_type]
		if current_tier >= EvolutionTier.TIER_3:
			continue  # Already maxed

		var data := get_evolved_ball_data(evolved_type)
		var base_name: String = data.get("name", "Unknown")
		var new_tier: int = current_tier + 1

		available.append({
			"evolved_type": evolved_type,
			"current_tier": current_tier,
			"new_tier": new_tier,
			"name": TIER_PREFIXES[new_tier] + base_name,
			"sacrifice_options": fusion_ready.duplicate()
		})

	return available


# ===== MULTI-EVOLUTION (Evolved L3 + L3 Ball) =====

func get_multi_evolution_recipe_key(evolved_type: EvolvedBallType, ball_type: BallRegistry.BallType) -> String:
	"""Generate consistent recipe key for multi-evolution lookup"""
	var evolved_name: String = EvolvedBallType.keys()[evolved_type]
	var ball_name: String = BallRegistry.BallType.keys()[ball_type]
	return evolved_name + "_" + ball_name


func has_multi_evolution_recipe(evolved_type: EvolvedBallType, ball_type: BallRegistry.BallType) -> bool:
	"""Check if a multi-evolution recipe exists"""
	var key := get_multi_evolution_recipe_key(evolved_type, ball_type)
	return key in MULTI_EVOLUTION_RECIPES


func get_multi_evolution_result(evolved_type: EvolvedBallType, ball_type: BallRegistry.BallType) -> EvolvedBallType:
	"""Get the result of a multi-evolution (NONE if no recipe)"""
	var key := get_multi_evolution_recipe_key(evolved_type, ball_type)
	return MULTI_EVOLUTION_RECIPES.get(key, EvolvedBallType.NONE)


func get_available_multi_evolutions() -> Array[Dictionary]:
	"""Get all multi-evolutions possible with current L3 evolved balls and L3 basic balls"""
	var available: Array[Dictionary] = []
	var fusion_ready_evolved := get_fusion_ready_evolved_balls()
	var fusion_ready_basic := BallRegistry.get_fusion_ready_balls()

	if fusion_ready_evolved.is_empty() or fusion_ready_basic.is_empty():
		return available

	for key in MULTI_EVOLUTION_RECIPES:
		# Parse the key to get evolved type and ball type
		var parts: PackedStringArray = key.split("_")
		if parts.size() < 2:
			continue

		var evolved_name: String = parts[0]
		var ball_name: String = parts[1]

		# Find the evolved type
		var evolved_type: int = -1
		for et in EvolvedBallType.values():
			if EvolvedBallType.keys()[et] == evolved_name:
				evolved_type = et
				break

		if evolved_type == -1:
			continue

		# Find the ball type
		var ball_type: int = -1
		for bt in BallRegistry.BallType.values():
			if BallRegistry.BallType.keys()[bt] == ball_name:
				ball_type = bt
				break

		if ball_type == -1:
			continue

		# Check if we have both required balls at L3
		var has_evolved := evolved_type in fusion_ready_evolved
		var has_basic := ball_type in fusion_ready_basic

		var result_type: EvolvedBallType = MULTI_EVOLUTION_RECIPES[key]
		var result_data := get_evolved_ball_data(result_type)

		available.append({
			"recipe_key": key,
			"evolved_type": evolved_type,
			"ball_type": ball_type,
			"result": result_type,
			"result_name": result_data.get("name", "Unknown"),
			"can_create": has_evolved and has_basic,
			"has_evolved": has_evolved,
			"has_basic": has_basic
		})

	return available


func multi_evolve_ball(evolved_type: EvolvedBallType, ball_type: BallRegistry.BallType) -> EvolvedBallType:
	"""Perform multi-evolution: combine L3 evolved ball with L3 basic ball.
	Returns the new evolved type or NONE if invalid."""
	var result := get_multi_evolution_result(evolved_type, ball_type)
	if result == EvolvedBallType.NONE:
		return EvolvedBallType.NONE

	# Check evolved ball is L3
	if not is_evolved_ball_fusion_ready(evolved_type):
		return EvolvedBallType.NONE

	# Check basic ball is L3
	if not BallRegistry.is_fusion_ready(ball_type):
		return EvolvedBallType.NONE

	# Remove the source evolved ball from slots
	for i in range(unlocked_evolved_slots):
		if active_evolved_slots[i] == evolved_type:
			active_evolved_slots[i] = -1
			break

	# Remove the source evolved ball from ownership
	owned_evolved_balls.erase(evolved_type)
	evolved_ball_levels.erase(evolved_type)
	evolved_ball_xp.erase(evolved_type)

	# Remove the basic ball from registry
	BallRegistry.owned_balls.erase(ball_type)

	# Add the new multi-evolved ball at Tier 2 (multi-evolutions start at tier 2)
	owned_evolved_balls[result] = EvolutionTier.TIER_2
	evolved_ball_levels[result] = 1
	evolved_ball_xp[result] = 0
	active_evolved_type = result
	active_evolved_tier = EvolutionTier.TIER_2

	# Auto-assign to first empty evolved slot
	assign_evolved_to_empty_slot(result)

	evolution_completed.emit(result)
	return result


# ===== ULTIMATE FUSION (Three L3 Evolved Balls) =====

func get_ultimate_recipe_key(type_a: EvolvedBallType, type_b: EvolvedBallType, type_c: EvolvedBallType) -> String:
	"""Generate consistent recipe key for ultimate fusion lookup (alphabetically sorted)"""
	var names: Array[String] = [
		EvolvedBallType.keys()[type_a],
		EvolvedBallType.keys()[type_b],
		EvolvedBallType.keys()[type_c]
	]
	names.sort()
	return names[0] + "_" + names[1] + "_" + names[2]


func has_ultimate_recipe(type_a: EvolvedBallType, type_b: EvolvedBallType, type_c: EvolvedBallType) -> bool:
	"""Check if an ultimate three-way fusion recipe exists"""
	var key := get_ultimate_recipe_key(type_a, type_b, type_c)
	return key in ULTIMATE_RECIPES


func get_ultimate_result(type_a: EvolvedBallType, type_b: EvolvedBallType, type_c: EvolvedBallType) -> EvolvedBallType:
	"""Get the result of an ultimate fusion (NONE if no recipe)"""
	var key := get_ultimate_recipe_key(type_a, type_b, type_c)
	return ULTIMATE_RECIPES.get(key, EvolvedBallType.NONE)


func get_available_ultimate_fusions() -> Array[Dictionary]:
	"""Get all ultimate fusions possible with current L3 evolved balls"""
	var available: Array[Dictionary] = []
	var fusion_ready_evolved := get_fusion_ready_evolved_balls()

	if fusion_ready_evolved.size() < 3:
		return available  # Need at least 3 L3 evolved balls

	for key in ULTIMATE_RECIPES:
		# Parse the key to get the three evolved types
		var parts: PackedStringArray = key.split("_")
		if parts.size() != 3:
			continue

		var types: Array[int] = []
		var all_found := true

		for part in parts:
			var found := false
			for et in EvolvedBallType.values():
				if EvolvedBallType.keys()[et] == part:
					types.append(et)
					found = true
					break
			if not found:
				all_found = false
				break

		if not all_found or types.size() != 3:
			continue

		# Check if we have all three evolved balls at L3
		var has_all := true
		for et in types:
			if et not in fusion_ready_evolved:
				has_all = false
				break

		var result_type: EvolvedBallType = ULTIMATE_RECIPES[key]
		var result_data := get_evolved_ball_data(result_type)

		available.append({
			"recipe_key": key,
			"evolved_types": types,
			"result": result_type,
			"result_name": result_data.get("name", "Unknown"),
			"can_create": has_all
		})

	return available


func ultimate_fuse_balls(type_a: EvolvedBallType, type_b: EvolvedBallType, type_c: EvolvedBallType) -> EvolvedBallType:
	"""Perform ultimate three-way fusion: combine three L3 evolved balls.
	Returns the new evolved type or NONE if invalid."""
	var result := get_ultimate_result(type_a, type_b, type_c)
	if result == EvolvedBallType.NONE:
		return EvolvedBallType.NONE

	# Check all three evolved balls are L3
	if not is_evolved_ball_fusion_ready(type_a):
		return EvolvedBallType.NONE
	if not is_evolved_ball_fusion_ready(type_b):
		return EvolvedBallType.NONE
	if not is_evolved_ball_fusion_ready(type_c):
		return EvolvedBallType.NONE

	var source_types: Array[EvolvedBallType] = [type_a, type_b, type_c]

	# Remove all three source evolved balls from slots and ownership
	for source_type in source_types:
		for i in range(unlocked_evolved_slots):
			if active_evolved_slots[i] == source_type:
				active_evolved_slots[i] = -1
				break

		owned_evolved_balls.erase(source_type)
		evolved_ball_levels.erase(source_type)
		evolved_ball_xp.erase(source_type)

	# Add the new ultimate ball at Tier 4 (ultimate fusions are legendary tier)
	owned_evolved_balls[result] = EvolutionTier.TIER_4
	evolved_ball_levels[result] = 1
	evolved_ball_xp[result] = 0
	active_evolved_type = result
	active_evolved_tier = EvolutionTier.TIER_4

	# Auto-assign to first empty evolved slot
	assign_evolved_to_empty_slot(result)

	evolution_completed.emit(result)
	return result


# ===== EVOLVED BALL LEVELING (L1 -> L2 -> L3) =====

func get_evolved_ball_level(evolved_type: EvolvedBallType) -> int:
	"""Get the level of an evolved ball (0 if not owned)"""
	return evolved_ball_levels.get(evolved_type, 0)


func get_evolved_ball_xp(evolved_type: EvolvedBallType) -> int:
	"""Get current XP of an evolved ball"""
	return evolved_ball_xp.get(evolved_type, 0)


func get_evolved_ball_xp_to_next_level(evolved_type: EvolvedBallType) -> int:
	"""Get XP needed for next level"""
	var level := get_evolved_ball_level(evolved_type)
	if level <= 0 or level >= 3:
		return 0  # Not owned or already max level
	return EVOLVED_BALL_XP_PER_LEVEL[level]


func add_evolved_ball_xp(evolved_type: EvolvedBallType, xp: int) -> void:
	"""Add XP to an evolved ball and check for level up"""
	if not owned_evolved_balls.has(evolved_type):
		return

	var current_level := get_evolved_ball_level(evolved_type)
	if current_level >= 3:
		return  # Already max level

	evolved_ball_xp[evolved_type] = evolved_ball_xp.get(evolved_type, 0) + xp

	# Check for level up
	var xp_needed := EVOLVED_BALL_XP_PER_LEVEL[current_level]
	if evolved_ball_xp[evolved_type] >= xp_needed:
		_level_up_evolved_ball(evolved_type)


func _level_up_evolved_ball(evolved_type: EvolvedBallType) -> void:
	"""Level up an evolved ball"""
	var current_level := get_evolved_ball_level(evolved_type)
	if current_level >= 3:
		return

	var new_level := current_level + 1
	evolved_ball_levels[evolved_type] = new_level
	evolved_ball_xp[evolved_type] = 0  # Reset XP for next level

	evolved_ball_leveled_up.emit(evolved_type, new_level)


func is_evolved_ball_fusion_ready(evolved_type: EvolvedBallType) -> bool:
	"""Check if an evolved ball is L3 and ready for multi-evolution"""
	return get_evolved_ball_level(evolved_type) >= 3


func get_fusion_ready_evolved_balls() -> Array[EvolvedBallType]:
	"""Get all evolved balls that are L3 and ready for multi-evolution"""
	var ready: Array[EvolvedBallType] = []
	for evolved_type in evolved_ball_levels:
		if evolved_ball_levels[evolved_type] >= 3:
			ready.append(evolved_type)
	return ready


func get_evolved_ball_level_multiplier(level: int) -> float:
	"""Get stat multiplier for an evolved ball level"""
	match level:
		1: return 1.0
		2: return 1.5
		3: return 2.0
		_: return 1.0


# ===== EVOLVED BALL SLOTS =====

func get_active_evolved_slots() -> Array[int]:
	"""Get all active evolved ball slots"""
	return active_evolved_slots


func get_filled_evolved_slots() -> Array[int]:
	"""Get only non-empty evolved slots (evolved types that will fire)"""
	var filled: Array[int] = []
	for i in range(unlocked_evolved_slots):
		if active_evolved_slots[i] != -1:
			filled.append(active_evolved_slots[i])
	return filled


func get_evolved_slot_count() -> int:
	"""Get number of filled evolved slots"""
	var count: int = 0
	for i in range(unlocked_evolved_slots):
		if active_evolved_slots[i] != -1:
			count += 1
	return count


func set_evolved_slot(slot_index: int, evolved_type: int) -> bool:
	"""Set a specific evolved slot to an evolved ball type. Use -1 to clear slot."""
	if slot_index < 0 or slot_index >= MAX_EVOLVED_SLOTS:
		return false
	if evolved_type != -1 and evolved_type not in owned_evolved_balls:
		return false  # Can't equip evolved ball we don't own

	active_evolved_slots[slot_index] = evolved_type
	evolved_slots_changed.emit()
	return true


func clear_evolved_slot(slot_index: int) -> void:
	"""Clear an evolved slot (set to empty)"""
	if slot_index >= 0 and slot_index < MAX_EVOLVED_SLOTS:
		active_evolved_slots[slot_index] = -1
		evolved_slots_changed.emit()


func assign_evolved_to_empty_slot(evolved_type: EvolvedBallType) -> bool:
	"""Assign evolved ball to first empty slot. Returns true if successful."""
	for i in range(unlocked_evolved_slots):
		if active_evolved_slots[i] == -1:
			active_evolved_slots[i] = evolved_type
			evolved_slots_changed.emit()
			return true
	return false  # No empty unlocked slots


func is_evolved_ball_in_slot(evolved_type: EvolvedBallType) -> bool:
	"""Check if an evolved ball type is currently equipped in any slot"""
	return evolved_type in active_evolved_slots


func get_empty_evolved_slot_count() -> int:
	"""Get number of empty evolved slots (within unlocked slots)"""
	var count: int = 0
	for i in range(unlocked_evolved_slots):
		if active_evolved_slots[i] == -1:
			count += 1
	return count


func unlock_evolved_slot() -> bool:
	"""Unlock next evolved ball slot. Returns true if successful."""
	if unlocked_evolved_slots >= MAX_EVOLVED_SLOTS:
		return false  # Already at max
	unlocked_evolved_slots += 1
	evolved_slots_changed.emit()
	return true


func get_unlocked_evolved_slots() -> int:
	"""Get number of unlocked evolved ball slots."""
	return unlocked_evolved_slots


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


func get_evolved_ball_name(evolved_type: EvolvedBallType, include_tier: bool = true) -> String:
	"""Get display name for an evolved ball (with tier prefix if owned and include_tier is true)"""
	var data := get_evolved_ball_data(evolved_type)
	var base_name: String = data.get("name", "Unknown")

	if include_tier and owned_evolved_balls.has(evolved_type):
		var tier: int = owned_evolved_balls[evolved_type]
		return TIER_PREFIXES.get(tier, "") + base_name

	return base_name


func get_evolved_ball_damage(evolved_type: EvolvedBallType) -> int:
	"""Get damage for an evolved ball (scaled by tier and level if owned)"""
	var data := get_evolved_ball_data(evolved_type)
	var base_damage: int = data.get("base_damage", 10)

	if owned_evolved_balls.has(evolved_type):
		var tier: int = owned_evolved_balls[evolved_type]
		var tier_mult: float = get_tier_damage_multiplier(tier)
		var level: int = get_evolved_ball_level(evolved_type)
		var level_mult: float = get_evolved_ball_level_multiplier(level)
		return int(base_damage * tier_mult * level_mult)

	return base_damage


func get_evolved_ball_speed(evolved_type: EvolvedBallType) -> float:
	"""Get speed for an evolved ball"""
	var data := get_evolved_ball_data(evolved_type)
	return data.get("base_speed", 800.0)


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

	# Track total fission upgrades this run
	var upgrades_array: Array = result["upgrades"]
	var upgrade_count: int = upgrades_array.size()
	if upgrade_count > 0:
		fission_upgrades += upgrade_count
		fission_upgrades_changed.emit(fission_upgrades)

	return result


func get_fission_upgrades() -> int:
	"""Get total fission upgrades this run"""
	return fission_upgrades


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
# PASSIVE SLOT SYSTEM (5 slots with levels L1-L3, start with 3 unlocked)
# =============================================================================

const MAX_PASSIVE_SLOTS: int = 5  # Maximum of 5 slots
const MAX_PASSIVE_LEVEL: int = 3
var unlocked_passive_slots: int = 3  # Start with 3 slots, unlock up to 5

# Each slot: {"type": PassiveType or -1 for empty, "level": 0-3}
var passive_slots: Array[Dictionary] = []

signal passive_slots_changed()


func _init_passive_slots() -> void:
	"""Initialize empty passive slots (all 5, but only first 3 unlocked)"""
	passive_slots.clear()
	unlocked_passive_slots = 3  # Start with 3 unlocked
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
	for i in unlocked_passive_slots:
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
	"""Get all equipped passives with their slot index and level (within unlocked slots)"""
	var equipped: Array[Dictionary] = []
	for i in unlocked_passive_slots:
		if passive_slots[i]["type"] != -1:
			equipped.append({
				"slot": i,
				"type": passive_slots[i]["type"],
				"level": passive_slots[i]["level"]
			})
	return equipped


func get_empty_slot_count() -> int:
	"""Get number of empty passive slots (within unlocked slots)"""
	var count: int = 0
	for i in unlocked_passive_slots:
		if passive_slots[i]["type"] == -1:
			count += 1
	return count


func has_empty_slot() -> bool:
	"""Check if there's an empty passive slot (within unlocked slots)"""
	for i in unlocked_passive_slots:
		if passive_slots[i]["type"] == -1:
			return true
	return false


func unlock_passive_slot() -> bool:
	"""Unlock next passive slot. Returns true if successful."""
	if unlocked_passive_slots >= MAX_PASSIVE_SLOTS:
		return false  # Already at max
	unlocked_passive_slots += 1
	passive_slots_changed.emit()
	return true


func get_unlocked_passive_slots() -> int:
	"""Get number of unlocked passive slots."""
	return unlocked_passive_slots


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
		# Not equipped - try to fill an empty unlocked slot
		for i in unlocked_passive_slots:
			if passive_slots[i]["type"] == -1:
				passive_slots[i] = {"type": passive_type, "level": 1}
				_apply_passive_effect(passive_type)
				passive_slots_changed.emit()
				return true
		return false  # No empty unlocked slots
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
		# Evolution unlocked - UI notification handled via MetaManager signal
		var _evolution_data: PassiveEvolutions.EvolutionData = PassiveEvolutions.get_evolution(evolution_id)


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

	# Convert evolved ball levels to JSON
	var evolved_levels_json := {}
	for evolved_type in evolved_ball_levels:
		evolved_levels_json[str(evolved_type)] = evolved_ball_levels[evolved_type]

	# Convert evolved ball XP to JSON
	var evolved_xp_json := {}
	for evolved_type in evolved_ball_xp:
		evolved_xp_json[str(evolved_type)] = evolved_ball_xp[evolved_type]

	# Passive slots need to convert enum to int for JSON
	var passive_slots_json: Array[Dictionary] = []
	for slot in passive_slots:
		passive_slots_json.append({
			"type": slot["type"],
			"level": slot["level"]
		})

	return {
		"owned_evolved_balls": evolved_balls_json,
		"evolved_ball_levels": evolved_levels_json,
		"evolved_ball_xp": evolved_xp_json,
		"owned_fused_balls": owned_fused_balls.duplicate(true),
		"active_evolved_type": active_evolved_type,
		"active_fused_id": active_fused_id,
		"passive_slots": passive_slots_json,
		"unlocked_passive_slots": unlocked_passive_slots,
		"active_evolved_slots": active_evolved_slots.duplicate(),
		"unlocked_evolved_slots": unlocked_evolved_slots
	}


func restore_session_state(data: Dictionary) -> void:
	"""Restore fusion registry state from session save."""
	# Clear current state
	owned_evolved_balls.clear()
	evolved_ball_levels.clear()
	evolved_ball_xp.clear()
	owned_fused_balls.clear()
	_init_passive_slots()

	# Restore evolved balls (convert string keys back to int)
	var saved_evolved: Dictionary = data.get("owned_evolved_balls", {})
	for evolved_type_str in saved_evolved:
		var evolved_type: int = int(evolved_type_str)
		owned_evolved_balls[evolved_type] = saved_evolved[evolved_type_str]

	# Restore evolved ball levels
	var saved_levels: Dictionary = data.get("evolved_ball_levels", {})
	for evolved_type_str in saved_levels:
		var evolved_type: int = int(evolved_type_str)
		evolved_ball_levels[evolved_type] = saved_levels[evolved_type_str]

	# Restore evolved ball XP
	var saved_xp: Dictionary = data.get("evolved_ball_xp", {})
	for evolved_type_str in saved_xp:
		var evolved_type: int = int(evolved_type_str)
		evolved_ball_xp[evolved_type] = saved_xp[evolved_type_str]

	# Backward compatibility: if no levels saved, set all owned evolved balls to L1
	if saved_levels.is_empty() and not saved_evolved.is_empty():
		for evolved_type in owned_evolved_balls:
			evolved_ball_levels[evolved_type] = 1
			evolved_ball_xp[evolved_type] = 0

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

	# Restore unlocked passive slots (backward compatibility: infer from filled slots if not saved)
	if data.has("unlocked_passive_slots"):
		unlocked_passive_slots = data.get("unlocked_passive_slots", 3)
	else:
		# Old save - count filled slots and ensure at least that many unlocked
		var filled_count := 0
		for slot in passive_slots:
			if slot["type"] != -1:
				filled_count += 1
		unlocked_passive_slots = maxi(filled_count, 3)

	# Restore evolved ball slots
	var saved_evolved_slots: Array = data.get("active_evolved_slots", [-1, -1, -1, -1, -1])
	for i in range(mini(saved_evolved_slots.size(), MAX_EVOLVED_SLOTS)):
		active_evolved_slots[i] = saved_evolved_slots[i]

	# Restore unlocked evolved slots (backward compatibility: default to 1 if not saved)
	if data.has("unlocked_evolved_slots"):
		unlocked_evolved_slots = data.get("unlocked_evolved_slots", 1)
	else:
		# Old save - count filled slots and ensure at least that many unlocked
		var filled_evolved_count := 0
		for slot in active_evolved_slots:
			if slot != -1:
				filled_evolved_count += 1
		unlocked_evolved_slots = maxi(filled_evolved_count, 1)

	passive_slots_changed.emit()
	evolved_slots_changed.emit()
