extends Node
## Manages object pools for performance optimization
## Reduces GC pressure by reusing nodes instead of instantiating/freeing

# Pool for balls
var _ball_pool: Array[Node] = []
var _ball_scene: PackedScene

# Pool for damage numbers
var _damage_pool: Array[Label] = []
var _damage_scene: PackedScene

# Configuration
const BALL_POOL_INITIAL_SIZE := 20
const BALL_POOL_MAX_SIZE := 50
const DAMAGE_POOL_INITIAL_SIZE := 30
const DAMAGE_POOL_MAX_SIZE := 100


func _ready() -> void:
	# Preload scenes
	_ball_scene = load("res://scenes/entities/ball.tscn")
	_damage_scene = load("res://scenes/effects/damage_number.tscn")

	# Pre-warm pools
	_prewarm_ball_pool()
	_prewarm_damage_pool()


func _prewarm_ball_pool() -> void:
	for i in range(BALL_POOL_INITIAL_SIZE):
		var ball := _ball_scene.instantiate()
		ball.set_meta("pooled", true)
		_deactivate_ball(ball)
		_ball_pool.append(ball)


func _prewarm_damage_pool() -> void:
	for i in range(DAMAGE_POOL_INITIAL_SIZE):
		var label: Label = _damage_scene.instantiate()
		label.set_meta("pooled", true)
		_deactivate_damage(label)
		_damage_pool.append(label)


# ============================================================================
# Ball Pool Methods
# ============================================================================

func get_ball() -> Node:
	var ball: Node

	if _ball_pool.size() > 0:
		ball = _ball_pool.pop_back()
	else:
		# Pool exhausted, create new instance
		ball = _ball_scene.instantiate()
		ball.set_meta("pooled", true)

	_activate_ball(ball)
	return ball


func release_ball(ball: Node) -> void:
	if not is_instance_valid(ball):
		return

	# Don't pool non-pooled balls (safety check)
	if not ball.has_meta("pooled"):
		ball.queue_free()
		return

	# Enforce max pool size
	if _ball_pool.size() >= BALL_POOL_MAX_SIZE:
		ball.queue_free()
		return

	_deactivate_ball(ball)
	_ball_pool.append(ball)


func _activate_ball(ball: Node) -> void:
	ball.set_physics_process(true)
	ball.set_process(true)
	ball.visible = true
	# Reset will be called by the spawner after configuration


func _deactivate_ball(ball: Node) -> void:
	ball.set_physics_process(false)
	ball.set_process(false)
	ball.visible = false

	# Remove from parent if attached
	if ball.get_parent():
		ball.get_parent().remove_child(ball)


# ============================================================================
# Damage Number Pool Methods
# ============================================================================

func get_damage_number() -> Label:
	var label: Label

	if _damage_pool.size() > 0:
		label = _damage_pool.pop_back()
	else:
		# Pool exhausted, create new instance
		label = _damage_scene.instantiate()
		label.set_meta("pooled", true)

	_activate_damage(label)
	return label


func release_damage_number(label: Label) -> void:
	if not is_instance_valid(label):
		return

	# Don't pool non-pooled labels
	if not label.has_meta("pooled"):
		label.queue_free()
		return

	# Enforce max pool size
	if _damage_pool.size() >= DAMAGE_POOL_MAX_SIZE:
		label.queue_free()
		return

	_deactivate_damage(label)
	_damage_pool.append(label)


func _activate_damage(label: Label) -> void:
	label.visible = true
	label.modulate.a = 1.0
	label.scale = Vector2.ONE


func _deactivate_damage(label: Label) -> void:
	label.visible = false

	# Tween cleanup is handled by the label's reset() method

	# Remove from parent if attached
	if label.get_parent():
		label.get_parent().remove_child(label)


# ============================================================================
# Debug / Stats
# ============================================================================

func get_pool_stats() -> Dictionary:
	return {
		"ball_pool_available": _ball_pool.size(),
		"damage_pool_available": _damage_pool.size(),
	}
