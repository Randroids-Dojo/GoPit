---
title: Research stat building integration points
status: completed
priority: 1
issue-type: research
created-at: 2026-01-24T12:00:00Z
completed-at: 2026-01-24T12:30:00Z
---

## Overview

Research how stat bonuses from meta-progression buildings should integrate with the existing character stat system.

## Research Findings

### BallxPit Building System

Per [BallxPit Wiki](https://ballxpit.wiki.gg/wiki/Buildings), there are two categories of stat buildings:

**Capped buildings (max level 5):**
| Building | Stat | Effect |
|----------|------|--------|
| Barracks | Strength | +1 per level |
| Gunsmith | Dexterity | +1 per level |
| Schoolhouse | Intelligence | +1 per level |
| Consulate | Leadership | +1 per level |
| Clinic | Endurance | +1 per level |
| Shoemaker | Speed | +1 per level |

**Key insight:** BallxPit uses **+1 flat stat per level**, NOT percentage bonuses.

### GoPit Current Stat System

**Stats with base+scaling system:**
- `base_strength` (8-10) + scaling grade (S/A/B/C/D/E)
- `base_dexterity` (5) + scaling grade
- `base_intelligence` (5) + scaling grade

**Stats still using old multiplier system:**
- `leadership` (float multiplier, e.g., 1.0, 1.5)

### Recommended Approach

**Match BallxPit: +1 flat stat per building level**

This is simpler and more impactful than percentages:
- +1 STR = +1 base damage (significant early game)
- +1 DEX = +2% crit chance, +5% fire rate
- +1 INT = +10% status duration, +5% status damage
- +1 LEAD = more baby balls, +15% baby damage

**Integration Point: GameManager stat getters**

Modify `GameManager.get_character_*()` to add MetaManager bonus:

```gdscript
func get_character_strength() -> int:
    var base := selected_character.get_strength_at_level(player_level)
    return base + MetaManager.get_strength_bonus()  # +1 per building level
```

### Stat Usage Audit

| Stat | Effect | Usage Location |
|------|--------|----------------|
| STR | Ball damage | `ball_spawner.gd:381` |
| STR | Baby ball damage | `ball_spawner.gd:429` |
| DEX | Crit chance | `character.gd:186` (2% per point) |
| DEX | Fire rate mult | `character.gd:194` (5% per point above 5) |
| INT | Status duration | `character.gd:230` (10% per point above 5) |
| INT | Status damage | `character.gd:237` (5% per point above 5) |
| LEAD | Baby ball count | `baby_ball_spawner.gd:52` |
| LEAD | Baby damage bonus | `baby_ball_spawner.gd:73` |

### Edge Cases

1. **Leadership uses old system:** Currently uses `character_leadership_mult` multiplier instead of base+scaling. Bonus will need to be applied differently (add to `_leadership_bonus`).

2. **Dual character mode:** Both characters benefit from stat bonuses (bonuses are global, not per-character).

3. **Level 1 characters:** With +5 bonus, a character with base_strength=8 would have 13 effective strength at level 1 - still balanced.

### Building Names (Matching BallxPit)

| GDD Name | BallxPit Name | Recommendation |
|----------|---------------|----------------|
| Armory | Barracks | Use **Barracks** |
| Dojo | Gunsmith | Use **Gunsmith** |
| Library | Schoolhouse | Use **Schoolhouse** |
| Barracks | Consulate | Use **Consulate** |

### Final Recommendation

1. Use BallxPit building names for familiarity
2. Use +1 flat stat per level (not %)
3. Cap at level 5 (max +5 per stat)
4. Apply bonus in GameManager getters
5. Leadership requires special handling via `_leadership_bonus`

## Related Tasks

- Blocks: GoPit-implement-stat-buildings.md
