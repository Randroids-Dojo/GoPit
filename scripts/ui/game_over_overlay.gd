extends Control
## Game Over overlay with detailed stats and restart button

signal restart_pressed

@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var wave_label: Label = $Panel/VBoxContainer/WaveLabel
@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton


func _ready() -> void:
	visible = false

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)

	GameManager.game_over.connect(_on_game_over)


func _on_game_over() -> void:
	_update_stats()
	visible = true


func _update_stats() -> void:
	if wave_label:
		wave_label.text = "Reached Wave %d" % GameManager.current_wave
	if score_label:
		score_label.text = "Level %d" % GameManager.player_level
	if stats_label:
		var time := GameManager.stats["time_survived"]
		var minutes := int(time) / 60
		var seconds := int(time) % 60
		stats_label.text = """Enemies: %d
Damage: %d
Gems: %d
Time: %d:%02d""" % [
			GameManager.stats["enemies_killed"],
			GameManager.stats["damage_dealt"],
			GameManager.stats["gems_collected"],
			minutes,
			seconds
		]


func _on_restart_pressed() -> void:
	restart_pressed.emit()
	GameManager.return_to_menu()
	get_tree().reload_current_scene()
