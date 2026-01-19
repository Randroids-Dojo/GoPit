---
title: "implement: Add victory and defeat animations"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-19T09:58:05.432613-06:00\""
closed-at: "2026-01-19T10:14:03.938371-06:00"
close-reason: Added bounce animations to game over and stage complete overlays
---

# Add Victory and Defeat Animations

## Description

Add satisfying entry animations to the game over overlay (defeat) and stage complete/victory overlay. Currently both overlays appear instantly without any visual feedback.

## Implementation Status (2026-01-19)

**IMPLEMENTED:** Both overlay animations are now in the codebase (uncommitted):
- `game_over_overlay.gd` - Has `_animate_show()` with scale bounce (0.3s delay)
- `stage_complete_overlay.gd` - Has `_animate_show()` with dim fade + panel bounce + victory screen shake

**Minor issue:** `game_over_overlay.gd` calls `_show_shop_hint()` immediately after `_animate_show()` rather than waiting for the animation to complete. This is a minor timing issue - the shop hint will appear before the panel finishes animating.

**Remaining:** Test the implementation, commit the changes, and optionally add confetti for victory.

## Context

The game has two overlays that show end-game screens:
- `game_over_overlay.gd` - Shown when player dies
- `stage_complete_overlay.gd` - Shown when defeating a boss (stage complete) or winning the game (victory)

## Affected Files

- **MODIFY**: `scripts/ui/game_over_overlay.gd` - Add defeat animation
- **MODIFY**: `scripts/ui/stage_complete_overlay.gd` - Add victory/stage complete animation

## Implementation Notes

### Architecture Note

**IMPORTANT:** The two overlays have different base types:
- `game_over_overlay.gd` extends `Control`
- `stage_complete_overlay.gd` extends `CanvasLayer`

This affects how animations are applied (CanvasLayer children animate differently).

### Existing Behavior to Preserve

**IMPORTANT:** `game_over_overlay.gd` does NOT pause the game itself - it only sets `visible = true`. The game is presumably already paused by the death sequence or handled elsewhere. The entry animation must NOT add `get_tree().paused = true` to avoid double-pausing issues.

`game_over_overlay.gd` already has a shop hint pulsing animation (`_pulse_tween`). The entry animation must not interfere with this. The shop hint should start pulsing AFTER the entry animation completes.

### Game Over (Defeat) Animation

Add to `game_over_overlay.gd`:

```gdscript
func _on_game_over() -> void:
    # Existing stat recording code...
    _update_stats()
    _animate_show()  # NEW: Replace direct visible = true, calls _show_shop_hint() after animation


func _animate_show() -> void:
    visible = true

    # Get the panel for animation
    var panel := $Panel

    # Start state: scaled small, transparent
    panel.modulate.a = 0
    panel.scale = Vector2(0.8, 0.8)
    panel.pivot_offset = panel.size / 2

    # Brief delay for dramatic effect after player death
    await get_tree().create_timer(0.5).timeout

    # Animate in
    var tween := create_tween()
    tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    tween.tween_property(panel, "modulate:a", 1.0, 0.3)
    tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.4)

    # After animation completes, show shop hint
    tween.tween_callback(_show_shop_hint)
```

### Stage Complete / Victory Animation

Add to `stage_complete_overlay.gd`:

```gdscript
func _show() -> void:
    visible = true
    _animate_show()


func _animate_show() -> void:
    var panel := $DimBackground/Panel
    var dim := $DimBackground

    # Start state
    dim.modulate.a = 0
    panel.modulate.a = 0
    panel.scale = Vector2(0.5, 0.5)
    panel.pivot_offset = panel.size / 2

    var tween := create_tween()

    # Fade in dim background
    tween.tween_property(dim, "modulate:a", 1.0, 0.3)

    # Pop in panel with bounce
    tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    tween.tween_property(panel, "modulate:a", 1.0, 0.3)
    tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.5)

    # Screen shake for victory emphasis
    if _is_victory:
        tween.tween_callback(func(): CameraShake.shake(10.0, 5.0))

    # Pause after animation
    tween.tween_callback(func(): get_tree().paused = true)
```

### Victory Celebration (Optional Enhancement)

For victory specifically, consider adding confetti particles:

```gdscript
func show_victory() -> void:
    _is_victory = true
    # ... existing code ...
    _spawn_confetti()  # NEW

func _spawn_confetti() -> void:
    # Spawn particle emitter for celebration
    var confetti := preload("res://scenes/effects/confetti.tscn").instantiate()
    add_child(confetti)
```

Note: Confetti particle system would need to be created as a separate scene with GPUParticles2D.

## Verify

- [ ] `./test.sh` passes
- [ ] Die in game - brief pause (0.5s), then panel fades/scales in smoothly
- [ ] Game over panel has "bounce" feel on appearance
- [ ] Game pauses AFTER animation plays (allows death effects to show)
- [ ] Defeat a stage boss - panel fades in with bounce animation
- [ ] Victory (complete all stages) - panel animates in with screen shake
- [ ] Animations feel satisfying and not too long (~0.5-0.8s total)
- [ ] Clicking restart/continue still works after animations
