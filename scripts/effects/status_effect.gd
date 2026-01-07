class_name StatusEffect
extends RefCounted
## Base class for status effects that can be applied to enemies

enum Type { BURN, FREEZE, POISON, BLEED }

# Effect configuration
var type: Type
var duration: float
var damage_per_tick: float
var tick_interval: float = 0.5
var stacks: int = 1
var max_stacks: int = 1
var slow_multiplier: float = 1.0  # 1.0 = no slow, 0.5 = 50% slow

# Runtime state
var time_remaining: float = 0.0
var tick_timer: float = 0.0


func _init(effect_type: Type = Type.BURN) -> void:
	type = effect_type
	_configure()


func _configure() -> void:
	match type:
		Type.BURN:
			duration = 3.0
			damage_per_tick = 2.5  # 5 DPS (2.5 damage every 0.5s)
			tick_interval = 0.5
			max_stacks = 1  # Refreshes duration instead
		Type.FREEZE:
			duration = 2.0
			damage_per_tick = 0.0
			slow_multiplier = 0.5  # 50% slow
			max_stacks = 1
		Type.POISON:
			duration = 5.0
			damage_per_tick = 1.5  # 3 DPS
			tick_interval = 0.5
			max_stacks = 1
		Type.BLEED:
			duration = INF  # Permanent until enemy dies
			damage_per_tick = 1.0  # 2 DPS per stack (1.0 every 0.5s)
			tick_interval = 0.5
			max_stacks = 5

	time_remaining = duration


func apply() -> void:
	"""Called when effect is first applied or refreshed"""
	time_remaining = duration
	tick_timer = 0.0


func add_stack() -> bool:
	"""Add a stack if possible. Returns true if stack was added."""
	if stacks < max_stacks:
		stacks += 1
		return true
	return false


func refresh() -> void:
	"""Refresh duration without adding stacks"""
	time_remaining = duration


func update(delta: float) -> int:
	"""
	Process effect for one frame.
	Returns damage dealt this frame (0 if no damage tick occurred).
	"""
	if duration != INF:
		time_remaining -= delta

	tick_timer += delta

	if tick_timer >= tick_interval and damage_per_tick > 0:
		tick_timer -= tick_interval
		# Bleed damage scales with stacks
		if type == Type.BLEED:
			return int(damage_per_tick * stacks)
		return int(damage_per_tick)

	return 0


func is_expired() -> bool:
	"""Check if effect has expired"""
	if duration == INF:
		return false
	return time_remaining <= 0


func get_color() -> Color:
	"""Get the visual tint color for this effect"""
	match type:
		Type.BURN:
			return Color(1.5, 0.6, 0.2)  # Orange
		Type.FREEZE:
			return Color(0.5, 0.8, 1.3)  # Ice blue
		Type.POISON:
			return Color(0.4, 1.2, 0.4)  # Green
		Type.BLEED:
			return Color(1.3, 0.3, 0.3)  # Red
	return Color.WHITE


func get_type_name() -> String:
	"""Get human-readable name for this effect type"""
	match type:
		Type.BURN:
			return "Burn"
		Type.FREEZE:
			return "Freeze"
		Type.POISON:
			return "Poison"
		Type.BLEED:
			return "Bleed"
	return "Unknown"
