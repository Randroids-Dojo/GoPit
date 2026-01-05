extends Label
## Floating damage number that rises and fades out


func _ready() -> void:
	# Set up appearance
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Animate: rise up and fade out
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 60, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_delay(0.2)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)


static func spawn(parent: Node, pos: Vector2, damage: int, damage_color: Color = Color.WHITE) -> void:
	var scene := preload("res://scenes/effects/damage_number.tscn")
	var label: Label = scene.instantiate()
	label.text = str(damage)
	label.position = pos + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	label.modulate = damage_color
	label.z_index = 100
	parent.add_child(label)
