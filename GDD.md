# GoPit - Game Design Document

> **Version**: 0.2.0 (BallxPit Alignment)
> **Last Updated**: January 2026
> **Platform**: Mobile (iOS/Android), Web, Desktop
> **Engine**: Godot 4.x (automation branch)

---

## 1. Game Overview

### Concept
**GoPit** is a roguelike action game inspired by [Ball x Pit](https://www.ballxpit.com/) by Kenny Sun. Players control a character who fires balls upward into a pit of descending enemies. Defeat enemies, collect gems, level up balls through fusion, and survive increasingly challenging waves.

### Tagline
*"Bounce. Evolve. Survive the Pit."*

### Genre
- Roguelike / Roguelite
- Action / Arcade
- Ball Physics / Breakout-style

### Reference Game
**Ball x Pit** (Devolver Digital, 2025) - 1M+ copies sold
- Arkanoid-style ball bouncing + Vampire Survivors progression
- Ball fusion/evolution system with 100+ evolutions
- Multiple playable characters with unique mechanics
- Base-building meta-game between runs

### Core Loop
```
Fire Balls → Defeat Enemies → Collect Gems → Level Up → Fuse/Evolve Balls → Repeat
                                    ↓
                        Boss Fight (every 10 waves)
                                    ↓
                           Stage Complete → Next Biome
                                    ↓
                              Final Boss → Victory!
```

---

## 2. Current State vs Target Design

### 2.1 Implementation Status

| Feature | Current GoPit | Target (BallxPit-aligned) | Status |
|---------|---------------|---------------------------|--------|
| **Player Movement** | Virtual joystick | Free movement in play area | ✅ Done |
| **Ball Firing** | Autofire toggle + manual | Toggle autofire + manual | ✅ Done |
| **Baby Balls** | BabyBallSpawner + Leadership | Auto-generated small balls | ✅ Done |
| **Ball Types** | 6 types + 15+ fusions | Status effects + Fusion system | ✅ Done |
| **Enemy Warning** | Exclamation → Shake → Attack | Exclamation → Shake → Attack | ✅ Done |
| **Gem Collection** | Walk over + magnetism | Walk over / magnetism | ✅ Done |
| **Bosses** | 8 bosses + 16 mini-bosses | 2 stage + 1 final per level | ✅ Done |
| **Biomes** | 8 themed stages | Multiple themed stages | ✅ Done |
| **Characters** | 6 unique characters | Multiple with unique abilities | ✅ Done |
| **Win Condition** | Beat final boss | Level-based (beat final boss) | ✅ Done |

---

## 3. Core Mechanics

### 3.1 Player Character

**Movement**
- Player can move freely within the play area (not just at bottom)
- Virtual joystick controls movement direction
- Movement speed affected by upgrades/character choice

**Ball Firing**
- Aim with joystick direction (shows trajectory preview)
- Fire button: tap for single shot
- **Autofire toggle**: Enable/disable automatic firing
- Fire rate affected by upgrades

**Baby Balls** (NEW)
- Player passively generates small "baby balls" over time
- Baby balls deal reduced damage but fire automatically
- "Leadership" stat affects baby ball generation rate
- Some characters specialize in baby ball builds

### 3.2 Ball System

**Ball Properties**
| Property | Description |
|----------|-------------|
| Damage | Base damage dealt on hit |
| Speed | Ball movement speed |
| Bounce | Number of wall bounces before despawn |
| Pierce | Enemies passed through before bounce |
| Effect | Status effect applied on hit |

**Status Effects** (align with BallxPit)
| Effect | Description | Visual |
|--------|-------------|--------|
| **Burn** | Damage over time (fire) | Orange particles |
| **Freeze** | Slows enemy movement | Ice crystals |
| **Poison** | DoT that spreads on death | Green bubbles |
| **Bleed** | Stacking damage, lifesteal synergy | Red drips |
| **Lightning** | Chains to nearby enemies | Electric arcs |
| **Iron** | High physical damage, knockback | Metallic shine |

**Ball Levels & Fusion**
```
Level 1 (Basic) → Level 2 (+50% stats) → Level 3 (+100% stats, fusion-ready)
                                                    ↓
                                        Find Fusion Reactor drop
                                                    ↓
                                    Combine two L3 balls → Evolved Ball
```

**Example Fusions** (based on BallxPit)
| Ball A | Ball B | Result | Effect |
|--------|--------|--------|--------|
| Burn | Iron | **Bomb** | Explosion on hit |
| Freeze | Lightning | **Blizzard** | AoE freeze + chain |
| Poison | Bleed | **Virus** | Spreading DoT |
| Burn | Poison | **Magma** | Large DoT pools |
| Bleed | (evolve) | **Vampire** | Lifesteal on hit |

### 3.3 Enemy System

**Enemy Behavior (BallxPit-aligned)**
1. Spawn above viewport
2. Descend toward player
3. When reaching attack range:
   - **Red exclamation point** appears (warning)
   - **Shake/vibrate** for ~1 second
   - **Leap/attack** toward player position
   - Deal damage on contact
4. Despawn after attack (hit or miss)

**Enemy Types**

| Enemy | HP | Speed | Damage | Behavior | XP |
|-------|-----|-------|--------|----------|-----|
| **Slime** | 20 | Slow | 5 | Straight down | 10 |
| **Bat** | 15 | Fast | 10 | Zigzag pattern | 12 |
| **Crab** | 30 | Slow | 8 | Side-to-side | 15 |
| **Golem** | 50 | V.Slow | 20 | Tank, armored | 25 |
| **Swarm** | 5 | Normal | 3 | Groups of 5 | 5 |
| **Archer** | 20 | Slow | 15 | Ranged attacks | 18 |
| **Bomber** | 25 | Normal | 25 | Explodes near player | 20 |

**Wave Scaling**
| Wave | Enemy Count | Speed Mod | HP Mod | New Types |
|------|-------------|-----------|--------|-----------|
| 1-5 | 3-5 | 1.0x | 1.0x | Slime only |
| 6-10 | 5-8 | 1.2x | 1.3x | +Bat |
| 11-15 | 8-10 | 1.3x | 1.5x | +Crab |
| 16-20 | 10-12 | 1.4x | 1.8x | +Golem, Swarm |
| 21+ | 12+ | 1.5x | 2.0x+ | All types |

### 3.4 Boss System (NEW)

**Structure per Stage**
- **Stage Boss 1**: Wave 10 - Mini-boss, introduces stage mechanic
- **Stage Boss 2**: Wave 20 - Harder, bullet-hell patterns
- **Final Boss**: Wave 30 - Screen-filling, multiple phases

**Boss Mechanics**
- Large HP pool (bullet sponge)
- Unique attack patterns
- Invulnerability phases
- Adds spawn during fight
- Telegraphed attacks (learn patterns)

**Example Bosses**
| Boss | Stage | HP | Attacks |
|------|-------|-----|---------|
| **Slime King** | Forest | 500 | Splits into smaller slimes, slam |
| **Frost Wyrm** | Ice Cavern | 750 | Ice breath, tail swipe, summons |
| **Sand Golem** | Desert | 1000 | Ground pound, rock throw, burrow |

### 3.5 Gem & XP System

**Gem Collection (BallxPit-aligned)**
- Enemies drop gems on death
- **Player must move to collect gems** (walk over them)
- Gems do NOT auto-collect at player zone wall
- **Magnetism upgrade**: Increases gem attraction range
- Gems despawn after ~10 seconds if not collected

**XP & Leveling**
- Gems grant XP based on enemy killed
- XP bar fills → Level Up triggered
- XP requirement scales: `100 + (level - 1) * 50`

**Combo System**
- Kill enemies in quick succession for combo
- Combo multiplier: 1x (1-2), 1.5x (3-4), 2x (5+)
- Taking damage resets combo

---

## 4. Progression System

### 4.1 Per-Run Progression

**Level Up Choices** (pick 1 of 3)
1. **New Ball** - Add a new ball type with unique effect
2. **Upgrade Ball** - Level up existing ball (L1→L2→L3)
3. **Passive Item** - Permanent buff for the run

**Passive Items**
| Item | Effect | Max Stacks |
|------|--------|------------|
| Power Up | +5 ball damage | 10 |
| Quick Fire | -0.1s cooldown | 4 |
| Vitality | +25 max HP | 10 |
| Multi Shot | +1 ball per shot | 3 |
| Velocity | +100 ball speed | 5 |
| Piercing | Pierce +1 enemy | 3 |
| Ricochet | +5 wall bounces | 4 |
| Critical Hit | +10% crit chance | 5 |
| Magnetism | +200 gem range | 3 |
| Heal | Restore 30 HP | ∞ |

**Special Drops**
- **Fusion Reactor**: Combine two L3 balls
- **Fission Bomb**: Drops multiple random upgrades
- **Evolution Stone**: Evolve compatible L3 ball

### 4.2 Characters (NEW)

Each character has unique starting ball, stats, and passive ability.

| Character | Starting Ball | Passive | Playstyle |
|-----------|---------------|---------|-----------|
| **Rookie** | Basic | None (balanced stats) | Beginner-friendly |
| **Pyro** | Burn | Fire balls deal +20% damage | Aggressive DoT |
| **Frost Mage** | Freeze | Frozen enemies take +50% damage | Control |
| **Tactician** | Iron | +2 baby balls | Swarm tactics |
| **Gambler** | Random | Critical hits deal 3x damage | High risk/reward |
| **Vampire** | Bleed | Lifesteal on all damage | Sustain |

**Character Stats**
| Stat | Effect |
|------|--------|
| Endurance | Max HP |
| Strength | Ball damage |
| Leadership | Baby ball generation |
| Speed | Movement velocity |
| Dexterity | Critical hit chance |
| Intelligence | Status effect duration |

### 4.3 Biomes/Stages (NEW)

Each biome has unique visual theme, hazards, and enemy variants.

| Biome | Theme | Hazards | Enemies |
|-------|-------|---------|---------|
| **The Pit** | Underground cave | Falling rocks | Slimes, Bats |
| **Frozen Depths** | Ice cavern | Slippery floors, ice spikes | Ice Slimes, Yetis |
| **Burning Sands** | Desert ruins | Quicksand, heat waves | Sand Golems, Scorpions |
| **Toxic Swamp** | Poison marsh | Poison pools, vines | Toads, Mushrooms |
| **Final Descent** | Eldritch void | Gravity shifts | All + Eldritch horrors |

---

## 5. Controls & UI

### 5.1 Control Scheme

**Mobile (Primary)**
```
┌─────────────────────────────────────┐
│                                     │
│         [GAME AREA]                 │
│     Player can move freely          │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  ┌─────┐              ┌─────┐       │
│  │ ◎   │   [AUTO]     │ 🔥  │       │
│  │MOVE │              │FIRE │       │
│  └─────┘              └─────┘       │
└─────────────────────────────────────┘
     ↑                      ↑
  Movement              Fire button
  Joystick            + Autofire toggle
```

**Desktop/Web**
- WASD / Arrow keys: Move
- Mouse aim + Left click: Fire
- Space: Toggle autofire
- ESC: Pause

### 5.2 HUD Layout

```
┌─────────────────────────────────────┐
│ Wave: 5/30  [||]   HP: ████████░░   │  ← Top bar (wave, pause, HP)
│ Lv.3  XP: ██████░░░░  Combo: x2.0   │  ← Stats bar
├─────────────────────────────────────┤
│                                     │
│                                     │
│           [GAME AREA]               │
│         Enemies descend             │
│         Player moves                │
│         Balls bounce                │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  (◎)                    [AUTO] [🔥] │  ← Controls
└─────────────────────────────────────┘
```

### 5.3 Level Up Screen

```
┌─────────────────────────────────────┐
│           LEVEL UP!                 │
│                                     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │  BURN   │ │ FREEZE  │ │MULTI-   ││
│  │  BALL   │ │  (L2)   │ │  SHOT   ││
│  │         │ │         │ │         ││
│  │ DoT dmg │ │ +50%    │ │ +1 ball ││
│  │         │ │ stats   │ │         ││
│  └─────────┘ └─────────┘ └─────────┘│
│                                     │
│        [Tap card to select]         │
└─────────────────────────────────────┘
```

---

## 6. Technical Specifications

### 6.1 Engine & Tools
| Component | Technology |
|-----------|------------|
| Engine | Godot 4.x (automation branch) |
| Unit Tests | GdUnit4 |
| E2E Tests | PlayGodot (Python) |
| Skills | Godot-Claude-Skills |

### 6.2 Display
- **Orientation**: Portrait (mobile-first)
- **Base Resolution**: 720 x 1280
- **Aspect Ratios**: Support 16:9 to 19.5:9
- **Target FPS**: 60fps

### 6.3 Collision Layers
| Layer | Name | Objects |
|-------|------|---------|
| 1 | Walls | Stage boundaries |
| 2 | Balls | Player projectiles |
| 4 | Enemies | All enemy types |
| 8 | Gems | Collectible XP gems |
| 16 | Player | Player character |

---

## 7. Development Roadmap

### Phase 1: Core Alignment ✅ COMPLETE
- [x] Player free movement (virtual joystick controls)
- [x] Autofire toggle (toggle button in HUD)
- [x] Enemy warning system (exclamation → shake → attack animation)
- [x] Gem collection via player movement (magnetism upgrade available)
- [x] Baby ball system (BabyBallSpawner, Leadership stat)

### Phase 2: Ball Evolution ✅ COMPLETE
- [x] Status effect system (Burn, Freeze, Poison, Bleed, Lightning, Iron)
- [x] Ball leveling (L1 → L2 → L3 with stat scaling)
- [x] Fusion Reactor drops (random spawn, combine L3 balls)
- [x] Ball fusion combinations (15+ fusion recipes)
- [x] Evolution stones (passive evolution system)

### Phase 3: Boss & Stages ✅ COMPLETE
- [x] Boss base class with phases (BossBase with attack patterns)
- [x] 8 stage bosses (Slime King, Frost Wyrm, Sand Golem, etc.)
- [x] Biome system (8 biomes with unique hazards)
- [x] Stage progression (The Pit → Frozen Depths → Burning Sands → etc.)
- [x] Win condition (defeat final boss)

### Phase 4: Characters ✅ COMPLETE
- [x] Character selection screen (CharacterSelect overlay)
- [x] 6 unique characters with abilities (Rookie, Pyro, Frost Mage, etc.)
- [x] Character-specific starting balls (fire, ice, bleed, etc.)
- [x] Stat system (Endurance, Strength, Leadership, Speed, Dexterity, Intelligence)

### Phase 5: Polish ✅ COMPLETE
- [x] Sound effects + music per biome (procedural audio, 8 biome music modes)
- [x] Visual juice (17 particle effects, screen shake, damage vignette)
- [x] Mobile optimization (export presets, gl_compatibility renderer)
- [x] Tutorial for new players (first-time hints system)

---

## 8. References

- [Ball x Pit (Steam)](https://store.steampowered.com/app/2062430/BALL_x_PIT/)
- [Ball x Pit (Official Site)](https://www.ballxpit.com/)
- [Ball x Pit Wikipedia](https://en.wikipedia.org/wiki/Ball_x_Pit)
- [Ball x Pit Tactics Guide](https://md-eksperiment.org/en/post/20251224-ball-x-pit-2025-pro-tactics-for-character-builds-boss-fights-and-efficient-bases)
- [HTMAG Game of Year Article](https://howtomarketagame.com/2025/12/01/ball-x-pit-my-game-of-the-year-2025/)

---

## Appendix A: Implementation Summary

**All Core Features Complete** (aligned with BallxPit):

*Movement & Controls:*
1. Player free movement via virtual joystick
2. Autofire toggle + manual firing
3. Aim line trajectory preview

*Ball System:*
1. 6 ball types with status effects (Burn, Freeze, Poison, Bleed, Lightning, Iron)
2. Ball leveling (L1 → L2 → L3)
3. 15+ fusion combinations via Fusion Reactor
4. Baby ball generation (BabyBallSpawner, Leadership stat)
5. Passive evolution system

*Combat:*
1. Enemy warning system (exclamation → shake → attack)
2. 7 enemy types (Slime, Bat, Crab, Golem, Swarm, Archer, Bomber)
3. 8 stage bosses with phases (Slime King, Frost Wyrm, Sand Golem, etc.)
4. 16 mini-bosses across biomes

*Progression:*
1. Gem collection via player movement + magnetism
2. XP/level-up system with upgrade choices
3. 8 biomes with unique themes and hazards
4. Level-based win condition (beat final boss)
5. 6 playable characters with unique stats and abilities

*Polish:*
1. Procedural audio (25+ sound types)
2. Per-biome music with crossfades
3. 17 particle effects
4. Screen shake, damage vignette
5. Tutorial hints for new players

---

*This document reflects completed Ball x Pit alignment as of January 2026.*
