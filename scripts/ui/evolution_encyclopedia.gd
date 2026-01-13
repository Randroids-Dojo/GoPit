extends CanvasLayer
## Evolution Encyclopedia - Shows all evolution recipes and their effects
## Accessible from the pause menu for player reference

signal closed

@onready var dim_background: ColorRect = $DimBackground
@onready var panel: Panel = $DimBackground/Panel
@onready var title_label: Label = $DimBackground/Panel/VBoxContainer/TitleLabel
@onready var close_button: Button = $DimBackground/Panel/VBoxContainer/CloseButton
@onready var scroll_container: ScrollContainer = $DimBackground/Panel/VBoxContainer/ScrollContainer
@onready var evolution_list: VBoxContainer = $DimBackground/Panel/VBoxContainer/ScrollContainer/EvolutionList


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	if close_button:
		close_button.pressed.connect(_on_close_pressed)


func show_encyclopedia() -> void:
	"""Show the encyclopedia overlay"""
	_populate_evolutions()
	visible = true


func _populate_evolutions() -> void:
	"""Populate the evolution list with all recipes"""
	# Clear existing entries
	for child in evolution_list.get_children():
		child.queue_free()

	# Add all evolution recipes
	for recipe_key in FusionRegistry.EVOLUTION_RECIPES:
		var evolved_type: FusionRegistry.EvolvedBallType = FusionRegistry.EVOLUTION_RECIPES[recipe_key]
		var evolved_data: Dictionary = FusionRegistry.get_evolved_ball_data(evolved_type)

		# Parse recipe key to get ball types (e.g., "BURN_IRON" -> [BURN, IRON])
		var parts: PackedStringArray = recipe_key.split("_")
		if parts.size() != 2:
			continue

		var ball_a_name: String = parts[0].capitalize()
		var ball_b_name: String = parts[1].capitalize()

		# Create entry container
		var entry := _create_entry(ball_a_name, ball_b_name, evolved_data)
		evolution_list.add_child(entry)


func _create_entry(ball_a: String, ball_b: String, evolved_data: Dictionary) -> Control:
	"""Create a single evolution entry"""
	var container := PanelContainer.new()
	container.custom_minimum_size = Vector2(0, 80)

	# Style the container
	var style := StyleBoxFlat.new()
	var evo_color: Color = evolved_data.get("color", Color.WHITE)
	style.bg_color = evo_color.darkened(0.7)
	style.set_border_width_all(2)
	style.border_color = evo_color.darkened(0.3)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	container.add_theme_stylebox_override("panel", style)

	# Content
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	# Recipe line
	var recipe_label := Label.new()
	recipe_label.text = "%s + %s = %s" % [ball_a, ball_b, evolved_data.get("name", "???")]
	recipe_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(recipe_label)

	# Description line
	var desc_label := Label.new()
	desc_label.text = evolved_data.get("description", "No description")
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.modulate = Color(0.8, 0.8, 0.8)
	vbox.add_child(desc_label)

	# Stats line
	var stats_label := Label.new()
	var damage: int = evolved_data.get("base_damage", 0)
	var speed: float = evolved_data.get("base_speed", 0.0)
	stats_label.text = "Damage: %d | Speed: %d" % [damage, int(speed)]
	stats_label.add_theme_font_size_override("font_size", 11)
	stats_label.modulate = Color(0.6, 0.6, 0.6)
	vbox.add_child(stats_label)

	container.add_child(vbox)
	return container


func _on_close_pressed() -> void:
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
