extends Control
## Fusion Overlay - Shows when player collects a Fusion Reactor
## Five options: Fission (random), Fusion (2 L3s), Evolution (recipes),
## Multi-Evolution (evolved L3 + basic L3), Ultimate (3 evolved L3s)

signal action_completed(action_type: String, result: Variant)

enum Tab { FISSION, FUSION, EVOLUTION, MULTI_EVOLUTION, ULTIMATE }

@onready var tab_container: HBoxContainer = $Panel/VBoxContainer/TabButtons
@onready var content_container: VBoxContainer = $Panel/VBoxContainer/ContentContainer
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var fission_button: Button = $Panel/VBoxContainer/TabButtons/FissionTab
@onready var fusion_button: Button = $Panel/VBoxContainer/TabButtons/FusionTab
@onready var evolution_button: Button = $Panel/VBoxContainer/TabButtons/EvolutionTab
@onready var confirm_button: Button = $Panel/VBoxContainer/ConfirmButton
@onready var description_label: Label = $Panel/VBoxContainer/DescriptionLabel

# Dynamically created tab buttons for multi-evolution and ultimate
var multi_evo_button: Button = null
var ultimate_button: Button = null

# Ball selection grid (for Fusion/Evolution tabs)
@onready var ball_grid: GridContainer = $Panel/VBoxContainer/ContentContainer/BallGrid
# Preview area for fusion result
@onready var preview_container: HBoxContainer = $Panel/VBoxContainer/ContentContainer/PreviewContainer
@onready var preview_label: Label = $Panel/VBoxContainer/ContentContainer/PreviewContainer/PreviewLabel

var _current_tab: Tab = Tab.FISSION
var _selected_balls: Array[BallRegistry.BallType] = []
var _selected_evolved_balls: Array[FusionRegistry.EvolvedBallType] = []  # For multi/ultimate
var _ball_buttons: Dictionary = {}  # BallType -> Button
var _evolved_buttons: Dictionary = {}  # EvolvedBallType -> Button
var _available_evolutions: Array[Dictionary] = []
var _available_multi_evolutions: Array[Dictionary] = []
var _available_ultimate_fusions: Array[Dictionary] = []


func _ready() -> void:
	visible = false
	# CRITICAL: On web builds, invisible Controls can still block input
	# Set mouse_filter to IGNORE when hidden to allow input pass-through
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect tab buttons
	fission_button.pressed.connect(_on_tab_pressed.bind(Tab.FISSION))
	fusion_button.pressed.connect(_on_tab_pressed.bind(Tab.FUSION))
	evolution_button.pressed.connect(_on_tab_pressed.bind(Tab.EVOLUTION))
	confirm_button.pressed.connect(_on_confirm_pressed)

	# Create multi-evolution and ultimate tab buttons dynamically
	_create_advanced_tab_buttons()


func _create_advanced_tab_buttons() -> void:
	"""Create multi-evolution and ultimate tab buttons"""
	if not tab_container:
		return

	# Create Multi-Evolution button
	multi_evo_button = Button.new()
	multi_evo_button.text = "Multi-Evo"
	multi_evo_button.custom_minimum_size = Vector2(90, 40)
	multi_evo_button.pressed.connect(_on_tab_pressed.bind(Tab.MULTI_EVOLUTION))
	tab_container.add_child(multi_evo_button)

	# Create Ultimate button
	ultimate_button = Button.new()
	ultimate_button.text = "Ultimate"
	ultimate_button.custom_minimum_size = Vector2(90, 40)
	ultimate_button.pressed.connect(_on_tab_pressed.bind(Tab.ULTIMATE))
	tab_container.add_child(ultimate_button)


func show_fusion_ui() -> void:
	"""Called when player collects a Fusion Reactor"""
	_selected_balls.clear()
	_selected_evolved_balls.clear()
	_update_tab_availability()
	_on_tab_pressed(Tab.FISSION)  # Default to Fission
	# Enable input capture when showing overlay
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	get_tree().paused = true


