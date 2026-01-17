---
title: Autofire Toggle System
status: done
priority: 0
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:21:40.471805-06:00
---

# Autofire Toggle System

## Parent Epic
GoPit-3ky (Phase 1 - Core Alignment)

## Overview
Add ability to toggle automatic ball firing on/off, allowing hands-free shooting while player focuses on movement and dodging.

## Current State
- fire_button.gd handles manual tap-to-fire
- Has cooldown_duration property (default 0.5s)
- Fires on button press via "fired" signal
- No autofire capability exists

## Requirements
1. Add "AUTO" toggle button near fire button
2. When enabled, balls fire automatically at cooldown rate
3. Visual indicator showing autofire state (on/off)
4. Autofire direction: last aimed direction OR nearest enemy
5. Autofire respects existing cooldown system
6. Toggle persists during gameplay (not across sessions)

## Implementation Approach

### Step 1: Modify fire_button.gd
```gdscript
# Add to existing fire_button.gd

var autofire_enabled: bool = false
var _autofire_timer: float = 0.0

signal autofire_toggled(enabled: bool)

func toggle_autofire() -> void:
    autofire_enabled = not autofire_enabled
    autofire_toggled.emit(autofire_enabled)
    _update_autofire_visual()

func _process(delta: float) -> void:
    if autofire_enabled and _can_fire:
        _autofire_timer += delta
        if _autofire_timer >= cooldown_duration:
            _autofire_timer = 0.0
            _do_fire()

func _update_autofire_visual() -> void:
    # Change button color/icon when autofire active
    modulate = Color(0.5, 1.0, 0.5) if autofire_enabled else Color.WHITE
```

### Step 2: Add Autofire Toggle Button
In HUD scene, add button near fire button:
- Small toggle button labeled "AUTO"
- Or: Long-press fire button to toggle
- Or: Separate button in control area

UI Layout:
```
┌─────────────────────────────────────┐
│  (◎)              [AUTO] [🔥]       │
│  Move              Toggle  Fire     │
└─────────────────────────────────────┘
```

### Step 3: Auto-aim Logic (Optional Enhancement)
When autofire is on, optionally aim at nearest enemy:
```gdscript
func _get_autofire_direction() -> Vector2:
    if aim_at_nearest_enemy:
        var nearest = _find_nearest_enemy()
        if nearest:
            return (nearest.global_position - player.global_position).normalized()
    # Fallback to last aimed direction
    return current_aim_direction
```

### Step 4: Wire to game_controller.gd
```gdscript
func _ready() -> void:
    # ... existing code ...
    if fire_button:
        fire_button.autofire_toggled.connect(_on_autofire_toggled)

func _on_autofire_toggled(enabled: bool) -> void:
    # Optional: play sound, show indicator
    if enabled:
        SoundManager.play(SoundManager.SoundType.UI_TOGGLE)
```

## Files to Modify
- MODIFY: scripts/input/fire_button.gd
- MODIFY: scenes/ui/hud.tscn (add AUTO button)
- MODIFY: scripts/ui/hud.gd (wire toggle)
- OPTIONAL: scripts/game/game_controller.gd

## Testing
```python
async def test_autofire_toggle(game):
    fire_btn = "/root/Game/UI/HUD/.../FireButton"
    
    # Initially off
    autofire = await game.get_property(fire_btn, "autofire_enabled")
    assert autofire == False
    
    # Toggle on
    await game.call(fire_btn, "toggle_autofire")
    autofire = await game.get_property(fire_btn, "autofire_enabled")
    assert autofire == True
    
    # Verify balls fire automatically
    initial_balls = await game.call("/root/Game/GameArea/Balls", "get_child_count")
    await asyncio.sleep(1.5)  # Wait for ~3 shots at 0.5s cooldown
    final_balls = await game.call("/root/Game/GameArea/Balls", "get_child_count")
    assert final_balls > initial_balls

async def test_autofire_respects_cooldown(game):
    # Enable autofire, count balls over time
    # Should fire at cooldown_duration rate, not faster
    pass
```

## Acceptance Criteria
- [ ] AUTO toggle button visible in HUD
- [ ] Tapping AUTO toggles autofire state
- [ ] Visual feedback shows autofire is active
- [ ] Balls fire automatically when enabled
- [ ] Fire rate matches cooldown_duration
- [ ] Can still manual fire when autofire is off
- [ ] Autofire stops when game is paused

## Design Considerations
- BallxPit has autofire as standard feature
- Most players will use autofire most of the time
- Manual fire still useful for precise timing
- Consider: autofire could be upgrade that increases fire rate
