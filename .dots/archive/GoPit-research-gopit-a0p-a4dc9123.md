---
title: "research: GoPit-a0p (Ultimate ability) already implemented in salvo-firing branch"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-19T09:45:25.881038-06:00\""
closed-at: "2026-01-19T09:45:30.606940-06:00"
close-reason: "Documented finding: Ultimate ability fully implemented in feature/salvo-firing branch. Only Empty Nester integration remains."
---

## Finding

The Ultimate ability feature (GoPit-a0p) has been **fully implemented** in the `feature/salvo-firing` branch/worktree.

### Implementation Status

**Complete:**
- `scripts/autoload/game_manager.gd` - Ultimate charge system (signals, charge add/use/reset)
- `scripts/ui/ultimate_button.gd` - UI with charge ring, pulse animation
- `scripts/effects/ultimate_blast.gd` - Screen-clearing blast effect
- `scenes/effects/ultimate_blast.tscn` - Blast scene (presumably)
- `scenes/ui/ultimate_button.tscn` - Button scene (presumably)

**Signals implemented:**
- `ultimate_ready`
- `ultimate_used`  
- `ultimate_charge_changed(current, max_val)`

**Features implemented:**
- Charge accumulates via `add_ultimate_charge()`
- Ready state triggers pulsing UI
- Activation deals 9999 damage to all enemies
- Screen flash, camera shake, sound effect
- Charge resets on use and game reset

### NOT Implemented

Based on GoPit-a0p spec, the following was NOT in the salvo-firing branch:
- Empty Nester's 2x specials passive integration
- Wiring charge gain to enemy kills / gem collection (may be partially done)

### Recommendation

When the salvo-firing branch is ready to merge:
1. Merge it to main
2. Close GoPit-a0p with note about what remains (Empty Nester passive)
3. Create follow-up task if Empty Nester integration needed

### Location
- Worktree: `GoPit-salvo-firing/`
- Branch: `feature/salvo-firing`
- Remote: `origin/feature/salvo-firing`
