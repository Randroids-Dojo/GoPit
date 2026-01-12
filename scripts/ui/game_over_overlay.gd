extends Control
## Game Over overlay with detailed stats, coins earned, and restart button

signal restart_pressed

@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var wave_label: Label = $Panel/VBoxContainer/WaveLabel
@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var coins_label: Label = $Panel/VBoxContainer/CoinsLabel
@onready var shop_button: Button = $Panel/VBoxContainer/ButtonsContainer/ShopButton
@onready var restart_button: Button = $Panel/VBoxContainer/ButtonsContainer/RestartButton

var _coins_earned: int = 0


func _ready() -> void:
	visible = false

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)

	if shop_button:
		shop_button.pressed.connect(_on_shop_pressed)

	GameManager.game_over.connect(_on_game_over)


func _on_game_over() -> void:
	# Record run end with session stats and earn coins
	if MetaManager:
		MetaManager.record_run_end(
			GameManager.current_wave,
			GameManager.player_level,
			GameManager.stats["enemies_killed"],
			GameManager.stats["gems_collected"],
			GameManager.stats["damage_dealt"]
		)
		_coins_earned = MetaManager.earn_coins(GameManager.current_wave, GameManager.player_level)

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

	# Display coins earned
	if coins_label and MetaManager:
		coins_label.text = "+%d Pit Coins (Total: %d)" % [_coins_earned, MetaManager.pit_coins]


func _on_restart_pressed() -> void:
	restart_pressed.emit()
	GameManager.return_to_menu()
	get_tree().reload_current_scene()


func _on_shop_pressed() -> void:
	# Find and show the meta shop
	var meta_shop := get_tree().get_first_node_in_group("meta_shop")
	if meta_shop and meta_shop.has_method("show_shop"):
		meta_shop.show_shop()
