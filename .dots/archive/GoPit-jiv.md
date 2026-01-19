---
title: Baby Ball Auto-Generation System
status: done
priority: 1
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:21:41.301447-06:00
---

# Baby Ball Auto-Generation System

## Parent Epic
GoPit-3ky (Phase 1 - Core Alignment)

## Overview
Implement passive baby ball generation - small balls that automatically spawn and fire at enemies, providing base DPS.

## Current State
- ball.gd handles regular ball behavior
- ball_spawner.gd fires balls on command
- No passive/automatic ball generation exists
- GameManager has no "Leadership" stat for baby ball rate

## BallxPit Reference
In BallxPit:
- Player generates "child balls" automatically
- Baby balls are smaller, deal less damage
- "Leadership" stat affects generation rate
- Some characters (Tactician) specialize in baby balls
- Baby balls fire in aimed direction or at nearest enemy

## Requirements
1. Baby balls spawn automatically on timer
2. Baby balls are visually smaller than regular balls
3. Baby balls deal reduced damage (50% of regular)
4. Fire direction: toward nearest enemy (or aimed direction)
5. Generation rate affected by "Leadership" stat
6. Base rate: 1 baby ball every 2 seconds
7. Baby balls share physics with regular balls (bounce, etc.)

## Implementation Approach

### Step 1: Add Baby Ball Spawner
Create new script: scripts/entities/baby_ball_spawner.gd
```gdscript
class_name BabyBallSpawner
extends Node2D

signal baby_ball_spawned(ball: Node2D)

@export var ball_scene: PackedScene
@export var base_spawn_interval: float = 2.0
@export var baby_ball_damage_multiplier: float = 0.5
@export var baby_ball_scale: float = 0.6

var _spawn_timer: Timer
var _player: Node2D
var _balls_container: Node2D

# Leadership stat affects spawn rate
var leadership_bonus: float = 0.0

func _ready() -> void:
    _setup_timer()
    _player = get_tree().get_first_node_in_group("player")
    
func _setup_timer() -> void:
    _spawn_timer = Timer.new()
    _spawn_timer.one_shot = false
    _spawn_timer.timeout.connect(_spawn_baby_ball)
    add_child(_spawn_timer)
    
func start() -> void:
    _update_spawn_rate()
    _spawn_timer.start()
    
func stop() -> void:
    _spawn_timer.stop()

func set_leadership(value: float) -> void:
    leadership_bonus = value
    _update_spawn_rate()

func _update_spawn_rate() -> void:
    # Higher leadership = faster spawns
    # leadership_bonus of 1.0 = 2x spawn rate
    var rate := base_spawn_interval / (1.0 + leadership_bonus)
    _spawn_timer.wait_time = max(0.3, rate)

func _spawn_baby_ball() -> void:
    if not _player or not ball_scene:
        return
    
    var ball := ball_scene.instantiate()
    ball.position = _player.global_position
    ball.scale = Vector2(baby_ball_scale, baby_ball_scale)
    ball.damage = int(ball.damage * baby_ball_damage_multiplier)
    
    # Set direction toward nearest enemy
    var direction := _get_target_direction()
    ball.set_direction(direction)
    
    if _balls_container:
        _balls_container.add_child(ball)
    else:
        get_parent().add_child(ball)
    
    baby_ball_spawned.emit(ball)

func _get_target_direction() -> Vector2:
    var nearest := _find_nearest_enemy()
    if nearest:
        return (_player.global_position.direction_to(nearest.global_position))
    # Fallback: random upward direction
    return Vector2(randf_range(-0.3, 0.3), -1.0).normalized()

func _find_nearest_enemy() -> Node2D:
    var enemies_container := get_tree().get_first_node_in_group("enemies_container")
    if not enemies_container:
        return null
    
    var nearest: Node2D = null
    var nearest_dist: float = INF
    
    for enemy in enemies_container.get_children():
        if enemy is EnemyBase:
            var dist: float = _player.global_position.distance_to(enemy.global_position)
            if dist < nearest_dist:
                nearest_dist = dist
                nearest = enemy
    
    return nearest
```

### Step 2: Visual Distinction
Baby balls should look different:
```gdscript
# In ball.gd, add baby ball visual
var is_baby_ball: bool = false

func _draw() -> void:
    if is_baby_ball:
        # Smaller, different color tint
        draw_circle(Vector2.ZERO, radius * 0.6, ball_color.lightened(0.3))
        # Trail is shorter
    else:
        # Normal ball drawing
        draw_circle(Vector2.ZERO, radius, ball_color)
```

### Step 3: Integrate with game_controller.gd
```gdscript
@onready var baby_ball_spawner: BabyBallSpawner = $GameArea/BabyBallSpawner

func _on_game_started() -> void:
    # ... existing code ...
    if baby_ball_spawner:
        baby_ball_spawner._balls_container = balls_container
        baby_ball_spawner.start()

func _on_game_over() -> void:
    # ... existing code ...
    if baby_ball_spawner:
        baby_ball_spawner.stop()
```

### Step 4: Add to GameManager
```gdscript
# In game_manager.gd
var leadership: float = 0.0

func add_leadership(amount: float) -> void:
    leadership += amount
    # Notify baby ball spawner
    var spawner := get_tree().get_first_node_in_group("baby_ball_spawner")
    if spawner:
        spawner.set_leadership(leadership)
```

### Step 5: Add Leadership Upgrade
In level_up_overlay.gd:
```gdscript
UpgradeType.LEADERSHIP: {
    "name": "Leadership",
    "description": "+1 Baby Ball rate",
    "apply": "_apply_leadership",
    "max_stacks": 5
}

func _apply_leadership() -> void:
    GameManager.add_leadership(0.2)  # 20% faster baby balls per stack
```

## Files to Create/Modify
- NEW: scripts/entities/baby_ball_spawner.gd
- NEW: scenes/entities/baby_ball_spawner.tscn
- MODIFY: scripts/game/game_controller.gd
- MODIFY: scripts/autoload/game_manager.gd (add leadership)
- MODIFY: scripts/ui/level_up_overlay.gd (add leadership upgrade)
- MODIFY: scripts/entities/ball.gd (baby ball visual)

## Testing
```python
async def test_baby_balls_spawn_automatically(game):
    """Baby balls should spawn without player input"""
    balls = "/root/Game/GameArea/Balls"
    
    # Don't fire manually, just wait
    initial = await game.call(balls, "get_child_count")
    await asyncio.sleep(3.0)  # Wait for 1-2 baby balls
    final = await game.call(balls, "get_child_count")
    
    assert final > initial, "Baby balls should auto-spawn"

async def test_baby_balls_target_enemies(game):
    """Baby balls should fire toward nearest enemy"""
    # Spawn enemy at known position
    # Wait for baby ball
    # Check ball direction points toward enemy
    pass

async def test_leadership_affects_spawn_rate(game):
    """Higher leadership = more baby balls"""
    # Apply leadership upgrade multiple times
    # Measure spawn rate
    pass
```

## Acceptance Criteria
- [ ] Baby balls spawn automatically every ~2 seconds
- [ ] Baby balls are visually smaller than regular balls
- [ ] Baby balls deal 50% damage
- [ ] Baby balls fire toward nearest enemy
- [ ] Leadership upgrade increases spawn rate
- [ ] Baby balls follow same physics (bounce, despawn)
- [ ] Sound plays on baby ball spawn (quieter than manual)

## Dependencies
- Requires Player Free Movement (baby balls spawn at player position)

## Notes
- Baby balls create constant base DPS
- Frees player to focus on dodging
- Leadership builds viable in later phases
- Consider: baby balls could inherit ball type effects
