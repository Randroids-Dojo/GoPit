class_name FormationGroup
extends RefCounted
## Tracks a group of enemies spawned in formation
## Coordinates their descent so they maintain relative positions

signal formation_dissolved(group: FormationGroup)

const DISSOLUTION_THRESHOLD: float = 0.5  # Dissolve when < 50% members remain

var leader: Node2D  # First enemy is leader, others follow (EnemyBase type)
var members: Array = []  # Array of EnemyBase nodes
var offsets: Array[Vector2] = []  # Relative offsets from leader
var is_active: bool = true
var _initial_count: int = 0


func setup(enemies: Array) -> void:
	"""Initialize formation with spawned enemies"""
	if enemies.is_empty():
		return

	members = enemies.duplicate()
	_initial_count = members.size()
	leader = members[0]

	# Calculate and store offsets from leader
	offsets.clear()
	for enemy in members:
		var offset := enemy.global_position - leader.global_position
		offsets.append(offset)
		# Mark enemy as formation member
		enemy.set_meta("formation_member", true)
		enemy.set_meta("formation_group", self)
		# Connect death signal
		if not enemy.died.is_connected(_on_member_died):
			enemy.died.connect(_on_member_died)


func update(delta: float) -> void:
	"""Update follower positions to match leader"""
	if not is_active:
		return

	# Check if leader still valid
	if not is_instance_valid(leader) or leader.hp <= 0:
		_try_promote_new_leader()
		if not is_active:
			return

	# Update follower positions relative to leader
	for i in range(members.size()):
		var member := members[i]
		if member == leader:
			continue
		if not is_instance_valid(member) or member.hp <= 0:
			continue

		# Check if member entered attack mode - remove from formation
		# Use duck-typing to avoid class resolution issues in headless mode
		if member.has_method("get") and member.get("current_state") in [2, 3]:  # ATTACKING=2, WARNING=3
			_remove_member(member)
			continue

		# Maintain relative position to leader
		var target_pos := leader.global_position + offsets[i]
		member.global_position = target_pos


func _try_promote_new_leader() -> void:
	"""Promote next valid member to leader"""
	leader = null
	for member in members:
		if is_instance_valid(member) and member.hp > 0:
			leader = member
			# Recalculate offsets relative to new leader
			_recalculate_offsets()
			break

	if not leader:
		dissolve()


func _recalculate_offsets() -> void:
	"""Recalculate offsets when leader changes"""
	if not leader:
		return

	var new_offsets: Array[Vector2] = []
	for member in members:
		if is_instance_valid(member):
			new_offsets.append(member.global_position - leader.global_position)
		else:
			new_offsets.append(Vector2.ZERO)
	offsets = new_offsets


func _remove_member(enemy: Node) -> void:
	"""Remove a member from formation tracking"""
	var idx := members.find(enemy)
	if idx >= 0:
		enemy.remove_meta("formation_member")
		enemy.remove_meta("formation_group")

	# Check dissolution threshold
	var alive_count := _count_alive_members()
	if float(alive_count) / float(_initial_count) < DISSOLUTION_THRESHOLD:
		dissolve()


func _count_alive_members() -> int:
	var count := 0
	for member in members:
		if is_instance_valid(member) and member.hp > 0:
			count += 1
	return count


func _on_member_died(enemy: Node) -> void:
	"""Handle member death"""
	_remove_member(enemy)

	# If leader died, try to promote
	if enemy == leader:
		_try_promote_new_leader()


func dissolve() -> void:
	"""Dissolve the formation - all members move independently"""
	if not is_active:
		return

	is_active = false

	# Clear formation metadata from surviving members
	for member in members:
		if is_instance_valid(member):
			if member.has_meta("formation_member"):
				member.remove_meta("formation_member")
			if member.has_meta("formation_group"):
				member.remove_meta("formation_group")

	formation_dissolved.emit(self)


func has_active_members() -> bool:
	"""Check if any members are still alive"""
	return _count_alive_members() > 0
