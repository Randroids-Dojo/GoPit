extends ParallaxBackground
## Parallax scrolling background for the "descending into the pit" visual effect
## Uses multiple layers at different scroll speeds to create depth

signal scroll_updated(offset: float)

# Layer scroll multipliers (relative to world scroll speed)
const FAR_LAYER_MULT: float = 0.3   # Slow, subtle pattern
const MID_LAYER_MULT: float = 0.6   # Medium, biome features
const NEAR_LAYER_MULT: float = 1.0  # Fast, particles/atmospheric

@onready var far_layer: ParallaxLayer = $FarLayer
@onready var mid_layer: ParallaxLayer = $MidLayer
@onready var near_layer: ParallaxLayer = $NearLayer

# Track total scroll for seamless looping
var _total_scroll: float = 0.0
var _is_scrolling: bool = false


func _ready() -> void:
	# Configure layer motion scales
	if far_layer:
		far_layer.motion_scale = Vector2(0, FAR_LAYER_MULT)
	if mid_layer:
		mid_layer.motion_scale = Vector2(0, MID_LAYER_MULT)
	if near_layer:
		near_layer.motion_scale = Vector2(0, NEAR_LAYER_MULT)


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Get world scroll speed (already includes difficulty multiplier)
	var scroll_speed := GameManager.get_world_scroll_speed()

	# Update scroll offset (negative Y = scroll upward = descending into pit)
	_total_scroll -= scroll_speed * delta
	scroll_offset.y = _total_scroll

	# Seamless wrap (reset when scrolled beyond a full texture repeat)
	# This prevents float precision issues over long play sessions
	const WRAP_THRESHOLD: float = 10000.0
	if abs(_total_scroll) > WRAP_THRESHOLD:
		_total_scroll = fmod(_total_scroll, WRAP_THRESHOLD)

	scroll_updated.emit(_total_scroll)


func start_scrolling() -> void:
	_is_scrolling = true


func stop_scrolling() -> void:
	_is_scrolling = false


func reset_scroll() -> void:
	_total_scroll = 0.0
	scroll_offset = Vector2.ZERO


func set_biome_colors(far_color: Color, mid_color: Color, near_color: Color) -> void:
	"""Update parallax layer colors for biome changes (procedural backgrounds)"""
	if far_layer:
		var far_bg := far_layer.get_node_or_null("Background") as ColorRect
		if far_bg:
			far_bg.color = far_color

	if mid_layer:
		var mid_bg := mid_layer.get_node_or_null("Background") as ColorRect
		if mid_bg:
			mid_bg.color = mid_color

	if near_layer:
		var near_bg := near_layer.get_node_or_null("Background") as ColorRect
		if near_bg:
			near_bg.color = near_color
