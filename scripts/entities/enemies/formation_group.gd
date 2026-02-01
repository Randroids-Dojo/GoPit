extends RefCounted
## Tracks a group of enemies spawned in formation
## Coordinates their descent so they maintain relative positions

signal formation_dissolved

const DISSOLUTION_THRESHOLD: float = 0.5  # Dissolve when < 50% members remain

var leader = null  # First enemy is leader
var members: Array = []  # Enemy nodes
var offsets: Array = []  # Vector2 offsets from leader
var is_active: bool = true
var _initial_count: int = 0


func setup(enemies: Array) -> void:
	"""Initialize formation with spawned enemies"""
	if enemies.is_empty():
		return

	members = enemies.duplicate()
	_initial_count = members.size()
	leader = members[0]

	# Calculate offsets from leader
	offsets.clear()
	for enemy in members:
		var offset = enemy.global_position - leader.global_position
		offsets.append(offset)
		# Connect death signal
		if enemy.has_signal("died") and not enemy.died.is_connected(_on_member_died):
			enemy.died.connect(_on_member_died)


func update(_delta: float) -> void:
	"""Update follower positions to match leader"""
	if not is_active:
		return

	# Check if leader still valid
	if not is_instance_valid(leader) or leader.hp <= 0:
		_try_promote_new_leader()
		if not is_active:
			return

	# Update follower positions
	for i in range(members.size()):
		var member = members[i]
		if member == leader:
			continue
		if not is_instance_valid(member) or member.hp <= 0:
			continue

		# Check if member is attacking - remove from formation control
		if member.get("current_state") != null and member.current_state >= 2:
			continue

		# Maintain relative position to leader
		var target_pos = leader.global_position + offsets[i]
		member.global_position = target_pos


func _try_promote_new_leader() -> void:
	"""Promote next valid member to leader"""
	leader = null
	for member in members:
		if is_instance_valid(member) and member.hp > 0:
			leader = member
			_recalculate_offsets()
			break

	if not leader:
		dissolve()


func _recalculate_offsets() -> void:
	"""Recalculate offsets when leader changes"""
	if not leader:
		return

	var new_offsets: Array = []
	for member in members:
		if is_instance_valid(member):
			new_offsets.append(member.global_position - leader.global_position)
		else:
			new_offsets.append(Vector2.ZERO)
	offsets = new_offsets


func _on_member_died(_enemy) -> void:
	"""Handle member death"""
	var alive_count := _count_alive_members()
	if float(alive_count) / float(_initial_count) < DISSOLUTION_THRESHOLD:
		dissolve()


func _count_alive_members() -> int:
	var count := 0
	for member in members:
		if is_instance_valid(member) and member.hp > 0:
			count += 1
	return count


func dissolve() -> void:
	"""Dissolve the formation - all members move independently"""
	if not is_active:
		return
	is_active = false
	formation_dissolved.emit()


func has_active_members() -> bool:
	return _count_alive_members() > 0
