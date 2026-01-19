---
title: Add floating XP text on gem collection
status: done
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:13:40.513145-06:00
---

## Problem
When collecting gems, XP bar fills silently. No indication of amount gained.

## Implementation Plan

### Create Floating Text Component
**File: `scripts/effects/floating_text.gd`** (new)

```gdscript
extends Label

@export var float_distance: float = 60.0
@export var duration: float = 0.8

func _ready():
    # Center the label
    horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    
    # Animation
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Float up
    tween.tween_property(self, "position:y", position.y - float_distance, duration)
    
    # Fade out (delayed start)
    modulate.a = 1.0
    tween.tween_property(self, "modulate:a", 0.0, duration * 0.5).set_delay(duration * 0.5)
    
    # Scale pop
    scale = Vector2(0.5, 0.5)
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT)
    
    tween.chain().tween_callback(queue_free)

static func spawn(parent: Node, pos: Vector2, text: String, color: Color = Color.WHITE):
    var label = preload("res://scenes/effects/floating_text.tscn").instantiate()
    label.text = text
    label.position = pos
    label.modulate = color
    parent.add_child(label)
```

### Scene Setup
**File: `scenes/effects/floating_text.tscn`**

```
FloatingText (Label)
- font_size: 24
- outline_size: 2
- outline_color: black
- z_index: 100
```

### Wire Up XP Display
**Modify: `scripts/game/game_controller.gd`**

```gdscript
func _on_player_zone_area_entered(area: Area2D) -> void:
    if area.collision_layer & 8:  # Gem layer
        if area.has_method("get_xp_value"):
            var xp = area.get_xp_value()
            GameManager.add_xp(xp)
            
            # Spawn floating text
            FloatingText.spawn(
                self,
                area.global_position,
                "+%d XP" % xp,
                Color(0.3, 1.0, 0.5)  # Green tint
            )
        
        SoundManager.play(SoundManager.SoundType.GEM_COLLECT)
        area.queue_free()
```

### Optional: XP Bar Pulse
**Modify: `scripts/ui/hud.gd`**

```gdscript
func _on_xp_gained():
    var tween = create_tween()
    tween.tween_property(xp_bar, "modulate", Color(1.5, 1.5, 1.5), 0.1)
    tween.tween_property(xp_bar, "modulate", Color.WHITE, 0.2)
```

### Files to Create/Modify
1. NEW: `scenes/effects/floating_text.tscn`
2. NEW: `scripts/effects/floating_text.gd`
3. MODIFY: `scripts/game/game_controller.gd` - spawn floating text
4. MODIFY: `scripts/ui/hud.gd` - XP bar pulse (optional)
