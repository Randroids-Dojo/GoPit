---
title: Add Visual Feedback for Locked/Unlocked Slots
status: open
priority: 4
issue-type: implement
created-at: 2026-01-22T05:30:00Z
---

## Overview

Add polish and visual clarity to locked/unlocked slot states in BallSlotsDisplay and PassiveSlotsDisplay.

## Context

After implementing slot progression, players need clear visual feedback about which slots are available vs locked. This improves UX and reduces confusion.

See: `docs/research/slot-system-comparison.md`

## Requirements

### 1. Locked Slot Visual State

**Both BallSlotsDisplay and PassiveSlotsDisplay:**

Visual indicators for locked slots:
- **Grayed out panel** with reduced opacity (50%)
- **Lock icon** overlaid on slot
- **"Locked"** text or level requirement ("Unlock at L5")
- **Border styling** different from unlocked empty slots

Example:
```
[Ball] [Ball] [+Empty] [🔒 L5] [🔒 L15]
 L1     L2     (ready)  (locked)(locked)
```

### 2. Unlock Animation

When slot unlocks:
- **Glow effect** on newly unlocked slot panel
- **Scale animation** (grow slightly, then return)
- **Color flash** (gold/yellow highlight)
- **SFX** (satisfying "ding" or unlock sound)
- **Duration:** 1-2 seconds, non-intrusive

### 3. Hover Tooltips

Add tooltips to slots:
- **Equipped slots:** Show ball/passive name, level, description
- **Empty unlocked slots:** "Empty slot - Select new ball/passive on level-up"
- **Locked slots:** "🔒 Unlocks at Level 5" (or appropriate level)

Implementation:
- Use Godot's `Control.tooltip_text` property
- Or custom tooltip system if more control needed

### 4. Visual Hierarchy

Ensure clear distinction:
1. **Equipped (filled):** Full color, border, level indicator
2. **Empty unlocked:** "+" icon, slight transparency, subtle border
3. **Locked:** Grayed out, lock icon, no interaction

### 5. Accessibility

Consider accessibility:
- **Color-blind friendly:** Don't rely solely on color for locked state
- **Icon + text:** Use both lock icon and text label
- **High contrast:** Ensure locked state is clearly visible

## Implementation Files

### BallSlotsDisplay
**File:** `scripts/ui/ball_slots_display.gd`

Add methods:
```gdscript
func _update_slot_locked_state(slot_index: int, is_locked: bool):
    var slot_panel = slot_panels[slot_index]
    if is_locked:
        slot_panel.modulate.a = 0.5
        _show_lock_icon(slot_panel)
    else:
        slot_panel.modulate.a = 1.0
        _hide_lock_icon(slot_panel)

func _play_unlock_animation(slot_index: int):
    var slot_panel = slot_panels[slot_index]
    var tween = create_tween()
    tween.tween_property(slot_panel, "scale", Vector2(1.2, 1.2), 0.2)
    tween.tween_property(slot_panel, "scale", Vector2(1.0, 1.0), 0.2)
    # + glow effect, color flash, etc.
```

### PassiveSlotsDisplay
**File:** `scripts/ui/passive_slots_display.gd`

Apply same pattern as BallSlotsDisplay.

### Tests

**Files:** `tests/test_ball_slots_ui.py`, `tests/test_passive_slots_ui.py`

Add test coverage:
- Locked slots have reduced opacity
- Lock icon appears on locked slots
- Unlock animation plays when slot unlocks
- Tooltips show correct text for each state

## Visual Design Mockup

```
Ball Slots Display (Top-Right HUD):
┌──────────────────────────────────────────────┐
│ [FireBall] [IceBall] [  +   ] [🔒 L5] [🔒 L15] │
│    L2        L1      Empty     Lock    Lock  │
└──────────────────────────────────────────────┘

Passive Slots Display (Bottom-Center HUD):
┌───────────────────────────────────────────────┐
│ [DA] [CR] [  +  ] [🔒 L5] [🔒 L15]            │
│  L2   L1   Empty   Lock    Lock               │
└───────────────────────────────────────────────┘
```

## Acceptance Criteria

- [ ] Locked slots visually distinct (opacity, lock icon, text)
- [ ] Unlock animation plays when slot unlocks
- [ ] Tooltips implemented for all slot states
- [ ] SFX plays on unlock
- [ ] Visual hierarchy clear (equipped > empty > locked)
- [ ] Accessible (icon + text, high contrast)
- [ ] Consistent between ball and passive displays
- [ ] Tests verify visual states
- [ ] No performance issues with animations

## Polish Ideas (Optional)

- **Particle effects** on unlock (sparkles, confetti)
- **Camera shake** (subtle) on unlock
- **Unlock banner** across screen ("New Slot Unlocked!")
- **Progressive reveal** animation for locked slots (fade in as approach level)

## Related Tasks

- Depends on: GoPit-implement-ball-slots-ui.md
- Depends on: GoPit-implement-ball-slot-progression.md
- Depends on: GoPit-implement-passive-slot-progression.md
- Depends on: GoPit-implement-slot-unlock-system.md
