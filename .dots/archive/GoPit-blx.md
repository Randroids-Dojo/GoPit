---
title: Add gem magnetism toward player zone
status: done
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:12:31.173714-06:00
---

## Problem
Gems fall straight down at fixed speed. No attraction. Players passively wait for collection.

## Implementation Plan

### Add Magnetism to Gem Entity
**Modify: `scripts/entities/gem.gd`**

```gdscript
@export var magnetism_range: float = 300.0
@export var magnetism_strength: float = 2.0
@export var max_speed: float = 500.0

const PLAYER_ZONE_Y: float = 1200.0

func _physics_process(delta: float) -> void:
    var distance_to_zone = PLAYER_ZONE_Y - global_position.y
    
    if distance_to_zone < magnetism_range and distance_to_zone > 0:
        # Calculate pull strength (stronger when closer)
        var pull_factor = 1.0 - (distance_to_zone / magnetism_range)
        pull_factor = pow(pull_factor, 0.5)  # Ease curve
        
        # Accelerate toward zone
        var target_speed = lerp(fall_speed, max_speed, pull_factor)
        fall_speed = move_toward(fall_speed, target_speed, magnetism_strength * 100 * delta)
        
        # Also pull horizontally toward center
        var center_x = 360.0  # Screen center
        var horizontal_pull = (center_x - global_position.x) * pull_factor * 0.5
        global_position.x += horizontal_pull * delta
    
    # Continue normal fall
    global_position.y += fall_speed * delta
```

### Visual Feedback
When magnetism kicks in:
- Add subtle sparkle trail
- Increase gem brightness slightly

```gdscript
func _draw():
    # Base gem draw...
    
    if fall_speed > base_fall_speed * 1.5:
        # Draw speed lines or trail
        draw_line(Vector2.ZERO, Vector2(0, -10), Color.WHITE.with_alpha(0.3), 2)
```

### Optional: Upgrade Integration
If magnetism is an upgrade (from GoPit-28w), make range configurable:

```gdscript
static var global_magnetism_bonus: float = 0.0

var effective_range: float:
    get:
        return magnetism_range + global_magnetism_bonus * 100  # +100px per upgrade level
```

### Files to Modify
1. MODIFY: `scripts/entities/gem.gd` - add magnetism physics
