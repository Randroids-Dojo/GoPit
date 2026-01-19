---
title: "implement: Add UI animations for level-up and cards"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-19T09:58:48.660669-06:00\\\"\""
closed-at: "2026-01-19T10:25:38.960400-06:00"
close-reason: "Added level-up animations: panel bounce, staggered cards, hover effects, selection highlight"
---

# Add UI Animations for Level-up and Cards

## Implementation Status (2026-01-19)

**FULLY IMPLEMENTED** but uncommitted. Changes in working tree:
- `scripts/ui/level_up_overlay.gd` has all animations added

**What's implemented:**
- [x] Entry animation (`_animate_show()`) - panel fade/scale with bounce
- [x] Staggered card entrance - cards animate in one by one
- [x] Card hover effect (`_on_card_hover()`) - scale to 1.05x on hover
- [x] Card selection animation (`_animate_selection()`) - highlights selected, fades others

**Remaining:**
- [ ] Run tests and commit changes
- [ ] Close this task

## Description

Add polish animations to the level-up overlay including:
1. Entry animation for the overlay panel
2. Staggered card entrance (cards animate in one by one)
3. Card hover/selection feedback
4. Card selection animation before dismissing

## Context

The level-up overlay (`level_up_overlay.gd`) currently appears instantly without animations. Wave announcements already demonstrate good animation patterns (fade/scale with tween). The level-up experience should feel rewarding and "juicy."

## Affected Files

- **MODIFY**: `scripts/ui/level_up_overlay.gd` - Add animations

## Implementation Notes

### Entry Animation + Staggered Cards

Add to `level_up_overlay.gd`:

```gdscript
func _on_level_up() -> void:
    _randomize_cards()
    _update_cards()
    visible = true
    _animate_show()  # NEW
    _show_first_time_hint()


func _animate_show() -> void:
    # Get panel for animation
    var panel := $Panel

    # Initial state
    panel.modulate.a = 0
    panel.scale = Vector2(0.9, 0.9)
    panel.pivot_offset = panel.size / 2

    # Hide all cards initially
    for i in range(cards_container.get_child_count()):
        var card: Button = cards_container.get_child(i)
        card.modulate.a = 0
        card.scale = Vector2(0.8, 0.8)
        card.pivot_offset = card.size / 2

    var tween := create_tween()

    # Fade in panel
    tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    tween.tween_property(panel, "modulate:a", 1.0, 0.2)
    tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3)

    # Staggered card entrance
    for i in range(cards_container.get_child_count()):
        var card: Button = cards_container.get_child(i)
        tween.tween_property(card, "modulate:a", 1.0, 0.15)
        tween.parallel().tween_property(card, "scale", Vector2(1.0, 1.0), 0.2)

    # Pause after cards are shown
    tween.tween_callback(func(): get_tree().paused = true)

    # Play sound for "LEVEL UP!" announcement
    SoundManager.play(SoundManager.SoundType.LEVEL_UP)
```

### Card Hover Effect

Add hover feedback to cards in `_setup_cards()`.

**IMPORTANT:** On mobile/touch devices, `mouse_entered`/`mouse_exited` fire only on touch-down/up, not on hover. The hover effect is primarily for desktop play but should degrade gracefully on mobile (touch-down briefly scales card before selection animation plays).

```gdscript
func _setup_cards() -> void:
    for i in range(cards_container.get_child_count()):
        var card: Button = cards_container.get_child(i)
        card.pressed.connect(_on_card_pressed.bind(i))
        card.mouse_entered.connect(_on_card_hover.bind(card, true))
        card.mouse_exited.connect(_on_card_hover.bind(card, false))


func _on_card_hover(card: Button, is_hovered: bool) -> void:
    var target_scale := Vector2(1.05, 1.05) if is_hovered else Vector2(1.0, 1.0)
    var tween := create_tween()
    tween.tween_property(card, "scale", target_scale, 0.1)
```

### Card Selection Animation

Add selection feedback before dismissing.

**IMPORTANT:** The current `_on_card_pressed()` immediately applies the upgrade, hides overlay, and resumes game (lines 210-273). The animation must be inserted BEFORE `visible = false` and `get_tree().paused = false`. Move existing logic to `_apply_selection()` as shown below.

```gdscript
func _on_card_pressed(index: int) -> void:
    if _available_cards.is_empty() or index >= _available_cards.size():
        return

    var card: Button = cards_container.get_child(index)
    _animate_selection(card, index)


func _animate_selection(card: Button, index: int) -> void:
    # Flash selected card
    var tween := create_tween()

    # Scale up and highlight
    tween.tween_property(card, "scale", Vector2(1.15, 1.15), 0.1)
    tween.tween_property(card, "modulate", Color(1.3, 1.3, 1.0, 1.0), 0.1)

    # Fade out other cards
    for i in range(cards_container.get_child_count()):
        if i != index:
            var other_card: Button = cards_container.get_child(i)
            tween.parallel().tween_property(other_card, "modulate:a", 0.3, 0.2)

    # Brief pause then apply selection
    tween.tween_interval(0.2)
    tween.tween_callback(func(): _apply_selection(index))


func _apply_selection(index: int) -> void:
    # Existing selection logic moved here
    var selected := _available_cards[index]
    # ... rest of existing card selection code ...
    visible = false
    get_tree().paused = false
```

### XP Bar Fill Animation (Optional Enhancement)

If the HUD has an XP bar, add smooth fill animation:

```gdscript
# In hud.gd or wherever XP bar is managed
func _on_xp_changed(current: int, required: int) -> void:
    var target_progress := float(current) / float(required)
    var tween := create_tween()
    tween.tween_property(xp_bar, "value", target_progress * 100, 0.3)
```

## Verify

- [ ] `./test.sh` passes
- [ ] Level up triggers - panel fades in with slight scale bounce
- [ ] Cards animate in one by one (staggered, ~0.15s apart)
- [ ] Hovering a card scales it up slightly (1.05x)
- [ ] Clicking a card highlights it and fades other cards
- [ ] Selection animation plays before overlay dismisses
- [ ] Total entry animation feels snappy (~0.6s for panel + cards)
- [ ] Animations don't interfere with card functionality
- [ ] Touch input works correctly with hover states (mobile)
