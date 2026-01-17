---
title: Reduce joystick dead zone for responsiveness
status: done
priority: 4
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:13:41.034539-06:00
---

## Problem
10% dead zone (8px on 80px radius) might feel laggy for small movements.

## Implementation Plan

### Reduce Dead Zone
**Modify: `scripts/input/virtual_joystick.gd`**

```gdscript
# Change from 0.1 to 0.05
@export var dead_zone: float = 0.05  # 5% dead zone = 4px
```

### Add Visual Dead Zone Feedback (Optional)
Show subtle indicator when in dead zone:

```gdscript
func _process(_delta):
    if is_active:
        var distance = knob_position.length() / max_distance
        
        if distance < dead_zone:
            # In dead zone - show subtle feedback
            knob.modulate = Color(0.7, 0.7, 0.7)
        else:
            knob.modulate = Color.WHITE
```

### Alternative: Adaptive Dead Zone
Smaller dead zone for precise aiming, larger when moving fast:

```gdscript
func _calculate_dead_zone() -> float:
    # If knob was moving fast recently, use larger dead zone
    # For precision aiming, use smaller dead zone
    var velocity = (knob_position - last_knob_position).length()
    last_knob_position = knob_position
    
    if velocity > 10:
        return 0.1  # Fast movement - larger dead zone
    else:
        return 0.05  # Slow/precise - smaller dead zone
```

### Files to Modify
1. MODIFY: `scripts/input/virtual_joystick.gd` - reduce dead zone
