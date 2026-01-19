---
title: Add special ability (Ultimate)
status: open
priority: 4
issue-type: feature
assignee: randroid
created-at: 2026-01-05T02:15:33.520331-06:00
---

## Problem
No power moment. Just steady fire. Players need satisfying payoff.

## Implementation Plan

### Ultimate Ability System
**Modify: `scripts/autoload/game_manager.gd`**

```gdscript
signal ultimate_ready
signal ultimate_used
signal ultimate_charge_changed(current: float, max: float)

const ULTIMATE_CHARGE_MAX: float = 100.0
const CHARGE_PER_KILL: float = 10.0
const CHARGE_PER_GEM: float = 5.0

var ultimate_charge: float = 0.0

func add_ultimate_charge(amount: float):
    var was_ready = ultimate_charge >= ULTIMATE_CHARGE_MAX
    ultimate_charge = min(ULTIMATE_CHARGE_MAX, ultimate_charge + amount)
    ultimate_charge_changed.emit(ultimate_charge, ULTIMATE_CHARGE_MAX)
    
    if not was_ready and ultimate_charge >= ULTIMATE_CHARGE_MAX:
        ultimate_ready.emit()

func use_ultimate() -> bool:
    if ultimate_charge >= ULTIMATE_CHARGE_MAX:
        ultimate_charge = 0
        ultimate_used.emit()
        ultimate_charge_changed.emit(0, ULTIMATE_CHARGE_MAX)
        return true
    return false
```

### Ultimate Types
**File: `scripts/effects/ultimate_blast.gd`** (new)

```gdscript
extends Node2D
## Screen-clearing blast ultimate

func execute():
    # Visual effect
    var flash = ColorRect.new()
    flash.color = Color(1, 1, 1, 0.8)
    flash.size = get_viewport().size
    get_tree().current_scene.add_child(flash)
    
    # Fade out flash
    var tween = create_tween()
    tween.tween_property(flash, "color:a", 0.0, 0.5)
    tween.tween_callback(flash.queue_free)
    
    # Kill all enemies on screen
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if enemy is EnemyBase:
            enemy.take_damage(9999)
    
    # Screen shake
    CameraShake.shake(20.0, 2.0)
    
    # Sound effect
    SoundManager.play(SoundManager.SoundType.ULTIMATE)
    
    queue_free()
```

### Ultimate Button UI
**Modify: `scenes/game.tscn`**

Add ultimate button next to fire button (or as overlay on fire button when ready).

**File: `scripts/ui/ultimate_button.gd`** (new)

```gdscript
extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var ready_indicator: Control = $ReadyIndicator

var pulse_tween: Tween

func _ready():
    ready_indicator.visible = false
    GameManager.ultimate_charge_changed.connect(_on_charge_changed)
    GameManager.ultimate_ready.connect(_on_ultimate_ready)

func _on_charge_changed(current: float, max_charge: float):
    progress_bar.value = current / max_charge * 100
    
    if current < max_charge:
        ready_indicator.visible = false
        if pulse_tween:
            pulse_tween.kill()

func _on_ultimate_ready():
    ready_indicator.visible = true
    
    # Pulsing glow effect
    pulse_tween = create_tween().set_loops()
    pulse_tween.tween_property(ready_indicator, "modulate", Color(1.5, 1.5, 0.5), 0.5)
    pulse_tween.tween_property(ready_indicator, "modulate", Color(1.0, 1.0, 1.0), 0.5)

func _gui_input(event):
    if event is InputEventScreenTouch and event.pressed:
        if GameManager.use_ultimate():
            _execute_ultimate()

func _execute_ultimate():
    var blast = preload("res://scenes/effects/ultimate_blast.tscn").instantiate()
    get_tree().current_scene.add_child(blast)
    blast.execute()
```

### Wire Up Charge Gain
**Modify: `scripts/game/game_controller.gd`**

```gdscript
func _on_enemy_died(enemy: EnemyBase):
    GameManager.add_ultimate_charge(GameManager.CHARGE_PER_KILL)
    # existing code...

func _on_gem_collected(gem):
    GameManager.add_ultimate_charge(GameManager.CHARGE_PER_GEM)
    # existing code...
```

### Files to Create/Modify
1. MODIFY: `scripts/autoload/game_manager.gd` - ultimate charge system
2. NEW: `scenes/effects/ultimate_blast.tscn`
3. NEW: `scripts/effects/ultimate_blast.gd`
4. NEW: `scenes/ui/ultimate_button.tscn`
5. NEW: `scripts/ui/ultimate_button.gd`
6. MODIFY: `scenes/game.tscn` - add ultimate button
7. MODIFY: `scripts/game/game_controller.gd` - wire charge gain
8. MODIFY: `scripts/autoload/sound_manager.gd` - add ULTIMATE sound

## Verify

- [ ] `./test.sh` passes
- [ ] Ultimate charge increases when killing enemies
- [ ] Ultimate charge increases when collecting gems
- [ ] UI shows charge progress (0-100%)
- [ ] UI pulses/glows when ultimate is ready
- [ ] Tapping ultimate button activates the effect
- [ ] All enemies on screen are damaged/killed
- [ ] Visual blast effect plays with screen flash
- [ ] Screen shake occurs on activation
- [ ] Sound effect plays
- [ ] Ultimate charge resets to 0 after use
- [ ] Cannot activate ultimate when charge < 100%
