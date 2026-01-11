extends CanvasLayer
## Level/Stage selection screen - shown after character select

signal stage_selected(stage_index: int)

const STAGE_COLORS := [
	Color(0.102, 0.102, 0.18),  # The Pit - dark blue
	Color(0.15, 0.25, 0.35),    # Frozen Depths - icy blue
	Color(0.35, 0.2, 0.1),      # Burning Sands - orange
	Color(0.15, 0.1, 0.2),      # Final Descent - dark purple
]

const STAGE_ICONS := ["1", "2", "3", "4"]

var _stages: Array[Resource] = []
var _current_index: int = 0
var _dots: Array[ColorRect] = []
var _unlocked_stages: int = 1  # Start with first stage unlocked

@onready var name_label: Label = $DimBackground/Panel/VBoxContainer/StagePanel/InfoContainer/NameLabel
@onready var desc_label: Label = $DimBackground/Panel/VBoxContainer/StagePanel/InfoContainer/DescLabel
@onready var portrait: ColorRect = $DimBackground/Panel/VBoxContainer/StagePanel/PortraitContainer/Portrait
@onready var portrait_label: Label = $DimBackground/Panel/VBoxContainer/StagePanel/PortraitContainer/Portrait/PortraitLabel
@onready var waves_label: Label = $DimBackground/Panel/VBoxContainer/StagePanel/InfoContainer/WavesLabel
@onready var prev_button: Button = $DimBackground/Panel/VBoxContainer/NavContainer/PrevButton
@onready var next_button: Button = $DimBackground/Panel/VBoxContainer/NavContainer/NextButton
@onready var start_button: Button = $DimBackground/Panel/VBoxContainer/StartButton
@onready var dots_container: HBoxContainer = $DimBackground/Panel/VBoxContainer/NavContainer/DotsContainer
@onready var locked_overlay: ColorRect = $DimBackground/Panel/LockedOverlay
@onready var lock_label: Label = $DimBackground/Panel/LockedOverlay/LockLabel


func _ready() -> void:
	add_to_group("level_select")
	_load_stages()
	_load_progress()
	_create_dots()
	_connect_signals()
	_update_display()
	visible = false


func _load_stages() -> void:
	_stages = [
		preload("res://resources/biomes/the_pit.tres"),
		preload("res://resources/biomes/frozen_depths.tres"),
		preload("res://resources/biomes/burning_sands.tres"),
		preload("res://resources/biomes/final_descent.tres"),
	]


func _load_progress() -> void:
	# Load from MetaManager if available
	if MetaManager:
		_unlocked_stages = MetaManager.get_highest_stage_cleared() + 1
		_unlocked_stages = clampi(_unlocked_stages, 1, _stages.size())


func _create_dots() -> void:
	for i in range(_stages.size()):
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(12, 12)
		dot.color = Color(0.4, 0.4, 0.4)
		dots_container.add_child(dot)
		_dots.append(dot)


func _connect_signals() -> void:
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	start_button.pressed.connect(_on_start_pressed)


func show_select() -> void:
	visible = true
	_load_progress()  # Refresh in case progress changed
	_update_display()


func hide_select() -> void:
	visible = false


func _on_prev_pressed() -> void:
	_current_index = (_current_index - 1 + _stages.size()) % _stages.size()
	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	_update_display()


func _on_next_pressed() -> void:
	_current_index = (_current_index + 1) % _stages.size()
	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	_update_display()


func _on_start_pressed() -> void:
	if not _is_stage_unlocked(_current_index):
		SoundManager.play(SoundManager.SoundType.BLOCKED)
		return

	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	stage_selected.emit(_current_index)
	hide_select()


func _is_stage_unlocked(index: int) -> bool:
	return index < _unlocked_stages


func _update_display() -> void:
	if _stages.is_empty():
		return

	var stage: Biome = _stages[_current_index]
	var is_unlocked := _is_stage_unlocked(_current_index)

	# Update portrait
	portrait.color = STAGE_COLORS[_current_index]
	portrait_label.text = STAGE_ICONS[_current_index]

	# Update name and description
	name_label.text = stage.biome_name.to_upper()
	desc_label.text = _get_stage_description(_current_index)

	# Update waves info
	waves_label.text = "Waves: " + str(stage.waves_before_boss) + " + Boss"

	# Update dots
	for i in range(_dots.size()):
		if i == _current_index:
			_dots[i].color = Color(1, 0.9, 0.3)  # Selected
		elif i < _unlocked_stages:
			_dots[i].color = Color(0.6, 0.6, 0.6)  # Unlocked
		else:
			_dots[i].color = Color(0.3, 0.3, 0.3)  # Locked

	# Update locked overlay
	locked_overlay.visible = not is_unlocked
	if not is_unlocked:
		lock_label.text = "LOCKED\nBeat " + _stages[_current_index - 1].biome_name + " first"

	# Update start button
	start_button.disabled = not is_unlocked


func _get_stage_description(index: int) -> String:
	match index:
		0: return "Where it all begins. Basic enemies and learning the ropes."
		1: return "Chilling depths with frozen foes. Ice hazards await."
		2: return "Scorching desert with fire enemies. Stay cool."
		3: return "The final challenge. Everything comes together."
		_: return "Unknown territory."


func get_selected_stage() -> int:
	return _current_index
