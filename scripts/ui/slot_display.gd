extends HBoxContainer
## Displays equipped ball slots in the HUD
## Shows all slots, filled ones with ball type icon and level, empty ones with "+"

const BALL_ICONS := {
	BallRegistry.BallType.BASIC: "O",
	BallRegistry.BallType.BURN: "F",
	BallRegistry.BallType.FREEZE: "I",
	BallRegistry.BallType.POISON: "P",
	BallRegistry.BallType.BLEED: "B",
	BallRegistry.BallType.LIGHTNING: "L",
	BallRegistry.BallType.IRON: "M",
}

var slot_labels: Array[Label] = []


func _ready() -> void:
	_create_slot_labels()
	_update_display()
	BallRegistry.slot_changed.connect(_on_slot_changed)


func _create_slot_labels() -> void:
	# Clear existing children
	for child in get_children():
		child.queue_free()
	slot_labels.clear()

	# Create a label for each slot
	for i in range(BallRegistry.MAX_SLOTS):
		var label := Label.new()
		label.custom_minimum_size = Vector2(50, 40)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		add_child(label)
		slot_labels.append(label)


func _update_display() -> void:
	for i in range(BallRegistry.MAX_SLOTS):
		_update_slot(i)


func _update_slot(index: int) -> void:
	if index >= slot_labels.size():
		return

	var label := slot_labels[index]
	var slot = BallRegistry.ball_slots[index] if index < BallRegistry.ball_slots.size() else null

	if slot == null:
		# Empty slot
		label.text = "[+]"
		label.modulate = Color(0.5, 0.5, 0.5, 0.5)
	else:
		# Filled slot: show icon and level
		var ball_type: BallRegistry.BallType = slot.ball_type
		var level: int = slot.level
		var icon: String = BALL_ICONS.get(ball_type, "?")
		label.text = "[%s%d]" % [icon, level]
		label.modulate = BallRegistry.get_color(ball_type)


func _on_slot_changed(_slot_index: int, _ball_type) -> void:
	_update_display()
