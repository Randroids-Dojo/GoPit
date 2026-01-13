extends Label
## Floating damage number that rises and fades out

var _tween: Tween


func _ready() -> void:
	# Set up appearance
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func animate() -> void:
	"""Start the rise and fade animation - call after configuring text/position"""
	# Kill any existing tween
	if _tween and _tween.is_valid():
		_tween.kill()

	# Animate: rise up and fade out
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "position:y", position.y - 60, 0.6).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", 0.0, 0.6).set_delay(0.2)
	_tween.set_parallel(false)
	_tween.tween_callback(_on_animation_complete)


func _on_animation_complete() -> void:
	"""Return to pool or free when animation completes"""
	if has_meta("pooled") and PoolManager:
		reset()
		PoolManager.release_damage_number(self)
	else:
		queue_free()


func reset() -> void:
	"""Reset for object pool reuse"""
	# Kill any running tween
	if _tween and _tween.is_valid():
		_tween.kill()
		_tween = null

	# Reset visual state
	text = ""
	modulate = Color.WHITE
	scale = Vector2.ONE
	position = Vector2.ZERO


static func spawn(parent: Node, pos: Vector2, value: int, text_color: Color = Color.WHITE, prefix: String = "") -> void:
	var label: Label

	# Get from pool if available
	if PoolManager:
		label = PoolManager.get_damage_number()
	else:
		var scene := preload("res://scenes/effects/damage_number.tscn")
		label = scene.instantiate()

	label.text = prefix + str(value)
	label.position = pos + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	label.modulate = text_color
	label.z_index = 100
	parent.add_child(label)

	# Start animation (pooled or not)
	if label.has_method("animate"):
		label.animate()


static func spawn_text(parent: Node, pos: Vector2, text: String, text_color: Color = Color.WHITE) -> void:
	"""Spawn floating text (like 'EXECUTE') instead of a number"""
	var label: Label

	# Get from pool if available
	if PoolManager:
		label = PoolManager.get_damage_number()
	else:
		var scene := preload("res://scenes/effects/damage_number.tscn")
		label = scene.instantiate()

	label.text = text
	label.position = pos + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	label.modulate = text_color
	label.z_index = 100
	parent.add_child(label)

	# Start animation (pooled or not)
	if label.has_method("animate"):
		label.animate()
