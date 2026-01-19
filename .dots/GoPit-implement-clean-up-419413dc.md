---
title: "implement: Clean up obsolete feature branches"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T12:09:37.615910-06:00"
after: GoPit-research-audit-feature-706ba0eb
---

## Description

Delete 60+ remote branches whose content has been merged to main via PRs. The branches were not deleted after merging, leading to branch proliferation.

## Context

Research found that while git reports only 3 branches as "merged", nearly all features from 70+ branches are already in main (ball types, bosses, characters, stats, etc.). The branches can be safely removed.

## Affected Files

- Remote git branches only (no code changes)

## Implementation Notes

### Branches to DELETE (safe - content in main)

```bash
# Ball types
git push origin --delete feature/wind-ball-type feature/ghost-ball-type feature/vampire-ball feature/dark-ball-type feature/cell-ball-type feature/charm-effect feature/laser-ball-type feature/brood-mother-ball

# Bosses/enemies
git push origin --delete feature/slime-king feature/mini-bosses feature/more-bosses feature/new-enemy-types feature/boss-weak-points feature/weak-point-system

# Stats/mechanics
git push origin --delete feature/strength-stat feature/strength-based-damage feature/ball-speed-multiplier feature/fire-rate-stat feature/dodge-chance feature/character-stats feature/dexterity-stat-implementation

# Progression
git push origin --delete feature/multi-tier-evolutions feature/passive-evolutions feature/achievement-system feature/xp-bonus-buildings feature/character-unlock-tracking feature/gear-unlock-system

# Status effects
git push origin --delete feature/status-effects feature/new-status-effects feature/hemorrhage-mechanic

# Slot system
git push origin --delete feature/ball-slot-system feature/passive-slots feature/passive-slot-system feature/ball-slot-ui feature/ball-queue-system

# Other completed
git push origin --delete feature/baby-balls feature/baby-ball-inheritance feature/baby-ball-limit feature/new-characters feature/matchmaker-dual-character feature/win-condition feature/more-evolution-recipes feature/more-passives feature/invincibility-frames feature/screen-shake-toggle feature/speed-toggle feature/speed-level-system feature/bounce-damage-scaling feature/diagonal-shot-bounces feature/return-path-damage feature/shooting-slows-movement feature/lightning-chain-improvement feature/passives-in-fission feature/fission-coin-fallback feature/fission-counter feature/post-boss-hp-spike feature/ball-catching

# Fixes
git push origin --delete fix/bleed-on-hit-damage fix/character-select-tests fix/tutorial-overlay mute-fix

# Misc
git push origin --delete feature/aim-sensitivity research/stage-speed-progression vercel/set-up-vercel-web-analytics-fo-vke4ie
```

### Branches to KEEP (need review or potential value)

- `origin/main` - main branch
- `origin/redesign` - 304 commits, contains analysis docs, review before deleting
- `origin/claude/streamline-onboarding-MJDcK` - active work, review first
- `origin/feature/hitbox-display` - hitbox toggle UI not in main
- `origin/feature/evolution-encyclopedia` - encyclopedia UI
- `origin/feature/execute-mechanic` - execute low-HP enemies
- `origin/feature/environmental-hazards` - stage hazards
- `origin/feature/enemy-spawn-formations` - spawn patterns
- `origin/feature/collector-magnet-passive` - collector-specific passive
- `origin/feature/empty-nester-passive` - empty nester-specific passive

## Verify

- [ ] Capture `git branch -r | sort` before deletion for reference
- [ ] Delete branches in batches; re-run `git branch -r | wc -l` to confirm count drops as expected
- [ ] Run `git fetch --prune` and confirm deleted branches are gone
- [ ] Spot-check that the "KEEP" branch list is still present
