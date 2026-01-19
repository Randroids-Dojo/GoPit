---
title: Add special ability (Ultimate)
status: closed
priority: 4
issue-type: feature
assignee: randroid
created-at: "2026-01-05T02:15:33.520331-06:00"
closed-at: "2026-01-19T10:16:04.348363-06:00"
---

## Implementation Note (2026-01-19)

**IMPORTANT:** This feature is already implemented in the `feature/salvo-firing` branch (worktree: `GoPit-salvo-firing/`).

### Files Implemented
- `scripts/autoload/game_manager.gd` - Ultimate charge system (signals, add/use/reset)
- `scripts/ui/ultimate_button.gd` - UI with charge ring visualization, pulse animation
- `scripts/effects/ultimate_blast.gd` - Screen-clearing blast effect
- `scenes/effects/ultimate_blast.tscn`
- `scenes/ui/ultimate_button.tscn`
- `scripts/game/game_controller.gd` - Wired charge gain on enemy kill and gem collection

### What's Complete
- [x] Ultimate charge accumulates via `add_ultimate_charge()` (line 446 in game_manager.gd)
- [x] Charge increases on enemy kill (`CHARGE_PER_KILL = 10.0`) at game_controller.gd:324
- [x] Charge increases on gem collection (`CHARGE_PER_GEM = 5.0`) at game_controller.gd:357
- [x] UI shows charge progress with ring visualization
- [x] Button pulses when ultimate is ready
- [x] Activation deals 9999 damage to all enemies
- [x] Screen flash, camera shake, sound effect
- [x] Charge resets on use and game reset

### Remaining Work
- [ ] Empty Nester 2x specials passive for ultimate (see child task GoPit-implement-wire-empty-cbe1c611)

The function `GameManager.get_special_fire_multiplier()` (line 617) returns 2 for Empty Nester but is never called in `_on_ultimate_activated()`. The child implementation task specifies the fix.

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

### Character Interactions

**Empty Nester Passive: "2x specials"**
Per the GDD (Section 2.3), Empty Nester has "No babies, 2x specials". This means:
- When Empty Nester uses ultimate, execute it TWICE (or deal 2x damage)
- Implementation: Check character passive in `use_ultimate()` and modify effect

```gdscript
func use_ultimate() -> bool:
    if ultimate_charge >= ULTIMATE_CHARGE_MAX:
        ultimate_charge = 0
        ultimate_used.emit()
        ultimate_charge_changed.emit(0, ULTIMATE_CHARGE_MAX)

        # Empty Nester fires ultimate twice
        var multiplier = 1
        var character = GameManager.selected_character
        if character and character.passive == "NO_BABIES_2X_SPECIALS":
            multiplier = 2

        return true, multiplier  # Caller handles multiplier
    return false, 0
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
9. MODIFY: Character handling to support Empty Nester's 2x special multiplier

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
- [ ] Empty Nester's 2x specials passive triggers double ultimate effect
