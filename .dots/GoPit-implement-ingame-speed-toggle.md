---
title: Implement in-game speed toggle
status: open
priority: 2
issue-type: implement
created-at: "2026-01-27"
---

## Overview

Add a real-time speed toggle (1/2/3) during gameplay, separate from difficulty tier. Players can slow down for tough sections or speed up for farming.

## Context

BallxPit has an in-game speed toggle accessible via:
- Keyboard: 1, 2, 3 keys
- Controller: R1 (PS5) / RB (Xbox) / R (PC)

This is SEPARATE from the difficulty tier system. It affects Engine.time_scale for all gameplay.

See: `docs/research/level-scrolling-comparison.md`

## Requirements

### 1. Speed Levels

| Key | Speed | time_scale | Use Case |
|-----|-------|------------|----------|
| 1 | Slow | 0.5x | Boss fights, learning patterns |
| 2 | Normal | 1.0x | Standard gameplay |
| 3 | Fast | 2.0x | Farming easy enemies |

### 2. GameManager Speed System

```gdscript
enum GameSpeed { SLOW, NORMAL, FAST }

var current_game_speed: GameSpeed = GameSpeed.NORMAL

const SPEED_SCALES := {
    GameSpeed.SLOW: 0.5,
    GameSpeed.NORMAL: 1.0,
    GameSpeed.FAST: 2.0,
}

func set_game_speed(speed: GameSpeed) -> void:
    current_game_speed = speed
    Engine.time_scale = SPEED_SCALES[speed]
    game_speed_changed.emit(speed)

func cycle_game_speed() -> void:
    var speeds := [GameSpeed.SLOW, GameSpeed.NORMAL, GameSpeed.FAST]
    var current_index := speeds.find(current_game_speed)
    var next_index := (current_index + 1) % speeds.size()
    set_game_speed(speeds[next_index])
```

### 3. Input Handling

In `game_controller.gd`:
```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_1:
                GameManager.set_game_speed(GameManager.GameSpeed.SLOW)
            KEY_2:
                GameManager.set_game_speed(GameManager.GameSpeed.NORMAL)
            KEY_3:
                GameManager.set_game_speed(GameManager.GameSpeed.FAST)
```

Or cycle button for mobile:
```gdscript
func _on_speed_button_pressed() -> void:
    GameManager.cycle_game_speed()
```

### 4. HUD Speed Indicator

Add visual indicator showing current speed:
- Show "0.5x" / "1x" / "2x" near pause button
- Color coding: Blue (slow), White (normal), Orange (fast)
- Icon: Turtle / Normal / Rabbit (optional)

### 5. Pause Menu Integration

Add speed control to pause menu alongside sound/music toggles.

## Implementation Steps

1. Add speed system to `GameManager`
2. Add keyboard input handling in `game_controller.gd`
3. Create speed indicator UI in HUD
4. Add speed button/toggle for mobile
5. Integrate with pause menu

## Files to Modify

- `scripts/autoload/game_manager.gd` - speed system
- `scripts/game/game_controller.gd` - input handling
- `scenes/ui/hud.tscn` - speed indicator
- `scripts/ui/pause_overlay.gd` - speed control

## Edge Cases

- Reset to 1.0x when game ends/pauses
- Persist preference? (probably not - per-session)
- Audio pitch adjustment at different speeds?

## Testing

```python
async def test_game_speed_toggle(game):
    # Start at normal
    speed = await game.call(GAME_MANAGER, "get_game_speed")
    assert speed == 1  # NORMAL

    # Toggle to fast
    await game.call(GAME_MANAGER, "set_game_speed", [2])  # FAST
    time_scale = await game.get_property("/root", "Engine.time_scale")
    assert time_scale == 2.0
```

## Acceptance Criteria

- [ ] Keys 1/2/3 set game speed during gameplay
- [ ] HUD shows current speed indicator
- [ ] Time scale actually changes gameplay speed
- [ ] Speed resets appropriately on game end
- [ ] Mobile has accessible speed control
