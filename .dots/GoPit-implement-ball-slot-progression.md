---
title: Implement Ball Slot Progression (3→4→5)
status: open
priority: 2
issue-type: implement
created-at: 2026-01-22T05:30:00Z
---

## Overview

Change ball slots from fixed 5 slots to progressive unlock system (start with 3, unlock 4th and 5th).

## Context

BallxPit starts players with 3 ball slots and unlocks 4th/5th through buildings (Bag Maker → 5th slot building). This creates strategic scarcity early game and satisfying power spikes on unlock.

GoPit currently starts with all 5 slots unlocked, removing this progression mechanic.

See: `docs/research/slot-system-comparison.md`

## Requirements

### 1. Add Unlocked Slots Tracking
**File:** `scripts/autoload/ball_registry.gd`

Add new state:
```gdscript
const MAX_SLOTS: int = 5  # Keep as maximum
var unlocked_slots: int = 3  # Start with 3
```

### 2. Modify Slot Management

Update these methods to respect `unlocked_slots`:
- `get_active_slots()` - Only return unlocked slots
- `get_empty_slot_count()` - Only count unlocked empty slots
- `_assign_to_empty_slot()` - Only assign to unlocked slots
- Initialization of `active_ball_slots` array

### 3. Add Unlock Method

```gdscript
func unlock_slot() -> bool:
    """Unlock next ball slot. Returns true if successful."""
    if unlocked_slots >= MAX_SLOTS:
        return false
    unlocked_slots += 1
    slots_changed.emit()
    return true

func get_unlocked_slots() -> int:
    return unlocked_slots
```

### 4. Session Persistence

Update save/load to persist `unlocked_slots`:
- Add to session save data
- Restore on session load
- Reset to 3 on new game

### 5. Update Tests

**File:** `tests/test_ball_slots.py`

Update to test:
- Starting with 3 slots
- `unlock_slot()` method
- Cannot assign to locked slots
- Unlocking enables assignment
- Session persistence

## Implementation Notes

### Backward Compatibility
Existing saves with 5 equipped balls should migrate gracefully:
- Load all 5 balls
- Set `unlocked_slots = 5` for existing saves
- New games start with 3

### UI Integration
BallSlotsDisplay (from GoPit-implement-ball-slots-ui.md) should:
- Show locked slots with disabled/grayed state
- Only show unlocked slots initially (update when UI task implements locking)

## Acceptance Criteria

- [ ] New games start with 3 unlocked ball slots
- [ ] `unlock_slot()` method works correctly
- [ ] Cannot assign balls to locked slots
- [ ] Unlocking slot enables assignment
- [ ] Session persistence works
- [ ] Backward compatibility for existing saves
- [ ] All tests pass
- [ ] No regressions in ball firing

## Related Tasks

- GoPit-implement-ball-slots-ui.md (Phase 1 - needs this for locked slot display)
- GoPit-implement-slot-unlock-system.md (Phase 3 - will call unlock_slot())
- GoPit-implement-passive-slot-progression.md (Phase 2 - same pattern)
