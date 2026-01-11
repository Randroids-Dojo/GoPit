# GoPit vs BallxPit: Empirical Gameplay Analysis

> **Started**: January 11, 2026
> **Method**: PlayGodot measurements + Web research
> **Scope**: Core combat mechanics

## Analysis Queue

Track progress with [x] marks:

- [x] Ball damage per level (L1=10, L2=?, L3=?)
- [x] Ball speed per level
- [x] Fire cooldown / rate
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

---

### 2. Ball Speed Per Level
**Iteration**: 2 | **Date**: 2026-01-11

#### BallxPit (Web Research)

**Sources**:
- [Steam Discussion: How do stats work?](https://steamcommunity.com/app/2062430/discussions/0/687489618510307449/)
- [Steam Discussion: Speed scaling](https://steamcommunity.com/app/2062430/discussions/0/624436409752945056/)

**Key Findings**:
- Ball speed is a **multiplier** to a base "normal" speed (arbitrary developer-defined)
- Different ball types have different speeds based on traits:
  - Heavy lead ball moves **slower** but deals 2x damage
  - Other balls have fire/ice/poison/electric effects with standard speed
- Speed unit is "possibly tiles per second"
- Fire rate (balls per second) is separate from ball movement speed
- Game speed settings also affect overall projectile speed

**No explicit numeric values documented** - speed system appears to be relative/multiplier-based.

#### GoPit (PlayGodot Measurement)

**Test**: `tests/analysis/test_ball_speed.py`

**Base Speed by Ball Type** (pixels/second):
| Ball Type | Base Speed | Class |
|-----------|------------|-------|
| BASIC | 800 | Standard |
| BURN | 800 | Standard |
| FREEZE | 800 | Standard |
| POISON | 800 | Standard |
| BLEED | 800 | Standard |
| LIGHTNING | 900 | Fast (+12.5%) |
| IRON | 600 | Slow (-25%) |

**Speed with Level Multipliers**:
| Ball Type | L1 | L2 | L3 |
|-----------|-----|------|------|
| BASIC | 800 | 1200 | 1600 |
| BURN | 800 | 1200 | 1600 |
| FREEZE | 800 | 1200 | 1600 |
| POISON | 800 | 1200 | 1600 |
| BLEED | 800 | 1200 | 1600 |
| LIGHTNING | 900 | 1350 | 1800 |
| IRON | 600 | 900 | 1200 |

**Design Philosophy**:
- Most balls share standard 800 px/s base
- Lightning: 12.5% faster (hit & run playstyle)
- Iron: 25% slower (high damage trade-off)

#### Comparison

| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Speed System | Multiplier-based | Fixed px/s values | Both use relative approach |
| Heavy Ball | Slower, 2x damage | 25% slower (-200 px/s) | **Aligned** |
| Speed Variance | Traits determine speed | 2 variants (fast/slow) | GoPit simpler |
| Level Scaling | Unknown | L2=1.5x, L3=2.0x | Same as damage |

#### Alignment Recommendation

**Priority**: P3 (Low)

**Current Difference**: GoPit uses explicit pixel-per-second values while BallxPit uses multiplier-based relative speeds. Both implement the same concept (heavy = slow, some = fast).

**Options**:
1. **Keep current** - Clear, consistent, works well
2. **Add more speed variants** - Could add "fast" effect balls like Haste

**Recommendation**: Keep current system. The Iron ball's 25% slower speed with high damage mirrors BallxPit's heavy ball concept. Lightning as the "fast" ball provides variety. Consider adding more speed variants when introducing new ball types.

---

### 3. Fire Cooldown / Rate
**Iteration**: 3 | **Date**: 2026-01-11

#### BallxPit (Web Research)

**Sources**:
- [Steam Discussion: What does fire rate do?](https://steamcommunity.com/app/2062430/discussions/0/624436409752895957/)
- [Steam Discussion: Does anything reduce cooldown on balls?](https://steamcommunity.com/app/2062430/discussions/0/595162996671518864/)
- [Steam Discussion: Attack speed](https://steamcommunity.com/app/2062430/discussions/0/624436409752955709/)

**Key Findings**:
- Fire rate = how many balls you can "dump out per second from the queue"
- Fire rate is a **multiplier** to arbitrary base (same as other stats)
- **2x fire rate passive** creates highest potential DPS in the game
- Some balls have specific cooldowns (Dark ball: 3 second cooldown)
- Fire rate most useful when balls return quickly (short range focus firing)
- Stats: HP, damage, baby balls, ball speed, move speed, crit %, fire rate, AoE, status power, passive power

**Cooldown Reduction**:
- Cooldown reduction items exist
- Attack speed stat reduces ball shooting cooldown

#### GoPit (PlayGodot Measurement)

**Test**: `tests/analysis/test_fire_cooldown.py`

**Base Values**:
- Base Cooldown: **0.5 seconds**
- Base Fire Rate: **2.0 balls/second**
- All equipped balls fire simultaneously

**Fire Rate with Character Speed Modifier**:
| Speed Mult | Cooldown | Fire Rate |
|------------|----------|-----------|
| 1.0x | 0.50s | 2.0 balls/s |
| 1.25x | 0.40s | 2.5 balls/s |
| 1.5x | 0.33s | 3.0 balls/s |
| 2.0x | 0.25s | 4.0 balls/s |

**Permanent Upgrade: Rapid Fire**:
- Effect: -0.1s cooldown per level
- Max Levels: 5
- Cost: 200 Pit Coins (doubles per level)

| Level | Cooldown | Fire Rate |
|-------|----------|-----------|
| 0 | 0.5s | 2.0 balls/s |
| 1 | 0.4s | 2.5 balls/s |
| 2 | 0.3s | 3.3 balls/s |
| 3 | 0.2s | 5.0 balls/s |
| 4 | 0.1s | 10.0 balls/s |
| 5 | 0.1s | 10.0 balls/s (capped) |

**Features**:
- Autofire toggle (auto-fires when ready)
- Cooldown shared across all ball slots
- Character passives modify speed mult

#### Comparison

| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Fire Rate System | Multiplier-based | Fixed cooldown (0.5s) | Similar result |
| Max Upgrade | 2x fire rate passive | 10 balls/s (0.1s cap) | GoPit has ceiling |
| Special Cooldowns | Some balls (Dark: 3s) | None (uniform) | GoPit simpler |
| Multi-Ball | Balls queue, fire in sequence | All slots fire simultaneously | **Different!** |

#### Alignment Recommendation

**Priority**: P2 (Medium)

**Key Difference**: GoPit fires all equipped balls simultaneously, while BallxPit queues balls and fires them in sequence. This is a fundamental mechanic difference.

**Options**:
1. **Keep current** - Simultaneous fire is satisfying, simpler to understand
2. **Add ball-specific cooldowns** - Could differentiate balls more (Dark = slower but powerful)
3. **Align to BallxPit** - Add ball queue system (significant rework)

**Recommendation**: Keep simultaneous fire system - it's more visceral and fun. Consider adding ball-specific cooldown modifiers for future special balls (similar to Dark ball's 3s cooldown in BallxPit).
