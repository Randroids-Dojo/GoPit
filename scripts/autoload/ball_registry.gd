extends Node
## Ball Registry - tracks owned ball types and their levels for the current run
## Ball levels: L1 (base) -> L2 (+50% stats) -> L3 (+100% stats, fusion-ready)
##
## SLOT SYSTEM: Player has 5 slots, ALL equipped balls fire simultaneously.
## This is the core mechanic difference from single-active-ball systems.

signal ball_acquired(ball_type: BallType)
signal ball_leveled_up(ball_type: BallType, new_level: int)
signal slot_changed(slot_index: int, ball_type)  # null if slot emptied

enum BallType {
	BASIC,
	BURN,
	FREEZE,
	POISON,
	BLEED,
	LIGHTNING,
	IRON
}

## Maximum number of ball slots (all fire simultaneously)
const MAX_SLOTS := 5

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

# Ball slots: array of {ball_type: BallType, level: int} or null for empty slot
# ALL equipped slots fire simultaneously when player fires
var ball_slots: Array = []

# Currently active ball type for firing (legacy - now returns first slot's type)
var active_ball_type: BallType:
	get:
		for slot in ball_slots:
			if slot != null:
				return slot.ball_type
		return BallType.BASIC


func _ready() -> void:
	GameManager.game_started.connect(_reset_for_new_run)
	_init_slots()


func _init_slots() -> void:
	"""Initialize empty slots array"""
	ball_slots.clear()
	for i in range(MAX_SLOTS):
		ball_slots.append(null)


func _reset_for_new_run() -> void:
	owned_balls.clear()
	_init_slots()
	# Start with basic ball in slot 0
	add_ball(BallType.BASIC)


func add_ball(ball_type: BallType) -> bool:
	"""Add a new ball type to a slot, or level up if already equipped.
	Returns true if ball was added/leveled, false if no empty slots."""
	# Check if already in a slot
	var existing_slot := get_slot_index(ball_type)
	if existing_slot >= 0:
		# Already equipped - level it up
		return level_up_ball(ball_type)

	# Find empty slot
	var empty_slot := _find_empty_slot()
	if empty_slot < 0:
		return false  # No empty slots

	# Add to slot
	ball_slots[empty_slot] = {"ball_type": ball_type, "level": 1}
	owned_balls[ball_type] = 1
	ball_acquired.emit(ball_type)
	slot_changed.emit(empty_slot, ball_type)
	return true


func _find_empty_slot() -> int:
	"""Find first empty slot index, or -1 if none available"""
	for i in range(MAX_SLOTS):
		if ball_slots[i] == null:
			return i
	return -1


func get_slot_index(ball_type: BallType) -> int:
	"""Get slot index for a ball type, or -1 if not equipped"""
	for i in range(MAX_SLOTS):
		if ball_slots[i] != null and ball_slots[i].ball_type == ball_type:
			return i
	return -1


func get_equipped_slots() -> Array:
	"""Get all non-null slots for firing"""
	var equipped: Array = []
	for slot in ball_slots:
		if slot != null:
			equipped.append(slot)
	return equipped


func get_equipped_count() -> int:
	"""Get number of equipped ball types"""
	var count := 0
	for slot in ball_slots:
		if slot != null:
			count += 1
	return count


func has_empty_slot() -> bool:
	"""Check if there's room for another ball type"""
	return _find_empty_slot() >= 0


func level_up_ball(ball_type: BallType) -> bool:
	"""Level up a ball. Returns true if successful."""
	if ball_type not in owned_balls:
		return false

	var current_level: int = owned_balls[ball_type]
	if current_level >= 3:
		return false  # Already max level

	var new_level := current_level + 1
	owned_balls[ball_type] = new_level

	# Also update slot level
	var slot_idx := get_slot_index(ball_type)
	if slot_idx >= 0:
		ball_slots[slot_idx].level = new_level
		slot_changed.emit(slot_idx, ball_type)

	ball_leveled_up.emit(ball_type, new_level)
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


func set_active_ball(_ball_type: BallType) -> void:
	"""DEPRECATED: With slot system, all equipped balls fire simultaneously.
	This function is kept for backward compatibility but does nothing."""
	pass


func remove_from_slot(ball_type: BallType) -> bool:
	"""Remove a ball type from its slot (for evolutions/fusions).
	Returns true if removed, false if not found."""
	var slot_idx := get_slot_index(ball_type)
	if slot_idx < 0:
		return false

	ball_slots[slot_idx] = null
	owned_balls.erase(ball_type)
	slot_changed.emit(slot_idx, null)
	return true


func swap_slots(slot_a: int, slot_b: int) -> void:
	"""Swap contents of two slots (for UI reordering)"""
	if slot_a < 0 or slot_a >= MAX_SLOTS or slot_b < 0 or slot_b >= MAX_SLOTS:
		return
	var temp = ball_slots[slot_a]
	ball_slots[slot_a] = ball_slots[slot_b]
	ball_slots[slot_b] = temp
	slot_changed.emit(slot_a, ball_slots[slot_a].ball_type if ball_slots[slot_a] else null)
	slot_changed.emit(slot_b, ball_slots[slot_b].ball_type if ball_slots[slot_b] else null)


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
