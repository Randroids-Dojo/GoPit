---
title: Research stat building integration points
status: open
priority: 1
issue-type: research
created-at: 2026-01-24T12:00:00Z
---

## Overview

Research how stat bonuses from meta-progression buildings should integrate with the existing character stat system.

## Context

The GDD specifies 4 stat-specific buildings that are currently missing:
- **Armory**: +2% starting STR per level (5 max = +10%)
- **Dojo**: +2% starting DEX per level (5 max = +10%)
- **Library**: +2% starting INT per level (5 max = +10%)
- **Barracks**: +2% starting LEAD per level (5 max = +10%)

## Research Questions

### 1. Stat Application Point
Where should stat bonuses be applied?

**Current stat flow:**
```
Character.get_strength_at_level(level)
  → GameManager.get_character_strength()
    → ball_spawner.ball_damage
```

**Options:**
- **Option A:** Modify `GameManager.get_character_*()` to add MetaManager bonus
- **Option B:** Modify `Character.get_*_at_level()` to accept bonus parameter
- **Option C:** Apply bonus at usage site (ball_spawner, baby_ball_spawner, etc.)

**Recommendation:** Option A - keeps bonus logic centralized in GameManager

### 2. Percentage vs Flat Bonus
GDD says "+2% starting STR" - clarify implementation:

- **Percentage of base stat:** `base_strength * (1 + 0.02 * level)`
- **Percentage of scaled stat:** `get_strength_at_level(lvl) * (1 + 0.02 * level)`
- **Flat bonus:** `get_strength_at_level(lvl) + 2 * level`

**Recommendation:** Percentage of base stat (matches GDD wording "starting")

### 3. Stat Usage Audit
Document where each stat is consumed:

| Stat | Usage | File |
|------|-------|------|
| STR | Ball damage | `ball_spawner.gd:381` |
| STR | Baby ball damage | `baby_ball_spawner.gd` |
| DEX | Fire rate / crit chance | `ball_spawner.gd` |
| INT | Status effect duration | `status_effect.gd` |
| LEAD | Baby ball spawn count | `baby_ball_spawner.gd` |

### 4. UI Considerations
- Should stat bonuses show in character select screen?
- Should they show in a "bonuses active" tooltip?

## Files to Review

- `scripts/autoload/game_manager.gd:171-230` - Stat getter functions
- `scripts/autoload/meta_manager.gd:324-340` - Bonus calculation pattern
- `scripts/data/permanent_upgrades.gd` - Upgrade definitions
- `scripts/resources/character.gd` - Character stat definitions

## Acceptance Criteria

- [ ] Document recommended integration approach
- [ ] Confirm percentage vs flat bonus interpretation
- [ ] List all stat usage points that need updating
- [ ] Note any edge cases (dual character mode, etc.)

## Related Tasks

- Depends on: None
- Blocks: GoPit-implement-stat-buildings.md
