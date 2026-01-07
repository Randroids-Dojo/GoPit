extends Area2D
## Fusion Reactor - rare drop that enables ball fusion/evolution
## Collection triggers the fusion overlay UI

signal collected(reactor: Node2D)

@export var radius: float = 14.0
@export var fall_speed: float = 100.0
@export var pulse_speed: float = 2.0
@export var rotation_speed: float = 1.5
@export var despawn_time: float = 15.0

const MAGNETISM_SPEED: float = 350.0
const COLLECTION_RADIUS: float = 35.0

# Visual colors
const CORE_COLOR := Color(0.6, 0.2, 1.0)       # Purple core
const GLOW_COLOR := Color(0.3, 0.8, 1.0, 0.5)  # Cyan glow
const RING_COLOR := Color(0.8, 0.4, 1.0)       # Purple-pink ring

var _time: float = 0.0
var _player: Node2D = null
var _being_attracted: bool = false
var _orbit_angle: float = 0.0


func _ready() -> void:
	collision_layer = 32  # fusion_reactors layer (layer 6 = bit 32)
	collision_mask = 16   # player layer

	body_entered.connect(_on_body_entered)

	# Find player reference
	_player = get_tree().get_first_node_in_group("player")

	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	_orbit_angle += rotation_speed * delta

	# Check for player proximity and collect
	if _player and global_position.distance_to(_player.global_position) < COLLECTION_RADIUS:
		_collect()
		return

	# Check for magnetism toward player
	_being_attracted = false
	var magnetism_range := GameManager.gem_magnetism_range
	if magnetism_range > 0 and _player:
		var distance_to_player := global_position.distance_to(_player.global_position)
		# Reactors have larger magnetism range than gems
		if distance_to_player < magnetism_range * 1.5:
			_being_attracted = true
			var direction := (_player.global_position - global_position).normalized()
			var pull_strength := 1.0 - (distance_to_player / (magnetism_range * 1.5))
			var current_speed := lerpf(fall_speed, MAGNETISM_SPEED, pull_strength)
			global_position += direction * current_speed * delta
		else:
			position.y += fall_speed * delta
	else:
		position.y += fall_speed * delta

	queue_redraw()

	# Despawn after timeout or if off screen
	if _time > despawn_time or position.y > 1400:
		queue_free()


func _draw() -> void:
	# Draw magnetism pull line when being attracted
	if _being_attracted and _player:
		var to_player := to_local(_player.global_position)
		draw_line(Vector2.ZERO, to_player, Color(0.5, 0.8, 1.0, 0.3), 2.0)

	var pulse := (sin(_time * pulse_speed) + 1.0) * 0.5

	# Outer glow
	var glow_radius := radius * (1.8 + pulse * 0.4)
	draw_circle(Vector2.ZERO, glow_radius, GLOW_COLOR)

	# Orbiting particles (3 particles)
	for i in range(3):
		var orbit_offset := _orbit_angle + i * TAU / 3.0
		var orbit_pos := Vector2(cos(orbit_offset), sin(orbit_offset)) * radius * 1.2
		var particle_color := RING_COLOR.lightened(pulse * 0.3)
		draw_circle(orbit_pos, 3.0, particle_color)

	# Core circle with pulse
	var core_size := radius * (0.9 + pulse * 0.1)
	var core_color := CORE_COLOR.lightened(pulse * 0.2)
	draw_circle(Vector2.ZERO, core_size, core_color)

	# Inner highlight
	var highlight_color := Color(1.0, 1.0, 1.0, 0.5 + pulse * 0.3)
	draw_circle(Vector2(-3, -3), radius * 0.3, highlight_color)

	# Atom symbol (simplified) - three elliptical orbits
	var orbit_alpha := 0.4 + pulse * 0.2
	_draw_orbit_ring(0.0, orbit_alpha)
	_draw_orbit_ring(TAU / 3.0, orbit_alpha)
	_draw_orbit_ring(2.0 * TAU / 3.0, orbit_alpha)


func _draw_orbit_ring(angle_offset: float, alpha: float) -> void:
	var ring_color := Color(RING_COLOR.r, RING_COLOR.g, RING_COLOR.b, alpha)
	var points := PackedVector2Array()
	var segments := 16
	var orbit_radius := radius * 0.7

	for i in range(segments + 1):
		var angle := float(i) / segments * TAU
		# Elliptical orbit tilted by angle_offset
		var x := cos(angle) * orbit_radius
		var y := sin(angle) * orbit_radius * 0.4  # Flatten to ellipse
		# Rotate the ellipse
		var rotated := Vector2(x, y).rotated(angle_offset)
		points.append(rotated)

	draw_polyline(points, ring_color, 1.5)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_collect()


func _collect() -> void:
	collected.emit(self)
	# Play a distinct sound (reuse level up or add new one)
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	queue_free()
