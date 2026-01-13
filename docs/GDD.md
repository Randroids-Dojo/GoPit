# GoPit - Game Design Document

> **Version**: 1.0.0 (BallxPit Aligned)
> **Platform**: Mobile (iOS/Android), Web, Desktop
> **Engine**: Godot 4.x

---

## 1. Game Overview

### Concept
**GoPit** is a roguelike action game inspired by [Ball x Pit](https://www.ballxpit.com/) by Kenny Sun. Players control a character who fires balls upward into a pit of descending enemies. Defeat enemies, gain XP, level up, evolve balls through fusion, and survive increasingly challenging waves across multiple stages.

### Tagline
*"Bounce. Evolve. Survive the Pit."*

### Core Loop
```
Fire Balls → Defeat Enemies → Gain XP → Level Up → Upgrade/Evolve → Repeat
                                    ↓
                        Boss Fight (waves 10, 20, 30)
                                    ↓
                           Stage Complete → Next Stage
                                    ↓
                    Beat All 8 Stages at Speed 10 → Mastery!
```

---

## 2. Character System

### 2.1 Character Stats

Every character has four core stats:

| Stat | Abbrev | Effect |
|------|--------|--------|
| **Strength** | STR | Base ball damage. All balls deal damage based on character STR. |
| **Dexterity** | DEX | Critical hit chance and fire rate (queue drain speed). |
| **Intelligence** | INT | Status effect duration and damage. |
| **Leadership** | LEAD | Baby ball spawn count and damage multiplier. |

### 2.2 Stat Scaling Grades

Each stat has a scaling grade (S/A/B/C/D/E) determining growth on level-up:

| Grade | Growth per Level |
|-------|------------------|
| S | +3 |
| A | +2.5 |
| B | +2 |
| C | +1.5 |
| D | +1 |
| E | +0.5 |

### 2.3 Character Roster

| Character | STR | DEX | INT | LEAD | Passive | Playstyle |
|-----------|-----|-----|-----|------|---------|-----------|
| **Rookie** | 7 (C) | 5 (C) | 5 (C) | 5 (C) | Quick Learner (+10% XP) | Balanced beginner |
| **Warrior** | 10 (A) | 4 (D) | 3 (E) | 5 (C) | Berserker (+20% dmg <50% HP) | High damage |
| **Repentant** | 6 (C) | 7 (B) | 5 (C) | 4 (D) | Bounce Master (+5% dmg/bounce) | Diagonal shots |
| **Shade** | 5 (D) | 9 (A) | 4 (D) | 3 (E) | Execute (<20% HP crit = kill) | Assassin |
| **Pyromancer** | 5 (D) | 4 (D) | 10 (A) | 4 (D) | Inferno (+30% burn damage) | DoT specialist |
| **Broodmother** | 4 (E) | 3 (E) | 4 (D) | 12 (S) | Swarm Lord (+50% baby dmg) | Baby ball army |
| **Empty Nester** | 8 (B) | 8 (B) | 6 (C) | 0 (-) | No babies, 2x specials | Pure DPS |
| **Collector** | 5 (C) | 5 (C) | 5 (C) | 5 (C) | Built-in max magnet | QoL focused |
| **Gambler** | 6 (C) | 6 (B) | 6 (C) | 6 (C) | Jackpot (3x crit damage) | High variance |
| **Vampire** | 6 (C) | 5 (C) | 8 (B) | 4 (D) | Lifesteal (heal on bleed) | Sustain |

### 2.4 Character Completion Tracking

- Each character tracks completion per stage per speed level
- Matrix: Character × Stage × Speed Level (1-10)
- Unlock next speed level by beating previous
- UI shows which characters haven't completed each stage/speed

---

## 3. Ball System

### 3.1 Ball Damage

**Damage Formula:**
```
Base Damage = Character STR × Level Multiplier × Bounce Bonus × Crit Multiplier
```

| Level | Multiplier |
|-------|------------|
| L1 | 1.0x |
| L2 | 1.5x |
| L3 | 2.0x |

**Bounce Damage Scaling:**
- Characters with bounce passive: +5% damage per bounce
- Max bounces: 30 (allows diagonal shot strategy)
- Diagonal shots = 20-30 bounces = up to 2.5x damage

### 3.2 Ball Speed

**Speed Formula:**
```
Final Speed = BASE_SPEED (800) × Type Multiplier × Level Multiplier
```

| Ball Type | Speed Mult | Notes |
|-----------|------------|-------|
| Standard | 1.0x | Basic, Burn, Freeze, Poison, Bleed |
| Lightning | 1.125x | Fast |
| Iron | 0.75x | Slow but high knockback |
| Dark | 1.0x | Self-destructs on hit |

### 3.3 Ball Types & Effects

| Ball | Effect | Visual |
|------|--------|--------|
| **Basic** | None | Blue |
| **Burn** | Burn DoT (5 DPS, 3s) | Orange/fire |
| **Freeze** | 50% slow + 25% damage amp | Cyan/ice |
| **Poison** | Poison DoT (3 DPS, 5s) | Green |
| **Bleed** | Permanent stacking DoT | Dark red |
| **Lightning** | Chain to nearby enemies | Electric yellow |
| **Iron** | High knockback | Metallic gray |
| **Dark** | 3x damage, self-destructs | Dark purple |
| **Radiation** | +10% damage amp/stack | Glowing green |
| **Frostburn** | Slow + damage amp + DoT | Blue-white |

### 3.4 Ball Queue System

Balls fire through a queue system:

1. **Fire Button**: Adds all equipped balls to queue
2. **Queue Drain**: Fire rate (DEX-based) determines balls/second
3. **Queue Max**: 20 balls (prevents infinite stacking)
4. **Ball Cooldowns**: Some balls have per-type cooldowns (Dark: 0.5s)

**Queue Visualization**: UI shows queue depth and next ball to fire.

### 3.5 Baby Balls

- Spawn automatically based on Leadership stat
- Enter the firing queue (can flood it at high LEAD)
- Damage: 30% + (LEAD × 10%) of parent damage
- Count: 1 + floor(LEAD / 3) per spawn cycle
- Empty Nester: No baby balls, fires 2x special balls instead

### 3.6 Ball Leveling & Fusion

```
L1 (Base) → L2 (+50%) → L3 (+100%, fusion-ready)
                              ↓
                    Fusion Reactor Drop
                              ↓
                    Combine two L3 balls
                              ↓
                        Evolved Ball
```

---

## 4. Combat Mechanics

### 4.1 Critical Hits

- **Base Crit Chance**: 0% + DEX contribution + upgrades
- **Default Crit Damage**: 2.0x
- **Jackpot Passive**: 3.0x crit damage
- **Execute**: Crit on enemy <20% HP = instant kill (Shade passive)

### 4.2 Status Effects

| Effect | Duration | DPS | Max Stacks | Special |
|--------|----------|-----|------------|---------|
| **Burn** | 3s × INT | 5.0 | 5 | Refreshes on reapply |
| **Freeze** | 2s × INT | 0 | 4 | 50% slow, +25% damage taken |
| **Poison** | 5s × INT | 3.0 | 8 | Longer duration |
| **Bleed** | Permanent | 2.0/stack | 24 | Hemorrhage at 12+ |
| **Radiation** | 6s × INT | 0 | 5 | +10% damage amp/stack |
| **Frostburn** | 4s × INT | 1.5 | 4 | Slow + 25% amp |

**Hemorrhage Mechanic:**
- At 12+ Bleed stacks, triggers Hemorrhage
- Deals 20% of enemy's current HP as burst damage
- Resets Bleed stacks to 0

### 4.3 Damage Amplification

| Source | Amp | Stacks |
|--------|-----|--------|
| Freeze effect | +25% per stack | Up to +100% |
| Radiation | +10% per stack | Up to +50% |
| Frostburn | +25% per stack | Up to +100% |
| Shatter passive | +50% vs frozen | Flat bonus |

---

## 5. Enemy System

### 5.1 Enemy Types

| Enemy | Base HP | Speed | XP | Behavior |
|-------|---------|-------|-----|----------|
| **Slime** | 10 | 1.0x | 1 | Straight descent |
| **Bat** | 10 | 1.3x | 1 | Zigzag pattern |
| **Crab** | 15 | 0.6x | 1 | Side-to-side, tanky |
| **Golem** | 30 | 0.4x | 2 | Very tanky, armored |
| **Swarm** | 5 | 1.2x | 1 | Groups of 3-5 |
| **Archer** | 15 | 0.8x | 2 | Fires projectiles |
| **Bomber** | 20 | 1.0x | 2 | Explodes near player |

### 5.2 Enemy Scaling

**Per-Wave Scaling:**
- HP: +10% per wave (linear, no cap)
- Speed: +5% per wave (capped at 2x at wave 21)
- XP: +5% per wave (linear, no cap)

**Per-Speed-Level Scaling:**
- Compound 1.5x per speed level
- Speed 1: 1.0x | Speed 5: ~5x | Speed 10: ~38x
- Higher speeds = more XP reward (+15% per level)

---

## 6. Boss System

### 6.1 Boss Structure

Each stage has bosses at waves 10, 20, and 30:
- **Wave 10**: Mini-boss (500 HP base)
- **Wave 20**: Stage boss (750 HP base)
- **Wave 30**: Final boss (1000 HP base)

### 6.2 Boss Mechanics

**Phase System:**
- 3 phases: 100-66%, 66-33%, 33-0%
- New attacks unlock each phase
- Invulnerable during phase transitions (1.5s)

**Weak Points:**
- Each boss has a weak point hitbox
- Weak point hits deal 2x damage
- Requires precise aiming (skill expression)
- Example: Slime King's crown

**Auto-Magnet:**
- Magnetism range maxed during boss fights
- Gems auto-attract so player focuses on combat

### 6.3 Boss Roster

| Boss | Stage | HP | Weak Point | Signature Attack |
|------|-------|-----|------------|------------------|
| **Slime King** | 1 | 500 | Crown | Slam, summon, split |
| **Frost Wyrm** | 2 | 750 | Tail tip | Ice breath, tail swipe |
| **Sand Golem** | 3 | 1000 | Core gem | Ground pound, burrow |
| **Void Lord** | 4 | 1200 | Eye | Laser sweep, portals |

---

## 7. Progression System

### 7.1 XP & Leveling

**XP System:**
- 1 XP = 1 Kill (base)
- Modified by: combo multiplier, XP bonuses, difficulty bonus

**Level-Up Curve:**
```
XP Required = 10 + (level - 1) × 5
```

| Level | XP | Kills |
|-------|-----|-------|
| 1 | 10 | ~10 |
| 2 | 15 | ~15 |
| 5 | 30 | ~30 |
| 10 | 55 | ~55 |

### 7.2 Level-Up Choices

Pick 1 of 3 random options:
1. **New Ball Type** - Add to equipped slots
2. **Upgrade Ball** - L1→L2→L3
3. **Passive/Stat Upgrade** - Permanent for run

**Upgrade Types:**
| Upgrade | Effect | Max Stacks |
|---------|--------|------------|
| Power Up | +5% STR | 10 |
| Quick Fire | +10% fire rate | 5 |
| Vitality | +25 max HP | 10 |
| Multi Shot | +1 ball per fire | 3 |
| Piercing | +1 pierce | 3 |
| Ricochet | +5 max bounces | 4 |
| Critical | +10% crit chance | 5 |
| Magnetism | +200 gem range | 3 |
| Heal | Restore 30 HP | ∞ |

### 7.3 Stage & Speed Progression

**8 Stages**, each with **10 Speed Levels**:

```
Stage 1 (Forest)
├── Speed 1 (Normal) - Always unlocked
├── Speed 2 (Fast) - Beat Speed 1
├── Speed 3 (Fast+) - Beat Speed 2
├── ...
└── Speed 10 (Fast+8) - Beat Speed 9

Stage 2 (Caves)
├── Unlocked by beating Stage 1 Speed 1
└── Same 10 speed levels
```

**Speed Level Effects:**
| Level | Name | HP Mult | Spawn Rate | XP Bonus |
|-------|------|---------|------------|----------|
| 1 | Normal | 1.0x | 1.0x | +0% |
| 2 | Fast | 1.5x | 1.2x | +15% |
| 3 | Fast+ | 2.25x | 1.4x | +30% |
| 5 | Fast+3 | 5.1x | 1.8x | +60% |
| 10 | Fast+8 | 38.4x | 2.8x | +135% |

### 7.4 Meta-Progression Buildings

| Building | Effect | Max Level |
|----------|--------|-----------|
| Veteran's Hut | +5% XP per level | 5 (+25%) |
| Armory | +2% starting STR | 5 (+10%) |
| Dojo | +2% starting DEX | 5 (+10%) |
| Library | +2% starting INT | 5 (+10%) |
| Barracks | +2% starting LEAD | 5 (+10%) |

---

## 8. Controls & UI

### 8.1 Mobile Controls

```
┌─────────────────────────────────────┐
│ Wave 5/30  [||]   HP ████████░░     │
│ Lv.3  XP ██████░░   Queue: ■■■□□    │
├─────────────────────────────────────┤
│                                     │
│           [GAME AREA]               │
│                                     │
│      Player moves freely            │
│      Enemies descend                │
│      Balls bounce                   │
│                                     │
├─────────────────────────────────────┤
│  ┌─────┐              [A] ┌─────┐   │
│  │ ◎   │                  │ 🔥  │   │
│  │MOVE │                  │FIRE │   │
│  └─────┘                  └─────┘   │
└─────────────────────────────────────┘
```

### 8.2 Character Select

Shows all 4 stats with scaling grades, passive description, and starting ball.

### 8.3 Stage Select

Shows 8 stages, 10 speed levels per stage, and character completion status per stage/speed.

---

## 9. Technical Specifications

### 9.1 Engine & Tools
| Component | Technology |
|-----------|------------|
| Engine | Godot 4.x |
| Testing | PlayGodot (Python) |
| CI/CD | GitHub Actions |

### 9.2 Display
- **Orientation**: Portrait (mobile-first)
- **Base Resolution**: 720 × 1280
- **Target FPS**: 60fps

---

## 10. References

- [Ball x Pit (Steam)](https://store.steampowered.com/app/2062430/BALL_x_PIT/)
- [Ball x Pit Official Site](https://www.ballxpit.com/)
- [GameFAQs Passives Guide](https://gamefaqs.gamespot.com/ps5/551362-ball-x-pit/faqs/82316)

---

*This document reflects the complete BallxPit-aligned design for GoPit.*
