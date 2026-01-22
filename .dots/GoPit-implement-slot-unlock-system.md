---
title: Add Slot Unlock System (XP Milestones)
status: open
priority: 3
issue-type: implement
created-at: 2026-01-22T05:30:00Z
---

## Overview

Implement automatic slot unlocking at XP level milestones to provide meta-progression.

## Context

After implementing ball slot progression (3→5) and passive slot progression (3→5), we need a system to actually unlock these slots during gameplay.

BallxPit uses buildings/blueprints. For GoPit MVP, we'll use XP level milestones as a simpler initial approach.

See: `docs/research/slot-system-comparison.md`

## Requirements

### 1. Define Unlock Milestones

Proposed thresholds:
- **Level 5:** Unlock 4th ball slot + 4th passive slot
- **Level 15:** Unlock 5th ball slot + 5th passive slot

Alternative (faster progression):
- **Level 3:** Unlock 4th ball slot + 4th passive slot
- **Level 10:** Unlock 5th ball slot + 5th passive slot

**Decision needed:** Choose threshold set based on playtesting feedback.

### 2. Implement Unlock Logic
**File:** `scripts/autoload/game_manager.gd`

Add to level-up handler:
```gdscript
func _on_level_up(new_level: int) -> void:
    # ... existing level-up logic ...

    # Check for slot unlocks
    if new_level == 5:  # Or 3 for faster progression
        _unlock_fourth_slots()
    elif new_level == 15:  # Or 10 for faster progression
        _unlock_fifth_slots()

func _unlock_fourth_slots() -> void:
    var ball_unlocked = BallRegistry.unlock_slot()
    var passive_unlocked = FusionRegistry.unlock_passive_slot()

    if ball_unlocked or passive_unlocked:
        _show_slot_unlock_notification("4th Slot Unlocked!")

func _unlock_fifth_slots() -> void:
    var ball_unlocked = BallRegistry.unlock_slot()
    var passive_unlocked = FusionRegistry.unlock_passive_slot()

    if ball_unlocked or passive_unlocked:
        _show_slot_unlock_notification("5th Slot Unlocked!")
```

### 3. Add Notification System

Create visual/audio feedback when slots unlock:
- Toast notification or overlay message
- SFX for unlock event
- Brief animation on slot panels

Options:
- **Option A:** Simple toast message (quick implementation)
- **Option B:** Dedicated overlay with icon (more impactful)
- **Option C:** Highlight new slots in UI with glow effect

**Recommendation:** Start with Option A, iterate to Option C.

### 4. Meta-Progression Persistence

**Important decision:** Should slot unlocks persist across runs?

- **Option A (Meta):** Unlocks persist - once unlocked, always unlocked
  - Pros: Permanent progression, reduces frustration
  - Cons: Reduces roguelike purity

- **Option B (Per-Run):** Unlocks reset each run
  - Pros: True roguelike, every run is fresh challenge
  - Cons: May feel grindy, reduces build diversity early

**Recommendation:** Option A (Meta) - matches modern roguelite expectations and BallxPit's building system (permanent unlocks).

Implement via:
- Store `max_unlocked_ball_slots` and `max_unlocked_passive_slots` in meta-save
- On new run, start with saved unlock level
- Continue progression if player reaches new milestones

### 5. Update Tests

**File:** `tests/test_slot_unlocks.py` (new)

Test coverage:
- Slots start locked (3 each)
- Reaching Level 5 unlocks 4th slots
- Reaching Level 15 unlocks 5th slots
- Unlocks persist across runs (if meta)
- Notification appears on unlock
- Can immediately use newly unlocked slots

## Implementation Notes

### Alternative Unlock Systems (Future)

If XP milestones don't feel right, consider:
- **Currency purchase:** Spend gems in shop to unlock slots
- **Achievement-based:** "Defeat 100 enemies" → unlock slot
- **Building system:** Implement BallxPit-style base building
- **Hybrid:** Different unlock methods for each slot tier

### Balancing Considerations

- **Too early:** 4th slot at Level 3 may reduce early game challenge
- **Too late:** 5th slot at Level 20 may never be reached in typical run
- **Playtesting needed:** Monitor average player level at run end

## Acceptance Criteria

- [ ] Slots unlock at chosen level milestones
- [ ] Visual/audio feedback on unlock
- [ ] Newly unlocked slots immediately usable
- [ ] Persistence works (if meta-progression chosen)
- [ ] Tests cover unlock scenarios
- [ ] No duplicate unlocks (reaching Level 5 twice doesn't grant 5th slot)
- [ ] Unlock thresholds configurable for easy tuning

## Open Questions

1. **Unlock thresholds:** Level 5/15 or Level 3/10?
2. **Persistence:** Meta-progression or per-run?
3. **Notification style:** Toast, overlay, or highlight?
4. **Separate or together:** Unlock ball and passive slots together or independently?

**Recommendation for MVP:**
- Thresholds: Level 5/15 (safer balance)
- Persistence: Meta (better UX)
- Notification: Toast (quick implementation)
- Together: Unlock both slot types at same levels (simpler)

## Related Tasks

- Depends on: GoPit-implement-ball-slot-progression.md
- Depends on: GoPit-implement-passive-slot-progression.md
- Precedes: GoPit-add-slot-visual-feedback.md
