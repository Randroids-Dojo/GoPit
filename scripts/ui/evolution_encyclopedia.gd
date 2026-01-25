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
	"""Populate the evolution list with all recipes.
	Discovered recipes show full details, undiscovered show '???' hints."""
	# Get evolution_list dynamically if @onready hasn't resolved
	var evo_list: VBoxContainer = evolution_list
	if not evo_list:
		evo_list = get_node_or_null("DimBackground/Panel/VBoxContainer/ScrollContainer/EvolutionList")
	if not evo_list:
		return
	evolution_list = evo_list  # Cache for future use

	# Clear existing entries
	for child in evolution_list.get_children():
		child.queue_free()

	# Add section header for Tier 1 evolutions
	var tier1_header := _create_section_header("TIER 1 EVOLUTIONS", Color(0.6, 0.8, 1.0))
	evolution_list.add_child(tier1_header)

	# Add all Tier 1 evolution recipes
	for recipe_key in FusionRegistry.EVOLUTION_RECIPES:
		var evolved_type: FusionRegistry.EvolvedBallType = FusionRegistry.EVOLUTION_RECIPES[recipe_key]
		var evolved_data: Dictionary = FusionRegistry.get_evolved_ball_data(evolved_type)
		var is_discovered: bool = FusionRegistry.is_recipe_discovered(recipe_key)

		# Parse recipe key to get ball types (e.g., "BURN_IRON" -> [BURN, IRON])
		var parts: PackedStringArray = recipe_key.split("_")
		if parts.size() != 2:
			continue

		var ball_a_name: String = parts[0].capitalize()
		var ball_b_name: String = parts[1].capitalize()

		# Create entry container
		var entry := _create_entry(ball_a_name, ball_b_name, evolved_data, is_discovered)
		evolution_list.add_child(entry)

	# Add section for multi-evolutions
	var multi_header := _create_section_header("TIER 2 MULTI-EVOLUTIONS", Color(1.0, 0.8, 0.4))
	evolution_list.add_child(multi_header)
	_populate_multi_evolutions()

	# Add section for ultimate fusions
	var ult_header := _create_section_header("TIER 4 ULTIMATE FUSIONS", Color(1.0, 0.5, 0.8))
	evolution_list.add_child(ult_header)
	_populate_ultimate_fusions()


func _create_section_header(text: String, color: Color) -> Control:
	"""Create a section header label."""
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(0, 40)
	return label


func _populate_multi_evolutions() -> void:
	"""Populate multi-evolution recipes."""
	if not evolution_list:
		return
	for recipe_key in FusionRegistry.MULTI_EVOLUTION_RECIPES:
		var result: FusionRegistry.EvolvedBallType = FusionRegistry.MULTI_EVOLUTION_RECIPES[recipe_key]
		var result_data: Dictionary = FusionRegistry.get_evolved_ball_data(result)
		var is_discovered: bool = FusionRegistry.is_recipe_discovered(recipe_key)

		# Parse recipe key (e.g., "BOMB_POISON" -> evolved_BOMB + basic_POISON)
		var parts: PackedStringArray = recipe_key.split("_")
		if parts.size() != 2:
			continue

		var evolved_name: String = parts[0].capitalize()
		var basic_name: String = parts[1].capitalize()

		var entry := _create_multi_entry(evolved_name, basic_name, result_data, is_discovered)
		evolution_list.add_child(entry)


func _populate_ultimate_fusions() -> void:
	"""Populate ultimate fusion recipes."""
	if not evolution_list:
		return
	for recipe_key in FusionRegistry.ULTIMATE_RECIPES:
		var result: FusionRegistry.EvolvedBallType = FusionRegistry.ULTIMATE_RECIPES[recipe_key]
		var result_data: Dictionary = FusionRegistry.get_evolved_ball_data(result)
		var is_discovered: bool = FusionRegistry.is_recipe_discovered(recipe_key)

		# Parse recipe key (e.g., "BOMB_STORM_VIRUS")
		var parts: PackedStringArray = recipe_key.split("_")
		if parts.size() != 3:
			continue

		var entry := _create_ultimate_entry(parts, result_data, is_discovered)
		evolution_list.add_child(entry)