func _update_tab_availability() -> void:
	"""Enable/disable tabs based on current ball inventory"""
	var fusion_ready := BallRegistry.get_fusion_ready_balls()
	var evolved_fusion_ready := FusionRegistry.get_fusion_ready_evolved_balls()

	# Fission is always available
	fission_button.disabled = false
	fission_button.text = "Fission"

	# Fusion requires 2+ L3 balls (that don't have a recipe together, but we allow any combo)
	var can_fuse := fusion_ready.size() >= 2
	fusion_button.disabled = not can_fuse
	fusion_button.text = "Fusion" if can_fuse else "Fusion (Need 2 L3)"

	# Evolution requires at least one valid recipe with owned L3 balls
	_available_evolutions = FusionRegistry.get_available_evolutions()
	var can_evolve := false
	for evo in _available_evolutions:
		if evo["can_create"]:
			can_evolve = true
			break
	evolution_button.disabled = not can_evolve
	evolution_button.text = "Evo" if can_evolve else "Evo (No Recipe)"

	# Multi-Evolution requires L3 evolved ball + L3 basic ball
	_available_multi_evolutions = FusionRegistry.get_available_multi_evolutions()
	var can_multi := false
	for multi in _available_multi_evolutions:
		if multi["can_create"]:
			can_multi = true
			break
	if multi_evo_button:
		multi_evo_button.disabled = not can_multi
		multi_evo_button.text = "Multi" if can_multi else "Multi (Need L3)"

	# Ultimate requires 3+ L3 evolved balls
	_available_ultimate_fusions = FusionRegistry.get_available_ultimate_fusions()
	var can_ultimate := false
	for ult in _available_ultimate_fusions:
		if ult["can_create"]:
			can_ultimate = true
			break
	if ultimate_button:
		ultimate_button.disabled = not can_ultimate
		ultimate_button.text = "Ult" if can_ultimate else "Ult (Need 3 L3)"


func _on_tab_pressed(tab: Tab) -> void:
	_current_tab = tab
	_selected_balls.clear()
	_selected_evolved_balls.clear()

	# Update button states
	fission_button.button_pressed = (tab == Tab.FISSION)
	fusion_button.button_pressed = (tab == Tab.FUSION)
	evolution_button.button_pressed = (tab == Tab.EVOLUTION)
	if multi_evo_button:
		multi_evo_button.button_pressed = (tab == Tab.MULTI_EVOLUTION)
	if ultimate_button:
		ultimate_button.button_pressed = (tab == Tab.ULTIMATE)

	# Update content
	_update_content()


func _update_content() -> void:
	# Clear ball grid
	for child in ball_grid.get_children():
		child.queue_free()
	_ball_buttons.clear()
	_evolved_buttons.clear()

	match _current_tab:
		Tab.FISSION:
			_show_fission_content()
		Tab.FUSION:
			_show_fusion_content()
		Tab.EVOLUTION:
			_show_evolution_content()
		Tab.MULTI_EVOLUTION:
			_show_multi_evolution_content()
		Tab.ULTIMATE:
			_show_ultimate_content()

	_update_preview()
	_update_confirm_button()


func _show_fission_content() -> void:
	title_label.text = "FISSION"
	description_label.text = "Get random ball upgrades or new balls.\nIf all maxed, receive Pit Coins instead."
	ball_grid.visible = false
	preview_container.visible = false


func _show_fusion_content() -> void:
	title_label.text = "FUSION"
	description_label.text = "Select 2 L3 balls to combine.\nThe result has both ball effects."
	ball_grid.visible = true
	preview_container.visible = true

	_populate_ball_grid(BallRegistry.get_fusion_ready_balls(), true)


func _show_evolution_content() -> void:
	title_label.text = "EVOLUTION"
	description_label.text = "Select a recipe to create a unique evolved ball."
	ball_grid.visible = true
	preview_container.visible = true

	# Show available recipes
	_populate_evolution_recipes()


func _show_multi_evolution_content() -> void:
	title_label.text = "MULTI-EVOLUTION"
	description_label.text = "Combine L3 evolved ball with L3 basic ball.\nCreates a powerful Tier 2 evolved ball."
	ball_grid.visible = true
	preview_container.visible = true

	# Show available multi-evolution recipes
	_populate_multi_evolution_recipes()


