extends HBoxContainer
## Displays 5 passive slots in the HUD
## Shows equipped passives and their current stack/level

const MAX_SLOTS: int = 5

# Slot container references (will be created dynamically)
var _slots: Array[PanelContainer] = []

# Colors for different passive categories
const CATEGORY_COLORS := {
	"offensive": Color(0.9, 0.3, 0.3),  # Red
	"defensive": Color(0.3, 0.7, 0.3),  # Green
	"utility": Color(0.3, 0.5, 0.9),    # Blue
	"summoner": Color(0.9, 0.6, 0.2),   # Orange
}

# Map passives to categories
const PASSIVE_CATEGORIES := {
	# Offensive (original)
	0: "offensive",  # DAMAGE
	4: "offensive",  # BALL_SPEED
	7: "offensive",  # CRITICAL
	# Defensive (original)
	2: "defensive",  # MAX_HP
	# Utility (original)
	1: "utility",    # FIRE_RATE
	3: "utility",    # MULTI_SHOT
	5: "utility",    # PIERCING
	6: "utility",    # RICOCHET
	8: "utility",    # MAGNETISM
	# Summoner (original)
	9: "summoner",   # LEADERSHIP
	# New passives (10-19)
	10: "defensive",  # ARMOR
	11: "defensive",  # THORNS
	12: "defensive",  # HEALTH_REGEN
	13: "utility",    # DOUBLE_XP
	14: "offensive",  # KNOCKBACK
	15: "offensive",  # AREA_DAMAGE
	16: "offensive",  # STATUS_DURATION
	17: "defensive",  # DODGE
	18: "offensive",  # LIFE_STEAL
	19: "offensive",  # SPREAD_SHOT
}


func _ready() -> void:
	_create_slots()
	_update_display()
	# Connect to FusionRegistry for automatic updates
	if FusionRegistry:
		FusionRegistry.passive_slots_changed.connect(refresh)


func _create_slots() -> void:
	"""Create the 5 passive slot containers"""
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
	"""Update slot display based on current passives"""
	if not FusionRegistry:
		return

	# Get equipped passives and unlocked slot count
	var equipped_passives := FusionRegistry.get_equipped_passives()
	var unlocked_slots := FusionRegistry.get_unlocked_passive_slots()

	for i in MAX_SLOTS:
		var slot: PanelContainer = _slots[i]
		var vbox: VBoxContainer = slot.get_child(0)
		var icon_label: Label = vbox.get_node("IconLabel")
		var level_label: Label = vbox.get_node("LevelLabel")
		var style: StyleBoxFlat = slot.get_theme_stylebox("panel")

		var is_locked := i >= unlocked_slots

		if is_locked:
			# Locked slot
			icon_label.text = "🔒"
			icon_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
			level_label.visible = false
			style.border_color = Color(0.2, 0.2, 0.25, 0.4)
			slot.modulate.a = 0.5  # Grayed out
		else:
			# Find passive in slot i (if any)
			var passive_data: Dictionary = {}
			for eq in equipped_passives:
				if eq["slot"] == i:
					passive_data = eq
					break

			if not passive_data.is_empty():
				var passive_type: int = passive_data["type"]
				var level: int = passive_data["level"]

				# Get passive info
				var passive_name: String = FusionRegistry.get_passive_name(passive_type)
				var category: String = PASSIVE_CATEGORIES.get(passive_type, "utility")
				var color: Color = CATEGORY_COLORS.get(category, Color.WHITE)

				# Update icon (first 2 letters of name)
				icon_label.text = passive_name.substr(0, 2).to_upper()
				icon_label.add_theme_color_override("font_color", color)

				# Update level
				level_label.text = "L%d" % level
				level_label.visible = true

				# Update border color to match category
				style.border_color = color.lerp(Color.WHITE, 0.3)
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
