---
title: Add tutorial/onboarding overlay
status: done
priority: 1
issue-type: feature
assignee: randroid
created-at: 2026-01-05T02:02:56.981642-06:00
---

## Problem
New players have no guidance. Controls and objectives must be discovered through experimentation.

## Implementation Plan

### Approach: First-time overlay with step-by-step hints

**File: `scripts/ui/tutorial_overlay.gd`** (new)

```gdscript
extends CanvasLayer

enum TutorialStep { AIM, FIRE, HIT, COMPLETE }
var current_step: TutorialStep = TutorialStep.AIM
var has_completed_tutorial: bool = false

@onready var hint_label: Label = $HintLabel
@onready var highlight: Control = $Highlight

func _ready():
    has_completed_tutorial = _load_tutorial_state()
    if has_completed_tutorial:
        queue_free()
        return
    _show_step(TutorialStep.AIM)

func _show_step(step: TutorialStep):
    current_step = step
    match step:
        TutorialStep.AIM:
            hint_label.text = "Drag the joystick to AIM"
            _highlight_node("VirtualJoystick")
        TutorialStep.FIRE:
            hint_label.text = "Tap the button to FIRE!"
            _highlight_node("FireButton")
        TutorialStep.HIT:
            hint_label.text = "Hit enemies before they reach you!"
            _hide_highlight()
        TutorialStep.COMPLETE:
            _save_tutorial_complete()
            _fade_out()

func on_joystick_used():
    if current_step == TutorialStep.AIM:
        _show_step(TutorialStep.FIRE)

func on_ball_fired():
    if current_step == TutorialStep.FIRE:
        _show_step(TutorialStep.HIT)

func on_enemy_hit():
    if current_step == TutorialStep.HIT:
        _show_step(TutorialStep.COMPLETE)
```

### Visual Design
- Semi-transparent dark overlay (0.3 alpha)
- Cut-out highlight around target control
- Large white text with drop shadow
- Pulsing animation on highlighted element

### Files to Create/Modify
1. NEW: `scenes/ui/tutorial_overlay.tscn`
2. NEW: `scripts/ui/tutorial_overlay.gd`
3. MODIFY: `scripts/game/game_controller.gd` - emit tutorial events
4. MODIFY: `scripts/input/virtual_joystick.gd` - notify on first use
5. MODIFY: `scripts/entities/ball.gd` - notify on enemy hit

### Persistence
Save tutorial completion to `user://settings.save` so it only shows once.
