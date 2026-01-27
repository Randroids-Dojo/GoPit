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
@onready var boss_progress_bar: ProgressBar = get_node_or_null("BossProgressContainer/BossProgressBar")
@onready var boss_label: Label = get_node_or_null("BossProgressContainer/BossLabel")

var pause_overlay: CanvasLayer

# Fusion ready indicator (dynamically created)
var fusion_ready_label: Label = null
var _fusion_ready_tween: Tween = null
var _fusion_ready_visible: bool = false

# Speaker icons (ASCII-compatible)
const SPEAKER_ON := ")))"  # Sound waves
const SPEAKER_OFF := "X"   # Muted


func _ready() -> void:
	_update_hp()
	_update_wave()
	_update_xp()
	_update_boss_progress()

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

	# Connect to BallRegistry for fusion ready indicator
	if BallRegistry:
		BallRegistry.ball_leveled_up.connect(_on_ball_leveled_up)
		BallRegistry.ball_acquired.connect(_on_ball_acquired)

	# Create fusion ready indicator
	_create_fusion_ready_indicator()


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
	_update_boss_progress()


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


func _update_boss_progress() -> void:
	if not boss_progress_bar:
		return

	var waves_before_boss: int = StageManager.current_biome.waves_before_boss if StageManager.current_biome else 10
	var current_wave: int = StageManager.wave_in_stage

	boss_progress_bar.max_value = waves_before_boss
	boss_progress_bar.value = current_wave

	# Update label based on progress
	if boss_label:
		if current_wave >= waves_before_boss:
			boss_label.text = "BOSS!"
			boss_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
		elif current_wave >= waves_before_boss * 0.8:
			boss_label.text = "BOSS"
			boss_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
		else:
			boss_label.text = "BOSS"
			boss_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))


func _on_state_changed(_old_state: GameManager.GameState, _new_state: GameManager.GameState) -> void:
	_update_hp()
	_update_wave()
	_update_xp()
	_update_boss_progress()


func _on_fission_upgrades_changed(total: int) -> void:
	if not fission_counter:
		return

	fission_counter.visible = true
	fission_counter.text = "FISSION: %d" % total

	# Pop animation on update
	var tween := create_tween()
	fission_counter.scale = Vector2(1.2, 1.2)
	tween.tween_property(fission_counter, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)


# ===== FUSION READY INDICATOR =====

func _create_fusion_ready_indicator() -> void:
	"""Create the fusion ready indicator label dynamically"""
	fusion_ready_label = Label.new()
	fusion_ready_label.name = "FusionReadyLabel"
	fusion_ready_label.text = "FUSION READY!"
	fusion_ready_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fusion_ready_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Style the label
	fusion_ready_label.add_theme_font_size_override("font_size", 24)
	fusion_ready_label.add_theme_color_override("font_color", Color(0.9, 0.3, 1.0))  # Purple/pink
	fusion_ready_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	fusion_ready_label.add_theme_constant_override("outline_size", 3)

	# Position below XP bar (near fission counter area)
	fusion_ready_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	fusion_ready_label.position = Vector2(0, 90)  # Below XP bar
	fusion_ready_label.size = Vector2(720, 30)

	# Start hidden
	fusion_ready_label.visible = false
	fusion_ready_label.modulate.a = 0.0

	add_child(fusion_ready_label)

	# Check initial state
	_update_fusion_ready_indicator()


func _on_ball_leveled_up(_ball_type: int, _new_level: int) -> void:
	"""Called when a ball levels up - check if fusion is ready"""
	_update_fusion_ready_indicator()


func _on_ball_acquired(_ball_type: int) -> void:
	"""Called when a ball is acquired - check if fusion is ready"""
	_update_fusion_ready_indicator()


func _update_fusion_ready_indicator() -> void:
	"""Update the fusion ready indicator visibility"""
	if not fusion_ready_label:
		return

	var fusion_ready_count := BallRegistry.get_fusion_ready_balls().size()
	var should_show := fusion_ready_count >= 2

	if should_show and not _fusion_ready_visible:
		_show_fusion_ready_indicator()
	elif not should_show and _fusion_ready_visible:
		_hide_fusion_ready_indicator()


func _show_fusion_ready_indicator() -> void:
	"""Show the fusion ready indicator with pulsing animation"""
	if _fusion_ready_visible:
		return

	_fusion_ready_visible = true
	fusion_ready_label.visible = true

	# Cancel any existing tween
	if _fusion_ready_tween:
		_fusion_ready_tween.kill()

	# Fade in
	_fusion_ready_tween = create_tween()
	_fusion_ready_tween.tween_property(fusion_ready_label, "modulate:a", 1.0, 0.3)
	_fusion_ready_tween.tween_callback(_start_pulse_animation)


func _hide_fusion_ready_indicator() -> void:
	"""Hide the fusion ready indicator"""
	if not _fusion_ready_visible:
		return

	_fusion_ready_visible = false

	# Cancel any existing tween
	if _fusion_ready_tween:
		_fusion_ready_tween.kill()

	# Fade out
	_fusion_ready_tween = create_tween()
	_fusion_ready_tween.tween_property(fusion_ready_label, "modulate:a", 0.0, 0.2)
	_fusion_ready_tween.tween_callback(func(): fusion_ready_label.visible = false)


func _start_pulse_animation() -> void:
	"""Start the subtle pulsing animation for fusion ready indicator"""
	if not _fusion_ready_visible or not fusion_ready_label:
		return

	# Create looping pulse tween
	_fusion_ready_tween = create_tween()
	_fusion_ready_tween.set_loops()

	# Pulse scale and color
	_fusion_ready_tween.tween_property(fusion_ready_label, "scale", Vector2(1.05, 1.05), 0.5).set_ease(Tween.EASE_IN_OUT)
	_fusion_ready_tween.parallel().tween_property(fusion_ready_label, "modulate", Color(1.2, 1.0, 1.2, 1.0), 0.5).set_ease(Tween.EASE_IN_OUT)
	_fusion_ready_tween.tween_property(fusion_ready_label, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_IN_OUT)
	_fusion_ready_tween.parallel().tween_property(fusion_ready_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5).set_ease(Tween.EASE_IN_OUT)
