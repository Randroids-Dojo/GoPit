extends HBoxContainer
## Displays 5 ball slots in the HUD
## Shows equipped balls and their current level

const MAX_SLOTS: int = 5

# Slot container references (will be created dynamically)
var _slots: Array[PanelContainer] = []


func _ready() -> void:
	_create_slots()
	_update_display()
	# Connect to BallRegistry for automatic updates
	if BallRegistry:
		BallRegistry.slots_changed.connect(refresh)


func _create_slots() -> void:
	"""Create the 5 ball slot containers"""
	for i in MAX_SLOTS:
		var slot := _create_slot_container()
		add_child(slot)
		_slots.append(slot)


func _create_slot_container() -> PanelContainer:
	"""Create a single slot container with label"""
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(60, 60)

	# Style the panel
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.5, 0.8)
	panel.add_theme_stylebox_override("panel", style)

	# Add container for content
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# Icon/letter label (short name)
	var icon_label := Label.new()
	icon_label.name = "IconLabel"
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 20)
	icon_label.text = ""
	vbox.add_child(icon_label)

	# Level indicator
	var level_label := Label.new()
	level_label.name = "LevelLabel"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 12)
	level_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	level_label.text = ""
	vbox.add_child(level_label)

	return panel


func _update_display() -> void:
	"""Update slot display based on current ball slots"""
	if not BallRegistry:
		return

	# Get all active ball slots (includes -1 for empty slots)
	var ball_slots := BallRegistry.get_active_slots()
	var unlocked_slots := BallRegistry.get_unlocked_slots()

	for i in MAX_SLOTS:
		var slot: PanelContainer = _slots[i]
		var vbox: VBoxContainer = slot.get_child(0)
		var icon_label: Label = vbox.get_node("IconLabel")
		var level_label: Label = vbox.get_node("LevelLabel")
		var style: StyleBoxFlat = slot.get_theme_stylebox("panel")

		var is_locked := i >= unlocked_slots
		var ball_type: int = ball_slots[i]

		if is_locked:
			# Locked slot
			icon_label.text = "🔒"
			icon_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
			level_label.visible = false
			style.border_color = Color(0.2, 0.2, 0.25, 0.4)
			slot.modulate.a = 0.5  # Grayed out
		elif ball_type != -1:
			# Slot has a ball equipped
			var ball_data: Dictionary = BallRegistry.BALL_DATA.get(ball_type, {})
			var ball_name: String = ball_data.get("name", "???")
			var ball_color: Color = ball_data.get("color", Color.WHITE)
			var ball_level: int = BallRegistry.get_ball_level(ball_type)

			# Update icon (first 2 letters of ball name)
			icon_label.text = ball_name.substr(0, 2).to_upper()
			icon_label.add_theme_color_override("font_color", ball_color)

			# Update level
			level_label.text = "L%d" % ball_level
			level_label.visible = true

			# Update border color to match ball color
			style.border_color = ball_color.lerp(Color.WHITE, 0.3)
			slot.modulate.a = 1.0  # Full opacity
		else:
			# Empty unlocked slot
			icon_label.text = "+"
			icon_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
			level_label.visible = false
			style.border_color = Color(0.3, 0.3, 0.35, 0.6)
			slot.modulate.a = 1.0  # Full opacity


func refresh() -> void:
	"""Public method to refresh display"""
	_update_display()
