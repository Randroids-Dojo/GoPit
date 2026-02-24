extends Node2D
class_name LazerLine
## LazerLine - Instant full-screen line effect for Lazer ball types
## Creates a visual line that damages all enemies it intersects
## Used by LASER_H (horizontal) and LASER_V (vertical) ball types

signal damage_dealt(total_damage: int, enemy_count: int)
signal effect_finished

enum Orientation { HORIZONTAL, VERTICAL }

var orientation: int = Orientation.HORIZONTAL
var line_color: Color = Color(1.0, 0.1, 0.1, 0.9)  # Bright red
var glow_color: Color = Color(1.0, 0.4, 0.4, 0.4)  # Softer red glow
var line_width: float = 8.0
var glow_width: float = 24.0
var effect_duration: float = 0.2  # How long the line stays visible
var fade_duration: float = 0.15  # How long to fade out

var damage: int = 12
var _line: Line2D
var _glow: Line2D
var _game_area_rect: Rect2


func _ready() -> void:
	# Get game area bounds
	_game_area_rect = _get_game_area_rect()

	# Create visual lines
	_create_line_visuals()

	# Deal damage to intersecting enemies
	_deal_damage_to_enemies()

	# Start fade out after effect duration
	var timer := get_tree().create_timer(effect_duration)
	timer.timeout.connect(_start_fade_out)


func _get_game_area_rect() -> Rect2:
	"""Get the game area rectangle for line positioning"""
	var game_area := get_tree().get_first_node_in_group("game_area")
	if game_area and game_area is Control:
		return Rect2(game_area.global_position, game_area.size)

	# Fallback to viewport size
	var viewport_size := get_viewport_rect().size
	return Rect2(Vector2.ZERO, viewport_size)


func _create_line_visuals() -> void:
	"""Create the main line and glow effect"""
	var start_pos: Vector2
	var end_pos: Vector2

	if orientation == Orientation.HORIZONTAL:
		# Horizontal line at player's Y position (global_position.y)
		start_pos = Vector2(_game_area_rect.position.x, global_position.y)
		end_pos = Vector2(_game_area_rect.end.x, global_position.y)
	else:
		# Vertical line at player's X position (global_position.x)
		start_pos = Vector2(global_position.x, _game_area_rect.position.y)
		end_pos = Vector2(global_position.x, _game_area_rect.end.y)

	# Convert to local coordinates
	start_pos -= global_position
	end_pos -= global_position

	# Create glow (drawn first, behind main line)
	_glow = Line2D.new()
	_glow.width = glow_width
	_glow.default_color = glow_color
	_glow.add_point(start_pos)
	_glow.add_point(end_pos)
	_glow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_glow.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(_glow)

	# Create main line
	_line = Line2D.new()
	_line.width = line_width
	_line.default_color = line_color
	_line.add_point(start_pos)
	_line.add_point(end_pos)
	_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(_line)


func _deal_damage_to_enemies() -> void:
	"""Find and damage all enemies intersecting the line"""
	var enemies_container := get_tree().get_first_node_in_group("enemies")
	if not enemies_container:
		return

	var total_damage: int = 0
	var enemies_hit: int = 0

	for enemy in enemies_container.get_children():
		if not enemy.has_method("take_damage"):
			continue

		# Check if enemy intersects the line
		if _enemy_intersects_line(enemy):
			enemy.take_damage(damage)
			_apply_hit_effect(enemy)
			total_damage += damage
			enemies_hit += 1

	if enemies_hit > 0:
		damage_dealt.emit(total_damage, enemies_hit)
		SoundManager.play(SoundManager.SoundType.HIT_ENEMY)


func _enemy_intersects_line(enemy: Node2D) -> bool:
	"""Check if an enemy intersects this lazer line"""
	var enemy_pos := enemy.global_position
	var threshold: float = 30.0  # Half of enemy size approximately

	if orientation == Orientation.HORIZONTAL:
		# Check if enemy Y is close to line Y
		return absf(enemy_pos.y - global_position.y) < threshold
	else:
		# Check if enemy X is close to line X
		return absf(enemy_pos.x - global_position.x) < threshold


func _apply_hit_effect(enemy: Node2D) -> void:
	"""Apply visual hit effect to enemy"""
	var original_color := enemy.modulate
	enemy.modulate = Color(1.0, 0.3, 0.3)  # Red flash

	var tween := enemy.create_tween()
	tween.tween_property(enemy, "modulate", original_color, 0.15)


func _start_fade_out() -> void:
	"""Fade out the line effect"""
	var tween := create_tween()
	tween.set_parallel(true)

	if _line:
		tween.tween_property(_line, "modulate:a", 0.0, fade_duration)
	if _glow:
		tween.tween_property(_glow, "modulate:a", 0.0, fade_duration)

	tween.finished.connect(_on_fade_finished)


func _on_fade_finished() -> void:
	"""Clean up after fade out"""
	effect_finished.emit()
	queue_free()
