---
title: Implement stat-specific meta buildings
status: open
priority: 2
issue-type: implement
created-at: 2026-01-24T12:00:00Z
---

## Overview

Add 4 stat-boosting buildings to the meta-progression shop, matching the GDD specification.

## Context

The GDD specifies 5 meta-progression buildings. Currently only Veteran's Hut (+XP) is implemented. The remaining 4 stat-specific buildings need to be added:

| Building | Effect | Max Level | Total Bonus |
|----------|--------|-----------|-------------|
| Armory | +2% starting STR | 5 | +10% |
| Dojo | +2% starting DEX | 5 | +10% |
| Library | +2% starting INT | 5 | +10% |
| Barracks | +2% starting LEAD | 5 | +10% |

## Requirements

### 1. Add Upgrade Definitions
**File:** `scripts/data/permanent_upgrades.gd`

Add 4 new entries to `UPGRADES` dictionary:
```gdscript
"strength": UpgradeData.new(
    "strength",
    "Armory",
    "Increase starting Strength",
    "⚔️",
    150,
    2.0,  # 150, 300, 600, 1200, 2400
    5,
    "+%d%% STR"
),
"dexterity": UpgradeData.new(
    "dexterity",
    "Dojo",
    "Increase starting Dexterity",
    "🥋",
    150,
    2.0,
    5,
    "+%d%% DEX"
),
"intelligence": UpgradeData.new(
    "intelligence",
    "Library",
    "Increase starting Intelligence",
    "📖",
    150,
    2.0,
    5,
    "+%d%% INT"
),
"leadership": UpgradeData.new(
    "leadership",
    "Barracks",
    "Increase starting Leadership",
    "🏰",
    150,
    2.0,
    5,
    "+%d%% LEAD"
)
```

### 2. Add Bonus Variables to MetaManager
**File:** `scripts/autoload/meta_manager.gd`

Add bonus multipliers:
```gdscript
var bonus_strength_mult: float = 1.0   # 1.0 = no bonus
var bonus_dexterity_mult: float = 1.0
var bonus_intelligence_mult: float = 1.0
var bonus_leadership_mult: float = 1.0
```

### 3. Update Bonus Calculation
**File:** `scripts/autoload/meta_manager.gd` - `_calculate_bonuses()`

Add calculations:
```gdscript
# Stat bonuses: +2% per level (multiplier format)
bonus_strength_mult = 1.0 + get_upgrade_level("strength") * 0.02
bonus_dexterity_mult = 1.0 + get_upgrade_level("dexterity") * 0.02
bonus_intelligence_mult = 1.0 + get_upgrade_level("intelligence") * 0.02
bonus_leadership_mult = 1.0 + get_upgrade_level("leadership") * 0.02
```

Add getter functions:
```gdscript
func get_strength_mult() -> float:
    return bonus_strength_mult

func get_dexterity_mult() -> float:
    return bonus_dexterity_mult

func get_intelligence_mult() -> float:
    return bonus_intelligence_mult

func get_leadership_mult() -> float:
    return bonus_leadership_mult
```

### 4. Apply Bonuses to Character Stats
**File:** `scripts/autoload/game_manager.gd`

Modify stat getter functions:
```gdscript
func get_character_strength() -> int:
    if selected_character == null:
        return 10
    var base := selected_character.get_strength_at_level(player_level) if selected_character.has_method("get_strength_at_level") else int(10 * character_damage_mult)
    return int(base * MetaManager.get_strength_mult())

func get_character_dexterity() -> int:
    if selected_character == null:
        return 5
    var base := selected_character.get_dexterity_at_level(player_level) if selected_character.has_method("get_dexterity_at_level") else int(5 * character_crit_mult)
    return int(base * MetaManager.get_dexterity_mult())

func get_character_intelligence() -> int:
    if selected_character == null:
        return 5
    var base := selected_character.get_intelligence_at_level(player_level) if selected_character.has_method("get_intelligence_at_level") else int(5 * character_intelligence_mult)
    return int(base * MetaManager.get_intelligence_mult())

func get_character_leadership() -> int:
    if selected_character == null:
        return 5
    var base := selected_character.get_leadership_at_level(player_level) if selected_character.has_method("get_leadership_at_level") else 5
    return int(base * MetaManager.get_leadership_mult())
```

### 5. Update Save/Load
**File:** `scripts/autoload/meta_manager.gd`

Ensure new upgrade IDs are included in save/load (should work automatically via `unlocked_upgrades` dictionary).

### 6. Write Tests
**File:** `tests/test_stat_buildings.py` (new)

Test coverage:
- Each building appears in shop
- Purchasing increases stat multiplier
- Stat bonus applies to character stats
- Max level (5) is enforced
- Bonuses persist across sessions

## Implementation Notes

### Pricing Balance
Proposed costs match existing upgrade curve:
- Level 1: 150 coins
- Level 2: 300 coins
- Level 3: 600 coins
- Level 4: 1,200 coins
- Level 5: 2,400 coins
- **Total to max one building:** 4,650 coins
- **Total to max all four:** 18,600 coins

### Edge Cases
- **Dual character mode:** Both characters should benefit from stat bonuses
- **Session resume:** Bonuses should apply on resume (already loaded via MetaManager)
- **Percentage rounding:** Use `int()` to round down final stat values

### UI Shop Layout
Current shop has 7 upgrades. Adding 4 more = 11 total. May need to:
- Add scrolling to shop panel
- Or organize into categories (Stats / Combat / Economy)

## Acceptance Criteria

- [ ] All 4 buildings appear in meta shop
- [ ] Each can be purchased up to level 5
- [ ] Purchasing deducts correct coin amount
- [ ] Stat multipliers apply correctly to all characters
- [ ] Bonuses persist after game restart
- [ ] Tests pass for all new functionality
- [ ] Shop UI handles additional upgrades gracefully

## Related Tasks

- Depends on: GoPit-research-stat-building-integration.md
- Related: docs/GDD.md (Section 7.4 Meta-Progression Buildings)
