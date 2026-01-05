extends Control
## HUD - displays HP bar, wave counter, and XP progress

@onready var hp_bar: ProgressBar = $TopBar/HPBar
@onready var hp_label: Label = $TopBar/HPBar/HPLabel
@onready var wave_label: Label = $TopBar/WaveLabel
@onready var pause_button: Button = $TopBar/PauseButton
@onready var xp_bar: ProgressBar = $XPBarContainer/XPBar
@onready var level_label: Label = $XPBarContainer/LevelLabel

var pause_overlay: CanvasLayer


func _ready() -> void:
	_update_hp()
	_update_wave()
	_update_xp()

	# Get reference to pause overlay
	pause_overlay = get_node_or_null("../PauseOverlay")

	# Connect pause button
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

	# Connect to GameManager signals
	GameManager.state_changed.connect(_on_state_changed)


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
		wave_label.text = "Wave %d" % GameManager.current_wave


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
