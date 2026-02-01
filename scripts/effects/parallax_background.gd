extends ParallaxBackground
## Parallax scrolling background for the "descending into the pit" visual effect

# Track total scroll for seamless looping
var _total_scroll: float = 0.0


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Get world scroll speed (includes difficulty scaling)
	var scroll_speed := GameManager.get_world_scroll_speed()

	# Update scroll offset (positive Y = scroll downward = descending into pit)
	_total_scroll += scroll_speed * delta
	scroll_offset.y = _total_scroll

	# Wrap to prevent float precision issues over long sessions
	if _total_scroll > 10000.0:
		_total_scroll = fmod(_total_scroll, 1280.0)


func reset_scroll() -> void:
	_total_scroll = 0.0
	scroll_offset = Vector2.ZERO


func set_biome_colors(far_color: Color, mid_color: Color, near_color: Color) -> void:
	"""Update layer colors for biome changes"""
	var far_layer := get_node_or_null("FarLayer")
	var mid_layer := get_node_or_null("MidLayer")
	var near_layer := get_node_or_null("NearLayer")

	if far_layer:
		var bg := far_layer.get_node_or_null("Background") as ColorRect
		if bg:
			bg.color = far_color

	if mid_layer:
		var bg := mid_layer.get_node_or_null("Background") as ColorRect
		if bg:
			bg.color = mid_color

	if near_layer:
		var bg := near_layer.get_node_or_null("Background") as ColorRect
		if bg:
			bg.color = near_color
