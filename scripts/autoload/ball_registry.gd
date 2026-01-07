extends Node
## Ball Registry - tracks owned ball types and their levels for the current run
## Ball levels: L1 (base) -> L2 (+50% stats) -> L3 (+100% stats, fusion-ready)

signal ball_acquired(ball_type: BallType)
signal ball_leveled_up(ball_type: BallType, new_level: int)

enum BallType {
	BASIC,
	BURN,
	FREEZE,
	POISON,
	BLEED,
	LIGHTNING,
	IRON
}

const BALL_DATA := {
	BallType.BASIC: {
		"name": "Basic",
		"description": "Standard ball",
		"base_damage": 10,
		"base_speed": 800.0,
		"color": Color(0.3, 0.7, 1.0),  # Blue
		"effect": "none"
	},
	BallType.BURN: {
		"name": "Burn",
		"description": "Sets enemies on fire",
		"base_damage": 8,
		"base_speed": 800.0,
		"color": Color(1.0, 0.5, 0.1),  # Orange
		"effect": "burn"
	},
	BallType.FREEZE: {
		"name": "Freeze",
		"description": "Slows enemies",
		"base_damage": 6,
		"base_speed": 800.0,
		"color": Color(0.5, 0.9, 1.0),  # Cyan
		"effect": "freeze"
	},
	BallType.POISON: {
		"name": "Poison",
		"description": "Damage over time",
		"base_damage": 7,
		"base_speed": 800.0,
		"color": Color(0.4, 0.9, 0.2),  # Green
		"effect": "poison"
	},
	BallType.BLEED: {
		"name": "Bleed",
		"description": "Stacking damage",
		"base_damage": 8,
		"base_speed": 800.0,
		"color": Color(0.9, 0.2, 0.3),  # Dark red
		"effect": "bleed"
	},
	BallType.LIGHTNING: {
		"name": "Lightning",
		"description": "Chain damage",
		"base_damage": 9,
		"base_speed": 900.0,
		"color": Color(1.0, 1.0, 0.3),  # Yellow
		"effect": "lightning"
	},
	BallType.IRON: {
		"name": "Iron",
		"description": "High damage, knockback",
		"base_damage": 15,
		"base_speed": 600.0,
		"color": Color(0.7, 0.7, 0.75),  # Metallic gray
		"effect": "knockback"
	}
}

# Owned balls for current run: BallType -> level (1-3)
var owned_balls: Dictionary = {}

# Currently active ball type for firing
var active_ball_type: BallType = BallType.BASIC


func _ready() -> void:
	GameManager.game_started.connect(_reset_for_new_run)


func _reset_for_new_run() -> void:
	owned_balls.clear()
	active_ball_type = BallType.BASIC
	# Start with basic ball at L1
	add_ball(BallType.BASIC)


func add_ball(ball_type: BallType) -> void:
	"""Add a new ball type or level up existing one"""
	if ball_type in owned_balls:
		# Already owned - level it up
		level_up_ball(ball_type)
	else:
		# New ball type
		owned_balls[ball_type] = 1
		ball_acquired.emit(ball_type)
		# Auto-switch to new ball type (player choice)
		active_ball_type = ball_type


func level_up_ball(ball_type: BallType) -> bool:
	"""Level up a ball. Returns true if successful."""
	if ball_type not in owned_balls:
		return false

	var current_level: int = owned_balls[ball_type]
	if current_level >= 3:
		return false  # Already max level

	owned_balls[ball_type] = current_level + 1
	ball_leveled_up.emit(ball_type, current_level + 1)
	return true


func get_ball_level(ball_type: BallType) -> int:
	"""Get level of a ball type (0 if not owned)"""
	return owned_balls.get(ball_type, 0)


func can_level_up(ball_type: BallType) -> bool:
	"""Check if ball can be leveled up"""
	var level := get_ball_level(ball_type)
	return level > 0 and level < 3


func is_fusion_ready(ball_type: BallType) -> bool:
	"""Check if ball is L3 and ready for fusion"""
	return get_ball_level(ball_type) >= 3


func get_fusion_ready_balls() -> Array[BallType]:
	"""Get all L3 balls that can be fused"""
	var ready: Array[BallType] = []
	for ball_type in owned_balls:
		if owned_balls[ball_type] >= 3:
			ready.append(ball_type)
	return ready


func get_level_multiplier(level: int) -> float:
	"""Get stat multiplier for a level"""
	match level:
		1: return 1.0
		2: return 1.5
		3: return 2.0
		_: return 1.0


func get_damage(ball_type: BallType) -> int:
	"""Get damage for a ball type at its current level"""
	var data: Dictionary = BALL_DATA.get(ball_type, BALL_DATA[BallType.BASIC])
	var level := get_ball_level(ball_type)
	if level == 0:
		level = 1
	return int(data["base_damage"] * get_level_multiplier(level))


func get_speed(ball_type: BallType) -> float:
	"""Get speed for a ball type at its current level"""
	var data: Dictionary = BALL_DATA.get(ball_type, BALL_DATA[BallType.BASIC])
	var level := get_ball_level(ball_type)
	if level == 0:
		level = 1
	return data["base_speed"] * get_level_multiplier(level)


func get_color(ball_type: BallType) -> Color:
	"""Get color for a ball type"""
	var data: Dictionary = BALL_DATA.get(ball_type, BALL_DATA[BallType.BASIC])
	return data["color"]


func get_ball_name(ball_type: BallType) -> String:
	"""Get display name for a ball type"""
	var data: Dictionary = BALL_DATA.get(ball_type, BALL_DATA[BallType.BASIC])
	return data["name"]


func get_ball_description(ball_type: BallType) -> String:
	"""Get description for a ball type"""
	var data: Dictionary = BALL_DATA.get(ball_type, BALL_DATA[BallType.BASIC])
	return data["description"]


func get_active_damage() -> int:
	"""Get damage for currently active ball type"""
	return get_damage(active_ball_type)


func get_active_speed() -> float:
	"""Get speed for currently active ball type"""
	return get_speed(active_ball_type)


func get_active_color() -> Color:
	"""Get color for currently active ball type"""
	return get_color(active_ball_type)


func get_active_level() -> int:
	"""Get level of currently active ball type"""
	return get_ball_level(active_ball_type)


func set_active_ball(ball_type: BallType) -> void:
	"""Set the active ball type for firing"""
	if ball_type in owned_balls:
		active_ball_type = ball_type


func get_unowned_ball_types() -> Array[BallType]:
	"""Get ball types not yet acquired"""
	var unowned: Array[BallType] = []
	for ball_type in BallType.values():
		if ball_type not in owned_balls:
			unowned.append(ball_type)
	return unowned


func get_upgradeable_balls() -> Array[BallType]:
	"""Get owned balls that can still be leveled up"""
	var upgradeable: Array[BallType] = []
	for ball_type in owned_balls:
		if owned_balls[ball_type] < 3:
			upgradeable.append(ball_type)
	return upgradeable


func get_owned_ball_types() -> Array[BallType]:
	"""Get all owned ball types"""
	var owned: Array[BallType] = []
	for ball_type in owned_balls:
		owned.append(ball_type)
	return owned
