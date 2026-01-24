---
title: Implement stat-specific meta buildings
status: completed
priority: 2
issue-type: implement
created-at: 2026-01-24T12:00:00Z
completed-at: 2026-01-24T13:00:00Z
---

## Overview

Add 4 stat-boosting buildings to the meta-progression shop, matching BallxPit's building system.

## Context

Based on research, BallxPit uses **+1 flat stat per building level** (capped at level 5). Using BallxPit building names for player familiarity.

| Building | Stat | Effect | Max Bonus |
|----------|------|--------|-----------|
| Barracks | Strength | +1 damage per level | +5 |
| Gunsmith | Dexterity | +1 DEX per level | +5 |
| Schoolhouse | Intelligence | +1 INT per level | +5 |
| Consulate | Leadership | +1 LEAD per level | +5 |

## Requirements

### 1. Add Upgrade Definitions
**File:** `scripts/data/permanent_upgrades.gd`

```gdscript
"strength": UpgradeData.new(
    "strength",
    "Barracks",
    "Train soldiers to hit harder",
    "⚔️",
    150, 2.0, 5,
    "+%d Strength"
),
"dexterity": UpgradeData.new(
    "dexterity",
    "Gunsmith",
    "Precision tools for faster firing",
    "🎯",
    150, 2.0, 5,
    "+%d Dexterity"
),
"intelligence": UpgradeData.new(
    "intelligence",
    "Schoolhouse",
    "Knowledge amplifies your effects",
    "📚",
    150, 2.0, 5,
    "+%d Intelligence"
),
"leadership": UpgradeData.new(
    "leadership",
    "Consulate",
    "Command a larger baby ball army",
    "👑",
    150, 2.0, 5,
    "+%d Leadership"
)
```

### 2. Add Bonus Variables to MetaManager
**File:** `scripts/autoload/meta_manager.gd`

```gdscript
# Stat bonuses from buildings (flat +1 per level)
var bonus_strength: int = 0
var bonus_dexterity: int = 0
var bonus_intelligence: int = 0
var bonus_leadership: int = 0
```

### 3. Update Bonus Calculation
**File:** `scripts/autoload/meta_manager.gd` - `_calculate_bonuses()`

```gdscript
# Stat bonuses: +1 per level (BallxPit style)
bonus_strength = get_upgrade_level("strength")
bonus_dexterity = get_upgrade_level("dexterity")
bonus_intelligence = get_upgrade_level("intelligence")
bonus_leadership = get_upgrade_level("leadership")
```

Add getter functions:
```gdscript
func get_strength_bonus() -> int:
    return bonus_strength

func get_dexterity_bonus() -> int:
    return bonus_dexterity

func get_intelligence_bonus() -> int:
    return bonus_intelligence

func get_leadership_bonus() -> int:
    return bonus_leadership
```

### 4. Apply Bonuses in GameManager
**File:** `scripts/autoload/game_manager.gd`

```gdscript
func get_character_strength() -> int:
    if selected_character == null:
        return 10 + MetaManager.get_strength_bonus()
    var base: int = 10
    if selected_character.has_method("get_strength_at_level"):
        base = selected_character.get_strength_at_level(player_level)
    else:
        base = int(10 * character_damage_mult)
    return base + MetaManager.get_strength_bonus()

func get_character_dexterity() -> int:
    if selected_character == null:
        return 5 + MetaManager.get_dexterity_bonus()
    var base: int = 5
    if selected_character.has_method("get_dexterity_at_level"):
        base = selected_character.get_dexterity_at_level(player_level)
    else:
        base = int(5 * character_crit_mult)
    return base + MetaManager.get_dexterity_bonus()

func get_character_intelligence() -> int:
    if selected_character == null:
        return 5 + MetaManager.get_intelligence_bonus()
    var base: int = 5
    if selected_character.has_method("get_intelligence_at_level"):
        base = selected_character.get_intelligence_at_level(player_level)
    else:
        base = int(5 * character_intelligence_mult)
    return base + MetaManager.get_intelligence_bonus()
```

### 5. Apply Leadership Bonus
**File:** `scripts/game/game_controller.gd`

Leadership uses the old multiplier system, so apply bonus when setting leadership:

```gdscript
func _apply_character_to_spawner(character: Resource) -> void:
    # ... existing code ...
    if baby_ball_spawner:
        # Add leadership bonus from meta buildings
        var lead_bonus: float = MetaManager.get_leadership_bonus() if MetaManager else 0
        baby_ball_spawner.set_leadership(GameManager.leadership + lead_bonus)
```

### 6. Update Save/Load
Bonuses use `unlocked_upgrades` dictionary - should work automatically.

### 7. Write Tests
**File:** `tests/test_stat_buildings.py` (new)

- Each building appears in shop
- Purchasing increases stat
- Stat bonus applies correctly
- Max level (5) enforced
- Leadership bonus increases baby balls

## Pricing

| Level | Cost | Total Invested |
|-------|------|----------------|
| 1 | 150 | 150 |
| 2 | 300 | 450 |
| 3 | 600 | 1,050 |
| 4 | 1,200 | 2,250 |
| 5 | 2,400 | 4,650 |

**Total to max one building:** 4,650 coins
**Total to max all four:** 18,600 coins

## Acceptance Criteria

- [ ] All 4 buildings appear in meta shop
- [ ] Buildings use BallxPit names (Barracks/Gunsmith/Schoolhouse/Consulate)
- [ ] Each provides +1 flat stat per level
- [ ] Max level is 5 (+5 total)
- [ ] Strength bonus increases ball damage
- [ ] Dexterity bonus increases crit chance and fire rate
- [ ] Intelligence bonus increases status effect duration/damage
- [ ] Leadership bonus increases baby ball count and damage
- [ ] Bonuses persist after game restart
- [ ] Tests pass

## Related Tasks

- Depends on: GoPit-research-stat-building-integration.md (completed)
