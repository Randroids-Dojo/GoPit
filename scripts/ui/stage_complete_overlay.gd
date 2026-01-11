extends CanvasLayer
## Overlay shown when completing a stage or winning the game

@onready var dim_background: ColorRect = $DimBackground
@onready var panel: Panel = $DimBackground/Panel
@onready var title_label: Label = $DimBackground/Panel/VBoxContainer/TitleLabel
@onready var stage_label: Label = $DimBackground/Panel/VBoxContainer/StageLabel
@onready var stats_container: VBoxContainer = $DimBackground/Panel/VBoxContainer/StatsContainer
@onready var time_label: Label = $DimBackground/Panel/VBoxContainer/StatsContainer/TimeLabel
@onready var enemies_label: Label = $DimBackground/Panel/VBoxContainer/StatsContainer/EnemiesLabel
@onready var level_label: Label = $DimBackground/Panel/VBoxContainer/StatsContainer/LevelLabel
@onready var continue_button: Button = $DimBackground/Panel/VBoxContainer/ButtonsContainer/ContinueButton
@onready var endless_button: Button = $DimBackground/Panel/VBoxContainer/ButtonsContainer/EndlessButton

var _is_victory: bool = false


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if endless_button:
		endless_button.pressed.connect(_on_endless_pressed)


func show_stage_complete(stage: int) -> void:
	_is_victory = false
	var biome := StageManager.current_biome
	var stage_name := biome.biome_name if biome else "Stage %d" % (stage + 1)

	title_label.text = "STAGE COMPLETE!"
	stage_label.text = stage_name + " cleared!"
	continue_button.text = "Return to Menu"

	# Show stats for stage complete (each stage is a full run)
	if stats_container:
		stats_container.visible = true
		_update_stats()

	# Show endless button as option to continue playing
	if endless_button:
		endless_button.visible = true
		endless_button.text = "Continue Playing"

	_show()


func show_victory() -> void:
	_is_victory = true
	title_label.text = "VICTORY!"
	stage_label.text = "You conquered The Pit!"
	continue_button.text = "Play Again"

	# Show stats for victory
	if stats_container:
		stats_container.visible = true
		_update_stats()

	# Show endless mode button
	if endless_button:
		endless_button.visible = true

	_show()


func _update_stats() -> void:
	# Format time
	var time_secs: float = GameManager.stats["time_survived"]
	var minutes := int(time_secs) / 60
	var seconds := int(time_secs) % 60
	if time_label:
		time_label.text = "Time: %d:%02d" % [minutes, seconds]

	# Enemies killed
	if enemies_label:
		enemies_label.text = "Enemies: %d" % GameManager.stats["enemies_killed"]

	# Level reached
	if level_label:
		level_label.text = "Level: %d" % GameManager.player_level


func _show() -> void:
	visible = true
	get_tree().paused = true


func _on_continue_pressed() -> void:
	visible = false
	get_tree().paused = false

	# Each stage is a run - return to menu after completion
	# This applies to both stage complete and victory
	get_tree().reload_current_scene()


func _on_endless_pressed() -> void:
	visible = false
	get_tree().paused = false

	# Continue to next stage (optional - extends the run)
	# This allows players to keep playing through multiple stages
	StageManager.complete_stage()
