extends CanvasLayer
## ResumeRunDialog - Shown when selecting a slot with an active run

signal continue_chosen
signal new_game_chosen

@onready var title_label: Label = $DimBackground/Panel/VBoxContainer/TitleLabel
@onready var character_label: Label = $DimBackground/Panel/VBoxContainer/PreviewContainer/CharacterLabel
@onready var stats_label: Label = $DimBackground/Panel/VBoxContainer/PreviewContainer/StatsLabel
@onready var new_game_button: Button = $DimBackground/Panel/VBoxContainer/ButtonsContainer/NewGameButton
@onready var continue_button: Button = $DimBackground/Panel/VBoxContainer/ButtonsContainer/ContinueButton


func _ready() -> void:
	visible = false
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)


func show_dialog(session_preview: Dictionary) -> void:
	"""Show the resume dialog with session info."""
	# Get character name from path
	var character_path: String = session_preview.get("character_path", "")
	var character_name := "Unknown"
	if not character_path.is_empty():
		var character := load(character_path) as Resource
		if character and "character_name" in character:
			character_name = character.character_name

	var wave: int = session_preview.get("current_wave", 1)
	var hp: int = session_preview.get("player_hp", 100)
	var max_hp: int = session_preview.get("max_hp", 100)
	var level: int = session_preview.get("player_level", 1)
	var stage: int = session_preview.get("current_stage", 0)

	character_label.text = "%s - Wave %d" % [character_name, wave]
	stats_label.text = "HP: %d/%d | Level %d | Stage %d" % [hp, max_hp, level, stage + 1]

	visible = true
	get_tree().paused = true


func hide_dialog() -> void:
	visible = false
	get_tree().paused = false


func _on_new_game_pressed() -> void:
	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	hide_dialog()
	new_game_chosen.emit()


func _on_continue_pressed() -> void:
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	hide_dialog()
	continue_chosen.emit()
