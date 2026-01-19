---
title: Add ball type variants (Fire, Ice, Multi)
status: done
priority: 3
issue-type: feature
assignee: randroid
created-at: 2026-01-05T02:15:32.979968-06:00
---

## Problem
Only basic blue ball exists. No variety in gameplay.

## Implementation Plan

### Ball Type Enum
**Modify: `scripts/entities/ball.gd`**

```gdscript
enum BallType { BASIC, FIRE, ICE, MULTI }

@export var ball_type: BallType = BallType.BASIC

# Type-specific properties
var burn_damage: int = 0
var slow_amount: float = 0.0
var split_on_hit: bool = false

func _ready():
    _apply_type_properties()
    queue_redraw()

func _apply_type_properties():
    match ball_type:
        BallType.BASIC:
            ball_color = Color(0.3, 0.7, 1.0)  # Blue
        BallType.FIRE:
            ball_color = Color(1.0, 0.4, 0.1)  # Orange
            burn_damage = 3  # DoT
        BallType.ICE:
            ball_color = Color(0.5, 0.9, 1.0)  # Cyan
            slow_amount = 0.5  # 50% slow
        BallType.MULTI:
            ball_color = Color(1.0, 0.8, 0.2)  # Gold
            split_on_hit = true

func _on_hit_enemy(enemy, collision):
    # Apply base damage
    enemy.take_damage(damage)
    
    # Type-specific effects
    match ball_type:
        BallType.FIRE:
            enemy.apply_burn(burn_damage, 3.0)  # 3 damage over 3 seconds
        BallType.ICE:
            enemy.apply_slow(slow_amount, 2.0)  # 50% slow for 2 seconds
        BallType.MULTI:
            if split_on_hit:
                _split_ball(collision.get_normal())
                split_on_hit = false  # Only split once

func _split_ball(normal: Vector2):
    # Spawn 2 additional balls at 45 degree angles
    var spawner = get_tree().get_first_node_in_group("ball_spawner")
    if spawner:
        var left_dir = direction.rotated(-PI/4)
        var right_dir = direction.rotated(PI/4)
        spawner._spawn_ball_at(global_position, left_dir, BallType.BASIC)
        spawner._spawn_ball_at(global_position, right_dir, BallType.BASIC)
```

### Enemy Status Effects
**Modify: `scripts/entities/enemies/enemy_base.gd`**

```gdscript
var burn_timer: float = 0.0
var burn_dps: int = 0
var slow_timer: float = 0.0
var slow_amount: float = 0.0
var base_speed: float = 0.0

func _ready():
    base_speed = speed

func apply_burn(dps: int, duration: float):
    burn_dps = dps
    burn_timer = duration
    # Visual: add fire particles

func apply_slow(amount: float, duration: float):
    slow_amount = amount
    slow_timer = duration
    speed = base_speed * (1.0 - slow_amount)
    modulate = Color(0.7, 0.9, 1.0)  # Icy tint

func _process(delta):
    # Burn damage
    if burn_timer > 0:
        burn_timer -= delta
        take_damage(int(burn_dps * delta))
    
    # Slow expiry
    if slow_timer > 0:
        slow_timer -= delta
        if slow_timer <= 0:
            speed = base_speed
            modulate = Color.WHITE
```

### Ball Spawner Integration
**Modify: `scripts/entities/ball_spawner.gd`**

```gdscript
var current_ball_type: Ball.BallType = Ball.BallType.BASIC

func set_ball_type(type: Ball.BallType):
    current_ball_type = type

func _spawn_ball(dir: Vector2):
    var ball = ball_scene.instantiate()
    ball.ball_type = current_ball_type
    ball.damage = ball_damage
    ball.position = global_position + dir * 30
    ball.set_direction(dir)
    balls_container.add_child(ball)
```

### Unlock System
Ball types can be unlocked via meta-progression (Pit Coins) or as rare level-up upgrades.

### Files to Modify
1. MODIFY: `scripts/entities/ball.gd` - ball types
2. MODIFY: `scripts/entities/enemies/enemy_base.gd` - status effects
3. MODIFY: `scripts/entities/ball_spawner.gd` - type selection
4. MODIFY: `scripts/ui/level_up_overlay.gd` - ball type upgrades
