extends CanvasLayer
## Pause menu overlay with mute toggle

signal resumed
signal quit_requested

@onready var mute_button: Button = $DimBackground/Panel/VBoxContainer/MuteButton
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
	_update_mute_button()


func _update_mute_button() -> void:
	if mute_button:
		if SoundManager.is_muted:
			mute_button.text = "Sound: OFF"
		else:
			mute_button.text = "Sound: ON"
