extends CanvasLayer
## Overlay shown when completing a stage or winning the game

@onready var dim_background: ColorRect = $DimBackground
@onready var panel: Panel = $DimBackground/Panel
@onready var title_label: Label = $DimBackground/Panel/VBoxContainer/TitleLabel
@onready var stage_label: Label = $DimBackground/Panel/VBoxContainer/StageLabel
@onready var continue_button: Button = $DimBackground/Panel/VBoxContainer/ContinueButton

var _is_victory: bool = false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)


func show_stage_complete(stage: int) -> void:
	_is_victory = false
	var biome := StageManager.current_biome
	var stage_name := biome.biome_name if biome else "Stage %d" % (stage + 1)

	title_label.text = "STAGE COMPLETE!"
	stage_label.text = stage_name + " cleared!"
	continue_button.text = "Continue"

	_show()


func show_victory() -> void:
	_is_victory = true
	title_label.text = "VICTORY!"
	stage_label.text = "You conquered The Pit!"
	continue_button.text = "Play Again"

	_show()


func _show() -> void:
	visible = true
	get_tree().paused = true


func _on_continue_pressed() -> void:
	visible = false
	get_tree().paused = false

	if _is_victory:
		# Restart the game
		get_tree().reload_current_scene()
	else:
		# Advance to next stage
		StageManager.complete_stage()
