extends Node
## CameraShake autoload - provides global screen shake functionality

signal screen_shake_changed(enabled: bool)

var _camera: Camera2D
var shake_intensity: float = 0.0
var shake_decay: float = 5.0
var screen_shake_enabled: bool = true


func _ready() -> void:
	# Find or create camera when scene changes
	get_tree().root.child_entered_tree.connect(_on_scene_changed)


func _on_scene_changed(_node: Node) -> void:
	# Defer to let scene fully load
	call_deferred("_find_camera")


func _find_camera() -> void:
	_camera = get_tree().get_first_node_in_group("game_camera")


func _process(delta: float) -> void:
	if not _camera:
		return

	if shake_intensity > 0:
		_camera.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity = lerpf(shake_intensity, 0.0, shake_decay * delta)
		if shake_intensity < 0.1:
			shake_intensity = 0.0
			_camera.offset = Vector2.ZERO
	else:
		_camera.offset = Vector2.ZERO


func shake(intensity: float = 10.0, decay: float = 5.0) -> void:
	if not screen_shake_enabled:
		return
	shake_intensity = maxf(shake_intensity, intensity)
	shake_decay = decay


func toggle_screen_shake() -> void:
	screen_shake_enabled = not screen_shake_enabled
	screen_shake_changed.emit(screen_shake_enabled)
	# Reset any active shake when disabling
	if not screen_shake_enabled:
		shake_intensity = 0.0
		if _camera:
			_camera.offset = Vector2.ZERO


func set_screen_shake(enabled: bool) -> void:
	if screen_shake_enabled != enabled:
		screen_shake_enabled = enabled
		screen_shake_changed.emit(screen_shake_enabled)
		if not screen_shake_enabled:
			shake_intensity = 0.0
			if _camera:
				_camera.offset = Vector2.ZERO
