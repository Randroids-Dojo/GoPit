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
		var best_text := ""
		if GameManager.current_wave >= GameManager.high_score_wave:
			best_text = " (NEW BEST!)"
		wave_label.text = "Reached Wave %d%s" % [GameManager.current_wave, best_text]
	if score_label:
		var best_text := ""
		if GameManager.player_level >= GameManager.high_score_level:
			best_text = " (NEW BEST!)"
		score_label.text = "Level %d%s" % [GameManager.player_level, best_text]
	if stats_label:
		var time: float = GameManager.stats["time_survived"]
		var minutes: int = int(time) / 60
		var seconds: int = int(time) % 60
		stats_label.text = """Enemies: %d
Damage: %d
Gems: %d
Time: %d:%02d
Best Wave: %d | Best Level: %d""" % [
			GameManager.stats["enemies_killed"],
			GameManager.stats["damage_dealt"],
			GameManager.stats["gems_collected"],
			minutes,
			seconds,
			GameManager.high_score_wave,
			GameManager.high_score_level
		]


func _on_restart_pressed() -> void:
	restart_pressed.emit()
	GameManager.return_to_menu()
	get_tree().reload_current_scene()
