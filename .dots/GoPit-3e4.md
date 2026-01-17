---
title: Add ball limit for performance
status: open
priority: 4
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:13:41.289161-06:00
---

## Problem
With fire rate upgrades, many balls can exist simultaneously. Could cause performance issues.

## Implementation Plan

### Add Ball Limit to Spawner
**Modify: `scripts/entities/ball_spawner.gd`**

```gdscript
@export var max_balls: int = 25

func fire() -> void:
    if not balls_container:
        return
    
    # Check ball limit
    if balls_container.get_child_count() >= max_balls:
        # Despawn oldest ball
        var oldest = balls_container.get_child(0)
        oldest.despawn()
    
    # Spawn new ball(s)
    for i in range(ball_count):
        _spawn_ball(aim_direction)
```

### Alternative: Object Pooling
For better performance, reuse ball instances:

```gdscript
var ball_pool: Array[CharacterBody2D] = []

func _ready():
    # Pre-create pool
    for i in range(max_balls):
        var ball = ball_scene.instantiate()
        ball.visible = false
        ball.set_process(false)
        balls_container.add_child(ball)
        ball_pool.append(ball)

func _get_pooled_ball() -> CharacterBody2D:
    for ball in ball_pool:
        if not ball.visible:
            return ball
    
    # Pool exhausted - despawn oldest active
    for ball in ball_pool:
        if ball.visible:
            ball.despawn()
            return ball
    
    return null

func fire():
    var ball = _get_pooled_ball()
    if ball:
        ball.position = global_position + aim_direction * 30
        ball.set_direction(aim_direction)
        ball.visible = true
        ball.set_process(true)
```

### Ball Despawn Cleanup
**Modify: `scripts/entities/ball.gd`**

```gdscript
func despawn() -> void:
    despawned.emit()
    
    # For pooling: reset state instead of queue_free
    if is_pooled:
        visible = false
        set_process(false)
        velocity = Vector2.ZERO
    else:
        queue_free()
```

### Files to Modify
1. MODIFY: `scripts/entities/ball_spawner.gd` - add ball limit
2. MODIFY: `scripts/entities/ball.gd` - support pooling (optional)
