extends CanvasLayer
## Pause menu overlay with mute and screen shake toggles

signal resumed
signal quit_requested

@onready var mute_button: Button = $DimBackground/Panel/VBoxContainer/MuteButton
@onready var screen_shake_button: Button = $DimBackground/Panel/VBoxContainer/ScreenShakeButton
@onready var hitbox_button: Button = $DimBackground/Panel/VBoxContainer/HitboxButton
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
	if hitbox_button:
		hitbox_button.pressed.connect(_on_hitbox_pressed)
		_update_hitbox_button()

	# Listen for state changes
	SoundManager.mute_changed.connect(_on_mute_changed)
	CameraShake.screen_shake_changed.connect(_on_screen_shake_changed)


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
	_update_hitbox_button()


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


func _on_hitbox_pressed() -> void:
	GameManager.show_hitbox = not GameManager.show_hitbox
	_update_hitbox_button()
	# Force player to redraw with new hitbox setting
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.queue_redraw()


func _update_hitbox_button() -> void:
	if hitbox_button:
		if GameManager.show_hitbox:
			hitbox_button.text = "Show Hitbox: ON"
		else:
			hitbox_button.text = "Show Hitbox: OFF"
