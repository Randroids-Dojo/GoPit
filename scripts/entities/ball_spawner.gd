extends Node2D
## Spawns balls in the aimed direction when fire is triggered

signal ball_spawned(ball: Node2D)

@export var ball_scene: PackedScene
@export var spawn_offset: float = 30.0
@export var balls_container: Node2D

var current_aim_direction: Vector2 = Vector2.UP
var ball_damage: int = 10


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

	var ball := ball_scene.instantiate()
	ball.position = global_position + current_aim_direction * spawn_offset
	ball.set_direction(current_aim_direction)
	ball.damage = ball_damage

	if balls_container:
		balls_container.add_child(ball)
	else:
		get_parent().add_child(ball)

	ball_spawned.emit(ball)


func increase_damage(amount: int) -> void:
	ball_damage += amount


func get_spawn_position() -> Vector2:
	return global_position + current_aim_direction * spawn_offset


func get_aim_direction() -> Vector2:
	return current_aim_direction
