extends CanvasLayer
## Pause menu overlay with mute and screen shake toggles

signal resumed
signal quit_requested

@onready var mute_button: Button = $DimBackground/Panel/VBoxContainer/MuteButton
@onready var screen_shake_button: Button = $DimBackground/Panel/VBoxContainer/ScreenShakeButton
@onready var sensitivity_slider: HSlider = $DimBackground/Panel/VBoxContainer/SensitivityContainer/SensitivitySlider
@onready var sensitivity_value: Label = $DimBackground/Panel/VBoxContainer/SensitivityContainer/SensitivityValue
@onready var resume_button: Button = $DimBackground/Panel/VBoxContainer/ResumeButton
@onready var quit_button: Button = $DimBackground/Panel/VBoxContainer/QuitButton


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect buttons
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if mute_button:
		mute_button.pressed.connect(_on_mute_pressed)
		_update_mute_button()
	if screen_shake_button:
		screen_shake_button.pressed.connect(_on_screen_shake_pressed)
		_update_screen_shake_button()
	if sensitivity_slider:
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
		_update_sensitivity_slider()

	# Listen for state changes
	SoundManager.mute_changed.connect(_on_mute_changed)
	CameraShake.screen_shake_changed.connect(_on_screen_shake_changed)
	SoundManager.aim_sensitivity_changed.connect(_on_aim_sensitivity_changed)


func _unhandled_input(event: InputEvent) -> void:
	# Handle back button on Android / Escape key
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_resume()
		elif GameManager.current_state == GameManager.GameState.PLAYING:
			_pause()
		get_viewport().set_input_as_handled()


func show_pause() -> void:
	_pause()


func _pause() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	visible = true
	GameManager.pause_game()
	_update_mute_button()
	_update_screen_shake_button()
	_update_sensitivity_slider()


func _resume() -> void:
	visible = false
	GameManager.resume_game()
	resumed.emit()


func _on_resume_pressed() -> void:
	_resume()


func _on_quit_pressed() -> void:
	visible = false
	get_tree().paused = false
	quit_requested.emit()
	get_tree().reload_current_scene()


func _on_mute_pressed() -> void:
	SoundManager.toggle_mute()


func _on_mute_changed(_is_muted: bool) -> void:
	_update_mute_button()


func _update_mute_button() -> void:
	if mute_button:
		if SoundManager.is_muted:
			mute_button.text = "Sound: OFF"
		else:
			mute_button.text = "Sound: ON"


func _on_screen_shake_pressed() -> void:
	CameraShake.toggle_screen_shake()


func _on_screen_shake_changed(_enabled: bool) -> void:
	_update_screen_shake_button()


func _update_screen_shake_button() -> void:
	if screen_shake_button:
		if CameraShake.screen_shake_enabled:
			screen_shake_button.text = "Screen Shake: ON"
		else:
			screen_shake_button.text = "Screen Shake: OFF"


func _on_sensitivity_changed(value: float) -> void:
	SoundManager.set_aim_sensitivity(value)


func _on_aim_sensitivity_changed(_value: float) -> void:
	_update_sensitivity_slider()


func _update_sensitivity_slider() -> void:
	if sensitivity_slider:
		sensitivity_slider.value = SoundManager.get_aim_sensitivity()
	if sensitivity_value:
		sensitivity_value.text = "%.2gx" % SoundManager.get_aim_sensitivity()
