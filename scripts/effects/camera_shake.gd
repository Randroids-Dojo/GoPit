extends Node
## CameraShake autoload - provides global screen shake functionality

var _camera: Camera2D
var shake_intensity: float = 0.0
var shake_decay: float = 5.0


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
	shake_intensity = maxf(shake_intensity, intensity)
	shake_decay = decay
