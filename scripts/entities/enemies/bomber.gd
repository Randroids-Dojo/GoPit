class_name Bomber
extends "res://scripts/entities/enemies/enemy_base.gd"
## Bomber enemy - explodes on death, dealing AoE damage to nearby enemies and player

@export var body_color: Color = Color(0.8, 0.3, 0.1)
@export var fuse_color: Color = Color(1.0, 0.8, 0.2)
@export var body_radius: float = 18.0

# Explosion properties
const EXPLOSION_RADIUS: float = 100.0
const EXPLOSION_DAMAGE_TO_ENEMIES: int = 50
const EXPLOSION_DAMAGE_TO_PLAYER: int = 15
const EXPLOSION_VISUAL_DURATION: float = 0.4

# Fuse animation
var _fuse_flicker: float = 0.0
var _is_exploding: bool = false


func _ready() -> void:
	# Bombers are fragile but fast
	max_hp = int(max_hp * 0.6)
	hp = max_hp
	speed *= 1.2
	xp_value = int(xp_value * 1.8)
	# Low melee damage (explosion is the threat)
	damage_to_player = int(damage_to_player * 0.3)
	super._ready()


func _process(delta: float) -> void:
	# Animate fuse
	_fuse_flicker += delta * 15.0
	queue_redraw()


func _die() -> void:
	if _is_exploding:
		return
	_is_exploding = true

	# Trigger explosion
	_explode()

	# Call parent die after explosion
	super._die()


func _explode() -> void:
	# Damage nearby enemies
	_damage_nearby_enemies()

	# Damage player if close
	_damage_player_if_close()

	# Visual and audio feedback
	_explosion_effects()


func _damage_nearby_enemies() -> void:
	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if not enemies_container:
		return

	for enemy in enemies_container.get_children():
		if enemy == self:
			continue
		if enemy is EnemyBase:
			var dist: float = global_position.distance_to(enemy.global_position)
			if dist <= EXPLOSION_RADIUS:
				# Damage scales with distance
				var damage_mult := 1.0 - (dist / EXPLOSION_RADIUS)
				var damage := int(EXPLOSION_DAMAGE_TO_ENEMIES * damage_mult)
				enemy.take_damage(damage)


func _damage_player_if_close() -> void:
	var player := _get_player_node()
	if not player:
		return

	var dist: float = global_position.distance_to(player.global_position)
	if dist <= EXPLOSION_RADIUS:
		var damage_mult := 1.0 - (dist / EXPLOSION_RADIUS)
		var damage := int(EXPLOSION_DAMAGE_TO_PLAYER * damage_mult)
		if damage > 0:
			if player.has_method("take_damage"):
				player.take_damage(damage)
			else:
				GameManager.take_damage(damage)


func _explosion_effects() -> void:
	# Big camera shake
	CameraShake.shake(20.0, 8.0)

	# Play sound
	SoundManager.play(SoundManager.SoundType.ENEMY_DEATH)

	# Spawn explosion visual
	_spawn_explosion_visual()


func _spawn_explosion_visual() -> void:
	# Create explosion effect node
	var explosion := Node2D.new()
	explosion.global_position = global_position
	explosion.set_script(preload("res://scripts/entities/enemies/explosion_effect.gd"))
	explosion.set("explosion_radius", EXPLOSION_RADIUS)
	explosion.set("duration", EXPLOSION_VISUAL_DURATION)

	get_tree().current_scene.add_child(explosion)


func _draw() -> void:
	# Draw body (bomb shape - round with highlights)
	_draw_bomb_body()

	# Draw fuse
	_draw_fuse()

	# Draw warning skull
	_draw_skull()


func _draw_bomb_body() -> void:
	# Main body
	draw_circle(Vector2.ZERO, body_radius, body_color)

	# Highlight
	draw_circle(Vector2(-body_radius * 0.3, -body_radius * 0.3), body_radius * 0.25,
				body_color.lightened(0.3))

	# Dark bottom
	var bottom_points := PackedVector2Array()
	var segments := 16
	for i in range(segments + 1):
		var angle := PI * i / segments
		var x := cos(angle) * body_radius
		var y := sin(angle) * body_radius * 0.5 + body_radius * 0.3
		bottom_points.append(Vector2(x, y))
	if bottom_points.size() > 2:
		draw_colored_polygon(bottom_points, body_color.darkened(0.3))


func _draw_fuse() -> void:
	# Fuse stem
	var fuse_base := Vector2(0, -body_radius)
	var fuse_tip := Vector2(5, -body_radius - 15)

	draw_line(fuse_base, fuse_tip, Color(0.4, 0.3, 0.2), 3)

	# Sparking flame (animated)
	var flicker_offset := sin(_fuse_flicker) * 3
	var flame_color := fuse_color if int(_fuse_flicker) % 2 == 0 else fuse_color.lightened(0.3)

	var flame_points := PackedVector2Array([
		fuse_tip + Vector2(-4, 0),
		fuse_tip + Vector2(0 + flicker_offset, -12),
		fuse_tip + Vector2(4, 0)
	])
	draw_colored_polygon(flame_points, flame_color)

	# Inner flame
	var inner_points := PackedVector2Array([
		fuse_tip + Vector2(-2, -2),
		fuse_tip + Vector2(0 + flicker_offset * 0.5, -8),
		fuse_tip + Vector2(2, -2)
	])
	draw_colored_polygon(inner_points, Color(1, 1, 0.8))


func _draw_skull() -> void:
	# Simple skull warning symbol
	var skull_color := Color(0.9, 0.9, 0.8)

	# Skull outline
	draw_circle(Vector2.ZERO, body_radius * 0.45, skull_color)

	# Eye sockets
	draw_circle(Vector2(-body_radius * 0.15, -body_radius * 0.1), 4, body_color)
	draw_circle(Vector2(body_radius * 0.15, -body_radius * 0.1), 4, body_color)

	# Nose hole
	var nose_points := PackedVector2Array([
		Vector2(-2, body_radius * 0.1),
		Vector2(0, body_radius * 0.0),
		Vector2(2, body_radius * 0.1)
	])
	draw_colored_polygon(nose_points, body_color)