func _show_ultimate_content() -> void:
	title_label.text = "ULTIMATE FUSION"
	description_label.text = "Combine 3 L3 evolved balls.\nCreates a Legendary Tier 4 ball."
	ball_grid.visible = true
	preview_container.visible = true

	# Show available ultimate fusion recipes
	_populate_ultimate_recipes()


func _populate_ball_grid(balls: Array[BallRegistry.BallType], selectable: bool) -> void:
	"""Create buttons for each ball in the grid"""
	for ball_type in balls:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(100, 80)

		var ball_name := BallRegistry.get_ball_name(ball_type)
		var ball_level := BallRegistry.get_ball_level(ball_type)
		btn.text = "%s\nL%d" % [ball_name, ball_level]

		# Color the button based on ball type
		var ball_color := BallRegistry.get_color(ball_type)
		var style := StyleBoxFlat.new()
		style.bg_color = ball_color.darkened(0.3)
		style.set_border_width_all(2)
		style.border_color = ball_color
		style.set_corner_radius_all(8)
		btn.add_theme_stylebox_override("normal", style)

		if selectable:
			btn.pressed.connect(_on_ball_selected.bind(ball_type))

		ball_grid.add_child(btn)
		_ball_buttons[ball_type] = btn


func _populate_evolution_recipes() -> void:
	"""Show evolution recipes as buttons"""
	for evo in _available_evolutions:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(280, 60)

		var name_a := BallRegistry.get_ball_name(evo["ball_a"])
		var name_b := BallRegistry.get_ball_name(evo["ball_b"])
		var result_name := FusionRegistry.get_evolved_ball_name(evo["result"])

		btn.text = "%s + %s = %s" % [name_a, name_b, result_name]
		btn.disabled = not evo["can_create"]

		if evo["can_create"]:
			var evo_data := FusionRegistry.get_evolved_ball_data(evo["result"])
			var evo_color: Color = evo_data.get("color", Color.WHITE)
			var style := StyleBoxFlat.new()
			style.bg_color = evo_color.darkened(0.5)
			style.set_border_width_all(2)
			style.border_color = evo_color
			style.set_corner_radius_all(8)
			btn.add_theme_stylebox_override("normal", style)
			btn.pressed.connect(_on_evolution_selected.bind(evo))
		else:
			btn.tooltip_text = "Missing: "
			if not evo["has_ball_a"]:
				btn.tooltip_text += name_a + " L3 "
			if not evo["has_ball_b"]:
				btn.tooltip_text += name_b + " L3"

		ball_grid.add_child(btn)


func _populate_multi_evolution_recipes() -> void:
	"""Show multi-evolution recipes as buttons"""
	for multi in _available_multi_evolutions:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(320, 60)

		var evolved_name := FusionRegistry.get_evolved_ball_name(multi["evolved_type"], false)
		var basic_name := BallRegistry.get_ball_name(multi["ball_type"])
		var result_name: String = multi.get("result_name", "Unknown")

		btn.text = "%s + %s = %s" % [evolved_name, basic_name, result_name]
		btn.disabled = not multi["can_create"]

		if multi["can_create"]:
			var result_data := FusionRegistry.get_evolved_ball_data(multi["result"])
			var result_color: Color = result_data.get("color", Color.WHITE)
			var style := StyleBoxFlat.new()
			style.bg_color = result_color.darkened(0.5)
			style.set_border_width_all(2)
			style.border_color = result_color
			style.set_corner_radius_all(8)
			btn.add_theme_stylebox_override("normal", style)
			btn.pressed.connect(_on_multi_evolution_selected.bind(multi))
		else:
			btn.tooltip_text = "Missing: "
			if not multi["has_evolved"]:
				btn.tooltip_text += evolved_name + " L3 "
			if not multi["has_basic"]:
				btn.tooltip_text += basic_name + " L3"

		ball_grid.add_child(btn)


