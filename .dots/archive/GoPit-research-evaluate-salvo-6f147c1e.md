---
title: "research: Evaluate salvo-firing branch merge strategy"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-19T11:37:39.025038-06:00\\\"\""
closed-at: "2026-01-19T11:39:08.767552-06:00"
close-reason: Research complete. Determined salvo-firing branch is 90+ commits behind main and cannot be merged. Created GoPit-implement-add-ultimate-b935a504 with detailed code extraction spec for manual addition of Ultimate ability to main. Recommended branch deletion after implementation.
---

## Context

The `feature/salvo-firing` branch contains the Ultimate ability implementation, but is severely out of date with main. Main has 90+ commits since the common ancestor including:
- Phase 5 polish (biome music, crossfades, boss music)
- iOS/Android export presets
- CI Godot 4.5.1 upgrade
- First-time tutorial hints
- And much more

The branch shows 17,046 lines of deletions vs main, indicating it's missing all recent work.

## Research Questions

1. What specific files from salvo-firing contain the Ultimate ability?
2. Can those files be cleanly cherry-picked to main?
3. Are there conflicts with Phase 5 changes (sound_manager, game_manager, etc.)?
4. Should we re-implement fresh on main instead of merging?

## Affected Files (suspected)
- scripts/effects/ultimate_blast.gd
- scripts/ui/ultimate_button.gd
- scenes/effects/ultimate_blast.tscn
- scenes/ui/ultimate_button.tscn
- scripts/autoload/game_manager.gd (partial - ultimate charge signals/methods)
- scripts/game/game_controller.gd (partial - ultimate wiring)

## Expected Deliverables
- Decision: cherry-pick vs fresh implementation
- If cherry-pick: List of specific commits/files to extract
- If fresh: Implementation spec based on archived GoPit-a0p task

---

## Research Findings (2026-01-19)

### 1. Branch Divergence Analysis

**Common ancestor:** `69604f0a` (2026-01-05)
**Main ahead by:** 90+ commits including all Phase 5 work
**Salvo-firing ahead by:** 5 commits (salvo firing + ultimate ability)

The salvo-firing branch is **severely stale** and cannot be merged without losing:
- Dual character mode (Matchmaker building)
- Extended Passive enum (BERSERKER, SWARM_LORD, etc.)
- Aim sensitivity feature
- All Phase 5 polish (biome music, crossfades, boss music)
- iOS/Android export presets
- CI Godot 4.5.1 upgrade
- First-time tutorial hints
- And 17,000+ lines of other work

### 2. Ultimate Ability Files in Salvo-Firing

**Standalone files (can copy directly):**
- `scripts/effects/ultimate_blast.gd` - Clean, self-contained
- `scripts/ui/ultimate_button.gd` - Clean, self-contained
- `scenes/effects/ultimate_blast.tscn` - Simple scene
- `scenes/ui/ultimate_button.tscn` - Simple scene

**Partial modifications needed for:**
- `scripts/autoload/game_manager.gd` - Adds signals + charge system
- `scripts/autoload/sound_manager.gd` - Adds ULTIMATE enum + generator
- `scripts/game/game_controller.gd` - Wires charge gain + activation
- `scenes/game.tscn` - Adds ultimate button to UI hierarchy

### 3. Conflict Assessment

**game_manager.gd conflicts:**
- Main has `secondary_character`, `secondary_passive` (dual mode) - salvo-firing removed these
- Main has extended Passive enum - salvo-firing has fewer values
- **Resolution:** Extract only the ultimate-related additions, ignore destructive changes

**sound_manager.gd conflicts:**
- Main has `aim_sensitivity` feature - salvo-firing removed it
- **Resolution:** Add ULTIMATE enum and generator without removing aim sensitivity

**game_controller.gd conflicts:**
- Complex file, need careful extraction
- **Resolution:** Manually add ultimate wiring to main's version

### 4. Decision: Manual Extraction (Not Cherry-Pick or Merge)

**Reason:** Cherry-pick won't work cleanly due to extensive context differences. The commits in salvo-firing touch files that have changed significantly in main.

**Strategy:** Copy the ultimate ability code directly to main:
1. Copy standalone files as-is
2. Manually add ultimate-related code to game_manager.gd
3. Manually add ULTIMATE sound type to sound_manager.gd
4. Manually wire charge/activation in game_controller.gd
5. Add ultimate button to game.tscn

### 5. Deliverable

Created implementation spec: `GoPit-implement-add-ultimate-ability` with detailed code additions based on extracted salvo-firing code.

### 6. Recommendation for salvo-firing branch

After ultimate ability is implemented on main, the `feature/salvo-firing` branch should be:
1. Deleted from remote (`git push origin --delete feature/salvo-firing`)
2. Deleted locally (`git branch -D feature/salvo-firing`)
3. The worktree directory `GoPit-salvo-firing/` can be removed
