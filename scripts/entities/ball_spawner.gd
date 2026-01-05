extends Node2D
## Spawns balls in the aimed direction when fire is triggered

signal ball_spawned(ball: Node2D)

@export var ball_scene: PackedScene
@export var spawn_offset: float = 30.0
@export var balls_container: Node2D

var current_aim_direction: Vector2 = Vector2.UP
var ball_damage: int = 10
var ball_speed: float = 800.0
var ball_count: int = 1
var ball_spread: float = 0.15  # radians between balls
var pierce_count: int = 0
var max_bounces: int = 10  # default wall bounces
var crit_chance: float = 0.0


func _ready() -> void:
	add_to_group("ball_spawner")
	if ball_scene == null:
		ball_scene = preload("res://scenes/entities/ball.tscn")


func set_aim_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		current_aim_direction = direction.normalized()


func fire() -> void:
	if current_aim_direction == Vector2.ZERO:
		return

	for i in range(ball_count):
		# Calculate spread offset for multi-shot
		var spread_offset: float = 0.0
		if ball_count > 1:
			spread_offset = (i - (ball_count - 1) / 2.0) * ball_spread

		var dir := current_aim_direction.rotated(spread_offset)
		_spawn_ball(dir)

	SoundManager.play(SoundManager.SoundType.FIRE)


func _spawn_ball(direction: Vector2) -> void:
	var ball := ball_scene.instantiate()
	ball.position = global_position + direction * spawn_offset
	ball.set_direction(direction)
	ball.damage = ball_damage
	ball.speed = ball_speed
	ball.pierce_count = pierce_count
	ball.max_bounces = max_bounces
	ball.crit_chance = crit_chance

	if balls_container:
		balls_container.add_child(ball)
	else:
		get_parent().add_child(ball)

	ball_spawned.emit(ball)


func increase_damage(amount: int) -> void:
	ball_damage += amount


func increase_speed(amount: float) -> void:
	ball_speed += amount


func add_multi_shot() -> void:
	ball_count += 1


func add_piercing(amount: int) -> void:
	pierce_count += amount


func add_ricochet(amount: int) -> void:
	max_bounces += amount


func add_crit_chance(amount: float) -> void:
	crit_chance = minf(1.0, crit_chance + amount)


func get_spawn_position() -> Vector2:
	return global_position + current_aim_direction * spawn_offset


func get_aim_direction() -> Vector2:
	return current_aim_direction
