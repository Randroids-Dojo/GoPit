---
title: "research: Audit feature branches for cleanup or unmerged work"
status: closed
priority: 2
issue-type: task
created-at: "\"2026-01-19T12:03:22.064602-06:00\""
closed-at: "2026-01-19T12:10:00.896849-06:00"
close-reason: Found 60+ branches safe to delete (content in main via PRs). Created implement task for cleanup.
---

## Description

There are 100+ feature branches in the repository. With all 5 development phases complete, many of these are likely:
1. **Merged to main** - Can be safely deleted
2. **Superseded** - Work was implemented differently
3. **Abandoned** - Never completed, can be deleted
4. **Valuable unmerged** - Contains work worth extracting

## Context

Running `git branch -r | grep feature | wc -l` shows ~70 remote feature branches. Most are 1-5 commits ahead of main.

## Questions to Answer

1. Which branches have work that was never merged?
2. Are any of those unmerged commits valuable features that should be added?
3. Which branches can be safely deleted (already merged or abandoned)?
4. Should we create a branch cleanup script?

## Expected Deliverables

- List of branches categorized by status (merged, superseded, abandoned, valuable)
- `implement:` tasks for any valuable unmerged features
- `implement:` task for branch cleanup with list of branches to delete

---

## Research Findings (2026-01-19)

### Summary

Analyzed 75 remote branches. Key finding: **Nearly all feature branches have their content already in main**, either via PR merges, cherry-picks, or parallel implementation. The branches themselves weren't deleted after merging.

### Git vs Content Merge Status

Git reports only 3 feature branches as "merged" (`--merged`), but content analysis shows all major features ARE in main:
- Ball types (Wind, Ghost, Vampire, Dark, Cell, Charm, Laser, Brood Mother): All in `ball_registry.gd`
- Bosses: Full boss system with mini-bosses and final bosses
- Characters: 16 characters in main
- Stats: Strength, dodge_chance, fire_rate all exist
- Multi-tier evolutions: TIER_1/2/3 system exists
- Passive evolutions: `passive_evolutions.gd` exists
- Auto-magnet boss fights: `BOSS_MAGNET_RANGE` exists
- XP bonus buildings: bonus_xp_percent in meta_manager
- Achievement system: achievements dict in meta_manager

### Branch Categories

#### 1. SAFE TO DELETE - Content in Main (60+ branches)

**Ball Type Branches** (all ball types exist in main):
- origin/feature/wind-ball-type
- origin/feature/ghost-ball-type
- origin/feature/vampire-ball
- origin/feature/dark-ball-type
- origin/feature/cell-ball-type
- origin/feature/charm-effect
- origin/feature/laser-ball-type
- origin/feature/brood-mother-ball

**Boss/Enemy Branches** (boss system complete in main):
- origin/feature/slime-king
- origin/feature/mini-bosses
- origin/feature/more-bosses
- origin/feature/new-enemy-types
- origin/feature/boss-weak-points
- origin/feature/weak-point-system

**Stat/Mechanic Branches** (stats exist in main):
- origin/feature/strength-stat
- origin/feature/strength-based-damage
- origin/feature/ball-speed-multiplier
- origin/feature/fire-rate-stat
- origin/feature/dodge-chance
- origin/feature/character-stats
- origin/feature/dexterity-stat-implementation

**Progression Branches** (systems exist in main):
- origin/feature/multi-tier-evolutions
- origin/feature/passive-evolutions
- origin/feature/achievement-system
- origin/feature/xp-bonus-buildings
- origin/feature/character-unlock-tracking
- origin/feature/gear-unlock-system

**Status Effect Branches** (effects in ball_registry):
- origin/feature/status-effects
- origin/feature/new-status-effects
- origin/feature/hemorrhage-mechanic

**Slot System Branches** (slot system in main):
- origin/feature/ball-slot-system (git-merged)
- origin/feature/passive-slots (git-merged)
- origin/feature/passive-slot-system
- origin/feature/ball-slot-ui
- origin/feature/ball-queue-system

**Other Completed Branches**:
- origin/feature/baby-balls
- origin/feature/baby-ball-inheritance
- origin/feature/baby-ball-limit
- origin/feature/new-characters
- origin/feature/matchmaker-dual-character
- origin/feature/win-condition (git-merged)
- origin/feature/more-evolution-recipes
- origin/feature/more-passives
- origin/feature/invincibility-frames
- origin/feature/screen-shake-toggle
- origin/feature/speed-toggle
- origin/feature/speed-level-system
- origin/feature/bounce-damage-scaling
- origin/feature/diagonal-shot-bounces
- origin/feature/return-path-damage
- origin/feature/shooting-slows-movement
- origin/feature/lightning-chain-improvement
- origin/feature/passives-in-fission
- origin/feature/fission-coin-fallback
- origin/feature/fission-counter
- origin/feature/post-boss-hp-spike
- origin/feature/ball-catching

**Fix Branches** (issues resolved):
- origin/fix/bleed-on-hit-damage
- origin/fix/character-select-tests
- origin/fix/tutorial-overlay
- origin/mute-fix

**Miscellaneous**:
- origin/feature/aim-sensitivity
- origin/research/stage-speed-progression
- origin/vercel/set-up-vercel-web-analytics-fo-vke4ie

#### 2. POTENTIALLY VALUABLE - Minor Features Not Clearly in Main

- **origin/feature/hitbox-display** (6 commits): Hitbox display toggle for pause menu. No evidence this specific UI feature is in main.
- **origin/feature/evolution-encyclopedia** (1 commit): Encyclopedia UI. May not be in main.
- **origin/feature/execute-mechanic** (1 commit): Execute low-HP enemies. May not be in main.
- **origin/feature/environmental-hazards** (1 commit): Stage hazards. May not be in main.
- **origin/feature/enemy-spawn-formations** (1 commit): Spawn patterns. May not be in main.
- **origin/feature/collector-magnet-passive** (1 commit): Collector-specific passive. May not be in main.
- **origin/feature/empty-nester-passive** (1 commit): Empty Nester-specific passive. May not be in main.

#### 3. DIVERGENT/SPECIAL - Separate Consideration

- **origin/redesign** (304 commits ahead, 135 behind): Old development branch. Contains analysis/documentation work but significantly diverged from main. Review before deleting.
- **origin/claude/streamline-onboarding-MJDcK** (3 commits, 58 behind): Onboarding changes, but removes many features. Would need careful review.

### Answers to Questions

1. **Which branches have work that was never merged?**
   - Very few. Most "unmerged" branches actually have their content in main via PRs.
   - Potentially unmerged: hitbox-display UI, evolution-encyclopedia, execute-mechanic, environmental-hazards, enemy-spawn-formations

2. **Are any unmerged commits valuable features?**
   - Hitbox display toggle could be useful for accessibility
   - Evolution encyclopedia could improve discoverability
   - Enemy spawn formations could add variety
   - These are minor polish features, not critical

3. **Which branches can be safely deleted?**
   - 60+ branches can be safely deleted (see list above)
   - All ball type, boss, stat, progression branches are safe to delete

4. **Should we create a branch cleanup script?**
   - Yes. Recommend a script that deletes all branches EXCEPT:
     - origin/main
     - origin/redesign (needs manual review)
     - origin/claude/streamline-onboarding-MJDcK (needs manual review)
     - origin/feature/hitbox-display (may have value)
     - origin/feature/evolution-encyclopedia (may have value)
     - origin/feature/execute-mechanic (may have value)
     - origin/feature/environmental-hazards (may have value)
     - origin/feature/enemy-spawn-formations (may have value)
