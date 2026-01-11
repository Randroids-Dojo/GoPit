# GoPit vs BallxPit: Empirical Gameplay Analysis

> **Started**: January 11, 2026
> **Method**: PlayGodot measurements + Web research
> **Scope**: Core combat mechanics

## Analysis Queue

Track progress with [x] marks:

- [x] Ball damage per level (L1=10, L2=?, L3=?)
- [ ] Ball speed per level
- [ ] Fire cooldown / rate
- [ ] Bounce damage scaling (+X% per bounce?)
- [ ] Enemy base HP (slime, bat, crab)
- [ ] Enemy HP scaling per wave
- [ ] Enemy speed scaling per wave
- [ ] XP per gem (base value)
- [ ] XP to level up curve (100, 150, 200...?)
- [ ] Crit damage multiplier
- [ ] Crit chance mechanics
- [ ] Status effect: Burn damage/duration
- [ ] Status effect: Freeze slow %/duration
- [ ] Status effect: Poison damage/duration
- [ ] Status effect: Bleed damage/duration
- [ ] Boss HP (Slime King)
- [ ] Boss weak point damage multiplier
- [ ] Baby ball damage (% of parent)
- [ ] Baby ball spawn interval
- [ ] Magnetism range per upgrade level

---

## Findings

### 1. Ball Damage Per Level
**Iteration**: 1 | **Date**: 2026-01-11

#### BallxPit (Web Research)

**Sources**:
- [Steam Discussion: How do stats work?](https://steamcommunity.com/app/2062430/discussions/0/687489618510307449/)
- [Ball X Pit Wiki: Balls](https://ballpit.fandom.com/wiki/Balls)
- [Advanced Mechanics Guide](https://ballxpit.org/guides/advanced-mechanics/)

**Key Findings**:
- Damage is based on **character Strength stat**, not fixed ball values
- Warrior (Strength 7, scaling E) does **25-44 base damage**
- All ball types at the same level deal the **same base damage** (determined by character, not ball type)
- Ball type affects **effects** (burn, freeze, etc.) not base hit damage
- **No explicit L1/L2/L3 multipliers documented** in guides

**Evolved Ball Damage Multipliers** (documented):
| Evolution | Multiplier |
|-----------|------------|
| Dark Ball | 3.0x (self-destructs) |
| Bomb | 2.0x + AoE |
| Nuclear Bomb | 3.0x + radiation |
| Black Hole | 3.5x + pull |

#### GoPit (PlayGodot Measurement)

**Test**: `tests/analysis/test_ball_damage.py`

**Level Scaling Formula**:
- L1: 1.0x (base)
- L2: 1.5x (+50%)
- L3: 2.0x (+100%)

**Base Damage by Ball Type**:
| Ball Type | L1 | L2 | L3 |
|-----------|----|----|-----|
| BASIC | 10 | 15 | 20 |
| BURN | 8 | 12 | 16 |
| FREEZE | 6 | 9 | 12 |
| POISON | 7 | 10 | 14 |
| BLEED | 8 | 12 | 16 |
| LIGHTNING | 9 | 13 | 18 |
| IRON | 15 | 22 | 30 |

**Additional Modifiers**:
- Bounce scaling: +5% per bounce
- Crit multiplier: 2x (3x with Jackpot)
- Inferno passive: +20% fire damage
- Shatter passive: +50% vs frozen
- vs Burning: +25%
- vs Bleeding: +15%

#### Comparison

| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Damage Source | Character Strength stat | Fixed per ball type | **Different approach** |
| Level Scaling | Unknown/undocumented | L2=1.5x, L3=2.0x | GoPit has clear progression |
| Ball Type Effect | Effects only, same damage | Different base damage per type | GoPit differentiates more |
| Base Range | 25-44 (Warrior) | 6-15 (varies by type) | GoPit lower absolute values |

#### Alignment Recommendation

**Priority**: P2 (Medium)

**Current Difference**: GoPit uses fixed damage per ball type, while BallxPit derives damage from character Strength stat.

**Options**:
1. **Keep current** - Simpler system, clear progression, differentiated ball types
2. **Align to BallxPit** - Would require character stat system rework

**Recommendation**: Keep current system. The fixed-damage-per-type approach is simpler and more transparent to players. Consider adding character Strength stat as a **multiplier** rather than base, preserving ball type differentiation.
