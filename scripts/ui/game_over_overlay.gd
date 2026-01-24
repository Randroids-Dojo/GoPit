extends Control
## Game Over overlay with detailed stats, coins earned, and restart button

signal restart_pressed

const SETTINGS_PATH := "user://settings.save"
const SHOP_HINT_TEXT := "Spend Pit Coins on permanent upgrades!"

@onready var panel: Panel = $Panel
@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var wave_label: Label = $Panel/VBoxContainer/WaveLabel
@onready var stats_label: Label = $Panel/VBoxContainer/StatsLabel
@onready var coins_label: Label = $Panel/VBoxContainer/CoinsLabel
@onready var shop_button: Button = $Panel/VBoxContainer/ButtonsContainer/ShopButton
@onready var restart_button: Button = $Panel/VBoxContainer/ButtonsContainer/RestartButton
@onready var shop_hint_label: Label = $Panel/VBoxContainer/ShopHintLabel

var _coins_earned: int = 0
var _shop_hint_seen: bool = false
var _pulse_tween: Tween = null


func _ready() -> void:
	visible = false
	_shop_hint_seen = _load_shop_hint_state()

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)

	if shop_button:
		shop_button.pressed.connect(_on_shop_pressed)

	_setup_shop_hint()
	GameManager.game_over.connect(_on_game_over)


func _on_game_over() -> void:
	# Pause game immediately so all animations stop
	get_tree().paused = true

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
	_animate_show()
	_show_shop_hint()


func _animate_show() -> void:
	"""Animate the panel in with a scale bounce effect."""
	if not panel:
		return

	# Start state: scaled small, transparent
	panel.modulate.a = 0
	panel.scale = Vector2(0.8, 0.8)
	panel.pivot_offset = panel.size / 2

	# Brief delay for dramatic effect after player death
	var delay_tween := create_tween()
	delay_tween.tween_interval(0.3)
	await delay_tween.finished

	# Animate in with bounce
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.4)


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
	# Hide shop hint on shop button click
	_dismiss_shop_hint()

	# Find and show the meta shop
	var meta_shop := get_tree().get_first_node_in_group("meta_shop")
	if meta_shop and meta_shop.has_method("show_shop"):
		meta_shop.show_shop()


# =============================================================================
# SHOP HINT SYSTEM
# =============================================================================

func _setup_shop_hint() -> void:
	"""Setup the shop hint label (created dynamically if not in scene)."""
	if not shop_hint_label:
		shop_hint_label = Label.new()
		shop_hint_label.name = "ShopHintLabel"
		shop_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		shop_hint_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0, 1.0))
		shop_hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		shop_hint_label.add_theme_constant_override("outline_size", 2)
		shop_hint_label.add_theme_font_size_override("font_size", 14)
		# Insert after coins label
		if coins_label:
			var vbox := coins_label.get_parent()
			vbox.add_child(shop_hint_label)
			vbox.move_child(shop_hint_label, coins_label.get_index() + 1)
	shop_hint_label.text = ""
	shop_hint_label.visible = false


func _show_shop_hint() -> void:
	"""Show shop hint with pulsing animation on first game over."""
	if _shop_hint_seen:
		return

	if shop_hint_label:
		shop_hint_label.text = SHOP_HINT_TEXT
		shop_hint_label.visible = true

		# Pulsing animation for the hint
		_pulse_tween = create_tween().set_loops()
		_pulse_tween.tween_property(shop_hint_label, "modulate:a", 0.5, 0.5)
		_pulse_tween.tween_property(shop_hint_label, "modulate:a", 1.0, 0.5)

	# Also add glow/pulse effect to shop button
	if shop_button:
		var btn_tween := create_tween().set_loops()
		btn_tween.tween_property(shop_button, "modulate", Color(1.2, 1.1, 0.8, 1.0), 0.5)
		btn_tween.tween_property(shop_button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)


func _dismiss_shop_hint() -> void:
	"""Dismiss shop hint and save state when shop is clicked."""
	if _shop_hint_seen:
		return

	# Stop pulsing animations
	if _pulse_tween and _pulse_tween.is_running():
		_pulse_tween.kill()

	if shop_hint_label:
		shop_hint_label.visible = false

	if shop_button:
		shop_button.modulate = Color(1.0, 1.0, 1.0, 1.0)

	# Mark as seen and save
	_shop_hint_seen = true
	_save_shop_hint_state()


func _load_shop_hint_state() -> bool:
	"""Load shop_hint_seen state from settings."""
	if not FileAccess.file_exists(SETTINGS_PATH):
		return false

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return false

	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if data and data.has("shop_hint_seen"):
		return data["shop_hint_seen"]
	return false


func _save_shop_hint_state() -> void:
	"""Save shop_hint_seen state to settings."""
	var data := {}

	# Load existing settings first
	if FileAccess.file_exists(SETTINGS_PATH):
		var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var existing = JSON.parse_string(file.get_as_text())
			file.close()
			if existing:
				data = existing

	data["shop_hint_seen"] = true

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
