---
title: Stage select UI polish and improvements
status: open
priority: 4
issue-type: implement
created-at: "2026-01-27"
---

## Overview

Polish the stage select UI to better match BallxPit's information density and visual feedback. Lower priority than core scrolling mechanics.

## Context

BallxPit's level select shows per-character completion, difficulty badges, and smooth transitions. GoPit's current UI is functional but lacks polish.

See: `docs/research/level-scrolling-comparison.md`

## Requirements

### 1. Per-Character Completion Display

Show which characters have beaten the current stage:

```
Stage: THE PIT
Completed by: [Rookie ✓] [Tank ✓] [Speed ✗]
```

**Implementation:**
- Query `MetaManager.get_characters_who_beat_stage(stage_index)`
- Display small character icons with checkmarks
- Gray out characters who haven't beaten it

### 2. Difficulty Completion Badges

Visual indicators on difficulty buttons:

| Status | Visual |
|--------|--------|
| Never attempted | Gray button |
| Attempted, not beaten | White button |
| Beaten by some character | Silver ring |
| Beaten by current character | Gold ring |

### 3. Smooth Stage Transitions

Animate between stages when pressing `<` / `>`:

```gdscript
func _on_next_pressed() -> void:
    var tween := create_tween()
    # Slide out current stage info
    tween.tween_property(stage_panel, "modulate:a", 0.0, 0.1)
    tween.tween_callback(_update_stage_index.bind(1))
    # Slide in new stage info
    tween.tween_property(stage_panel, "modulate:a", 1.0, 0.1)
```

### 4. Highest Difficulty Display

Prominently show highest beaten difficulty per stage:

```
THE PIT - Best: Fast+3 ⭐⭐⭐
```

### 5. Swipe Gesture Support (Mobile)

Add touch drag/swipe to navigate stages:

```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventScreenDrag:
        if abs(event.relative.x) > 50:  # Swipe threshold
            if event.relative.x > 0:
                _on_prev_pressed()
            else:
                _on_next_pressed()
```

## Implementation Steps

1. Add character completion icons to stage panel
2. Add completion badges to difficulty buttons
3. Add fade transition between stages
4. Add "Best: X" label to stage info
5. Add swipe gesture handling

## Files to Modify

- `scripts/ui/level_select.gd` - all changes
- `scenes/ui/level_select.tscn` - add new UI elements
- `scripts/autoload/meta_manager.gd` - add helper queries

## Testing

- Visual verification of completion indicators
- Verify swipe works on mobile
- Verify transitions don't break navigation

## Acceptance Criteria

- [ ] Character completion icons visible per stage
- [ ] Difficulty buttons show completion status
- [ ] Stage transitions have smooth animation
- [ ] Highest difficulty shown prominently
- [ ] Swipe gestures work for stage navigation
