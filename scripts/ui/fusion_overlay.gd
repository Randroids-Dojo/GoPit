extends Control
## Fusion Overlay - Shows when player collects a Fusion Reactor
## Three options: Fission (random upgrades), Fusion (any 2 L3s), Evolution (recipes)

signal action_completed(action_type: String, result: Variant)

enum Tab { FISSION, FUSION, EVOLUTION }

@onready var tab_container: HBoxContainer = $Panel/VBoxContainer/TabButtons
@onready var content_container: VBoxContainer = $Panel/VBoxContainer/ContentContainer
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var fission_button: Button = $Panel/VBoxContainer/TabButtons/FissionTab
@onready var fusion_button: Button = $Panel/VBoxContainer/TabButtons/FusionTab
@onready var evolution_button: Button = $Panel/VBoxContainer/TabButtons/EvolutionTab
@onready var confirm_button: Button = $Panel/VBoxContainer/ConfirmButton
@onready var description_label: Label = $Panel/VBoxContainer/DescriptionLabel

# Ball selection grid (for Fusion/Evolution tabs)
@onready var ball_grid: GridContainer = $Panel/VBoxContainer/ContentContainer/BallGrid
# Preview area for fusion result
@onready var preview_container: HBoxContainer = $Panel/VBoxContainer/ContentContainer/PreviewContainer
@onready var preview_label: Label = $Panel/VBoxContainer/ContentContainer/PreviewContainer/PreviewLabel

var _current_tab: Tab = Tab.FISSION
var _selected_balls: Array[BallRegistry.BallType] = []
var _ball_buttons: Dictionary = {}  # BallType -> Button
var _available_evolutions: Array[Dictionary] = []


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect tab buttons
	fission_button.pressed.connect(_on_tab_pressed.bind(Tab.FISSION))
	fusion_button.pressed.connect(_on_tab_pressed.bind(Tab.FUSION))
	evolution_button.pressed.connect(_on_tab_pressed.bind(Tab.EVOLUTION))
	confirm_button.pressed.connect(_on_confirm_pressed)


func show_fusion_ui() -> void:
	"""Called when player collects a Fusion Reactor"""
	_selected_balls.clear()
	_update_tab_availability()
	_on_tab_pressed(Tab.FISSION)  # Default to Fission
	visible = true
	get_tree().paused = true


func _update_tab_availability() -> void:
	"""Enable/disable tabs based on current ball inventory"""
	var fusion_ready := BallRegistry.get_fusion_ready_balls()

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
	evolution_button.text = "Evolution" if can_evolve else "Evolution (No Recipe)"


func _on_tab_pressed(tab: Tab) -> void:
	_current_tab = tab
	_selected_balls.clear()

	# Update button states
	fission_button.button_pressed = (tab == Tab.FISSION)
	fusion_button.button_pressed = (tab == Tab.FUSION)
	evolution_button.button_pressed = (tab == Tab.EVOLUTION)

	# Update content
	_update_content()


func _update_content() -> void:
	# Clear ball grid
	for child in ball_grid.get_children():
		child.queue_free()
	_ball_buttons.clear()

	match _current_tab:
		Tab.FISSION:
			_show_fission_content()
		Tab.FUSION:
			_show_fusion_content()
		Tab.EVOLUTION:
			_show_evolution_content()

	_update_preview()
	_update_confirm_button()


func _show_fission_content() -> void:
	title_label.text = "FISSION"
	description_label.text = "Get random ball upgrades or new balls.\nIf all maxed, receive bonus XP instead."
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


func _update_preview() -> void:
	"""Update the preview area showing fusion result"""
	if not preview_container.visible:
		return

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

	action_completed.emit(action_type, result)

	# Play sound
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)

	# Close overlay and resume game
	visible = false
	get_tree().paused = false
