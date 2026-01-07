extends Control
## HUD - displays HP bar, wave counter, XP progress, and combo

@onready var hp_bar: ProgressBar = $TopBar/HPBar
@onready var hp_label: Label = $TopBar/HPBar/HPLabel
@onready var wave_label: Label = $TopBar/WaveLabel
@onready var pause_button: Button = $TopBar/PauseButton
@onready var xp_bar: ProgressBar = $XPBarContainer/XPBar
@onready var level_label: Label = $XPBarContainer/LevelLabel
@onready var combo_label: Label = $ComboLabel

var pause_overlay: CanvasLayer
var _combo_tween: Tween


func _ready() -> void:
	_update_hp()
	_update_wave()
	_update_xp()

	# Hide combo label initially
	if combo_label:
		combo_label.visible = false

	# Get reference to pause overlay
	pause_overlay = get_node_or_null("../PauseOverlay")

	# Connect pause button
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

	# Connect to GameManager signals
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.combo_changed.connect(_on_combo_changed)


func _on_pause_pressed() -> void:
	if pause_overlay:
		pause_overlay.show_pause()


func _process(_delta: float) -> void:
	_update_hp()
	_update_wave()
	_update_xp()


func _update_hp() -> void:
	if hp_bar:
		hp_bar.max_value = GameManager.max_hp
		hp_bar.value = GameManager.player_hp
	if hp_label:
		hp_label.text = "%d/%d" % [GameManager.player_hp, GameManager.max_hp]


func _update_wave() -> void:
	if wave_label:
		var stage_name := StageManager.get_stage_name()
		var wave_in_stage := StageManager.wave_in_stage
		wave_label.text = "%s %d/%d" % [stage_name, wave_in_stage, StageManager.current_biome.waves_before_boss if StageManager.current_biome else 10]


func _update_xp() -> void:
	if xp_bar:
		xp_bar.max_value = GameManager.xp_to_next_level
		xp_bar.value = GameManager.current_xp
	if level_label:
		level_label.text = "Lv.%d" % GameManager.player_level


func _on_state_changed(_old_state: GameManager.GameState, _new_state: GameManager.GameState) -> void:
	_update_hp()
	_update_wave()
	_update_xp()


func _on_combo_changed(combo: int, multiplier: float) -> void:
	if not combo_label:
		return

	if combo >= 2:
		combo_label.visible = true
		combo_label.text = "%dx COMBO!" % combo
		if multiplier > 1.0:
			combo_label.text += " (%.1fx XP)" % multiplier

		# Color based on multiplier
		if multiplier >= 2.0:
			combo_label.modulate = Color(1.0, 0.3, 0.3)  # Red for max
		elif multiplier >= 1.5:
			combo_label.modulate = Color(1.0, 0.8, 0.2)  # Yellow
		else:
			combo_label.modulate = Color.WHITE

		# Pop animation
		if _combo_tween and _combo_tween.is_valid():
			_combo_tween.kill()
		_combo_tween = create_tween()
		combo_label.scale = Vector2(1.3, 1.3)
		_combo_tween.tween_property(combo_label, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)
	else:
		combo_label.visible = false
