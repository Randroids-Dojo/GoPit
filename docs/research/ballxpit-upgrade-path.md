# BallxPit First Level Upgrade Path Research

## Research Goal
Understand XP curve, level-up options, and power progression in BallxPit's first 5 minutes.

## BallxPit Upgrade Systems (From Research)

### XP System
- **1 XP = 1 Kill** (base rate)
- XP crystals drop from enemies and must be collected
- Missing XP = lost progression (5 missed × 20 waves = 100 XP lost)
- Veteran's Hut building provides XP bonus

### Level-Up Rewards
Each level grants:
1. **3 random upgrade options** to choose from
2. **Permanent stat bonuses** for 2-3 stats
3. All characters share the same XP scale

### Three Upgrade Categories
1. **Ball Evolutions** (43 total) - Fuse two balls for new type
2. **Passive Evolutions** (8 total) - Permanent stat bonuses
3. **Buildings** (70+) - Meta-progression between runs

### First Level Focus
- Focus on getting **more special balls first**
- Then **evolutions**
- Then **passives**
- Simple progression - not overwhelming

## GoPit Current Implementation

### XP Curve
```gdscript
# game_manager.gd line 891
func _calculate_xp_requirement(level: int) -> int:
    # Level 1: 10 kills, Level 2: 15 kills, etc.
    return 10 + (level - 1) * 5
```

| Level | XP Needed | Total Kills |
|-------|-----------|-------------|
| 1 | 10 | 10 |
| 2 | 15 | 25 |
| 3 | 20 | 45 |
| 4 | 25 | 70 |
| 5 | 30 | 100 |

### Level-Up Card Types
```gdscript
enum CardType {
    PASSIVE,        # Stat upgrades (damage, speed, etc.)
    NEW_BALL,       # Acquire new ball type
    LEVEL_UP_BALL,  # Level up owned ball (L1→L2→L3)
    FISSION,        # Random upgrades
    HEAL,           # One-time heal (+30 HP)
    TIER_UPGRADE    # Upgrade evolved ball tier
}
```

### Upgrade Options
GoPit offers these upgrade choices:
- **Power Up**: +5% damage (max 10 stacks)
- **Quick Fire**: +10% fire rate (max 5 stacks)
- **Vitality**: +25 max HP (max 10 stacks)
- **Multi Shot**: +1 ball per fire (max 3 stacks)
- **Piercing**: +1 pierce (max 3 stacks)
- **Ricochet**: +5 max bounces (max 4 stacks)
- **Critical**: +10% crit chance (max 5 stacks)
- **Magnetism**: +200 gem range (max 3 stacks)
- **Heal**: +30 HP (unlimited)

## Gap Analysis

### First 5 Minutes Progression
| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Level-ups in 5 min | ~2-3 | ~2-3 | Similar pace |
| XP curve | Unknown exact | 10+5n | May need tuning |
| Options per level | 3 | 3 | Match |
| First upgrades | New balls | Mixed | GoPit more varied |

### Key Differences
1. **BallxPit prioritizes ball variety early** - Get new balls first
2. **GoPit offers too many options early** - Can be overwhelming
3. **BallxPit has simpler passives early** - Complex ones come later

## Recommendations for Experiment Mode

### Simplified First-Level Upgrade Path
```gdscript
var exp_upgrade_settings := {
    # Slower XP curve (more time between level-ups)
    "xp_base": 15,        # 15 kills for level 1 (was 10)
    "xp_increment": 8,    # +8 per level (was 5)

    # Limited upgrade options
    "max_card_types": 2,  # Only PASSIVE and HEAL
    "available_passives": [
        "Power Up",
        "Vitality",
        "Magnetism"
    ],
    # No ball evolutions or complex options
}
```

### First 5 Minutes Progression Target

| Time | Kills | Level | Upgrade Unlocked |
|------|-------|-------|------------------|
| 0:00 | 0 | 1 | - |
| 1:00 | 15 | 2 | First upgrade |
| 2:30 | 38 | 3 | Second upgrade |
| 4:30 | 70 | 4 | Third upgrade |

### Upgrade Card Priorities for First Level
1. **Power Up** - Simple damage increase
2. **Vitality** - Survivability
3. **Magnetism** - QoL improvement
4. **Heal** - Emergency option

### What to EXCLUDE in Experiment Mode
- Ball evolutions (too complex)
- Fission upgrades (confusing)
- Multi-shot/Pierce (changes core mechanic)
- Complex passives

## Testing Metrics

To validate progression matches BallxPit:
1. **Time to first level-up**: ~60-90 seconds
2. **Upgrade feel**: Should feel impactful but not game-changing
3. **Decision difficulty**: Should be easy choice, not analysis paralysis
4. **Power curve**: Gradual increase, not explosive growth

## Sources

- [Ball x Pit Wiki - Character Level Mechanics](https://ballxpit.wiki.gg/wiki/Character_Level_Mechanics)
- [Ball x Pit Upgrades Guide](https://ballxpit.org/guides/upgrades/)
- [Steam: XP and Experience Discussion](https://steamcommunity.com/app/2062430/discussions/0/624436409753060847/)
- [Ball x Pit Beginner Tips](https://steamcommunity.com/sharedfiles/filedetails/?id=3635216044)
- [Ball x Pit Tips & Tricks](https://ballxpit.org/guides/tips-tricks/)
- GoPit Codebase Analysis (scripts/autoload/game_manager.gd, scripts/ui/level_up_overlay.gd)
