extends Node
## Ball Registry - tracks owned ball types and their levels for the current run
## Ball levels: L1 (base) -> L2 (+50% stats) -> L3 (+100% stats, fusion-ready)
## Ball Slot System: 4 slots, all equipped balls fire simultaneously

signal ball_acquired(ball_type: BallType)
signal ball_leveled_up(ball_type: BallType, new_level: int)
signal slot_updated(slot_index: int, ball_type: BallType)

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

# Ball slot configuration
const MAX_SLOTS: int = 4
const EMPTY_SLOT: int = -1

# Owned balls for current run: BallType -> level (1-3)
var owned_balls: Dictionary = {}

# Ball slots - each slot fires simultaneously when firing
# Array of BallType or EMPTY_SLOT (-1) for empty slots
var ball_slots: Array[int] = []

# Currently active ball type for firing (legacy, kept for backward compatibility)
var active_ball_type: BallType = BallType.BASIC


func _ready() -> void:
	GameManager.game_started.connect(_reset_for_new_run)


func _reset_for_new_run() -> void:
	owned_balls.clear()
	active_ball_type = BallType.BASIC
	# Initialize empty slots
	ball_slots.clear()
	for i in range(MAX_SLOTS):
		ball_slots.append(EMPTY_SLOT)
	# Start with basic ball at L1 in first slot
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
		# Auto-assign to first empty slot
		_assign_to_empty_slot(ball_type)
		# Legacy: update active ball type for backward compatibility
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


# ============================================================================
# Ball Slot System
# ============================================================================

func _assign_to_empty_slot(ball_type: BallType) -> bool:
	"""Assign a ball type to the first empty slot. Returns true if successful."""
	for i in range(ball_slots.size()):
		if ball_slots[i] == EMPTY_SLOT:
			ball_slots[i] = ball_type
			slot_updated.emit(i, ball_type)
			return true
	# No empty slots available
	return false


func get_active_slots() -> Array[int]:
	"""Get all non-empty ball slots (ball types that will fire)"""
	var active: Array[int] = []
	for slot in ball_slots:
		if slot != EMPTY_SLOT:
			active.append(slot)
	return active


func get_slot(index: int) -> int:
	"""Get the ball type in a specific slot (or EMPTY_SLOT)"""
	if index < 0 or index >= ball_slots.size():
		return EMPTY_SLOT
	return ball_slots[index]


func set_slot(index: int, ball_type: int) -> bool:
	"""Set a specific slot to a ball type. Returns true if successful."""
	if index < 0 or index >= ball_slots.size():
		return false
	# Can only assign owned balls or clear the slot
	if ball_type != EMPTY_SLOT and ball_type not in owned_balls:
		return false
	# Check if ball type is already in another slot (no duplicates)
	if ball_type != EMPTY_SLOT:
		for i in range(ball_slots.size()):
			if i != index and ball_slots[i] == ball_type:
				return false  # Already in another slot
	ball_slots[index] = ball_type
	slot_updated.emit(index, ball_type)
	return true


func clear_slot(index: int) -> void:
	"""Clear a specific slot"""
	set_slot(index, EMPTY_SLOT)


func is_ball_in_slot(ball_type: BallType) -> bool:
	"""Check if a ball type is currently equipped in any slot"""
	return ball_type in ball_slots


func get_empty_slot_count() -> int:
	"""Get the number of empty slots"""
	var count: int = 0
	for slot in ball_slots:
		if slot == EMPTY_SLOT:
			count += 1
	return count


func get_filled_slot_count() -> int:
	"""Get the number of filled slots"""
	return MAX_SLOTS - get_empty_slot_count()
