---
title: Add fire button blocked feedback
status: done
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:13:40.260334-06:00
---

## Problem
Tapping fire button during cooldown is silently ignored. No feedback that press was registered.

## Implementation Plan

### Add Blocked State Feedback
**Modify: `scripts/input/fire_button.gd`**

```gdscript
signal blocked  # New signal for blocked attempts

var shake_tween: Tween

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch or event is InputEventMouseButton:
        if event.pressed:
            if can_fire:
                _fire()
            else:
                _on_blocked()

func _on_blocked():
    blocked.emit()
    _shake_button()
    _flash_red()
    SoundManager.play_blocked()  # Optional subtle click

func _shake_button():
    if shake_tween:
        shake_tween.kill()
    
    var original_pos = position
    shake_tween = create_tween()
    shake_tween.tween_property(self, "position:x", original_pos.x + 5, 0.05)
    shake_tween.tween_property(self, "position:x", original_pos.x - 5, 0.05)
    shake_tween.tween_property(self, "position:x", original_pos.x + 3, 0.05)
    shake_tween.tween_property(self, "position:x", original_pos.x, 0.05)

func _flash_red():
    var original_color = modulate
    modulate = Color(1.5, 0.5, 0.5)
    await get_tree().create_timer(0.1).timeout
    modulate = original_color
```

### Optional: Haptic Feedback (Mobile)
```gdscript
func _on_blocked():
    # Haptic feedback on supported devices
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(50)  # 50ms vibration
```

### Sound Effect (Optional)
**Modify: `scripts/autoload/sound_manager.gd`**

```gdscript
enum SoundType { ..., BLOCKED }

func _generate_blocked() -> AudioStreamWAV:
    # Short, low, muted click
    # Duration: 0.05s
    # Frequency: 100Hz
    # Very quiet
```

### Files to Modify
1. MODIFY: `scripts/input/fire_button.gd` - add blocked feedback
2. MODIFY: `scripts/autoload/sound_manager.gd` - add blocked sound (optional)