func _populate_ultimate_recipes() -> void:
	"""Show ultimate fusion recipes as buttons"""
	for ult in _available_ultimate_fusions:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(350, 70)

		var types: Array = ult.get("evolved_types", [])
		var type_names: Array[String] = []
		for et in types:
			type_names.append(FusionRegistry.get_evolved_ball_name(et, false))

		var result_name: String = ult.get("result_name", "Unknown")

		btn.text = "%s + %s + %s\n= %s" % [
			type_names[0] if type_names.size() > 0 else "?",
			type_names[1] if type_names.size() > 1 else "?",
			type_names[2] if type_names.size() > 2 else "?",
			result_name
		]
		btn.disabled = not ult["can_create"]

		if ult["can_create"]:
			var result_data := FusionRegistry.get_evolved_ball_data(ult["result"])
			var result_color: Color = result_data.get("color", Color.WHITE)
			var style := StyleBoxFlat.new()
			style.bg_color = result_color.darkened(0.4)
			style.set_border_width_all(3)
			style.border_color = result_color.lightened(0.3)
			style.set_corner_radius_all(10)
			btn.add_theme_stylebox_override("normal", style)
			btn.pressed.connect(_on_ultimate_selected.bind(ult))

		ball_grid.add_child(btn)


func _on_ball_selected(ball_type: BallRegistry.BallType) -> void:
	"""Handle ball selection for Fusion"""
	if ball_type in _selected_balls:
		_selected_balls.erase(ball_type)
	else:
		if _selected_balls.size() < 2:
			_selected_balls.append(ball_type)
		else:
			# Replace oldest selection
			_selected_balls[0] = _selected_balls[1]
			_selected_balls[1] = ball_type

	# Update button visuals
	for bt in _ball_buttons:
		var btn: Button = _ball_buttons[bt]
		if bt in _selected_balls:
			btn.modulate = Color(1.5, 1.5, 1.5)  # Highlight
		else:
			btn.modulate = Color.WHITE

	_update_preview()
	_update_confirm_button()


func _on_evolution_selected(evo: Dictionary) -> void:
	"""Handle evolution recipe selection"""
	_selected_balls.clear()
	_selected_balls.append(evo["ball_a"])
	_selected_balls.append(evo["ball_b"])

	_update_preview()
	_update_confirm_button()


func _on_multi_evolution_selected(multi: Dictionary) -> void:
	"""Handle multi-evolution recipe selection"""
	_selected_evolved_balls.clear()
	_selected_balls.clear()
	_selected_evolved_balls.append(multi["evolved_type"])
	_selected_balls.append(multi["ball_type"])

	_update_preview()
	_update_confirm_button()


func _on_ultimate_selected(ult: Dictionary) -> void:
	"""Handle ultimate fusion recipe selection"""
	_selected_evolved_balls.clear()
	var types: Array = ult.get("evolved_types", [])
	for et in types:
		_selected_evolved_balls.append(et)

	_update_preview()
	_update_confirm_button()


func _update_preview() -> void:
	"""Update the preview area showing fusion result"""
	if not preview_container.visible:
		return

	match _current_tab:
		Tab.MULTI_EVOLUTION:
			if _selected_evolved_balls.is_empty() or _selected_balls.is_empty():
				preview_label.text = "Select a recipe..."
				return
			var evolved_name := FusionRegistry.get_evolved_ball_name(_selected_evolved_balls[0], false)
			var basic_name := BallRegistry.get_ball_name(_selected_balls[0])
			var result := FusionRegistry.get_multi_evolution_result(_selected_evolved_balls[0], _selected_balls[0])
			if result != FusionRegistry.EvolvedBallType.NONE:
				var data := FusionRegistry.get_evolved_ball_data(result)
				preview_label.text = "%s + %s = %s\n%s" % [evolved_name, basic_name, data.get("name", ""), data.get("description", "")]
			return

		Tab.ULTIMATE:
			if _selected_evolved_balls.size() < 3:
				preview_label.text = "Select a recipe..."
				return
			var names: Array[String] = []
			for et in _selected_evolved_balls:
				names.append(FusionRegistry.get_evolved_ball_name(et, false))
			var result := FusionRegistry.get_ultimate_result(_selected_evolved_balls[0], _selected_evolved_balls[1], _selected_evolved_balls[2])
			if result != FusionRegistry.EvolvedBallType.NONE:
				var data := FusionRegistry.get_evolved_ball_data(result)
				preview_label.text = "%s + %s + %s = %s\n%s" % [names[0], names[1], names[2], data.get("name", ""), data.get("description", "")]
			return

	# Original logic for Fusion/Evolution tabs
	if _selected_balls.size() < 2:
		preview_label.text = "Select 2 balls..."
		return

	var ball_a: BallRegistry.BallType = _selected_balls[0]
	var ball_b: BallRegistry.BallType = _selected_balls[1]
	var name_a := BallRegistry.get_ball_name(ball_a)
	var name_b := BallRegistry.get_ball_name(ball_b)

	if _current_tab == Tab.EVOLUTION:
		var result := FusionRegistry.get_evolution_result(ball_a, ball_b)
		if result != FusionRegistry.EvolvedBallType.NONE:
			var result_name := FusionRegistry.get_evolved_ball_name(result)
			var data := FusionRegistry.get_evolved_ball_data(result)
			preview_label.text = "%s + %s = %s\n%s" % [name_a, name_b, result_name, data.get("description", "")]
		else:
			preview_label.text = "No evolution recipe"
	else:
		# Fusion tab
		if FusionRegistry.has_evolution_recipe(ball_a, ball_b):
			preview_label.text = "%s + %s\nHas recipe! Use Evolution tab." % [name_a, name_b]
		else:
			var fused_data := FusionRegistry.create_fused_ball_data(ball_a, ball_b)
			preview_label.text = "%s + %s = %s\n%s" % [name_a, name_b, fused_data["name"], fused_data["description"]]


