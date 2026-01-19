---
title: Show persistent aim indicator after joystick release
status: done
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:12:30.92006-06:00
---

## Problem
Aim line disappears when joystick is released. Players lose visual feedback of current aim direction.

## Implementation Plan

### Modify Aim Line Behavior
**Modify: `scripts/input/aim_line.gd`**

```gdscript
var is_active: bool = false
var last_direction: Vector2 = Vector2.UP
var fade_alpha: float = 0.3  # Alpha when not actively aiming

func show_line(direction: Vector2, origin: Vector2) -> void:
    is_active = true
    last_direction = direction
    modulate.a = 1.0
    _update_line(direction, origin)

func hide_line() -> void:
    is_active = false
    # Don't hide - just fade to ghost state
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", fade_alpha, 0.2)

func _update_line(direction: Vector2, origin: Vector2) -> void:
    clear_points()
    add_point(origin)
    add_point(origin + direction * max_length)
```

### Wire Up Origin Updates
**Modify: `scripts/game/game_controller.gd`**

```gdscript
func _process(delta):
    # Keep ghost aim line updated with ball spawner position
    if not joystick.is_active and aim_line.visible:
        aim_line._update_line(aim_line.last_direction, ball_spawner.global_position)
```

### Visual Styling
- Active: Bright white, full opacity
- Ghost: Dim gray, 30% opacity, slightly shorter

### Files to Modify
1. MODIFY: `scripts/input/aim_line.gd` - ghost state behavior
2. MODIFY: `scripts/game/game_controller.gd` - update ghost line position
