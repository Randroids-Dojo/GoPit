---
title: Implement upward gem drift for BallxPit-style collection
status: closed
priority: 2
issue-type: feature
created-at: "2026-01-25T23:58:34.615394+00:00"
closed-at: "2026-01-26T00:10:00.000000+00:00"
---

## Summary

Implement an upward gem drift option to simulate BallxPit's scrolling world gem collection feel.

## Background

Research in `docs/research/gem-collection-comparison.md` identified that BallxPit's gem collection feels harder because:
1. Gems don't auto-collect - player must physically move to them
2. The screen scrolls upward, causing gems to "scroll away" if not collected
3. Creates natural pressure without explicit despawn timers

In GoPit's static arena, we can simulate this by having gems drift upward (away from the player at the bottom), creating similar collection pressure.

## Implementation

1. Add gem movement mode enum (FALL_DOWN, DRIFT_UP, STATIONARY)
2. Change default gem behavior to drift upward
3. Gems drift upward at configurable speed (opposite of current fall)
4. Despawn when reaching top of screen instead of bottom
5. Keep magnetism system working (pull toward player still works)

## Files Modified

- `scripts/entities/gem.gd` - Added GemMovementMode enum with FALL_DOWN, DRIFT_UP, STATIONARY modes
- `tests/test_gem_collection.py` - Added tests for gem movement mode system

## Changes Made

1. Added `GemMovementMode` enum with three modes:
   - `FALL_DOWN` - Classic behavior (gems fall toward player)
   - `DRIFT_UP` - BallxPit-style (gems drift away from player)
   - `STATIONARY` - Gems stay where spawned

2. Renamed `fall_speed` to `base_speed` for clarity

3. Added `_apply_movement()` function that applies movement based on mode

4. Added static methods for mode control:
   - `set_movement_mode(mode)` / `get_movement_mode()`
   - `set_drift_up_mode()` / `set_fall_down_mode()` / `set_stationary_mode()`

5. Default mode is now `DRIFT_UP` for BallxPit-style feel

6. Updated despawn logic to check both top and bottom of screen

7. Magnetism still works regardless of mode - pulls gems toward player
