---
title: Add combo system with XP multiplier
status: done
priority: 3
issue-type: feature
assignee: randroid
created-at: 2026-01-05T02:15:32.464892-06:00
---

## Problem
No reward for rapid kills. Skill expression is limited.

## Implementation Plan

### Combo Tracking in GameManager
**Modify: `scripts/autoload/game_manager.gd`**

```gdscript
signal combo_changed(combo: int, multiplier: float)

const COMBO_TIMEOUT: float = 2.0
const COMBO_MULTIPLIERS := {
    0: 1.0,
    3: 1.25,
    5: 1.5,
    10: 2.0,
    20: 3.0
}

var current_combo: int = 0
var combo_timer: float = 0.0
var combo_multiplier: float = 1.0

func _process(delta):
    if current_state == GameState.PLAYING and combo_timer > 0:
        combo_timer -= delta
        if combo_timer <= 0:
            _reset_combo()

func add_combo():
    current_combo += 1
    combo_timer = COMBO_TIMEOUT
    
    # Calculate multiplier
    for threshold in COMBO_MULTIPLIERS:
        if current_combo >= threshold:
            combo_multiplier = COMBO_MULTIPLIERS[threshold]
    
    combo_changed.emit(current_combo, combo_multiplier)

func _reset_combo():
    if current_combo > stats.highest_combo:
        stats.highest_combo = current_combo
    current_combo = 0
    combo_multiplier = 1.0
    combo_changed.emit(0, 1.0)

func add_xp(amount: int) -> void:
    var modified_xp = int(amount * combo_multiplier)
    current_xp += modified_xp
    # ...
```

### Combo UI Display
**File: `scripts/ui/combo_display.gd`** (new)

```gdscript
extends Control

@onready var combo_label: Label = $ComboLabel
@onready var multiplier_label: Label = $MultiplierLabel

var display_tween: Tween

func _ready():
    visible = false
    GameManager.combo_changed.connect(_on_combo_changed)

func _on_combo_changed(combo: int, multiplier: float):
    if combo == 0:
        _hide_display()
        return
    
    visible = true
    combo_label.text = "%d" % combo
    multiplier_label.text = "x%.1f" % multiplier if multiplier > 1.0 else ""
    
    # Pop animation
    if display_tween:
        display_tween.kill()
    
    scale = Vector2(1.3, 1.3)
    display_tween = create_tween()
    display_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT)

func _hide_display():
    var tween = create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.3)
    tween.tween_callback(func(): visible = false; modulate.a = 1.0)
```

### Wire Up Combo Increments
**Modify: `scripts/game/game_controller.gd`**

```gdscript
func _on_enemy_died(enemy: EnemyBase) -> void:
    GameManager.add_combo()
    # existing code...
```

### Visual Design
- Large combo number in center-right of screen
- Multiplier text below (only shown when > 1x)
- Color changes: white (1-4), yellow (5-9), orange (10-19), red (20+)
- Shake effect when combo increases

### Files to Create/Modify
1. MODIFY: `scripts/autoload/game_manager.gd` - combo tracking
2. NEW: `scenes/ui/combo_display.tscn`
3. NEW: `scripts/ui/combo_display.gd`
4. MODIFY: `scenes/game.tscn` - add combo display
5. MODIFY: `scripts/game/game_controller.gd` - trigger combo
