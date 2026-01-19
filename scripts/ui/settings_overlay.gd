extends CanvasLayer
## Settings overlay with volume controls for master, SFX, and music

signal closed

@onready var master_slider: HSlider = $DimBackground/Panel/VBoxContainer/MasterContainer/MasterSlider
@onready var master_value: Label = $DimBackground/Panel/VBoxContainer/MasterContainer/MasterValue
@onready var sfx_slider: HSlider = $DimBackground/Panel/VBoxContainer/SFXContainer/SFXSlider
@onready var sfx_value: Label = $DimBackground/Panel/VBoxContainer/SFXContainer/SFXValue
@onready var music_slider: HSlider = $DimBackground/Panel/VBoxContainer/MusicContainer/MusicSlider
@onready var music_value: Label = $DimBackground/Panel/VBoxContainer/MusicContainer/MusicValue
@onready var mute_button: CheckButton = $DimBackground/Panel/VBoxContainer/MuteButton
@onready var close_button: Button = $DimBackground/Panel/VBoxContainer/CloseButton


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect sliders
	if master_slider:
		master_slider.value_changed.connect(_on_master_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_changed)
	if music_slider:
		music_slider.value_changed.connect(_on_music_changed)
	if mute_button:
		mute_button.toggled.connect(_on_mute_toggled)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	# Listen for state changes
	SoundManager.mute_changed.connect(_on_mute_changed)


func show_settings() -> void:
	visible = true
	_update_all_controls()


func hide_settings() -> void:
	visible = false


func _update_all_controls() -> void:
	_update_master_slider()
	_update_sfx_slider()
	_update_music_slider()
	_update_mute_button()


func _on_master_changed(value: float) -> void:
	SoundManager.set_master_volume(value)
	_update_master_slider()


func _update_master_slider() -> void:
	if master_slider:
		master_slider.value = SoundManager.master_volume
	if master_value:
		master_value.text = str(int(SoundManager.master_volume * 100)) + "%"


func _on_sfx_changed(value: float) -> void:
	SoundManager.set_sfx_volume(value)
	_update_sfx_slider()


func _update_sfx_slider() -> void:
	if sfx_slider:
		sfx_slider.value = SoundManager.sfx_volume
	if sfx_value:
		sfx_value.text = str(int(SoundManager.sfx_volume * 100)) + "%"


func _on_music_changed(value: float) -> void:
	SoundManager.set_music_volume(value)
	_update_music_slider()


func _update_music_slider() -> void:
	if music_slider:
		music_slider.value = SoundManager.music_volume
	if music_value:
		music_value.text = str(int(SoundManager.music_volume * 100)) + "%"


func _on_mute_toggled(button_pressed: bool) -> void:
	if SoundManager.is_muted != button_pressed:
		SoundManager.toggle_mute()


func _on_mute_changed(_is_muted: bool) -> void:
	_update_mute_button()


func _update_mute_button() -> void:
	if mute_button:
		mute_button.button_pressed = SoundManager.is_muted
		mute_button.text = "Muted" if SoundManager.is_muted else "Mute All Audio"


func _on_close_pressed() -> void:
	hide_settings()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
