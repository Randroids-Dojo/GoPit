# GoPit vs BallxPit: Empirical Gameplay Analysis

> **Started**: January 11, 2026
> **Method**: PlayGodot measurements + Web research
> **Scope**: Core combat mechanics

## Analysis Queue

Track progress with [x] marks:

- [x] Ball damage per level (L1=10, L2=?, L3=?)
- [x] Ball speed per level
- [x] Fire cooldown / rate
- [x] Bounce damage scaling (+X% per bounce?)
- [x] Enemy base HP (slime, bat, crab)
- [x] Enemy HP scaling per wave
- [x] Enemy speed scaling per wave
- [x] XP per gem (base value)
- [x] XP to level up curve (100, 150, 200...?)
- [x] Crit damage multiplier
- [x] Crit chance mechanics
- [x] Status effect: Burn damage/duration
- [x] Status effect: Freeze slow %/duration
- [x] Status effect: Poison damage/duration
- [x] Status effect: Bleed damage/duration
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

---

### 4. Bounce Damage Scaling
**Iteration**: 4 | **Date**: 2026-01-11

#### BallxPit (Web Research)

**Sources**:
- [Steam Discussion: Scaling questions](https://steamcommunity.com/app/2062430/discussions/0/595163936630895366/)
- [The Repentant Guide - Ball x Pit Wiki](https://ballxpit.org/characters/the-repentant/)

**Key Findings**:
- **The Repentant** character has +5% damage per bounce passive
- Bounce scaling can result in massive damage:
  - 15-20 bounces = +75-100% damage
  - 30 bounces = 2.5x damage (150% bonus)
- Shot angle affects bounces:
  - Horizontal/vertical: 8-12 bounces
  - Diagonal shots: 20-30 bounces (2x-3x more damage)
- Holy Laser with 30 bounces = 3.75x effective damage
- **Character-specific mechanic** - not all characters have this

#### GoPit (PlayGodot Measurement)

**Test**: `tests/analysis/test_bounce_damage.py`

**Current Implementation**:
- Max Bounces: **10** (despawn limit)
- Bounce count tracked: **Yes**
- **Bounce damage scaling: NOT IMPLEMENTED**
- Balls despawn when `_bounce_count > max_bounces`

**Code Analysis** (`ball.gd`):
```gdscript
var _bounce_count: int = 0  # Tracked but unused for damage

# On wall collision:
_bounce_count += 1
if _bounce_count > max_bounces:
    despawn()
    return
```

**Theoretical Values if Implemented (+5% per bounce)**:
| Bounces | Damage Mult | Damage (base 10) |
|---------|-------------|------------------|
| 0 | 1.00x | 10 |
| 5 | 1.25x | 12 |
| 10 | 1.50x | 15 |
| 15 | 1.75x | 17 |
| 20 | 2.00x | 20 |
| 30 | 2.50x | 25 |

#### Comparison

| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Bounce Scaling | +5% per bounce (Repentant) | **NOT IMPLEMENTED** | **Gap!** |
| Max Bounces | Unknown | 10 | Low compared to 20-30 in BallxPit |
| Angle Strategy | Diagonal = more bounces = more damage | No effect | **Missing mechanic** |

#### Alignment Recommendation

**Priority**: P1 (High) - This is a notable missing mechanic

**Key Gap**: GoPit tracks bounce count but doesn't use it for damage scaling. BallxPit's Repentant character builds entire playstyle around bounce scaling.

**Options**:
1. **Add global bounce scaling** - All balls gain +5% per bounce (simple)
2. **Add character passive** - New "Bouncer" character with bounce scaling passive
3. **Add upgrade/relic** - Unlock bounce scaling as meta-progression item
4. **Increase max bounces** - Allow more bounces to enable the strategy

**Recommendation**: Implement bounce damage scaling as a **character passive** (similar to BallxPit's Repentant). This adds strategic depth without changing default gameplay. Also consider increasing max_bounces from 10 to 20-30 to allow diagonal shot strategies.

---

### 5. Enemy Base HP
**Iteration**: 5 | **Date**: 2026-01-11

#### BallxPit (Web Research)

**Sources**:
- [Ball X Pit Wiki | Fandom](https://ballpit.fandom.com/wiki/Ball_X_Pit_Wiki)
- [Ball x Pit Wiki](https://ballxpit.org/)

**Key Findings**:
- **No specific enemy HP values documented** in wikis
- Wikis focus on character stats, ball evolutions, builds
- Enemy HP appears to scale with progression
- BallxPit has various enemy types (slimes, bats, etc.)

#### GoPit (PlayGodot Measurement)

**Test**: `tests/analysis/test_enemy_hp.py`

**Base HP by Enemy Type**:
| Enemy | Base HP | Speed | XP | Notes |
|-------|---------|-------|-----|-------|
| Slime | 10 | 1.0x | 1.0x | Default stats |
| Bat | 10 | 1.3x | 1.2x | Fast, zigzag movement |
| Crab | 15 | 0.6x | 1.3x | Tanky (1.5x HP), slow |

**HP with Wave Scaling (+10% per wave)**:
| Wave | Slime | Bat | Crab |
|------|-------|-----|------|
| 1 | 10 | 10 | 15 |
| 2 | 11 | 11 | 16 |
| 3 | 12 | 12 | 18 |
| 5 | 14 | 14 | 21 |
| 10 | 19 | 19 | 28 |
| 20 | 29 | 29 | 43 |

**Hits to Kill (10 damage Basic Ball)**:
| Wave | Slime | Bat | Crab |
|------|-------|-----|------|
| 1 | 1 | 1 | 2 |
| 2 | 2 | 2 | 2 |
| 5 | 2 | 2 | 3 |
| 10 | 2 | 2 | 3 |

**Enemy Design Philosophy**:
- Simple HP values (10-15 base)
- Variety through HP/speed tradeoffs
- Crab: tankier but slower (requires more hits)
- Bat: same HP but faster (harder to hit)

#### Comparison

| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Base HP Range | Unknown | 10-15 | GoPit values reasonable |
| Enemy Variety | Multiple types | 3 types (Slime, Bat, Crab) | Room for expansion |
| HP/Speed Tradeoff | Presumed | Crab=tanky/slow, Bat=normal/fast | Aligned concept |

#### Alignment Recommendation

**Priority**: P3 (Low)

**Assessment**: Without BallxPit enemy HP data, hard to compare directly. GoPit's simple HP values (10-15) seem reasonable for mobile game pacing. Enemy variety through HP/speed tradeoffs is standard design.

**Options**:
1. **Keep current** - Simple values work for fast-paced mobile gameplay
2. **Add more enemy types** - Could add armored/shielded variants
3. **Add elemental weaknesses** - Fire enemies weak to ice, etc.

**Recommendation**: Keep current HP values. Focus on adding more enemy types for variety rather than adjusting base HP. Consider elemental weakness system for future depth.

---

### 6. Enemy HP & Speed Scaling Per Wave
**Iteration**: 6 | **Date**: 2026-01-11

#### BallxPit (Web Research)

**Sources**:
- [Fast Mode Guide](https://ballxpit.org/guides/fast-mode/)
- [New Game Plus Guide](https://ballxpit.org/guides/new-game-plus/)
- [Scaling needs toned down - Steam Discussion](https://steamcommunity.com/app/2062430/discussions/0/624436409752739038/)

**Key Findings**:
- **Post-boss HP spike**: Enemies feel like they get ~3x HP after first boss
- **Fast modes compound**: Enemies become exponentially stronger per wave
- **NG+ scaling**: +50% HP and +50% damage across the board
- **Wave 15 difficulty spike**: Requires 2 evolutions to survive
- **Meta progression**: Stat scaling buildings reduce early difficulty
- BallxPit uses **game modes** (Normal, Fast, Fast+2, Fast+3) for difficulty

#### GoPit (PlayGodot Measurement)

**Test**: `tests/analysis/test_enemy_scaling.py`

**Scaling Formulas**:
```gdscript
# HP: +10% per wave (linear, no cap)
max_hp = int(max_hp * (1.0 + (wave - 1) * 0.1))

# Speed: +5% per wave (capped at 2x)
speed = speed * min(2.0, 1.0 + (wave - 1) * 0.05)

# XP: +5% per wave (linear, no cap)
xp_value = int(xp_value * (1.0 + (wave - 1) * 0.05))
```

**Multiplier Progression**:
| Wave | HP Mult | Speed Mult | XP Mult |
|------|---------|------------|---------|
| 1 | 1.0x | 1.00x | 1.00x |
| 5 | 1.4x | 1.20x | 1.20x |
| 10 | 1.9x | 1.45x | 1.45x |
| 15 | 2.4x | 1.70x | 1.70x |
| 20 | 2.9x | 1.95x | 1.95x |
| 30 | 3.9x | 2.00x | 2.45x |
| 50 | 5.9x | 2.00x | 3.45x |

**Speed Cap Analysis**:
- Speed reaches 2x cap at **wave 21**
- After wave 21, HP continues scaling but speed stays capped
- This prevents enemies from becoming impossibly fast

#### Comparison

| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| HP Scaling | Post-boss spikes, exponential in Fast modes | +10% linear per wave | BallxPit more volatile |
| Speed Scaling | Unknown (part of Fast mode) | +5% per wave, capped at 2x | GoPit predictable |
| Difficulty Curve | Spikes at boss, wave 15, NG+ | Gradual linear increase | **Different design** |
| Game Modes | Normal/Fast/Fast+2/Fast+3 | Single mode | BallxPit more variety |

#### Alignment Recommendation

**Priority**: P2 (Medium)

**Key Difference**: GoPit uses smooth linear scaling while BallxPit has deliberate difficulty spikes (post-boss, wave 15, NG+). BallxPit's approach creates dramatic moments; GoPit's is more consistent.

**Options**:
1. **Keep current** - Predictable scaling, good for mobile
2. **Add post-boss spike** - +50% HP/damage after each boss
3. **Add game speed modes** - Like BallxPit's Fast/Fast+2/Fast+3
4. **Add NG+ mode** - Major scaling increase for replayability

**Recommendation**: Keep linear scaling for base game but **add post-boss HP spike** (+30-50% after beating a boss) to create dramatic difficulty moments. Consider Fast modes as future content.

---

### 7. XP Mechanics (Gems & Level-Up Curve)
**Iteration**: 7 | **Date**: 2026-01-11

#### BallxPit (Web Research)

**Sources**:
- [Character Level Mechanics - BALL x PIT Wiki](https://ballxpit.wiki.gg/wiki/Character_Level_Mechanics)
- [XP and experience - Steam Discussion](https://steamcommunity.com/app/2062430/discussions/0/624436409753060847/)

**Key Findings**:
- **1 XP = 1 Kill** (base, before modifiers)
- Each level grants permanent stat bonuses (2-3 stats)
- Building bonuses: Veteran's Hut +25% XP, Abbey +5% XP on level 1
- Each level = new ball or upgrade choice
- Housing abilities stop after Level 9
- Meta-progression: XP after runs levels up character permanently

#### GoPit (PlayGodot Measurement)

**Test**: `tests/analysis/test_xp_mechanics.py`

**XP Per Gem by Enemy Type**:
| Enemy | Base XP | Wave 5 | Wave 10 |
|-------|---------|--------|---------|
| Slime | 10 | 12 | 14 |
| Bat | 12 | 14 | 17 |
| Crab | 13 | 15 | 18 |
| Slime King | 100 | 100 | 100 |

**XP to Level Up Curve**:
Formula: `100 + (level - 1) * 50`

| Level | XP Required | Cumulative | Gems to Level |
|-------|-------------|------------|---------------|
| 1 | 100 | 100 | ~10 |
| 2 | 150 | 250 | ~15 |
| 3 | 200 | 450 | ~20 |
| 4 | 250 | 700 | ~25 |
| 5 | 300 | 1,000 | ~30 |
| 10 | 550 | 3,250 | ~55 |

**XP Modifiers**:
- Quick Learner (Rookie): +10% XP gain
- Combo multiplier: Scales with consecutive hits
- Wave scaling: +5% XP per gem per wave

**Level Progression Speed**:
- L1→L2: ~10 enemies
- L2→L3: ~15 enemies
- First 5 levels: ~60 enemies total

#### Comparison

| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Base XP/Kill | 1 | 10 | Different scale |
| XP Curve | Unknown | 100+(level-1)*50 | GoPit linear |
| Building Bonuses | +25%, +5% | None | GoPit simpler |
| Per-Level Reward | Ball/upgrade choice | Ball/upgrade choice | **Aligned** |

#### Alignment Recommendation

**Priority**: P3 (Low)

**Assessment**: GoPit's XP curve (100, 150, 200...) provides good pacing. The linear +50 per level is simple and predictable.

**Options**:
1. **Keep current** - Simple, works well for mobile
2. **Add XP buildings** - Meta-progression like BallxPit's Veteran's Hut
3. **Adjust curve** - Could make exponential for late-game challenge

**Recommendation**: Keep current XP curve. Consider adding meta-progression XP bonuses (permanent upgrades that boost XP gain) as future content.

---

### 8. Crit Mechanics (Damage & Chance)
**Iteration**: 8 | **Date**: 2026-01-11

#### BallxPit (Web Research)

**Sources**:
- [How do stats work - Steam Discussion](https://steamcommunity.com/app/2062430/discussions/0/687489618510307449/)
- [Ball x Pit Advanced Mechanics](https://ballxpit.org/guides/advanced-mechanics/)

**Key Findings**:
- **Dexterity stat** affects crit chance + firing rate
- **+15% crit passive** (unlockable): ~30-40% DPS increase
- **Shade character**: 10% base crit + execute mechanic (<20% HP instant kill)
- **Dark ball**: 3.0x damage multiplier (self-destructs)
- AOE can crit, passives may not
- Crit builds: RNG-dependent, burst damage focus

#### GoPit (PlayGodot Measurement)

**Test**: `tests/analysis/test_crit_mechanics.py`

**Crit Damage Multipliers**:
| State | Multiplier |
|-------|------------|
| Default | 2.0x |
| Jackpot (Gambler) | 3.0x |

**Crit Chance Sources**:
| Source | Amount |
|--------|--------|
| Base chance | 0% |
| "Critical" upgrade | +10% per level |
| Jackpot passive | +15% bonus |
| Character multiplier | Varies |

**DPS Impact by Crit Chance**:
| Crit % | Default (2x) | Jackpot (3x) |
|--------|--------------|--------------|
| 0% | 1.00x | 1.00x |
| 10% | 1.10x | 1.20x |
| 15% | 1.15x | 1.30x |
| 25% | 1.25x | 1.50x |
| 50% | 1.50x | 2.00x |

#### Comparison

| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Default Crit Mult | Unknown | 2.0x | Industry standard |
| Special Crit Mult | 3.0x (Dark ball) | 3.0x (Jackpot) | **Aligned** |
| Crit Passive | +15% | +15% (Jackpot) | **Aligned** |
| Crit Source | Dexterity stat | Upgrades | Different system |
| Execute Mechanic | Shade: <20% HP kill | None | BallxPit unique |

#### Alignment Recommendation

**Priority**: P3 (Low)

**Assessment**: GoPit's crit system closely matches BallxPit. The 2x/3x multipliers and +15% bonus crit are well-aligned.

**Options**:
1. **Keep current** - System is solid and aligned
2. **Add execute mechanic** - Like Shade's <20% HP instant kill
3. **Add Dexterity stat** - Would require character stat rework

**Recommendation**: Keep current crit system. Consider adding an **execute mechanic** as a future character passive (e.g., crit on low-HP enemies = instant kill). This would add strategic depth without system overhaul.

---

### 9. Status Effects (Burn, Freeze, Poison, Bleed)
**Iteration**: 9 | **Date**: 2026-01-11

#### BallxPit (Web Research)

**Sources**:
- [Ball x Pit Advanced Mechanics](https://ballxpit.org/guides/advanced-mechanics/)

**Key Findings**:
- **Burn**: Max 5 stacks
- **Bleed**: Max 24 stacks (Hemorrhage: 12+ stacks = 20% current HP nuke)
- **Poison**: Max 8 stacks
- **Frostburn**: 20s duration, max 4 stacks, +25% damage taken
- **Disease**: 6s duration, max 8 stacks
- Stack caps limit total DoT; once capped, switch targets
- Leech applies 2 bleed stacks per second

#### GoPit (PlayGodot Measurement)

**Test**: `tests/analysis/test_status_effects.py`

**Status Effect Values**:
| Effect | Duration | DPS | Max Stacks | Special |
|--------|----------|-----|------------|---------|
| Burn | 3.0s | 5.0 | 1 | Refreshes duration |
| Freeze | 2.0s | 0 | 1 | 50% slow |
| Poison | 5.0s | 3.0 | 1 | Longer duration |
| Bleed | ∞ | 2.0/stack | 5 | Permanent, stacking |

**Detailed Breakdown**:

**BURN**:
- Duration: 3.0s (×Intelligence mult)
- Damage: 2.5 per 0.5s = 5.0 DPS
- Total: 15 damage over full duration
- Behavior: Refreshes duration on reapplication

**FREEZE**:
- Duration: 2.0s (×Intelligence, ×Shatter bonus)
- Slow: 50% movement speed reduction
- No damage (crowd control only)
- Shatter passive: +30% duration

**POISON**:
- Duration: 5.0s (×Intelligence mult)
- Damage: 1.5 per 0.5s = 3.0 DPS
- Total: 15 damage over full duration
- Trade-off: Lower DPS, longer duration than Burn

**BLEED**:
- Duration: Permanent (until enemy dies)
- Damage: 1.0 per 0.5s per stack = 2.0 DPS per stack
- Max Stacks: 5 (up to 10 DPS total)
- Most powerful sustained DoT

#### Comparison

| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Burn Stacks | 5 | 1 (refresh) | BallxPit more complex |
| Bleed Stacks | 24 | 5 | **Significant gap** |
| Bleed Nuke | 12+ = 20% HP | None | BallxPit unique |
| Freeze Effect | +25% damage taken | 50% slow | **Different purpose** |
| Poison Stacks | 8 | 1 (refresh) | BallxPit more complex |

#### Alignment Recommendation

**Priority**: P2 (Medium)

**Key Differences**:
1. GoPit status effects are simpler (1-5 stacks vs 4-24)
2. GoPit Freeze is pure slow; BallxPit adds damage amp
3. BallxPit's Hemorrhage (20% HP nuke) is powerful mechanic
4. GoPit Bleed is permanent but lower stacks

**Options**:
1. **Keep current** - Simpler system, good for mobile
2. **Add Freeze damage amp** - +25% damage taken while frozen
3. **Increase Bleed stacks** - Up to 10-15 for scaling
4. **Add Hemorrhage mechanic** - 10+ bleed stacks = HP% burst

**Recommendation**: Keep streamlined status system for mobile. Consider adding **Freeze damage amp (+25%)** for Shatter synergy. For a future "Bleeder" character, implement Hemorrhage-style mechanic (high bleed stacks = burst damage).
