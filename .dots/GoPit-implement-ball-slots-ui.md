---
title: Create Ball Slots UI Display
status: completed
priority: 1
issue-type: implement
created-at: 2026-01-22T05:30:00Z
---

## Overview

Create a visual UI component to display equipped ball slots, mirroring the existing PassiveSlotsDisplay pattern.

## Context

BallxPit displays ball slots prominently in the HUD (top area near health). GoPit currently has no visual representation of equipped balls, which is a critical UX gap. Players can't see which balls they have equipped or how many slots are available.

See: `docs/research/slot-system-comparison.md`

## Requirements

### 1. Create BallSlotsDisplay Component
- **File:** `scripts/ui/ball_slots_display.gd`
- **Structure:** HBoxContainer with slot panels (similar to PassiveSlotsDisplay)
- **Display elements:**
  - Ball icon/identifier for each equipped ball
  - Ball level indicator (L1, L2, L3)
  - Empty slot indicator (e.g., "+")
  - Visual distinction for locked vs unlocked slots (future)

### 2. Scene Integration
- **File:** `scenes/ui/hud.tscn`
- **Position:** Top-right or top-center of HUD (suggest top-right to balance layout)
- **Anchoring:** Proper anchor settings for responsive layout

### 3. Signal Integration
- Connect to `BallRegistry.slots_changed` signal
- Auto-refresh display when slots change
- Show correct ball types and levels

### 4. Visual Design
- Match PassiveSlotsDisplay style (60×60px slots)
- Color-coded borders by ball element/type
- Clear visual hierarchy

## Implementation Pattern

Reference existing implementation:
- `scripts/ui/passive_slots_display.gd` - UI pattern to follow
- `scripts/autoload/ball_registry.gd:208` - Data source
- Current data: `BallRegistry.get_active_slots()` returns Array[int] with ball types

## Test Coverage

Create `tests/test_ball_slots_ui.py`:
- Test BallSlotsDisplay node exists in HUD
- Test displays correct number of slots (5)
- Test shows correct ball types when equipped
- Test updates when BallRegistry.slots_changed emits
- Test shows empty slots with "+" indicator

## Acceptance Criteria

- [ ] BallSlotsDisplay component created and added to HUD
- [ ] Displays all 5 ball slots
- [ ] Shows equipped ball icons/identifiers
- [ ] Shows ball levels (L1/L2/L3)
- [ ] Shows empty slots with clear indicator
- [ ] Updates in real-time when balls change
- [ ] Tests pass
- [ ] Visually consistent with PassiveSlotsDisplay

## Related Tasks

- GoPit-implement-ball-slot-progression.md (Phase 2)
- GoPit-implement-passive-slot-progression.md (Phase 2)
