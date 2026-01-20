extends Control
## HUD - displays HP bar, wave counter, and XP progress

@onready var hp_bar: ProgressBar = $TopBar/HPBar
@onready var hp_label: Label = $TopBar/HPBar/HPLabel
@onready var wave_label: Label = $TopBar/WaveLabel
@onready var mute_button: Button = $TopBar/MuteButton
@onready var pause_button: Button = $TopBar/PauseButton
@onready var xp_bar: ProgressBar = $XPBarContainer/XPBar
@onready var level_label: Label = $XPBarContainer/LevelLabel
@onready var fission_counter: Label = $FissionCounter

var pause_overlay: CanvasLayer

# Speaker icons (ASCII-compatible)
const SPEAKER_ON := ")))"  # Sound waves
const SPEAKER_OFF := "X"   # Muted


func _ready() -> void:
	_update_hp()
	_update_wave()
	_update_xp()

	# Hide fission counter initially (shows when first fission used)
	if fission_counter:
		fission_counter.visible = false

	# Get reference to pause overlay
	pause_overlay = get_node_or_null("../PauseOverlay")

	# Connect mute button
	if mute_button:
		mute_button.pressed.connect(_on_mute_pressed)
		_update_mute_button()

	# Listen for mute state changes (e.g., from pause menu)
	SoundManager.mute_changed.connect(_on_mute_changed)

	# Connect pause button
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

	# Connect to GameManager signals
	GameManager.state_changed.connect(_on_state_changed)

	# Connect to FusionRegistry for fission counter
	if FusionRegistry:
		FusionRegistry.fission_upgrades_changed.connect(_on_fission_upgrades_changed)


func _on_mute_pressed() -> void:
	SoundManager.toggle_mute()


func _on_mute_changed(_is_muted: bool) -> void:
	_update_mute_button()


func _update_mute_button() -> void:
	if mute_button:
		mute_button.text = SPEAKER_OFF if SoundManager.is_muted else SPEAKER_ON


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


func _on_fission_upgrades_changed(total: int) -> void:
	if not fission_counter:
		return

	fission_counter.visible = true
	fission_counter.text = "FISSION: %d" % total

	# Pop animation on update
	var tween := create_tween()
	fission_counter.scale = Vector2(1.2, 1.2)
	tween.tween_property(fission_counter, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)
