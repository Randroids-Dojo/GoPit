extends Label
## Queue Display - shows current firing queue status
## Displays queue depth and indicates when full

var ball_spawner: Node

# Colors for different queue states
const COLOR_NORMAL := Color(0.8, 0.8, 0.8)  # Light gray
const COLOR_HIGH := Color(1.0, 0.8, 0.3)    # Yellow-orange (queue getting full)
const COLOR_FULL := Color(1.0, 0.3, 0.3)    # Red (queue full)

var _current_queue_size: int = 0
var _max_queue_size: int = 20


func _ready() -> void:
	# Find ball spawner
	ball_spawner = get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner:
		ball_spawner.queue_changed.connect(_on_queue_changed)

	# Initial state
	_update_display()


func _on_queue_changed(queue_size: int, max_size: int) -> void:
	_current_queue_size = queue_size
	_max_queue_size = max_size
	_update_display()


func _update_display() -> void:
	# Update text
	if _current_queue_size == 0:
		text = ""
		visible = false
	else:
		text = "Q: %d/%d" % [_current_queue_size, _max_queue_size]
		visible = true

	# Update color based on fill level
	var fill_ratio: float = float(_current_queue_size) / float(_max_queue_size)
	if fill_ratio >= 1.0:
		add_theme_color_override("font_color", COLOR_FULL)
	elif fill_ratio >= 0.75:
		add_theme_color_override("font_color", COLOR_HIGH)
	else:
		add_theme_color_override("font_color", COLOR_NORMAL)
