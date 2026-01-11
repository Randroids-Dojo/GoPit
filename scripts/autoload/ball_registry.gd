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
	IRON,
	RADIATION,
	DISEASE,
	FROSTBURN,
	WIND,
	GHOST
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
	},
	BallType.RADIATION: {
		"name": "Radiation",
		"description": "Amplifies all damage",
		"base_damage": 6,
		"base_speed": 850.0,
		"color": Color(0.5, 1.0, 0.2),  # Toxic yellow-green
		"effect": "radiation"
	},
	BallType.DISEASE: {
		"name": "Disease",
		"description": "Stacking DoT",
		"base_damage": 7,
		"base_speed": 800.0,
		"color": Color(0.6, 0.3, 0.8),  # Sickly purple
		"effect": "disease"
	},
	BallType.FROSTBURN: {
		"name": "Frostburn",
		"description": "Slow + damage amp",
		"base_damage": 8,
		"base_speed": 800.0,
		"color": Color(0.3, 0.6, 1.0),  # Pale frost blue
		"effect": "frostburn"
	},
	BallType.WIND: {
		"name": "Wind",
		"description": "Pass-through + slow",
		"base_damage": 5,
		"base_speed": 1000.0,  # Fast like wind
		"color": Color(0.8, 1.0, 0.8),  # Light green-white (airy)
		"effect": "wind"
	},
	BallType.GHOST: {
		"name": "Ghost",
		"description": "Pass-through all",
		"base_damage": 4,
		"base_speed": 900.0,
		"color": Color(0.7, 0.7, 0.9, 0.6),  # Semi-transparent purple
		"effect": "ghost"
	}
}

# Owned balls for current run: BallType -> level (1-3)
var owned_balls: Dictionary = {}

# Currently active ball type for firing (legacy, kept for compatibility)
var active_ball_type: BallType = BallType.BASIC

# Ball slot system: 5 slots that can each hold a different ball type
# All equipped slots fire simultaneously per shot
# -1 means empty slot, otherwise holds a BallType value
const MAX_SLOTS: int = 5
var active_ball_slots: Array[int] = [-1, -1, -1, -1, -1]

signal slots_changed()


func _ready() -> void:
	GameManager.game_started.connect(_reset_for_new_run)


func _reset_for_new_run() -> void:
	owned_balls.clear()
	active_ball_type = BallType.BASIC
	# Reset all slots to empty
	active_ball_slots = [-1, -1, -1, -1, -1]
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
		# Auto-switch to new ball type (legacy compatibility)
		active_ball_type = ball_type
		# Auto-assign to first empty slot
		_assign_to_empty_slot(ball_type)


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


# =============================================================================
# BALL SLOT SYSTEM
# =============================================================================

func _assign_to_empty_slot(ball_type: BallType) -> bool:
	"""Assign ball to first empty slot. Returns true if successful."""
	for i in range(MAX_SLOTS):
		if active_ball_slots[i] == -1:
			active_ball_slots[i] = ball_type
			slots_changed.emit()
			return true
	return false  # No empty slots


func get_active_slots() -> Array[int]:
	"""Get all active ball slots (for firing)"""
	return active_ball_slots


func get_filled_slots() -> Array[int]:
	"""Get only non-empty slots (ball types that will fire)"""
	var filled: Array[int] = []
	for slot in active_ball_slots:
		if slot != -1:
			filled.append(slot)
	return filled


func get_slot_count() -> int:
	"""Get number of filled slots"""
	var count: int = 0
	for slot in active_ball_slots:
		if slot != -1:
			count += 1
	return count


func set_slot(slot_index: int, ball_type: int) -> bool:
	"""Set a specific slot to a ball type. Use -1 to clear slot."""
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return false
	if ball_type != -1 and ball_type not in owned_balls:
		return false  # Can't equip ball we don't own

	active_ball_slots[slot_index] = ball_type
	slots_changed.emit()
	return true


func clear_slot(slot_index: int) -> void:
	"""Clear a slot (set to empty)"""
	if slot_index >= 0 and slot_index < MAX_SLOTS:
		active_ball_slots[slot_index] = -1
		slots_changed.emit()


func swap_slots(slot_a: int, slot_b: int) -> void:
	"""Swap two slots"""
	if slot_a < 0 or slot_a >= MAX_SLOTS or slot_b < 0 or slot_b >= MAX_SLOTS:
		return
	var temp := active_ball_slots[slot_a]
	active_ball_slots[slot_a] = active_ball_slots[slot_b]
	active_ball_slots[slot_b] = temp
	slots_changed.emit()


func is_ball_in_slot(ball_type: BallType) -> bool:
	"""Check if a ball type is currently equipped in any slot"""
	return ball_type in active_ball_slots


func get_empty_slot_count() -> int:
	"""Get number of empty slots available"""
	var count: int = 0
	for slot in active_ball_slots:
		if slot == -1:
			count += 1
	return count
