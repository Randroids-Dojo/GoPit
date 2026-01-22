---
title: Implement Passive Slot Progression (3→4→5)
status: open
priority: 2
issue-type: implement
created-at: 2026-01-22T05:30:00Z
---

## Overview

Change passive slots from fixed 4 slots to progressive unlock system (start with 3, max 5).

## Context

BallxPit starts players with 3 passive slots and unlocks 4th/5th through buildings (Carpenter → 5th slot building). GoPit currently:
- Starts with 4 slots (should be 3)
- Max is 4 slots (should be 5)
- No progression mechanic

See: `docs/research/slot-system-comparison.md`

## Requirements

### 1. Update Constants and State
**File:** `scripts/autoload/fusion_registry.gd`

```gdscript
const MAX_PASSIVE_SLOTS: int = 5  # Change from 4 → 5
const MAX_PASSIVE_LEVEL: int = 3
var unlocked_passive_slots: int = 3  # New variable, start with 3
var passive_slots: Array[Dictionary] = []
```

### 2. Modify Slot Management

Update these methods to respect `unlocked_passive_slots`:
- `get_empty_slot_count()` - Only count unlocked empty slots
- `has_empty_slot()` - Check against unlocked slots
- `apply_passive()` - Only apply to unlocked slots
- `get_equipped_passives()` - Only return from unlocked slots
- `get_available_passives()` - Consider unlocked slot limit

### 3. Add Unlock Method

```gdscript
func unlock_passive_slot() -> bool:
    """Unlock next passive slot. Returns true if successful."""
    if unlocked_passive_slots >= MAX_PASSIVE_SLOTS:
        return false
    unlocked_passive_slots += 1
    passive_slots_changed.emit()
    return true

func get_unlocked_passive_slots() -> int:
    return unlocked_passive_slots
```

### 4. Update PassiveSlotsDisplay
**File:** `scripts/ui/passive_slots_display.gd`

Changes needed:
- Create 5 slot panels (currently creates 4)
- Show locked state for slots beyond `unlocked_passive_slots`
- Update refresh logic to handle 5 slots
- Visual distinction: locked slots grayed out or hidden

### 5. Session Persistence

Update save/load:
- Add `unlocked_passive_slots` to session data
- Restore on load
- Reset to 3 on new game

### 6. Update Tests

**File:** `tests/test_passive_slots.py`

Update to test:
- Starting with 3 slots (not 4)
- Maximum of 5 slots (not 4)
- `unlock_passive_slot()` method
- Cannot apply passive to locked slots
- UI shows 5 slots with locked state
- Session persistence

## Implementation Notes

### Backward Compatibility
Existing saves with 4 passives equipped:
- Load all 4 passives
- Set `unlocked_passive_slots = 4` for existing saves
- New games start with 3

### Visual Design
Locked slots in PassiveSlotsDisplay:
- Option A: Show grayed out with lock icon
- Option B: Show disabled with "?" placeholder
- Option C: Hide locked slots until unlocked (animate in)

**Recommendation:** Option A for clarity

## Acceptance Criteria

- [ ] MAX_PASSIVE_SLOTS changed from 4 → 5
- [ ] New games start with 3 unlocked passive slots
- [ ] `unlock_passive_slot()` method works correctly
- [ ] Cannot apply passives to locked slots
- [ ] PassiveSlotsDisplay shows 5 slots
- [ ] Locked slots visually distinguished
- [ ] Session persistence works
- [ ] Backward compatibility for existing saves
- [ ] All tests pass
- [ ] No regressions in passive system

## Related Tasks

- GoPit-implement-ball-slot-progression.md (Phase 2 - same pattern)
- GoPit-implement-slot-unlock-system.md (Phase 3 - will call unlock_passive_slot())
- GoPit-implement-ball-slots-ui.md (Phase 1 - ball slots need similar locked state)
