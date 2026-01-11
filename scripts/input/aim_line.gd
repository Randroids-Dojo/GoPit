extends Line2D
## Trajectory preview line for aiming with bounce prediction

@export var max_length: float = 400.0
@export var line_color: Color = Color(1.0, 1.0, 1.0, 0.4)
@export var ghost_color: Color = Color(0.5, 0.5, 0.5, 0.3)
@export var line_width_value: float = 3.0
@export var dash_length: float = 20.0
@export var gap_length: float = 10.0
@export var max_bounces: int = 3  # How many bounces to predict
@export var bounce_opacity_decay: float = 0.6  # Opacity multiplier per bounce

const WALL_COLLISION_LAYER: int = 1

var current_direction: Vector2 = Vector2.UP
var is_active: bool = false
var _last_origin: Vector2 = Vector2.ZERO
var _fade_tween: Tween
var _bounce_lines: Array[Line2D] = []  # Child lines for bounce segments


func _ready() -> void:
	width = line_width_value
	default_color = line_color
	visible = false
	_create_bounce_lines()


func show_line(direction: Vector2, start_pos: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	current_direction = direction.normalized()
	is_active = true
	visible = true
	_last_origin = start_pos

	# Cancel any fade animation
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	default_color = line_color

	# Reset bounce line colors to active state
	for i in range(_bounce_lines.size()):
		var opacity := line_color.a * pow(bounce_opacity_decay, i + 1)
		_bounce_lines[i].default_color = Color(line_color.r, line_color.g, line_color.b, opacity)

	_update_line(start_pos)


func hide_line() -> void:
	is_active = false
	# Don't hide - fade to ghost state
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(self, "default_color", ghost_color, 0.2)

	# Fade bounce lines too
	for i in range(_bounce_lines.size()):
		var opacity := ghost_color.a * pow(bounce_opacity_decay, i + 1)
		var bounce_ghost := Color(ghost_color.r, ghost_color.g, ghost_color.b, opacity)
		_fade_tween.tween_property(_bounce_lines[i], "default_color", bounce_ghost, 0.2)


func _update_line(start_pos: Vector2) -> void:
	clear_points()
	_last_origin = start_pos

	# Raycast to find first wall hit
	var result := _raycast_to_wall(start_pos, current_direction, max_length)
	var end_pos: Vector2
	if result.is_empty():
		end_pos = start_pos + current_direction * max_length
	else:
		end_pos = result.position

	# Draw main line to first wall (or max length)
	_draw_dashed_segment_main(start_pos, end_pos)

	# Draw bounce predictions
	_update_bounce_lines(start_pos, current_direction)


func _draw_dashed_segment_main(start: Vector2, end: Vector2) -> void:
	# Draw the main line's dashed segment
	var direction := (end - start).normalized()
	var total_length := start.distance_to(end)
	var current_pos := start
	var remaining := total_length
	var is_dash := true

	while remaining > 0:
		var segment_length := dash_length if is_dash else gap_length
		segment_length = minf(segment_length, remaining)

		if is_dash:
			add_point(current_pos)
			add_point(current_pos + direction * segment_length)

		current_pos += direction * segment_length
		remaining -= segment_length
		is_dash = not is_dash


func update_position(start_pos: Vector2) -> void:
	if visible:
		_update_line(start_pos)


func set_direction(direction: Vector2) -> void:
	current_direction = direction.normalized()


func _create_bounce_lines() -> void:
	# Create child Line2D nodes for bounce segments
	for i in range(max_bounces):
		var bounce_line := Line2D.new()
		bounce_line.width = line_width_value
		var opacity := line_color.a * pow(bounce_opacity_decay, i + 1)
		bounce_line.default_color = Color(line_color.r, line_color.g, line_color.b, opacity)
		bounce_line.visible = false
		add_child(bounce_line)
		_bounce_lines.append(bounce_line)


func _raycast_to_wall(from: Vector2, direction: Vector2, max_distance: float) -> Dictionary:
	# Raycast to detect wall collision
	var space_state := get_world_2d().direct_space_state
	if not space_state:
		return {}

	var query := PhysicsRayQueryParameters2D.create(from, from + direction * max_distance)
	query.collision_mask = WALL_COLLISION_LAYER
	query.collide_with_areas = false
	query.collide_with_bodies = true

	return space_state.intersect_ray(query)


func _draw_dashed_segment(line: Line2D, start: Vector2, end: Vector2) -> void:
	# Draw a dashed segment between two points
	line.clear_points()
	var direction := (end - start).normalized()
	var total_length := start.distance_to(end)
	var current_pos := start
	var remaining := total_length
	var is_dash := true

	while remaining > 0:
		var segment_length := dash_length if is_dash else gap_length
		segment_length = minf(segment_length, remaining)

		if is_dash:
			line.add_point(current_pos)
			line.add_point(current_pos + direction * segment_length)

		current_pos += direction * segment_length
		remaining -= segment_length
		is_dash = not is_dash


func _update_bounce_lines(start_pos: Vector2, direction: Vector2) -> void:
	# Hide all bounce lines first
	for line in _bounce_lines:
		line.visible = false
		line.clear_points()

	var current_pos := start_pos
	var current_dir := direction
	var remaining_length := max_length

	# Start from after the first segment (main line handles first segment)
	# Raycast to find first wall hit
	var result := _raycast_to_wall(current_pos, current_dir, remaining_length)
	if result.is_empty():
		return  # No wall hit within range

	# Move to the first hit point (main line goes here)
	var first_hit := result.position as Vector2
	remaining_length -= current_pos.distance_to(first_hit)
	current_pos = first_hit

	# Calculate first bounce direction
	var normal := result.normal as Vector2
	current_dir = current_dir.bounce(normal)

	# Draw subsequent bounces
	for i in range(max_bounces):
		if remaining_length <= 0:
			break

		# Find next wall hit
		# Offset slightly from wall to avoid self-collision
		var offset_pos := current_pos + current_dir * 2.0
		result = _raycast_to_wall(offset_pos, current_dir, remaining_length)

		var end_pos: Vector2
		if result.is_empty():
			# No more walls, draw to max length
			end_pos = current_pos + current_dir * remaining_length
			_bounce_lines[i].visible = visible
			_draw_dashed_segment(_bounce_lines[i], current_pos, end_pos)
			break
		else:
			end_pos = result.position
			_bounce_lines[i].visible = visible
			_draw_dashed_segment(_bounce_lines[i], current_pos, end_pos)

			# Prepare for next bounce
			remaining_length -= current_pos.distance_to(end_pos)
			current_pos = end_pos
			normal = result.normal
			current_dir = current_dir.bounce(normal)