func _update_confirm_button() -> void:
	"""Enable/disable confirm button based on current state"""
	match _current_tab:
		Tab.FISSION:
			confirm_button.disabled = false
			confirm_button.text = "Apply Fission"
		Tab.FUSION:
			var valid := _selected_balls.size() == 2 and not FusionRegistry.has_evolution_recipe(_selected_balls[0], _selected_balls[1])
			confirm_button.disabled = not valid
			confirm_button.text = "Fuse Balls" if valid else "Select 2 Balls"
		Tab.EVOLUTION:
			var valid := _selected_balls.size() == 2 and FusionRegistry.has_evolution_recipe(_selected_balls[0], _selected_balls[1])
			confirm_button.disabled = not valid
			confirm_button.text = "Evolve!" if valid else "Select Recipe"
		Tab.MULTI_EVOLUTION:
			var valid := _selected_evolved_balls.size() == 1 and _selected_balls.size() == 1
			if valid:
				valid = FusionRegistry.has_multi_evolution_recipe(_selected_evolved_balls[0], _selected_balls[0])
			confirm_button.disabled = not valid
			confirm_button.text = "Multi-Evolve!" if valid else "Select Recipe"
		Tab.ULTIMATE:
			var valid := _selected_evolved_balls.size() == 3
			if valid:
				valid = FusionRegistry.has_ultimate_recipe(_selected_evolved_balls[0], _selected_evolved_balls[1], _selected_evolved_balls[2])
			confirm_button.disabled = not valid
			confirm_button.text = "Ultimate Fusion!" if valid else "Select Recipe"


func _on_confirm_pressed() -> void:
	"""Apply the selected action"""
	var result: Variant = null
	var action_type := ""

	match _current_tab:
		Tab.FISSION:
			result = FusionRegistry.apply_fission()
			action_type = "fission"
		Tab.FUSION:
			if _selected_balls.size() == 2:
				result = FusionRegistry.fuse_balls(_selected_balls[0], _selected_balls[1])
				action_type = "fusion"
		Tab.EVOLUTION:
			if _selected_balls.size() == 2:
				result = FusionRegistry.evolve_balls(_selected_balls[0], _selected_balls[1])
				action_type = "evolution"
		Tab.MULTI_EVOLUTION:
			if _selected_evolved_balls.size() == 1 and _selected_balls.size() == 1:
				result = FusionRegistry.multi_evolve_ball(_selected_evolved_balls[0], _selected_balls[0])
				action_type = "multi_evolution"
		Tab.ULTIMATE:
			if _selected_evolved_balls.size() == 3:
				result = FusionRegistry.ultimate_fuse_balls(_selected_evolved_balls[0], _selected_evolved_balls[1], _selected_evolved_balls[2])
				action_type = "ultimate"

	action_completed.emit(action_type, result)

	# Play sound
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)

	# Close overlay and resume game
	visible = false
	# CRITICAL: Disable input capture when hiding to prevent blocking on web
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().paused = false