func _create_entry(ball_a: String, ball_b: String, evolved_data: Dictionary, is_discovered: bool = true) -> Control:
	"""Create a single evolution entry. Shows '???' for undiscovered recipes."""
	var container := PanelContainer.new()
	container.custom_minimum_size = Vector2(0, 80)

	# Style the container
	var style := StyleBoxFlat.new()
	var evo_color: Color = evolved_data.get("color", Color.WHITE) if is_discovered else Color(0.3, 0.3, 0.3)
	style.bg_color = evo_color.darkened(0.7)
	style.set_border_width_all(2)
	style.border_color = evo_color.darkened(0.3) if is_discovered else Color(0.4, 0.4, 0.4)
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
	if is_discovered:
		recipe_label.text = "%s + %s = %s" % [ball_a, ball_b, evolved_data.get("name", "???")]
	else:
		recipe_label.text = "%s + %s = ???" % [ball_a, ball_b]
	recipe_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(recipe_label)

	# Description line
	var desc_label := Label.new()
	if is_discovered:
		desc_label.text = evolved_data.get("description", "No description")
	else:
		desc_label.text = "Combine these balls to discover the result!"
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.modulate = Color(0.8, 0.8, 0.8) if is_discovered else Color(0.5, 0.5, 0.5)
	vbox.add_child(desc_label)

	# Stats line (only show for discovered)
	if is_discovered:
		var stats_label := Label.new()
		var damage: int = evolved_data.get("base_damage", 0)
		var speed: float = evolved_data.get("base_speed", 0.0)
		stats_label.text = "Damage: %d | Speed: %d" % [damage, int(speed)]
		stats_label.add_theme_font_size_override("font_size", 11)
		stats_label.modulate = Color(0.6, 0.6, 0.6)
		vbox.add_child(stats_label)

	container.add_child(vbox)
	return container


func _create_multi_entry(evolved_name: String, basic_name: String, result_data: Dictionary, is_discovered: bool = true) -> Control:
	"""Create a multi-evolution entry. Shows '???' for undiscovered recipes."""
	var container := PanelContainer.new()
	container.custom_minimum_size = Vector2(0, 70)

	var style := StyleBoxFlat.new()
	var evo_color: Color = result_data.get("color", Color.WHITE) if is_discovered else Color(0.3, 0.3, 0.3)
	style.bg_color = evo_color.darkened(0.6)
	style.set_border_width_all(2)
	style.border_color = evo_color.darkened(0.2) if is_discovered else Color(0.4, 0.4, 0.4)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	container.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)

	var recipe_label := Label.new()
	if is_discovered:
		recipe_label.text = "%s (L3) + %s (L3) = %s" % [evolved_name, basic_name, result_data.get("name", "???")]
	else:
		recipe_label.text = "%s (L3) + %s (L3) = ???" % [evolved_name, basic_name]
	recipe_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(recipe_label)

	var desc_label := Label.new()
	if is_discovered:
		desc_label.text = result_data.get("description", "")
	else:
		desc_label.text = "Level evolved ball to L3 and combine with basic L3!"
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.modulate = Color(0.7, 0.7, 0.7) if is_discovered else Color(0.5, 0.5, 0.5)
	vbox.add_child(desc_label)

	container.add_child(vbox)
	return container


func _create_ultimate_entry(ingredient_names: PackedStringArray, result_data: Dictionary, is_discovered: bool = true) -> Control:
	"""Create an ultimate fusion entry. Shows '???' for undiscovered recipes."""
	var container := PanelContainer.new()
	container.custom_minimum_size = Vector2(0, 80)

	var style := StyleBoxFlat.new()
	var evo_color: Color = result_data.get("color", Color.WHITE) if is_discovered else Color(0.25, 0.2, 0.3)
	style.bg_color = evo_color.darkened(0.5)
	style.set_border_width_all(3)
	style.border_color = evo_color.lightened(0.2) if is_discovered else Color(0.4, 0.35, 0.45)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	container.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	var recipe_label := Label.new()
	var name_a: String = ingredient_names[0].capitalize() if ingredient_names.size() > 0 else "?"
	var name_b: String = ingredient_names[1].capitalize() if ingredient_names.size() > 1 else "?"
	var name_c: String = ingredient_names[2].capitalize() if ingredient_names.size() > 2 else "?"
	if is_discovered:
		recipe_label.text = "%s + %s + %s = %s" % [name_a, name_b, name_c, result_data.get("name", "???")]
	else:
		recipe_label.text = "%s + %s + %s = ???" % [name_a, name_b, name_c]
	recipe_label.add_theme_font_size_override("font_size", 15)
	vbox.add_child(recipe_label)

	var desc_label := Label.new()
	if is_discovered:
		desc_label.text = result_data.get("description", "Legendary power!")
	else:
		desc_label.text = "Combine three L3 evolved balls to unlock legendary power!"
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.modulate = Color(0.85, 0.85, 0.85) if is_discovered else Color(0.5, 0.5, 0.5)
	vbox.add_child(desc_label)

	container.add_child(vbox)
	return container


func _on_close_pressed() -> void:
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
