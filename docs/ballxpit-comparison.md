# BallxPit vs GoPit Comparison Analysis

> **Document Version**: 2.4
> **Last Updated**: January 10, 2026
> **Status**: In Progress - Continuous Analysis (23 Appendices)
> **Related Epic**: GoPit-68o

This document provides a detailed comparison between the real **Ball x Pit** game (by Kenny Sun / Devolver Digital) and our implementation **GoPit**. The goal is to identify differences and alignment opportunities.

## Research Sources

- [Ball x Pit Tactics Guide 2025](https://md-eksperiment.org/en/post/20251224-ball-x-pit-2025-pro-tactics-for-character-builds-boss-fights-and-efficient-bases)
- [Ball x Pit Ultimate Beginner's Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-ultimate-beginners-guide/)
- [Ball x Pit Evolutions Guide](https://steelseries.com/blog/ball-x-pit-evolutions-and-guide)
- [Ball X Pit Autofire Guide](https://spot.monster/games/game-guides/ball-x-pit-autofire-guide-2/)
- [GAM3S.GG Evolution Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-evolution-guide/)
- [Dexerto - All Characters](https://www.dexerto.com/wikis/ball-x-pit/all-characters-how-to-unlock-them-2/)
- [BallxPit.org Boss Battle Guide](https://ballxpit.org/guides/boss-battle-guide/)

---

## Table of Contents

**Main Sections:**
1. [Executive Summary](#executive-summary)
2. [Ball Shooting Mechanics](#ball-shooting-mechanics)
3. [Player Movement](#player-movement)
4. [Enemy Spawning and Movement](#enemy-spawning-and-movement)
5. [Level Progression and Difficulty](#level-progression-and-difficulty)
6. [Fusion vs Fission vs Upgrade System](#fusion-vs-fission-vs-upgrade-system)
7. [Character Selection](#character-selection)
8. [Gem Collection and XP](#gem-collection-and-xp)
9. [Boss Fights](#boss-fights)
10. [Recommendations Summary](#recommendations-summary)

**Appendices:**
- A: [File Reference](#appendix-a-file-reference)
- B: [BallxPit Evolution Recipes](#appendix-b-ballxpit-evolution-recipes)
- C: [Baby Ball Mechanics](#appendix-c-baby-ball-mechanics-comparison)
- D: [Ball Bounce and Catching](#appendix-d-ball-bounce-and-catching-mechanics)
- E: [Difficulty and Pacing](#appendix-e-difficulty-and-pacing-analysis)
- F: [Character System](#appendix-f-character-system-comparison)
- G: [Meta-Progression](#appendix-g-meta-progression-comparison)
- H: [Stage/Biome System](#appendix-h-stagebiome-system-comparison)
- I: [Control and Input](#appendix-i-control-and-input-comparison)
- J: [Enemy and Boss](#appendix-j-enemy-and-boss-comparison)
- K: [Passive Upgrade System](#appendix-k-passive-upgrade-system-comparison)
- L: [Advanced Mechanics](#appendix-l-advanced-mechanics--hidden-features)
- M: [Ball Lifecycle and Catching](#appendix-m-ball-lifecycle-and-catching-mechanics-new) ⭐ NEW
- N: [Level Select and Unlock](#appendix-n-level-select-and-stage-unlock-system-new) ⭐ NEW
- O: [Run Structure](#appendix-o-run-structure---finite-vs-endless-new) ⭐ NEW
- P: [Meta Shop](#appendix-p-meta-shop-and-permanent-upgrades-new) ⭐ NEW
- Q: [Ball Types Deep Comparison](#appendix-q-ball-types-deep-comparison-new) ⭐ NEW
- R: [Evolution/Fusion Deep Comparison](#appendix-r-evolutionfusion-deep-comparison-new) ⭐ NEW
- S: [Difficulty and Speed Scaling](#appendix-s-difficulty-and-speed-scaling-new) ⭐ NEW
- T: [Enemy Placement and Patterns](#appendix-t-enemy-placement-and-patterns-new) ⭐ NEW
- U: [Input and Controls](#appendix-u-input-and-controls-comparison-new) ⭐ NEW
- V: [Achievements and Progression](#appendix-v-achievements-and-progression-system-new) ⭐ NEW
- W: [Audio and Sound Design](#appendix-w-audio-and-sound-design-new) ⭐ NEW

---

## Executive Summary

### Quick Stats Comparison

| Metric | GoPit | BallxPit | Gap |
|--------|-------|----------|-----|
| Characters | 6 | 16+ | -10 |
| Stages | 4 | 8 | -4 |
| Bosses | 1 | 8 | -7 |
| Evolution recipes | 5 | 42+ | -37 |
| Ball types | 7 | 18 | -11 |
| Status effects | 4 | 10+ | -6 |
| Passive upgrades | 11 | 51+ | -40 |
| Enemy types | 3 | 10+ | -7 |

### Current Alignment Status

| Category | Alignment | Priority | Key Gap |
|----------|-----------|----------|---------|
| Ball Mechanics | **Critical Gap** | P1 | No bounce damage (+5%/bounce) |
| Level-Up System | **Critical Gap** | P1 | No Fission card option |
| Characters | Large Gap | P2 | Stats only, no unique mechanics |
| Bosses | Large Gap | P2 | 1 boss, no weak points |
| Stages | Medium Gap | P3 | No unlock system |
| Controls | Good | Low | Missing ball catching |
| Gem/XP | Good | Low | Well aligned |

### Top 5 Critical Gaps (Must Fix)

| Priority | Gap | Bead | Impact |
|----------|-----|------|--------|
| **P1** | Bounce damage scaling (+5%/bounce) | GoPit-gdj | Changes core gameplay |
| **P1** | Fission as level-up card | GoPit-hfi | Missing upgrade path |
| **P2** | Unique character mechanics | GoPit-oyz | Characters feel same |
| **P2** | Boss weak points | GoPit-9ss | No precision play |
| **P2** | Autofire default ON | GoPit-7n5 | Different feel |

### Key Findings from Research

**Core Mechanics Differences:**

1. **Bounce Damage is CORE** - BallxPit balls gain +5% damage per bounce
   - Ricochet is a strategy, not limitation
   - The Repentant character specializes in this
   - Changes entire aiming philosophy

2. **Fission/Fusion/Evolution as Level-Up Choices**
   - BallxPit: Three card types at level-up
   - GoPit: Fission only via random drops

3. **Characters Have Unique MECHANICS**
   - The Shade fires from back of screen
   - The Cohabitants fire mirrored shots
   - GoPit: All characters fire identically

4. **Bosses Have Weak Points**
   - Skeleton King crown takes 2x damage
   - Precision targeting required
   - GoPit: Any hit does same damage

5. **Stage Unlock via Replay**
   - Complete with different characters for gears
   - Gears unlock new stages
   - Encourages multi-character play

### All Open Beads

**P1 - Critical:**
- GoPit-gdj: Add bounce damage scaling
- GoPit-hfi: Add Fission as level-up card
- GoPit-68o: EPIC - This comparison analysis

**P2 - High:**
- GoPit-oyz: Add unique firing mechanic character
- GoPit-b2k: Add boss phases and attack patterns
- GoPit-ri4: Add more evolution recipes
- GoPit-7n5: Make autofire default ON
- GoPit-9ss: Add weak point system for bosses

**P3 - Medium:**
- GoPit-nba: Expand character roster to 10+
- GoPit-clu: Add 2x fire rate character
- GoPit-a2b: Add stage unlock system
- GoPit-qxg: Add stage-specific enemies

---

## Ball Shooting Mechanics

### What GoPit Does

**Source Files:**
- `scripts/entities/ball_spawner.gd`
- `scripts/entities/ball.gd`
- `scripts/autoload/ball_registry.gd`

**Current Implementation:**
1. **Aim Direction**: Set via aim joystick (right joystick)
2. **Fire Button**: Manual fire with optional autofire toggle
3. **Ball Types**: 7 types (Basic, Burn, Freeze, Poison, Bleed, Lightning, Iron)
4. **Ball Levels**: L1 -> L2 (+50% stats) -> L3 (+100% stats, fusion-ready)
5. **Multi-shot**: Up to 3 balls per shot with spread pattern
6. **Ball Limits**: Max 30 simultaneous balls (oldest despawned first)

**Ball Stats from Registry:**
| Type | Base Damage | Base Speed | Effect |
|------|-------------|------------|--------|
| Basic | 10 | 800 | None |
| Burn | 8 | 800 | DoT fire |
| Freeze | 6 | 800 | Slow |
| Poison | 7 | 800 | DoT, spreads on death |
| Bleed | 8 | 800 | Stacking DoT |
| Lightning | 9 | 900 | Chain to 1 nearby enemy |
| Iron | 15 | 600 | Knockback |

**Key Code Patterns:**
```gdscript
# Ball spawning with registry integration (ball_spawner.gd:79-116)
func _spawn_ball(direction: Vector2) -> void:
    # Gets active ball type from BallRegistry
    # Applies damage/speed from registry + bonus upgrades
    # Sets ball_level for visual rings
```

### What BallxPit Does (Confirmed)

Based on guides and documentation research:

1. **Firing Direction**: Character position matters more than aim direction. Some characters fire from unique directions (e.g., The Shade fires from back of screen)
2. **Autofire**: Primary mode - toggle OFF with F key for precise boss aiming
3. **Ball Types**: 4 primary status effects (Freeze, Poison, Burn, Bleed)
4. **Ball Evolution**: Combine two L3 balls for either:
   - **Evolution**: New unique ball type (stronger, can combine further)
   - **Fusion**: Mixed features of both balls (simpler combination)
5. **Ball Catching**: Players can manually catch balls to reset them 2-3s faster
6. **Precision Strategy**:
   - Waves 1-5: Focus 80% dodging, 20% aiming
   - Waves 10+: Shift to 60% dodging, 40% aiming
7. **Positioning Tactics**: Aim balls into crevices for more bounces = more damage

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Ball types | 7 base types | Similar types | Yes |
| Ball levels | L1-L3 | Similar progression | Yes |
| Firing direction | Aim joystick | Movement direction? | Unclear |
| Autofire | Toggle option | Primary mode | Partial |
| Ball limit | 30 max | Unknown | Unclear |
| Status effects | 6 types | Similar | Yes |

### Recommendations

1. [ ] **Verify firing direction in BallxPit** - Watch gameplay to confirm
2. [ ] **Test autofire as default** - Consider making autofire ON by default
3. [ ] **Add more evolved ball types** - Currently 5 evolved types, may need more

---

## Player Movement

### What GoPit Does

**Source Files:**
- `scripts/entities/player.gd`
- `scripts/game/game_controller.gd:266-280`

**Current Implementation:**
1. **Movement**: Free movement via left joystick
2. **Speed**: Base 300, modified by character multiplier
3. **Bounds**: Constrained to game area (30-690 x, 280-1150 y)
4. **Aim Direction**: Last movement direction used for aim indicator

**Code Pattern:**
```gdscript
# Player movement (player.gd:28-42)
func _physics_process(_delta: float) -> void:
    var effective_speed := move_speed * GameManager.character_speed_mult
    velocity = movement_input * effective_speed
    move_and_slide()
    # Clamp to bounds...
```

### What BallxPit Does (Expected)

1. **Free Movement**: Player can move anywhere in play area
2. **Aim Direction**: Typically fires in movement direction
3. **Dodge Mechanics**: Movement is key for avoiding enemy attacks

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Free movement | Yes | Yes | Yes |
| Movement speed | 300 base | Unknown | Unclear |
| Bounds system | Yes | Yes | Yes |
| Aim = movement | Separate joysticks | Likely same | Partial |

### Recommendations

1. [ ] **Consider single-joystick mode** - Where movement = aim direction
2. [ ] **Tune movement speed** - Compare to BallxPit gameplay footage

---

## Enemy Spawning and Movement

### What GoPit Does

**Source Files:**
- `scripts/entities/enemies/enemy_spawner.gd`
- `scripts/entities/enemies/enemy_base.gd`
- `scripts/entities/enemies/slime.gd`, `bat.gd`, `crab.gd`

**Current Implementation:**

**Spawning:**
- Timer-based spawning with variance
- Spawn interval decreases per wave
- Burst spawn chance (10% base, increases with speed)
- Enemy type selection based on wave

**Enemy Types by Wave:**
| Wave | Available Enemies |
|------|-------------------|
| 1 | Slime only |
| 2-3 | Slime (70%), Bat (30%) |
| 4+ | Slime (50%), Bat (30%), Crab (20%) |

**Enemy Behavior State Machine:**
1. **DESCENDING**: Move down toward player
2. **WARNING**: Show "!" and shake when at player Y-level
3. **ATTACKING**: Lunge toward player position
4. **DEAD**: Queue free

**Attack Cycle:**
```gdscript
# enemy_base.gd attack logic
# WARNING: 1 second with exclamation mark + shake
# ATTACK: Lunge at ATTACK_SPEED (600) toward player
# Self-damage (3 HP) per attack attempt
# Snap back to pre-attack position if survive
```

**Enemy Scaling per Wave:**
- HP: +10% per wave
- Speed: +5% per wave (capped at 2x)
- XP: +5% per wave

### What BallxPit Does (Expected)

1. **Warning System**: Red exclamation + shake before attack (matches!)
2. **Attack Pattern**: Lunge toward player (matches!)
3. **Enemy Variety**: Many more enemy types per biome
4. **Scaling**: Progressive difficulty increase

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Warning before attack | Yes (1s) | Yes | Yes |
| Exclamation mark | Yes | Yes | Yes |
| Shake animation | Yes | Yes | Yes |
| Lunge attack | Yes | Yes | Yes |
| Enemy variety | 3 types + 1 boss | Many more | Partial |
| Wave scaling | HP/Speed/XP | Similar | Yes |

### Recommendations

1. [ ] **Add more enemy types** - Golem, Swarm, Archer, Bomber from GDD
2. [ ] **Verify attack timing** - Is 1 second warning duration correct?
3. [ ] **Add enemy-specific movement patterns** - Currently mostly straight down

---

## Level Progression and Difficulty

### What GoPit Does

**Source Files:**
- `scripts/autoload/stage_manager.gd`
- `scripts/autoload/game_manager.gd`
- `scripts/game/game_controller.gd:231-249`

**Current Implementation:**

**Wave System:**
- 5 enemies per wave to advance
- Spawn interval decreases by 0.1s per wave (min 0.5s)
- Music intensity increases with wave

**Stage/Biome System:**
- 4 stages: The Pit, Frozen Depths, Burning Sands, Final Descent
- Configurable waves per stage (default 10)
- Boss fight at end of each stage
- Victory after defeating all stage bosses

**XP Requirements:**
```gdscript
# XP to level up (game_manager.gd:419-420)
func _calculate_xp_requirement(level: int) -> int:
    return 100 + (level - 1) * 50
```

| Player Level | XP Required |
|--------------|-------------|
| 1 -> 2 | 100 |
| 2 -> 3 | 150 |
| 3 -> 4 | 200 |
| 4 -> 5 | 250 |

### What BallxPit Does (Expected)

1. **Biome Progression**: Multiple biomes with unique enemies/hazards
2. **Boss Fights**: 2 stage bosses + 1 final boss per stage
3. **Win Condition**: Beat final boss of last biome
4. **Difficulty Curve**: Carefully tuned for mobile engagement

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Biome system | 4 biomes | Multiple | Partial |
| Boss per biome | 1 | 2-3 | Gap |
| Win condition | Beat all bosses | Same | Yes |
| XP scaling | Linear +50 | Unknown | Unclear |

### Recommendations

1. [ ] **Add more bosses** - GDD specifies 2 stage + 1 final per biome
2. [ ] **Tune XP curve** - May need adjustment based on playtesting
3. [ ] **Add biome-specific hazards** - Currently just visual changes

---

## Fusion vs Fission vs Upgrade System

### What GoPit Does

**Source Files:**
- `scripts/autoload/fusion_registry.gd`
- `scripts/autoload/ball_registry.gd`
- `scripts/ui/level_up_overlay.gd`

**Current Implementation:**

**Ball Leveling (L1 -> L2 -> L3):**
- L2: +50% damage and speed
- L3: +100% damage and speed, fusion-ready

**Evolution (Specific Recipes):**
| Ball A | Ball B | Result | Effect |
|--------|--------|--------|--------|
| Burn | Iron | Bomb | AoE explosion |
| Freeze | Lightning | Blizzard | AoE freeze + chain |
| Poison | Bleed | Virus | Spreading DoT + lifesteal |
| Burn | Poison | Magma | Burning ground pools |
| Burn | Freeze | Void | Alternating burn/freeze |

**Generic Fusion:**
- Any two L3 balls without a recipe
- Combined stats (average + 10% bonus)
- Both effects active
- Cannot further evolve

**Fission:**
- Random 1-3 upgrades
- 60% chance level up existing, 40% new ball
- XP bonus if all maxed
- **Only triggered by Fusion Reactor drops (not level-up choice)**

**Level-Up Choices (pick 1 of 3):**
1. New ball type (from unowned)
2. Level up existing ball (L1->L2 or L2->L3)
3. Passive upgrade (11 types)

### What BallxPit Does (Confirmed)

Based on guides ([Deltia's Gaming](https://deltiasgaming.com/ball-x-pit-fission-fusion-and-evolution-guide/), [Fusion Reactor Wiki](https://ballpit.fandom.com/wiki/Fusion_Reactor)):

**Fusion Reactor Trigger:**
- Enemies sometimes drop Fusion Reactors (rainbow orb)
- Collecting one pauses game and presents 3 options

**Three Options (Fission/Fusion/Evolution):**

1. **Fission** (Always Available):
   - Upgrades **up to 5 items** (balls/passives) by one level each
   - If all maxed: grants **Gold** instead (not XP)
   - Primary early-game strategy for fast L3 farming

2. **Fusion** (Conditional - needs 2+ L3 balls):
   - Combines two L3 balls into one with both abilities
   - Simpler combination, weaker than evolution
   - Cannot fuse if pair has an evolution recipe

3. **Evolution** (Conditional - needs matching L3 recipe):
   - 42+ unique evolutions with specific recipes
   - Damage multipliers 1.5x to 4.0x
   - Evolutions can further evolve (multi-tier):
     - Nuclear Bomb = Bomb + Poison (evolved + L3)
     - Black Hole = Sun + Dark (evolved + evolved)
     - Satan = Incubus + Succubus
     - Nosferatu = Vampire Lord + Mosquito King + Spider Queen (**only 3-way**)

**Evolution Progression:**
- Base balls → L3 → Evolution → Advanced Evolution → Achievement Evolution
- Example chain: Burn L3 + Iron L3 → Bomb → Bomb L3 + Poison L3 → Nuclear Bomb

4. **In-Game Encyclopedia**: Fills in as you discover evolutions

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Ball leveling | L1-L3 | L1-L3 | ✅ Yes |
| Fusion Reactor trigger | Enemy drops | Enemy drops | ✅ Yes |
| Evolution recipes | 5 | 42+ | **❌ Gap (-37)** |
| Generic fusion | Yes | Yes (weaker than evolution) | ✅ Yes |
| Fission upgrade count | 1-3 items | **Up to 5 items** | **❌ Gap** |
| Maxed fallback | XP bonus | **Gold** bonus | ⚠️ Differs |
| Multi-tier evolution | No | Yes (evolved+evolved) | **❌ Gap** |
| 3-way fusion | No | Yes (Nosferatu only) | ⚠️ Missing |
| Damage multipliers | ~1.5x | 1.5x-4.0x | **❌ Gap** |
| In-game encyclopedia | No | Yes | **❌ Gap** |

### Critical Gaps Identified

**Gap 1: Fission Upgrade Count**
- BallxPit: Up to 5 items upgraded per Fission
- GoPit: Only 1-3 items
- **Impact**: Slower progression, less satisfying power spikes

**Gap 2: Multi-Tier Evolution System**
- BallxPit: Evolved balls can combine with other L3/evolved balls
  - Example: Bomb (evolved) + Poison L3 = Nuclear Bomb
  - Black Hole = Sun (evolved) + Dark (evolved)
- GoPit: No multi-tier evolutions, evolved balls are terminal
- **Impact**: Missing late-game depth and power fantasy

**Gap 3: Evolution Damage Multipliers**
- BallxPit: 1.5x to 4.0x damage per evolution tier
- GoPit: ~1.5x flat (from `EVOLVED_BALL_DATA`)
- **Impact**: Evolutions don't feel dramatically more powerful

**Gap 4: Evolution Recipe Count**
- BallxPit: 42+ recipes including achievement evolutions
- GoPit: Only 5 recipes
- **Impact**: Limited build variety

### Recommendations

1. [ ] **Increase Fission upgrade count** - 1-5 items (from 1-3)
2. [ ] **Add multi-tier evolution system** - Evolved + L3 = Advanced
3. [ ] **Scale evolution damage multipliers** - Tier 1: 1.5x, Tier 2: 2.5x, Tier 3: 4x
4. [ ] **Add 15+ evolution recipes** - Priority: Storm, Vampire Lord, Nuclear Bomb
5. [ ] **Add in-game encyclopedia** - Track discovered evolutions
6. [ ] **Change fission fallback to Gold** - Match BallxPit behavior

---

## Character Selection

### What GoPit Does

**Source Files:**
- `scripts/ui/character_select.gd`
- `resources/characters/*.tres`

**Current Implementation:**

**6 Characters:**
| Character | HP | DMG | SPD | CRIT | Starting Ball | Passive |
|-----------|-----|-----|-----|------|---------------|---------|
| Rookie | 1.0 | 1.0 | 1.0 | 1.0 | Basic | None |
| Pyro | 0.9 | 1.2 | 1.0 | 1.0 | Burn | Inferno (+20% fire dmg) |
| Frost Mage | 1.0 | 1.0 | 0.9 | 1.0 | Freeze | Shatter (+50% vs frozen) |
| Tactician | 1.0 | 0.9 | 1.0 | 1.0 | Iron | Squad Leader (+2 baby balls) |
| Gambler | 0.8 | 1.0 | 1.1 | 1.5 | Lightning | Jackpot (3x crits, +15% crit) |
| Vampire | 0.8 | 1.1 | 1.0 | 1.0 | Bleed | Lifesteal (5% dmg heals) |

**Character Stats affect:**
- Max HP (endurance)
- Ball damage (strength)
- Movement/ball speed (speed)
- Crit chance (dexterity)
- Baby ball rate (leadership)
- Status duration (intelligence)

**Unlock System:**
- Some characters start locked
- Unlock via achievements/progression

### What BallxPit Does (Confirmed)

Based on guides and character analysis:

1. **Multiple Characters**: Each with unique mechanics
2. **Character Unlocks**: Through gameplay achievements
3. **Unique Firing Directions**:
   - **The Shade**: All balls fire from back/top of screen (mirror mode)
   - **The Spendthrift**: Shoots all balls at once in wide arc
   - Some characters have balls that don't bounce until landing
4. **Character-Ball Synergies**:
   - The Shade + Brood Mother balls (baby balls bounce forward)
   - Frontline characters + piercing/direct-hit balls
5. **Known Characters**:
   - The Tactician: Control-focused, pairs with Blizzard
   - The Achy Finger: Rapid-fire damage
   - The Flagellant: Lifesteal-based sustain

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Character variety | 6 | Many | Partial |
| Stat differences | Yes | Yes | Yes |
| Passive abilities | 6 passives | Yes | Yes |
| Unique firing directions | No | Yes (The Shade, etc.) | **Gap** |
| Character-ball synergies | Implicit | Explicit recommended | Partial |
| Unlock system | Yes | Yes | Yes |

### Gap: Character-Specific Firing Mechanics

**BallxPit** has characters with radically different firing mechanics:
- The Shade fires from back of screen
- The Spendthrift fires all balls at once in arc
- Some characters have non-bouncing balls until landing

**GoPit** characters differ only in:
- Stat multipliers (HP, damage, speed, crit, leadership)
- Starting ball type
- Passive ability

### Recommendations

1. [ ] **Add unique firing mechanics** - At least 1-2 characters with different firing
2. [ ] **Document character-ball synergies** - Help players with builds
3. [ ] **Add more characters** - BallxPit has more variety

---

## Gem Collection and XP

### What GoPit Does

**Source Files:**
- `scripts/entities/gem.gd`
- `scripts/game/game_controller.gd:210-228`

**Current Implementation:**

**Gem Behavior:**
- Spawned on enemy death at enemy position
- Fall downward at 150 speed
- Despawn after 10 seconds or off-screen
- Collected by player touch (40 radius)

**Magnetism System:**
- Upgradeable via level-up (+200 range per stack)
- Gems attracted toward player in range
- Speed increases as gem gets closer (150 -> 400)
- Visual pull line when attracted

**Health Gems:**
- Spawned by Lifesteal passive (20% chance on kill)
- Heal 10 HP, no XP
- Pink/red color

**Combo System:**
- Kill enemies in succession for combo
- 2 second timeout between kills
- Multiplier: 1x (1-2), 1.5x (3-4), 2x (5+)
- Reset on player damage

### What BallxPit Does (Expected)

1. **Walk-to-collect**: Player must move to gems
2. **Magnetism upgrade**: Increases attraction range
3. **Combo multiplier**: Bonus XP for kill chains
4. **Gem despawn**: Limited time to collect

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Walk to collect | Yes | Yes | Yes |
| Magnetism upgrade | Yes (+200/stack) | Yes | Yes |
| Combo multiplier | Yes (up to 2x) | Yes | Yes |
| Despawn timer | 10 seconds | Unknown | Unclear |

### Recommendations

1. [ ] **Verify despawn timing** - 10s may be too long/short
2. [ ] **Tune magnetism range** - Compare to BallxPit
3. [ ] **Test combo multiplier values** - May need adjustment

---

## Boss Fights

### What GoPit Does

**Source Files:**
- `scripts/entities/enemies/boss_base.gd`
- `scripts/entities/enemies/bosses/slime_king.gd`
- `scripts/ui/boss_hp_bar.gd`

**Current Implementation:**

**Boss System:**
- Boss spawned at end of stage (waves_before_boss)
- Enemy spawning pauses during boss
- Baby ball spawning pauses during boss
- Boss HP bar shown at top of screen

**Slime King (Stage 1 Boss):**
- Only implemented boss currently
- Large HP pool (scaled by wave)
- Standard enemy attack pattern with warning

**Boss Defeat:**
- 1.5 second delay after death
- Stage complete overlay shown
- Proceed to next biome

### What BallxPit Does (Expected)

1. **Multiple Boss Types**: Unique per biome
2. **Boss Phases**: Multiple attack patterns
3. **Invulnerability Phases**: Damage immunity periods
4. **Add Spawns**: Minions during fight
5. **Telegraphed Attacks**: Clear patterns to learn

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Boss per stage | 1 | 2-3 | Gap |
| Boss HP bar | Yes | Yes | Yes |
| Multiple phases | No | Yes | Gap |
| Add spawns | No | Yes | Gap |
| Unique attacks | Basic | Complex | Gap |

### Recommendations

1. [ ] **Add boss phases** - Health-based phase transitions
2. [ ] **Add minion spawning** - Small enemies during boss
3. [ ] **Create more boss types** - Frost Wyrm, Sand Golem from GDD
4. [ ] **Add attack patterns** - Bullet-hell style patterns

---

## Recommendations Summary

### Critical Alignment Gaps (Priority 1)

These are fundamental mechanics differences that should be addressed first:

| Gap | Current GoPit | BallxPit | Recommendation | Bead |
|-----|---------------|----------|----------------|------|
| **Bounce Damage Scaling** | No scaling | +5% per bounce | Add damage per bounce | GoPit-gdj |
| **Fission in Level-Up** | Drop-only | Level-up option | Add Fission card type | GoPit-hfi |
| **Autofire Default** | Toggle (off default) | Primary mode | Make autofire default ON | GoPit-7n5 |
| **Ball Catching** | Not implemented | Instant re-fire | Consider adding | - |
| **Character Firing** | All same direction | Unique per character | Add 1-2 unique characters | GoPit-8a9 |

### NEW: Bounce Damage is Core Mechanic

**This is the biggest alignment gap discovered.**

In BallxPit, +5% damage per bounce fundamentally changes gameplay:
- Ricochet becomes a strategy, not a limitation
- Aiming at walls is often better than aiming at enemies
- The Repentant character specializes in bounce damage
- Narrow areas become tactical opportunities

In GoPit, bounces are a limitation (max 10) not an opportunity. This inverts the entire gameplay incentive.

### Content Expansion (Priority 2)

1. **Add more evolution recipes** - Currently 5, target 10-15
2. **Add more boss types** - Only Slime King implemented
3. **Add boss phases** - Health-based phase transitions
4. **Add more characters** - With unique firing mechanics

### Gameplay Tuning (Priority 3)

1. **Tune autofire behavior** - Primary mode for waves, manual for bosses
2. **Adjust difficulty curve** - Waves 1-5 easier, gradual ramp
3. **Balance character passives** - Compare to BallxPit equivalents
4. **Add biome-specific hazards** - Currently only visual changes

### Research Completed

Based on online guides, we now understand:
- [x] Autofire is primary mode (toggle off for bosses)
- [x] Fission/Fusion/Evolution are three level-up paths
- [x] Character firing directions vary significantly
- [x] Ball catching is a DPS optimization technique
- [x] Positioning matters more than precision aiming

### Research Still Needed

1. [ ] **Play BallxPit directly** - First-hand experience
2. [x] **Document all evolutions** - See Appendix B below
3. [x] **Map all characters** - See Appendix F below

---

## Appendix A: File Reference

### Core Game Files
- `scripts/game/game_controller.gd` - Main game orchestration
- `scripts/autoload/game_manager.gd` - Global state management
- `scripts/autoload/stage_manager.gd` - Biome/stage progression

### Entity Files
- `scripts/entities/ball.gd` - Ball behavior and effects
- `scripts/entities/ball_spawner.gd` - Ball spawning logic
- `scripts/entities/player.gd` - Player movement
- `scripts/entities/gem.gd` - Gem collection
- `scripts/entities/enemies/enemy_base.gd` - Base enemy behavior
- `scripts/entities/enemies/enemy_spawner.gd` - Enemy spawning

### Registry Files
- `scripts/autoload/ball_registry.gd` - Ball types and levels
- `scripts/autoload/fusion_registry.gd` - Fusion/evolution recipes

### UI Files
- `scripts/ui/level_up_overlay.gd` - Level-up card selection
- `scripts/ui/character_select.gd` - Character selection

---

## Appendix B: BallxPit Evolution Recipes

Research sources:
- [GAM3S.GG Evolution Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-evolution-guide/)
- [Dexerto Evolution List](https://www.dexerto.com/wikis/ball-x-pit/all-evolution-recipes-combinations/)
- [ballxpit.net Evolutions](https://ballxpit.net/evolutions)

### Ball Types in BallxPit (not all in GoPit)

**Base Ball Types**:
- Burn, Freeze, Poison, Bleed (we have these)
- Iron, Lightning (we have these)
- Dark, Light, Wind, Earthquake, Ghost (we DON'T have)
- Charm, Vampire, Cell, Brood Mother, Egg Sack, Laser (we DON'T have)

### Starter Evolution Recipes (Tier S/A)

| Evolution | Recipe | Effect | GoPit Has? |
|-----------|--------|--------|------------|
| **Bomb** | Burn + Iron | Explosive AoE damage | YES |
| **Sun** | Burn + Light | Blinding radiance | No (no Light) |
| **Magma** | Burn + Earthquake | Lava pools | Partial (Burn + Poison) |
| **Blizzard** | Lightning + Freeze | AoE freeze + chain | YES |
| **Frozen Flame** | Burn + Freeze | Contradictory power | YES (Void) |
| **Inferno** | Burn + Wind | Spreading fire | No (no Wind) |

### Bleed Evolution Recipes

| Evolution | Recipe | Effect | GoPit Has? |
|-----------|--------|--------|------------|
| **Vampire Lord** | Bleed + Vampire | Ultimate life drain | No (no Vampire) |
| **Hemorrhage** | Bleed + Iron | Armor-piercing bleed | No |
| **Leech** | Bleed + Brood Mother | Life-stealing | No (no Brood Mother) |
| **Berserk** | Bleed + Charm | Massive damage boost | No (no Charm) |
| **Sacrifice** | Bleed + Dark | Curse activation | No (no Dark) |

### Lightning Evolution Recipes

| Evolution | Recipe | Effect | GoPit Has? |
|-----------|--------|--------|------------|
| **Lightning Rod** | Lightning + Iron | Concentrated damage | No |
| **Flash** | Lightning + Light | Blinding speed | No (no Light) |
| **Storm** | Lightning + Wind | Chaotic weather | No (no Wind) |

### Advanced Multi-Tier Evolutions

These require evolving evolutions together:

| Evolution | Recipe | Requirement | GoPit Has? |
|-----------|--------|-------------|------------|
| **Nuclear Bomb** | Bomb + Poison | Achievement unlock | No |
| **Black Hole** | Sun + Dark | Sun evolution first | No |
| **Satan** | Incubus + Succubus | Both evolutions | No |
| **Nosferatu** | Vampire Lord + Mosquito King + Spider Queen | Three evolutions | No |

### GoPit Current Evolutions vs BallxPit

**GoPit Has (5 total):**
| GoPit Name | Recipe | BallxPit Equivalent |
|------------|--------|---------------------|
| Bomb | Burn + Iron | Bomb (exact match) |
| Blizzard | Freeze + Lightning | Blizzard (exact match) |
| Virus | Poison + Bleed | Similar to Leech/Virus |
| Magma | Burn + Poison | Different (BxP: Burn + Earthquake) |
| Void | Burn + Freeze | Similar to Frozen Flame |

**Missing Ball Types for More Evolutions:**
1. **Dark** - Needed for: Phantom, Assassin, Flicker, Sacrifice, Black Hole
2. **Light** - Needed for: Sun, Flash, Lovestruck
3. **Wind** - Needed for: Inferno, Storm, Sandstorm, Noxious
4. **Earthquake** - Needed for: Magma (proper), Glacier, Sandstorm, Swamp
5. **Ghost** - Needed for: Phantom, Wraith, Soul Sucker
6. **Vampire** - Needed for: Vampire Lord, Soul Sucker, Succubus, Mosquito King
7. **Brood Mother** - Needed for: Leech, Maggot, Mosquito King, Spider Queen
8. **Charm** - Needed for: Berserk, Incubus, Lovestruck, Succubus
9. **Cell** - Needed for: Maggot, Overgrowth, Radiation Beam, Virus
10. **Laser** - Needed for: Radiation Beam

### Evolution Expansion Priority

To add more evolutions, we should prioritize ball types that unlock multiple recipes:

| Ball Type | Evolutions Unlocked | Priority |
|-----------|---------------------|----------|
| Dark | 5+ (Phantom, Assassin, Sacrifice, etc.) | High |
| Vampire | 4+ (Vampire Lord, Nosferatu chain) | High |
| Light | 3+ (Sun, Flash, Lovestruck) | Medium |
| Wind | 4+ (Inferno, Storm, etc.) | Medium |
| Ghost | 3+ (Phantom, Wraith, Soul Sucker) | Medium |
| Earthquake | 4+ (Magma, Glacier, etc.) | Medium |
| Brood Mother | 3+ (Baby ball spawning theme) | Low |
| Charm | 3+ (Crowd control theme) | Low |

---

## Appendix C: Baby Ball Mechanics Comparison

Research sources:
- [Ball x Pit Brood Mother Guide](https://gamerblurb.com/articles/ball-x-pit-brood-mother-guide)
- [Ball x Pit Wiki - Balls](https://ballpit.fandom.com/wiki/Balls)

### BallxPit Baby Ball System

**Two Types of Baby Balls:**
1. **Personal Baby Balls** (auto-generated from Leadership)
   - Number capped by Leadership stat
   - Base 4 Leadership = 11-17 damage baby balls
   - Act like "auto attacks"

2. **Brood Mother Baby Balls** (from ball type)
   - Spawned on impact
   - Inherit traits of fused ball
   - Multiply exponentially with ball count

**Key Stats Affecting Baby Balls:**
| Stat | Effect |
|------|--------|
| Leadership | Baby ball count + damage |
| Ball Count | Multiplies spawn rates |
| Baby Ball Damage | Direct damage per ball |

**Brood Mother Evolutions:**
| Evolution | Recipe | Effect |
|-----------|--------|--------|
| Spider Queen | Brood Mother + Egg Sac | 25% chance spawn egg sac on hit |
| Mosquito King | Brood Mother + Vampire | Flying spawns that drain HP |
| Maggot | Brood Mother + Cell | Increased spawn rate + poison |

### GoPit Baby Ball System

From `baby_ball_spawner.gd`:
- **Base spawn interval**: 2.0 seconds
- **Damage multiplier**: 0.5x of main ball damage
- **Scale**: 0.6x of main ball
- **Targeting**: Aims at nearest enemy
- **Silent**: No fire sound (reduces audio spam)

**Leadership Scaling:**
```
rate = base_interval / ((1.0 + leadership_bonus * char_mult) * speed_mult)
```
- 1.0 leadership = 2x spawn rate (1.0s interval)
- Capped at minimum 0.3s interval

**Character Bonuses:**
- Squad Leader passive: +30% spawn rate
- Extra starting baby balls: +2 (from Squad Leader)

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Leadership stat | Yes | Yes | Yes |
| Baby ball count cap | No (unlimited) | Yes | Gap |
| Baby ball damage scaling | 50% fixed | Scales with Leadership | Partial |
| Brood Mother ball type | No | Yes | Gap |
| Baby balls from ball hits | No | Yes (Brood Mother) | Gap |
| Targeting | Nearest enemy | Variable | Similar |

### Gaps to Address

1. **Baby Ball Count Cap** - BallxPit caps active baby balls based on Leadership
2. **Brood Mother Ball Type** - Add a ball type that spawns babies on hit
3. **Leadership Damage Scaling** - Baby ball damage should scale with Leadership
4. **Ball Inheritance** - Brood Mother babies should inherit effects

### Recommendations

1. [ ] **Add baby ball count limit** - Cap based on Leadership stat
2. [ ] **Add Brood Mother ball type** - Spawns babies on enemy hit
3. [ ] **Scale baby damage with Leadership** - Not just spawn rate
4. [ ] **Add egg sac drop mechanic** - Like Spider Queen evolution

---

## Appendix D: Ball Bounce and Catching Mechanics

Research sources:
- [Steam Guide - Ball x Pit Beginner Tips](https://steamcommunity.com/sharedfiles/filedetails/?id=3635216044)
- [The Repentant Build Guide](https://gamepadsquire.com/blog/ball-x-pit/ball-x-pit-ultimate-guide-repentant-evolutions-strategies/)
- [Ball x Pit Tips & Tricks](https://ballxpit.org/guides/tips-tricks/)

### BallxPit Bounce Mechanics

**Bounce Damage Scaling:**
- ALL balls gain +5% damage per bounce
- This creates exponential damage for ricochet shots
- The Repentant character specializes in this mechanic

**Ball Catching:**
- Players can manually catch balls
- Catching = instant re-fire (saves 2-3 seconds)
- Shieldbearer: +100% damage to caught balls
- Active play rewards: more catches = more DPS

**Ball Return:**
- Balls return to player after hitting back wall
- Return path damages all enemies passed through
- Strategic goal: get balls behind enemies for bounce damage

**Ricochet Strategy:**
- Aim at walls, not directly at enemies
- Narrow gaps cause rapid bouncing = more damage
- Closed spaces = more bounces = more hits
- "Bounce channels" trap enemies in high-damage zones

### GoPit Bounce Mechanics

From `ball.gd`:
- **Max bounces**: 10 (default), increased via Ricochet upgrade
- **Bounce behavior**: `direction.bounce(collision.get_normal())`
- **Pierce count**: Reduces per enemy hit
- **No damage scaling per bounce**

**Current Ricochet Upgrade:**
- Level-up option: +5 wall bounces per stack
- Max stacks: 4 (total +20 bounces)
- No damage increase per bounce

**Ball Catching:** NOT IMPLEMENTED

### Critical Gaps

| Feature | GoPit | BallxPit | Impact |
|---------|-------|----------|--------|
| **Bounce damage scaling** | No | +5% per bounce | **HIGH** |
| Ball catching | No | Instant re-fire | Medium |
| Ball return path damage | No | Damages on return | Medium |
| Ricochet strategy | Bounces are passive | Core mechanic | HIGH |

### Why Bounce Damage Matters

BallxPit's +5% damage per bounce fundamentally changes gameplay:

1. **Positioning becomes strategic** - Where you aim matters more
2. **Ricochet builds viable** - The Repentant character exists for this
3. **Narrow areas are valuable** - Tactical use of level geometry
4. **Player skill expression** - Better aim = more damage

Without bounce damage scaling, GoPit treats bounces as a limitation (max 10), not an opportunity.

### Recommendations

**Priority 1 (Core Mechanic):**
1. [ ] **Add +5% damage per bounce** - Critical alignment gap
2. [ ] **Remove max bounce limit or increase dramatically** - Bounces should be rewarded

**Priority 2 (Enhanced):**
3. [ ] **Add ball catching mechanic** - Tap to catch and re-fire
4. [ ] **Add return path damage** - Balls damage enemies on way back

**Priority 3 (Character):**
5. [ ] **Add Repentant-style character** - Specializes in ricochet damage
6. [ ] **Add Shieldbearer catch bonus** - +100% damage to caught balls

---

## Appendix E: Difficulty and Pacing Analysis

### Enemy Spawn Rates (GoPit Current)

From `enemy_spawner.gd`:
- **Base interval**: 2.0 seconds
- **Variance**: ±0.5 seconds
- **Scaling**: -0.1s per wave (minimum 0.5s)
- **Burst chance**: 10% base, increases as interval decreases

| Wave | Spawn Interval | Burst Chance |
|------|----------------|--------------|
| 1 | 2.0s | 10% |
| 5 | 1.6s | 14% |
| 10 | 1.1s | 19% |
| 15 | 0.6s | 24% |
| 16+ | 0.5s (cap) | 25%+ |

### Enemies Per Wave

From `game_controller.gd`:
- **Enemies to advance wave**: 5 (constant)

### Wave Scaling (enemy_base.gd)

| Wave | HP Multiplier | Speed Multiplier | XP Multiplier |
|------|---------------|------------------|---------------|
| 1 | 1.0x | 1.0x | 1.0x |
| 5 | 1.4x | 1.2x | 1.2x |
| 10 | 1.9x | 1.45x | 1.45x |
| 15 | 2.4x | 1.7x | 1.7x |
| 20 | 2.9x | 1.95x | 1.95x |
| 21+ | 3.0x+ | 2.0x (cap) | 2.0x+ |

### BallxPit Pacing (from guides)

Recommended focus split:
- **Waves 1-5**: 80% dodging, 20% aiming (survival focused)
- **Waves 10+**: 60% dodging, 40% aiming (DPS focused)

This suggests BallxPit early waves should be relatively easy, with gradual difficulty increase.

### Potential Pacing Issues

**GoPit may be too hard early:**
- 2 second spawn with 5 kills per wave = 10s minimum per wave
- Combined with learning curve, may be punishing

**Recommendations:**
1. [ ] **Slower early spawn rate** - 3s for waves 1-5
2. [ ] **Fewer kills for early waves** - 3 enemies for wave 1-3
3. [ ] **Gentler scaling curve** - HP +5% instead of +10%

---

## Appendix F: Character System Comparison

Research sources:
- [Dexerto - All Characters](https://www.dexerto.com/wikis/ball-x-pit/all-characters-how-to-unlock-them-2/)
- [GAM3S.GG - Character Unlock Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-unlock-all-characters/)
- [GameRant - All Characters](https://gamerant.com/ball-x-pit-all-characters-stage-list-unlocks/)

### BallxPit Characters (16 Total)

| Character | Starting Ball | Special Mechanic | Unlock |
|-----------|---------------|------------------|--------|
| **The Warrior** | Bleed | Balanced starter, no special | Start |
| **The Itchy Finger** | Burn | 2x fire rate, full speed while firing | Sheriff's Office |
| **The Embedded** | Poison | Balls pierce until wall | Veteran's Hut |
| **The Repentant** | Freeze | +5% damage/bounce, return damage | Haunted House |
| **The Cohabitants** | Brood Mother | Mirrored shots (half damage) | Cozy Home |
| **The Physicist** | Light | Gravity manipulation, faster returns | Laboratory |
| **The Spendthrift** | Vampire | All balls in wide arc | Mansion |
| **The Flagellant** | Egg Sac | Chain ricochets | Monastery |
| **The Shade** | Dark | Fires from back, +10% crit | Mausoleum |
| **The Radical** | Wind | Auto-play mode | Campground |
| **The Empty Nester** | Ghost | Crowd control, sustain | Single Family Home |
| **The Shieldbearer** | Iron | Shield reflects, 2x bounce damage | Iron Fortress |
| **The Juggler** | Lightning | Throw to target area | Theater |
| **The Tactician** | Iron | Turn-based combat | Captain's HQ |
| **The Makeshift Sisyphus** | Earthquake | 4x AoE/status damage | Rocky Hill |
| **The Cogitator** | Laser | Auto-selects upgrades | Villa |

### GoPit Characters (6 Total)

| Character | Starting Ball | Passive | Stats |
|-----------|---------------|---------|-------|
| **Rookie** | Basic | +10% XP gain | All 1.0 |
| **Pyro** | Burn | +20% fire dmg, +25% vs burning | STR 1.4, END 0.8 |
| **Frost Mage** | Freeze | +50% vs frozen, +30% freeze duration | INT 1.5 |
| **Tactician** | Basic | +2 baby balls, +30% spawn rate | LEAD 1.6, STR 0.8 |
| **Gambler** | Lightning | 3x crit damage, +15% crit | DEX 1.6 |
| **Vampire** | Basic | 5% lifesteal, 20% health gem | END 1.5, locked |

### Critical Differences

| Aspect | GoPit | BallxPit | Gap Level |
|--------|-------|----------|-----------|
| **Character count** | 6 | 16+ | Large |
| **Unique mechanics** | Stat modifiers only | Completely different playstyles | **Critical** |
| **Starting balls** | 4 types used | 14+ different balls | Large |
| **Unlock system** | Wave survival | Blueprint/building | Different |

### Mechanical Depth Comparison

**BallxPit characters fundamentally change gameplay:**

1. **The Repentant** - Bounce damage specialist (+5%/bounce + return damage)
2. **The Shade** - Fires from back of screen (mirror mode)
3. **The Cohabitants** - Mirrored double shots
4. **The Shieldbearer** - Shield reflect mechanic
5. **The Tactician** - Turn-based mode (!)
6. **The Radical** - Auto-play/idle mode

**GoPit characters only modify stats:**
- All characters fire the same way
- All characters move the same way
- Differences are numeric (+X% damage, +Y% speed)
- No unique mechanics beyond passives

### Character-to-Character Mapping

| BallxPit | GoPit Equivalent | Match Quality |
|----------|------------------|---------------|
| The Warrior | Rookie | Good (both starter) |
| The Itchy Finger | - | None (2x fire rate) |
| The Repentant | Frost Mage | Poor (bounce vs freeze) |
| The Shieldbearer | - | None (shield mechanic) |
| The Shade | - | None (reverse firing) |
| The Cohabitants | Tactician | Poor (mirrors vs babies) |
| The Spendthrift | - | None (arc firing) |
| The Flagellant | Vampire | Poor (lifesteal different) |

### Priority Characters to Add

**High Priority (Unique Mechanics):**
1. **The Repentant** - Bounce damage character (pairs with GoPit-gdj)
2. **The Shade** - Back-firing character (unique gameplay)
3. **The Itchy Finger** - 2x fire rate (simple to implement)

**Medium Priority:**
4. **The Shieldbearer** - Shield/reflect mechanic
5. **The Cohabitants** - Mirrored shots

### Recommendations

1. [ ] **Add unique firing mechanics** - Not just stat modifiers
2. [ ] **Add Repentant-style character** - Bounce damage specialist
3. [ ] **Add reverse-firing character** - Like The Shade
4. [ ] **Add 2x fire rate character** - Like The Itchy Finger
5. [ ] **Expand to 10+ characters** - Match BallxPit variety
6. [ ] **Consider blueprint unlock system** - Like BallxPit

---

## Appendix G: Meta-Progression Comparison

### BallxPit Meta-Progression

**Base Building System:**
- Players build a base between runs
- Blueprints drop from bosses
- Buildings unlock characters
- Buildings provide passive bonuses

**Gear/Elevator System:**
- Complete stages with different characters = gears
- Gears upgrade elevator to unlock new stages
- Encourages replaying with multiple characters

**Permanent Upgrades:**
- Base buildings provide permanent stat boosts
- Some buildings unlock new ball types
- Others provide starting bonuses

### GoPit Meta-Progression

From `meta_manager.gd` (if exists) or `game_manager.gd`:
- Currently minimal meta-progression
- Character unlocks via achievements (e.g., "Survive wave 20")
- No base building system
- No permanent upgrade purchases

### Gap Analysis

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| Base building | No | Yes | Medium |
| Blueprint drops | No | Yes | Medium |
| Permanent upgrades | Minimal | Extensive | Medium |
| Character unlock system | Achievement | Building | Low |
| Multi-run incentives | Low | High | Medium |

### Recommendations

1. [ ] **Add meta-currency** - Earned per run based on performance
2. [ ] **Add permanent upgrades** - Starting stats, ball damage, etc.
3. [ ] **Consider base building** - Light version for mobile
4. [ ] **Multi-character incentives** - Rewards for playing different characters

---

## Appendix H: Stage/Biome System Comparison

Research sources:
- [GameRant - All Characters and Stage List](https://gamerant.com/ball-x-pit-all-characters-stage-list-unlocks/)
- [Deltia's Gaming - How to Unlock All Levels](https://deltiasgaming.com/ball-x-pit-how-to-unlock-all-levels/)

### BallxPit Stages (8 Total)

| Stage | Unlock Requirement | Gears Needed |
|-------|-------------------|--------------|
| **The Bone x Yard** | Default | 0 |
| **The Snowy x Shores** | Beat Bone Yard 2x | 2 |
| **The Liminal x Desert** | Beat Snowy Shores 2x | 2 |
| **The Fungal x Forest** | Beat earlier stages | 2 |
| **The Gory x Grasslands** | Beat earlier stages | 3 |
| **The Smoldering x Depths** | Beat earlier stages | 4 |
| **The Heavenly x Gates** | Beat earlier stages | 4 |
| **The Vast x Void** | Final stage | 5 |

**Key Mechanics:**
- Gears earned by completing stage with DIFFERENT characters
- Encourages replaying with multiple characters
- 8 unique environments with distinct themes

### GoPit Stages (4 Total)

| Stage | Background | Wall Color | Waves to Boss |
|-------|------------|------------|---------------|
| **The Pit** | Dark purple | Dark blue | 10 |
| **Frozen Depths** | Dark blue | Icy blue | 10 |
| **Burning Sands** | Orange/tan | Sandy | 10 |
| **Final Descent** | Dark | Dark | 10 |

**Current Implementation:**
- All stages unlocked from start
- No gear/unlock system
- No unique mechanics per stage (only visual)
- All stages have 10 waves to boss

### Gap Analysis

| Aspect | GoPit | BallxPit | Gap Level |
|--------|-------|----------|-----------|
| **Stage count** | 4 | 8 | Medium |
| **Unlock system** | None | Gear-based | Large |
| **Unique mechanics** | None | Per-stage hazards | Large |
| **Waves per stage** | 10 fixed | Variable | Medium |
| **Replay incentive** | None | Different characters | Large |

### Stage Feature Comparison

**BallxPit stages have:**
- Unique enemy types per biome
- Environmental hazards
- Different visual themes
- Specific bosses
- Blueprint drops

**GoPit stages have:**
- Different background color
- Different wall color
- Same enemy types
- Same mechanics
- No unique features

### Recommendations

1. [ ] **Add 4 more stages** - Match BallxPit's 8 stages
2. [ ] **Add unlock system** - Require completing with different characters
3. [ ] **Add stage-specific enemies** - Ice enemies for Frozen, fire for Burning
4. [ ] **Add environmental hazards** - Ice patches, fire vents, etc.
5. [ ] **Variable waves per stage** - Earlier stages easier (5-7 waves)

---

## Appendix I: Control and Input Comparison

### BallxPit Controls

**Desktop (KB+M):**
- Mouse to aim
- Click to fire (or autofire F key)
- WASD to move
- Ball catching: click on returning balls

**Mobile:**
- Touch to aim and fire
- Virtual joystick for movement
- Autofire toggle

### GoPit Controls

From `game_controller.gd`:
- Left joystick: Player movement
- Right joystick: Aim direction
- Fire button: Manual fire
- Auto toggle: Autofire on/off
- Ultimate button: Special ability

**Control Scheme:**
```
[Move Joystick] [Game Area] [Aim Joystick]
                [Fire] [Auto]
```

### Gap Analysis

| Feature | GoPit | BallxPit | Notes |
|---------|-------|----------|-------|
| Dual joystick | Yes | Yes (mobile) | Good |
| Autofire toggle | Yes | Yes | Good |
| Ball catching | No | Yes | Gap |
| Aim sensitivity | Fixed | Adjustable? | Unknown |

### Recommendations

1. [ ] **Add ball catching** - Tap on balls to catch and re-fire
2. [ ] **Add aim sensitivity setting** - Player preference
3. [ ] **Test control feel** - Compare responsiveness to BallxPit

---

## Appendix J: Enemy and Boss Comparison

Research sources:
- [BallxPit.org Boss Battle Guide](https://ballxpit.org/guides/boss-battle-guide/)
- [Deltia's Gaming - Skeleton King Guide](https://deltiasgaming.com/ball-x-pit-skeleton-king-boss-guide/)
- [TheGamer - All Bosses Ranked](https://www.thegamer.com/ball-x-pit-hardest-area-bosses-to-beat/)

### BallxPit Bosses (8 Total)

| Boss | Stage | Key Mechanics | Weak Point |
|------|-------|---------------|------------|
| **Skeleton King** | Bone x Yard | Arrow volleys, arm swipes | Crown/back of head (2x damage) |
| **Ice Colossus** | Snowy x Shores | Ice armor phases, shield burst | Vulnerable during non-armor |
| **Desert Titan** | Liminal x Desert | Underground dig, sandstorms | Dig emergence points |
| **Fungal Hivemind** | Fungal x Forest | Add summoning, repositioning | Add control priority |
| **Giant Blood Serpent** | Gory x Grasslands | Poison arrows, laser, adds | Add elimination first |
| **Infernal Demon** | Smoldering x Depths | Burn DoT, enrage, phases | Fire-themed hazards |
| **Celestial Guardian** | Heavenly x Gates | Flight phase, divebombs | Grounded phases only |
| **Void Sovereign** | Vast x Void | Multi-head, homing fire | Individual heads → core |

### Key Boss Mechanics in BallxPit

**Skeleton King (Stage 1):**
- Precision targeting required (crown weak point)
- 2x damage to weak spot
- Arrow volleys to dodge
- Arm loss creates attack window

**Boss Strategy Tips:**
- Pierce balls bypass armor
- Ghost/Wind effects trivialize some fights
- DoT evolutions (Magma, Virus) for tanky bosses
- Trap balls in crevices for sustained damage

### GoPit Bosses (1 Total)

**Slime King** (`slime_king.gd`):
| Stat | Value |
|------|-------|
| HP | 500 |
| XP | 100 |
| Slam Damage | 30 |
| Slam Radius | 120 |

**Phase System:**
- Phase 1 (100-66% HP): Slam, Summon
- Phase 2 (66-33% HP): Slam, Summon, Split
- Phase 3 (33-0% HP): Slam, Summon, Rage (faster attacks)

**Attacks:**
1. **Slam** - Jump to player position, AoE damage
2. **Summon** - Spawn 2-3 regular slimes
3. **Split** - Create 2 medium slimes (100 HP each)
4. **Rage** - 3 rapid slams in succession

**Mechanics:**
- Telegraph before attacks (1s default, 0.7s in Phase 3)
- Movement between attacks
- Visual phase colors (green → yellow → red)

### Gap Analysis

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Boss count** | 1 | 8 | Critical |
| **Weak points** | No | Yes (2x damage) | Large |
| **Phase complexity** | 3 phases | Multi-phase with unique attacks | Medium |
| **Boss variety** | Slime only | Unique per stage | Critical |
| **Invulnerability phases** | Brief (0.5s summon) | Full armor phases | Medium |

### What Slime King Does Well

- 3-phase system with different attacks
- Telegraph before attacks
- Visual feedback (color change per phase)
- Add spawning (minions)
- Rage mode in final phase

### What's Missing

1. **Weak Points** - No targeted damage mechanic
2. **Armor Phases** - No invulnerability windows
3. **Boss Variety** - Only 1 boss implemented
4. **Environmental Integration** - No stage-specific hazards
5. **Precision Requirement** - Any hit does same damage

### Regular Enemies Comparison

**GoPit Enemies (3 types):**
| Enemy | HP (Wave 1) | Speed | XP | Behavior |
|-------|-------------|-------|-----|----------|
| Slime | 30 | 100 | 10 | Standard movement |
| Bat | 20 | 120 | 15 | Fast, low HP |
| Crab | 50 | 60 | 20 | Slow, tanky |

**Enemy Spawning:**
- Wave 1: Slime only
- Wave 2-3: 70% Slime, 30% Bat
- Wave 4+: 50% Slime, 30% Bat, 20% Crab

**BallxPit likely has:**
- Stage-specific enemies (ice, fire, etc.)
- More enemy variety per stage
- Enemy-specific behaviors

### Recommendations

**Priority 1 (Critical):**
1. [ ] **Add more bosses** - One per stage (4 minimum)
2. [ ] **Add weak point system** - Targeted damage bonus
3. [ ] **Add stage-specific enemies** - Ice, fire, poison variants

**Priority 2 (High):**
4. [ ] **Add armor/invulnerability phases** - Strategic timing
5. [ ] **Add environmental hazards** - Stage-specific obstacles
6. [ ] **More enemy types** - 5-6 regular enemies

---

## Appendix K: Passive Upgrade System Comparison

Research sources:
- [Ball X Pit Wiki - Passives](https://ballpit.fandom.com/wiki/Passives)
- [Dexerto - All Passives](https://www.dexerto.com/wikis/ball-x-pit/all-passives/)
- [GAM3S.GG - Passive Evolution Ranked](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-passive-evolution-ranked/)

### BallxPit Passive System

**51 Base Passives** with:
- Level 1-3 for each
- Passive EVOLUTIONS (combine passives)
- Max 3 evolved passives per run

**Top Passive Evolutions:**
| Evolution | Recipe | Effect |
|-----------|--------|--------|
| **Soul Reaver** | Everflowing Goblet + Vampiric Sword | 25% lifesteal on all hits |
| **Deadeye's Cross** | All 4 elemental daggers | 60% crit chance |
| **Wings of Anointed** | Movement passives | +30% movement speed |
| **Cornucopia** | Baby Rattle + War Horn | Increased drops |

**Key Differences:**
- Passives can be EVOLVED (like balls)
- Don't need to be L3 to evolve
- Multiplicative with character stats

### GoPit Passive System

**11 Base Passives:**
| Upgrade | Effect | Max Stacks |
|---------|--------|------------|
| Power Up | +5 Ball Damage | 10 |
| Quick Fire | -0.1s Cooldown | 4 |
| Vitality | +25 Max HP | 10 |
| Multi Shot | +1 Ball per shot | 3 |
| Velocity | +100 Ball Speed | 5 |
| Piercing | Pierce +1 enemy | 3 |
| Ricochet | +5 wall bounces | 4 |
| Critical Hit | +10% crit chance | 5 |
| Magnetism | Gem attraction | 3 |
| Heal | Restore 30 HP | 99 |
| Leadership | +20% Baby Ball rate | 5 |

**No passive evolutions currently.**

### Gap Analysis

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| Base passives | 11 | 51 | Large |
| Passive evolutions | No | Yes | Large |
| Passive levels | 1 only | 1-3 | Medium |
| Evolved passive limit | N/A | 3 per run | N/A |

### Recommendations

1. [ ] **Add passive evolution system** - Combine passives for evolved effects
2. [ ] **Add more base passives** - Target 20-30 total
3. [ ] **Add passive leveling** - L1-L3 like balls
4. [ ] **Add evolved passive limit** - Strategic choice

---

## Summary: Implementation Priority

### Phase 1: Core Mechanics (P1)

These fundamentally change how the game feels:

1. **GoPit-gdj: Bounce Damage Scaling**
   - Add +5% damage per bounce
   - Remove/increase max bounce limit
   - Enables ricochet strategy

2. **GoPit-hfi: Fission as Level-Up Card**
   - Add Fission card type to level-up
   - Upgrades multiple balls to L3
   - Completes the Fission/Fusion/Evolution triad

### Phase 2: Character & Content (P2)

Add variety and depth:

3. **GoPit-oyz: Unique Firing Mechanics**
   - At least one character with different firing
   - The Shade (back-firing) or Cohabitants (mirrors)

4. **GoPit-9ss: Boss Weak Points**
   - Add weak point system (2x damage)
   - Adds precision skill expression

5. **GoPit-7n5: Autofire Default ON**
   - Match BallxPit feel
   - Manual for bosses

6. **GoPit-ri4: More Evolutions**
   - Target 10-15 total
   - Add new ball types first (Dark, Light, Vampire)

7. **GoPit-b2k: Boss Phases**
   - Improve existing Slime King
   - Add more bosses

### Phase 3: Content Expansion (P3)

Scale up content:

8. **GoPit-nba + GoPit-clu: More Characters**
   - Target 10+ characters
   - Include The Itchy Finger (2x fire rate)

9. **GoPit-a2b: Stage Unlock System**
   - Gears from completing with different characters
   - Encourages replay

10. **GoPit-qxg: Stage-Specific Enemies**
    - Ice enemies for Frozen Depths
    - Fire enemies for Burning Sands

---

## Appendix L: Advanced Mechanics & Hidden Features

Research sources:
- [BallxPit.org Advanced Mechanics Guide](https://ballxpit.org/guides/advanced-mechanics/)
- [Ball x Pit Tips & Tricks](https://ballxpit.org/guides/tips-tricks/)

### BallxPit Hidden Mechanics

**Speed Control System:**
- 3 speed settings (R1 button)
- Speed 3 (Fast): Waves 1-10, farming
- Speed 2 (Normal): Waves 10-15
- Speed 1 (Slow): Boss fights, learning patterns

**Status Effect Stacking Limits:**
| Effect | Max Stacks |
|--------|------------|
| Bleed | 24 |
| Disease | 8 |
| Poison | 8 |
| Burn | 5 |
| Radiation | 5 |
| Frostburn | 4 |

Once max stacks reached, additional applications provide zero benefit.

**Damage Amplification:**
- Status effects stack multiplicatively
- +50% radiation + +25% frostburn = +75% total
- Optimization creates huge damage differences

**Evolution vs Fusion Power:**
- Evolutions are 2x-3x stronger than Fusions
- Fusions just combine; Evolutions create new mechanics
- Hidden evolutions still being discovered

### GoPit Current Status Effects

From `status_effect.gd`:
| Effect | Implementation |
|--------|---------------|
| BURN | DoT damage |
| FREEZE | Slow movement |
| POISON | DoT + spread on death |
| BLEED | Stacking DoT |
| LIGHTNING | Chain to nearby |

**No stacking limits currently documented.**
**No speed control system.**

### Gap Analysis

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| Speed control | No | 3 speeds | Low |
| Status stack limits | No | Yes (varies) | Medium |
| Damage amplification math | Unknown | Multiplicative | Low |

### Recommendations

1. [ ] **Consider speed control** - Helpful for bosses
2. [ ] **Add status stack limits** - Prevents infinite scaling
3. [ ] **Document amplification math** - Clarify how bonuses combine

---

## Appendix M: Ball Lifecycle and Catching Mechanics (NEW)

Research sources:
- [GameRant - Beginner Tips](https://gamerant.com/ball-x-pit-beginner-tips/)
- [TheGamer - Complete Guide](https://www.thegamer.com/ball-x-pit-complete-guide/)
- [Steam Discussion - Catching Balls](https://steamcommunity.com/app/2062430/discussions/0/624436409752930018/)
- [Gamepad Squire - The Repentant Guide](https://gamepadsquire.com/blog/ball-x-pit-ultimate-guide-repentant-evolutions-strategies)

### BallxPit Ball Lifecycle

**Core Loop:**
1. Player shoots ball
2. Ball bounces off walls and enemies (+5% damage per bounce)
3. Ball returns to player (hits bottom/back wall)
4. Player can CATCH ball early for faster re-fire (saves 2-3 seconds)
5. Repeat

**Ball Catching Mechanic:**
- Players intercept returning balls by positioning
- Catching = skill-based DPS increase
- Active play (catching) >> passive play (waiting)
- The Shieldbearer gets +100% damage on caught balls

**Ball Return:**
- Balls NEVER despawn from bouncing
- They always return after hitting back wall
- Return path still damages enemies
- No "max bounces" limit

**Strategic Depth:**
- Stand close to enemies = faster catching = higher DPS
- Aim into crevices = more bounces = more damage
- Ricochet strategy rewards precision

### GoPit Ball Lifecycle

**Current Mechanic (ball.gd):**
```gdscript
var max_bounces: int = 10
# ...
if _bounce_count > max_bounces:
    despawn()  # Ball disappears!
```

1. Player shoots ball
2. Ball bounces off walls (no damage scaling)
3. Ball DESPAWNS after 10 bounces
4. No catching mechanic
5. Wait for cooldown, fire new ball

**Ball Limits:**
- Max 30 simultaneous balls (oldest despawn if exceeded)
- Balls despawn on max bounces OR pierce exhausted

### CRITICAL GAPS

| Aspect | GoPit | BallxPit | Impact |
|--------|-------|----------|--------|
| **Bounce limit** | 10 → despawn | Unlimited → return | **CRITICAL** |
| **Damage per bounce** | None | +5% per bounce | **CRITICAL** |
| **Ball catching** | Not implemented | Core skill mechanic | **HIGH** |
| **Ball return** | N/A (despawns) | Returns to player | **HIGH** |
| **Active play reward** | Minimal | Higher DPS | **HIGH** |

### Recommendations

**Priority 1 (Changes Core Loop):**
1. [ ] **Remove max_bounces despawn** - Balls should return, not despawn
2. [ ] **Add +5% damage per bounce** - Core damage mechanic
3. [ ] **Add ball return mechanic** - Balls return to player position

**Priority 2 (Skill Expression):**
4. [ ] **Add ball catching** - Tap on returning balls to catch early
5. [ ] **Add catch bonus character** - Like The Shieldbearer

---

## Appendix N: Level Select and Stage Unlock System (NEW)

Research sources:
- [Deltia's Gaming - Unlock All Levels](https://deltiasgaming.com/ball-x-pit-how-to-unlock-all-levels/)
- [GAM3S.GG - Character Unlock Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-unlock-all-characters/)

### BallxPit Level Select

**Stage Selection UI:**
- 8 stages visible in level select
- Locked stages show requirements
- Players CHOOSE which stage to play
- Each stage is a self-contained run

**Gear Unlock System:**
| Stage | Gears Needed |
|-------|--------------|
| Bone x Yard | 0 (default) |
| Snowy x Shores | 2 |
| Liminal x Desert | 2 |
| Fungal x Forest | 2 |
| Gory x Grasslands | 3 |
| Smoldering x Depths | 4 |
| Heavenly x Gates | 4 |
| Vast x Void | 5 |

**Gear Earning:**
- Beat stage with Character A = 1 gear
- Beat same stage with Character B = another gear
- Encourages playing multiple characters

### GoPit Stage System

**Current Implementation (stage_manager.gd):**
```gdscript
stages = [
    preload("res://resources/biomes/the_pit.tres"),
    preload("res://resources/biomes/frozen_depths.tres"),
    preload("res://resources/biomes/burning_sands.tres"),
    preload("res://resources/biomes/final_descent.tres"),
]
# ...
func _on_game_started() -> void:
    current_stage = 0  # Always starts at Stage 1
```

**Current Flow:**
1. Game ALWAYS starts at Stage 1 (The Pit)
2. Linear progression through all 4 stages
3. No level select UI
4. No stage unlock system
5. No replay of individual stages

### CRITICAL GAPS

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Level select UI** | None | Yes | **CRITICAL** |
| **Stage unlock system** | None | Gear-based | **LARGE** |
| **Replay individual stages** | No | Yes | **LARGE** |
| **Multi-character incentive** | None | Gears | **MEDIUM** |
| **Stage independence** | No (linear) | Yes | **LARGE** |

### Recommendations

1. [ ] **Add level select screen** - Between character select and game
2. [ ] **Add stage unlock system** - Gear-based or achievement-based
3. [ ] **Track character-stage completion** - For gear system

---

## Appendix O: Run Structure - Finite vs Endless (NEW)

### BallxPit Run Structure

**Stage-Based Runs:**
- Each stage = one complete run (10-20 minutes)
- Fixed waves leading to boss
- Beat boss = WIN for that stage
- Return to level select
- Pick next stage

**Session Characteristics:**
- Typical session: 1-3 stage runs
- Clear win/loss per stage
- Progress persists between sessions (unlocks, buildings)
- No "endless" feeling - defined endpoints

### GoPit Run Structure

**Current Implementation:**
- 4 stages × 10 waves = 40 waves total
- Single continuous run from Stage 1 → 4
- Victory ONLY after beating ALL 4 stages
- Death = lose ALL progress

**From stage_manager.gd:**
```gdscript
func complete_stage() -> void:
    current_stage += 1
    if current_stage >= stages.size():
        game_won.emit()  # Only win after all 4 stages
```

**Session Characteristics:**
- Typical run: 40+ minutes (if successful)
- No intermediate "wins"
- Feels endless due to length
- High death penalty (lose everything)

### COMPARISON

| Aspect | GoPit | BallxPit |
|--------|-------|----------|
| **Run length** | 40+ waves | 10-20 waves per stage |
| **Win condition** | All 4 bosses | Any stage boss |
| **Session length** | 40+ minutes | 10-20 minutes |
| **Death penalty** | Lose ALL progress | Lose stage progress |
| **Intermediate wins** | None | After each stage |

### The "Endless" Problem

GoPit feels endless because:
1. No level select (must start at Stage 1)
2. Must beat ALL stages in one run
3. Long session commitment required
4. No sense of "winning" until very end

BallxPit solves this by:
1. Level select (choose your challenge)
2. Each stage = complete run
3. Short sessions (10-20 min)
4. Frequent wins keep engagement high

### Recommendations

**Priority 1 (Fundamental Change):**
1. [ ] **Change win condition** - Beat stage boss = win for that stage
2. [ ] **Add level select** - Choose which stage to attempt
3. [ ] **Shorten session length** - Each stage is its own run

**Priority 2:**
4. [ ] **Add stage rewards** - Coins/unlocks per stage completion
5. [ ] **Add stage progression** - Unlocks persist between sessions

---

## Appendix P: Meta Shop and Permanent Upgrades (NEW)

### GoPit Current Implementation

**Meta Currency: Pit Coins**
- Earned per run: `wave * 10 + level * 25`
- From `meta_manager.gd`

**Permanent Upgrades (5 total):**
| Upgrade | Effect | Max Level | Cost Scale |
|---------|--------|-----------|------------|
| Pit Armor | +10 HP/level | 5 | 100 × 2^level |
| Ball Power | +2 damage/level | 5 | 150 × 2^level |
| Rapid Fire | -0.05s cooldown/level | 5 | 200 × 2^level |
| Coin Magnet | +10% coins/level | 4 | 250 × 2.5^level |
| Head Start | Start at level X | 3 | 500 × 3^level |

### BallxPit Meta-Progression

**Base Building System:**
- Buildings provide permanent bonuses
- Blueprints drop from enemies
- Resources needed: wheat, wood, stone, gold
- Buildings unlock characters

**Key Differences:**
- BallxPit has visual base progression
- Resource management layer
- Buildings vs simple upgrades
- Character unlocks tied to buildings

### Gap Analysis

| Feature | GoPit | BallxPit |
|---------|-------|----------|
| Permanent upgrades | 5 types | Many buildings |
| Visual progression | No base | Base grows |
| Resource variety | 1 (coins) | 4+ resources |
| Character unlock | Achievements | Buildings |

### Recommendations

1. [ ] **Expand upgrade count** - 10-15 permanent upgrades
2. [ ] **Add character unlock shop** - Buy unlocks with coins
3. [ ] **Consider visual progression** - Simple base or trophy room

---

## Appendix Q: Ball Types Deep Comparison (NEW)

Research sources:
- [Ball X Pit Wiki - Balls](https://ballpit.fandom.com/wiki/Balls)
- [GAM3S.GG - All Special Balls](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-all-special-balls/)
- [Dexerto - All Evolutions](https://www.dexerto.com/wikis/ball-x-pit/all-evolution-recipes-combinations/)

### BallxPit Ball Types (18 Base Balls)

| Ball | Ability | Damage Mod | Special Mechanic |
|------|---------|------------|------------------|
| **Bleed** | 2 stacks per hit, 1 dmg/stack on hit | Normal | Max 8 stacks, damage scales with hits |
| **Brood Mother** | 25% baby ball spawn on hit | Normal | Synergy with Leadership |
| **Burn** | 1 stack for 3s, 4-8 DPS/stack | Normal | Max 3 stacks |
| **Cell** | Splits into clone 2x on hit | Normal | Creates extra balls |
| **Charm** | 4% charm for 5s | Normal | Enemy attacks other enemies |
| **Dark** | 3x damage, self-destructs | 3x | 3s cooldown, The Shade's ball |
| **Earthquake** | 5-13 AoE dmg (3x3 tiles) | Normal | Area control |
| **Egg Sac** | Explodes into 2-4 baby balls | Normal | 3s cooldown |
| **Freeze** | 4% freeze for 5s, +25% dmg taken | Reduced | Crowd control |
| **Ghost** | Passes through enemies | Reduced | Hits backline |
| **Iron** | Double damage, 40% slower | 2x | Slow but powerful |
| **Laser H** | 9-18 dmg entire row | - | Pierces all |
| **Laser V** | 9-18 dmg entire column | - | Pierces all |
| **Light** | Blinds 3s, 50% miss chance | Normal | Defensive |
| **Lightning** | 1-20 chain dmg to 3 enemies | Normal | AoE chain |
| **Poison** | 1 stack, 1-4 DPS/stack, 6s | Normal | Max 5 stacks |
| **Vampire** | 4.5% chance heal 1 HP | Normal | Sustain |
| **Wind** | Passes through, 30% slow, -25% dmg | 0.75x | Control + pierce |

### GoPit Ball Types (7 Total)

From `scripts/autoload/ball_registry.gd`:

| Ball | Ability | Base Damage | Base Speed | Effect |
|------|---------|-------------|------------|--------|
| **Basic** | None | 10 | 800 | None |
| **Burn** | 3s burn, 5 DPS | 8 | 800 | Burn DoT |
| **Freeze** | 2s slow (50%) | 6 | 800 | Movement slow |
| **Poison** | 5s DoT, 3 DPS | 7 | 800 | Poison DoT |
| **Bleed** | Infinite stacking, 2 DPS/stack | 8 | 800 | Max 5 stacks |
| **Lightning** | Chain 50% to 1 enemy | 9 | 900 | Single chain |
| **Iron** | Knockback | 15 | 600 | Displacement |

### Status Effect Comparison

From `scripts/effects/status_effect.gd`:

| Effect | GoPit | BallxPit |
|--------|-------|----------|
| **Burn DPS** | 5 (2.5/0.5s) | 4-8/stack (max 3 stacks = 12-24 DPS) |
| **Burn Max Stacks** | 1 (refresh) | 3 |
| **Freeze Duration** | 2s | 5s |
| **Freeze Damage Amp** | None | +25% |
| **Poison DPS** | 3 (1.5/0.5s) | 1-4/stack (max 5 = 5-20 DPS) |
| **Poison Max Stacks** | 1 | 5 |
| **Bleed Max Stacks** | 5 | 8 |
| **Bleed Mechanic** | DoT per stack | Damage on HIT per stack |

### CRITICAL GAPS

#### Missing Ball Types (11)
1. **Cell** - Clone split mechanic
2. **Charm** - Enemy mind control
3. **Dark** - 3x damage glass cannon
4. **Earthquake** - AoE ground effect
5. **Egg Sac** - Baby ball burst
6. **Ghost** - Pass through enemies
7. **Laser H/V** - Full row/column pierce
8. **Light** - Blind (miss chance)
9. **Brood Mother** - 25% baby ball on hit
10. **Vampire** - Heal on hit
11. **Wind** - Pass through + slow

#### Mechanic Differences

| Mechanic | GoPit | BallxPit | Priority |
|----------|-------|----------|----------|
| **Freeze +25% damage** | Not implemented | Core mechanic | P1 |
| **Bleed on-hit damage** | DoT only | Damage on every hit | P1 |
| **Burn stacking** | Refresh only | 3 stacks = 3x DPS | P2 |
| **Poison stacking** | 1 stack | 5 stacks | P2 |
| **Lightning chain** | 1 enemy | 3 enemies | P2 |
| **Clone/split balls** | None | Cell ball | P3 |
| **Pass-through balls** | Piercing upgrade | Ghost/Wind types | P3 |

### Recommendations

**P1 (Core Balance)**:
1. [ ] **Fix Freeze** - Add +25% damage amplification on frozen targets
2. [ ] **Fix Bleed** - Damage on EACH HIT, not just DoT (or add on-hit)
3. [ ] **Add Burn stacking** - Allow 3 stacks for higher DPS ceiling

**P2 (Depth)**:
4. [ ] **Add Dark ball** - 3x damage self-destruct for high-risk play
5. [ ] **Add Ghost ball** - Pass through for backline targeting
6. [ ] **Improve Lightning** - Chain to 3 enemies instead of 1

**P3 (Content)**:
7. [ ] **Add Charm** - Mind control is unique mechanic
8. [ ] **Add Cell** - Clone mechanic creates ball variety
9. [ ] **Add Laser types** - Row/column clear for satisfying AoE

---

## Appendix R: Evolution/Fusion Deep Comparison (NEW)

### BallxPit Evolution System

**Requirements:**
- Two L3 balls of different types
- Both consumed to create evolved ball
- Evolved balls can further fuse with a third L3 ball

**Full Recipe List (42+ Evolutions):**

| Evolution | Recipe 1 | Recipe 2 | Effect |
|-----------|----------|----------|--------|
| Blizzard | Freeze + Lightning | Freeze + Wind | Mass freeze + chain |
| Bomb | Burn + Iron | - | 150-300 AoE explosion |
| Frozen Flame | Burn + Freeze | - | Alternating freeze/burn |
| Inferno | Burn + Wind | - | Piercing fire |
| Lightning Rod | Lightning + Iron | - | Double chain damage |
| Magma | Burn + Earthquake | - | Burning ground |
| Noxious | Poison + Wind | - | Poison AoE cloud |
| Storm | Lightning + Wind | - | AoE lightning |
| Swamp | Poison + Earthquake | - | Poison zone |
| Virus | Ghost + Poison | - | Spreading plague |
| Vampire Lord | Bleed + Vampire | - | Lifesteal + bleed |
| *...37+ more* | - | - | - |

### GoPit Evolution System

From `scripts/autoload/fusion_registry.gd`:

**Current Recipes (5 Total):**

| Evolution | Recipe | Effect |
|-----------|--------|--------|
| **Bomb** | Burn + Iron | 150% AoE explosion |
| **Blizzard** | Freeze + Lightning | AoE freeze + chain |
| **Virus** | Bleed + Poison | Spreading DoT + lifesteal |
| **Magma** | Burn + Poison | Burning ground pool |
| **Void** | Burn + Freeze | Alternating burn/freeze |

### Gap Analysis

| Metric | GoPit | BallxPit | Gap |
|--------|-------|----------|-----|
| **Total evolutions** | 5 | 42+ | -37 |
| **Ball types available** | 7 | 18 | -11 |
| **Possible combinations** | 21 (7C2) | 153 (18C2) | -132 |
| **Recipe coverage** | 24% | ~30% | Similar % |
| **Triple fusion** | No | Yes | Missing |

### Missing High-Impact Evolutions

**Priority Adds:**
1. **Storm** (Lightning + Wind) - AoE lightning popular pick
2. **Vampire Lord** (Bleed + Vampire) - Sustain build enabler
3. **Lightning Rod** (Lightning + Iron) - Power play
4. **Noxious** (Poison + Wind) - Poison cloud
5. **Inferno** (Burn + Wind) - Piercing fire

**Requires New Ball Types:**
- Ghost ball → unlocks Virus (current recipe uses Bleed+Poison)
- Wind ball → unlocks 5+ evolutions
- Vampire ball → unlocks Vampire Lord

### Fission Mechanics Deep Dive

**Research Sources:**
- [Deltia's Fission/Fusion Guide](https://deltiasgaming.com/ball-x-pit-fission-fusion-and-evolution-guide/)
- [Fusion Reactor Wiki](https://ballpit.fandom.com/wiki/Fusion_Reactor)

#### BallxPit Fission System

**Trigger:** Fusion Reactor drop (rainbow orb) from enemies

**Mechanics:**
- Always available option (no requirements)
- Upgrades **up to 5 items** (balls AND/OR passives) by one level each
- Random selection from all equipped items below max level
- If ALL items maxed: grants **Gold** instead
- Primary early-game farming strategy

**Strategic Use:**
- Stages 1-3: Spam fission to quickly get 2+ balls to L3
- Mid-game: Balance fission vs evolution opportunities
- Late-game: Gold income when build complete

#### GoPit Fission System (Current)

From `scripts/autoload/fusion_registry.gd:246-278`:

```gdscript
static func apply_fission() -> Dictionary:
    var upgraded_items: Array = []
    var num_upgrades := randi_range(1, 3)  # Only 1-3 items

    var upgradeable_balls := BallRegistry.get_upgradeable_balls()
    var eligible: Array = []

    for ball_type in upgradeable_balls:
        eligible.append({"type": "ball", "ball_type": ball_type})
    # Note: Passives NOT included currently

    # If nothing upgradeable, give XP
    if eligible.is_empty():
        GameManager.add_xp(100)  # XP, not Gold
        return {"upgraded": [], "xp_bonus": 100}
```

**Current Implementation Issues:**
1. Only upgrades 1-3 items (should be up to 5)
2. Only upgrades balls (not passives)
3. Falls back to XP (BallxPit uses Gold)
4. Fixed XP amount (100) vs variable Gold

#### Fission Gap Summary

| Feature | GoPit | BallxPit | Fix Priority |
|---------|-------|----------|--------------|
| Max upgrades | 1-3 | Up to 5 | P2 |
| Targets | Balls only | Balls + Passives | P2 |
| Maxed fallback | XP (100) | Gold (variable) | P3 |
| Early-game impact | Low | High (farming strat) | P2 |

### Recommendations

**Evolution System:**
1. [ ] **Add Wind ball type** - Enables many evolutions
2. [ ] **Add Ghost ball type** - Pass-through + unlocks evolutions
3. [ ] **Add Vampire ball** - Popular sustain option
4. [ ] **Implement multi-tier evolution** - Evolved + L3 = Advanced evolution
5. [ ] **Add 10+ evolutions** - Priority: Storm, Lightning Rod, Inferno
6. [ ] **Scale damage multipliers** - Tier 1: 1.5x, Tier 2: 2.5x, Tier 3: 4x

**Fission System:**
7. [ ] **Increase fission cap to 5** - Match BallxPit power
8. [ ] **Include passives in fission** - Not just balls
9. [ ] **Change fallback to Gold** - Instead of XP
10. [ ] **Add fission counter UI** - Show "Upgraded 4 items!"

---

## Appendix S: Difficulty and Speed Scaling (NEW)

Research sources:
- [BallxPit Fast Mode Guide](https://ballxpit.org/guides/fast-mode/)
- [BallxPit NG+ Guide](https://ballxpit.org/guides/new-game-plus/)

### BallxPit Difficulty System

**Speed Control (R1 button):**
| Speed | Usage |
|-------|-------|
| Speed 3 (Fast) | Waves 1-10, farming |
| Speed 2 (Normal) | Waves 10-15 |
| Speed 1 (Slow) | Bosses, new enemies |

**Difficulty Modes:**
- Normal, Fast, Fast+2, Fast+3
- Exponential scaling in Fast modes
- New Game Plus: +50% HP/damage globally

**Post-Boss Spike:**
- ~3x HP jump after first boss
- Creates distinct difficulty phases

### GoPit Difficulty System

**From enemy_base.gd:**
```gdscript
// Per wave scaling:
max_hp *= 1.0 + (wave - 1) * 0.1    // +10% HP
speed *= min(2.0, 1.0 + (wave - 1) * 0.05)  // +5% speed (cap 2x)
```

**Spawn Interval (game_controller.gd):**
- Start: 2.0s, decrease by 0.1s per wave
- Minimum: 0.5s

**No speed control, no difficulty modes, linear scaling only.**

### GAPS

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| Speed control | No | 3 speeds | P2 |
| Difficulty modes | No | 4+ modes | P3 |
| Scaling type | Linear | Exponential | P3 |
| Post-boss spike | No | ~3x HP | P2 |

### Recommendations

1. [ ] **Add speed control** - 3 speeds with UI toggle
2. [ ] **Add post-boss HP spike** - Difficulty phases

---

## Appendix T: Enemy Placement and Patterns (NEW)

### GoPit Spawning

**From enemy_spawner.gd:**
- Random X position (no patterns)
- Fixed spawn Y (above screen)
- Burst: 10% base chance, 2-3 enemies

**Enemy Mix by Wave:**
| Wave | Slime | Bat | Crab |
|------|-------|-----|------|
| 1 | 100% | 0% | 0% |
| 2-3 | 70% | 30% | 0% |
| 4+ | 50% | 30% | 20% |

### BallxPit Spawning (Expected)

- Formation spawns (lines, V-shapes)
- Stage-specific enemy types
- Wave patterns with gaps
- Higher enemy variety

### GAPS

| Feature | GoPit | BallxPit |
|---------|-------|----------|
| Spawn patterns | Random | Formations |
| Stage enemies | Same all stages | Unique per stage |
| Enemy variety | 3 types | 10+ types |

### Recommendations

1. [ ] **Add spawn formations** - Lines, V-shapes
2. [ ] **Add stage-specific enemies** - Ice/fire variants

---

## Appendix U: Input and Controls Comparison (NEW)

Research sources:
- [Ball x Pit Controls Guide](https://deltiasgaming.com/ball-x-pit-controls-list-guide/)
- [Steam Discussions - Controls](https://steamcommunity.com/app/2062430/discussions/0/595162650440290352/)

### BallxPit Input System

**Platforms:**
- Windows (KB+M, Controller)
- PlayStation 5 (DualSense with haptics)
- Xbox Series X/S
- Nintendo Switch

**Control Features:**
| Feature | Support |
|---------|---------|
| Controller | Full support (preferred) |
| Keyboard+Mouse | Rebindable keys |
| Aim sensitivity | Adjustable 0-100% |
| Deadzone | Adjustable 5-20% |
| Haptic feedback | PS5 DualSense |
| Adaptive triggers | PS5 DualSense |
| Accessibility | Xbox Adaptive, Eye Tracker |

**Speed Control:**
- R1 button cycles Speed 1/2/3
- Critical for boss fights (slow) vs farming (fast)

### GoPit Input System

**From `scripts/input/`:**

**Fire Button (`fire_button.gd`):**
- Touch/click support
- Cooldown visualization
- Autofire toggle
- Blocked feedback (shake + sound)

**Virtual Joystick (`virtual_joystick.gd`):**
- Drag-to-aim
- 5% dead zone
- Touch + mouse support
- Real-time direction emission

**Current Implementation:**
```gdscript
// Fire button handles:
- InputEventMouseButton
- InputEventScreenTouch

// Joystick handles:
- InputEventMouseButton
- InputEventMouseMotion
- InputEventScreenTouch
- InputEventScreenDrag
```

### Gap Analysis

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| Controller | Not implemented | Full support | P2 |
| Rebindable keys | No | Yes | P3 |
| Speed control | No | 3 speeds | P2 |
| Haptic feedback | No | PS5 | P4 |
| Aim sensitivity | Fixed | Adjustable | P3 |
| Deadzone config | Fixed 5% | Adjustable | P3 |

### GoPit Strengths

- Touch controls work well for mobile
- Autofire is implemented (BallxPit may require manual)
- Virtual joystick is intuitive

### Recommendations

1. [ ] **Add speed control** - 3 speeds accessible via button
2. [ ] **Add controller support** - Gamepad for PC builds
3. [ ] **Consider aim sensitivity slider** - Settings menu option

---

## Appendix V: Achievements and Progression System (NEW)

Research sources:
- [BallxPit Achievements Guide](https://ballxpit.org/achievements/)
- [TheGamer Achievement/Trophy Guide](https://www.thegamer.com/ball-x-pit-achievement-trophy-guide/)
- [TrueAchievements](https://www.trueachievements.com/game/BALL-x-PIT/achievements)

### BallxPit Achievement System

**Total Achievements: 51-63** (platform varies)
- 35 are secret achievements
- 30-35 hours for 100% completion

**Achievement Categories:**

| Category | Count | Examples |
|----------|-------|----------|
| Evolution | 10 | Create Bomb, Blizzard, Black Hole, Nosferatu |
| Biome | 9 | Complete each of 8 biomes + all bosses |
| Character | 5 | Win with specific characters |
| Progression | 20 | Build 10/50 buildings, 10/50/100 runs, gold milestones |
| Challenge | 7 | Flawless Victory, Fast+3, NG+, 100 balls |

**Difficulty Tiers:**
- **Easy**: First evolution, first boss
- **Hard**: Black Hole, Nuclear Bomb, late-game progression
- **Very Hard**: Nosferatu (3-way fusion), Flawless Victory, Plus Ultra

**Unlock Rewards:**
- 15+ characters unlocked via achievements
- 70+ buildings unlocked
- Encyclopedia completion tracking

### GoPit Progression System

From `scripts/autoload/meta_manager.gd`:

**Current Tracking:**
```gdscript
var pit_coins: int = 0
var total_runs: int = 0
var best_wave: int = 0
var unlocked_upgrades: Dictionary = {}
```

**Permanent Upgrades (3 types):**
- HP: +10 per level
- Damage: +2 per level
- Fire Rate: -0.05s per level

**No Achievement System Implemented**

### Gap Analysis

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| Achievement system | None | 51-63 achievements | P3 |
| Character unlocks | All available | Progress-gated | P3 |
| Encyclopedia | None | Completion tracking | P4 |
| Run milestones | Track only | Rewarded | P3 |
| Evolution achievements | None | 10 types | P3 |
| Difficulty achievements | None | Fast+3, NG+ | P4 |

### Recommendations

1. [ ] **Add basic achievement system** - Track first kill, first boss, first evolution
2. [ ] **Add character unlock gates** - Require achievements to unlock
3. [ ] **Add run milestone rewards** - 10, 50, 100 runs = bonus coins
4. [ ] **Track evolution discoveries** - Encyclopedia-style log

---

## Appendix W: Audio and Sound Design (NEW)

Research sources:
- [Kenny Sun - The Sound Design of BALL x PIT](https://kennysun.com/game-dev/the-sound-design-of-ball-x-pit/)
- [BALL x PIT Soundtrack - Steam](https://store.steampowered.com/app/4091070/BALL_x_PIT_Soundtrack/)
- [Amos Roddy - BALL x PIT OST](https://amosroddy.bandcamp.com/album/ball-x-pit-original-soundtrack)

### BallxPit Audio Design Philosophy

**Key Principles (from Kenny Sun's blog):**

1. **Textural Landscape** - Each run should have unique sonic feel based on equipment/environment
2. **Variety** - 6 variations per sound effect, unique sounds per ball/environment
3. **Mix Management** - Keep audio readable in chaotic gameplay (100+ balls)

**Technical Solutions:**
- Sounds kept "quick and snappy with very short tails"
- Sped up 2-3x, high/low end removed, mono (distant feel)
- Heavy sidechain compression: important sounds (bosses, special balls) compress less important ones
- Instance limiting: 2-4 max per sound, 40-100ms cooldown
- Dynamic EQ and panning based on screen position

**Soundtrack:**
- 22 tracks by Amos Roddy
- Dynamic intensity based on gameplay state
- Available on Steam, Spotify, Bandcamp

### GoPit Audio System

From `scripts/autoload/sound_manager.gd`:

**Sound Types (22):**
- Core: FIRE, HIT_WALL, HIT_ENEMY, ENEMY_DEATH, GEM_COLLECT
- Ball Types: FIRE_BALL, ICE_BALL, LIGHTNING_BALL, POISON_BALL, BLEED_BALL, IRON_BALL
- Status Effects: BURN_APPLY, FREEZE_APPLY, POISON_APPLY, BLEED_APPLY
- UI: LEVEL_UP, GAME_OVER, WAVE_COMPLETE, BLOCKED
- Fusion: FUSION_REACTOR, EVOLUTION, FISSION
- Ultimate: ULTIMATE

**Technical Implementation:**
- Procedural audio generation (no audio files)
- 8 polyphonic audio players
- Per-sound pitch/volume variance
- Separate buses: Master, SFX, Music
- Persistence of volume settings

**Procedural Sound Generation:**
```gdscript
// Examples of procedural sounds:
_generate_fire_whoosh()      // Noise + warm modulation + crackle
_generate_ice_chime()        // High frequencies + shimmer
_generate_electric_zap()     // Square wave + high-freq modulation
_generate_metallic_clang()   // Multiple harmonics + detuning
```

### Gap Analysis

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| Sound variations | 1 per type | 6 per type | P3 |
| Instance limiting | 8 max global | 2-4 per sound | P3 |
| Sidechain compression | None | Heavy use | P3 |
| Positional audio | None | Screen-based EQ | P4 |
| Professional soundtrack | Procedural only | 22-track OST | P4 |
| Environment sounds | None | Per-biome | P3 |

### GoPit Strengths

- **Zero file size** - All sounds generated procedurally
- **Infinite variations** - Pitch/volume variance on each play
- **Fast iteration** - Change sounds in code, no asset pipeline
- **Ball-type-specific sounds** - Unique sound per ball type
- **Status effect audio** - Audio feedback on effect application

### Recommendations

1. [ ] **Add sound variations** - 3-6 variations per sound type
2. [ ] **Add instance limiting per sound** - Max 4 concurrent fire sounds, etc.
3. [ ] **Add biome-specific ambience** - Background loop per stage
4. [ ] **Consider professional soundtrack** - Replace procedural music

---

## Analysis Complete

This document represents a comprehensive comparison between Ball x Pit and GoPit across all major game systems. The analysis identified **20+ actionable gaps** tracked as beads, prioritized for implementation.

### Key Takeaways

1. **Bounce damage (+5%/bounce)** is the single most impactful missing mechanic
2. **Character uniqueness** needs fundamental mechanics, not just stat differences
3. **Content volume** (characters, stages, bosses, evolutions) has large gaps
4. **Core systems** (gem collection, movement, basic ball mechanics) are well-aligned

### Next Steps

1. Implement P1 beads (GoPit-gdj, GoPit-hfi) first
2. Add at least one unique-mechanic character
3. Expand evolution system with new ball types
4. Add more bosses with weak points

---

*Document maintained as part of BallxPit alignment effort (GoPit-68o)*
*Analysis complete - 1600+ lines covering all major systems*
*Last updated: January 2026*

---

## Appendix X: Ball Slot System - CRITICAL DIFFERENCE (NEW)

Research sources:
- [TheGamer Complete Guide](https://www.thegamer.com/ball-x-pit-complete-guide/)
- [Steam Discussions - Fire Rate](https://steamcommunity.com/app/2062430/discussions/0/624436409752895957/)
- [GAM3S.GG Character Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-unlock-all-characters/)

### BallxPit Ball Slot System

**CRITICAL: This is a fundamental gameplay difference!**

**How BallxPit Works:**
- Player has **4-5 ball SLOTS**
- Each slot holds a different ball type
- **When you fire, ALL equipped balls fire simultaneously**
- Each shot = 4-5 different ball types + baby balls
- Fire rate = how fast you can fire your FULL volley again

**Example:**
```
Slots: [Fire L3] [Ice L3] [Lightning L2] [Poison L1]
One fire press → 4 balls fire (one of each type) + baby balls
```

**Character Variations:**
- **The Spendthrift**: Fires all balls in a wide arc pattern
- **The Empty Nester**: Fires multiple copies of ONE ball type (rotates which)
- **The Cohabitants**: Fires mirrored copies of every shot

**Strategic Depth:**
- Plan which balls to pick up (limited slots)
- Evolution combines 2 balls → frees a slot
- "Evolved balls can be fused with a normal ball (both L3), so that's 3 total balls in 1 slot"
- Managing slots is core strategy

### GoPit Current Implementation

From `scripts/entities/ball_spawner.gd`:

```gdscript
var use_registry := BallRegistry != null
if use_registry:
    var active_type: int = BallRegistry.active_ball_type  // ONE type
    ball.set_ball_type(_registry_to_ball_type(active_type))
```

**How GoPit Works:**
- Player OWNS multiple ball types (via level-up cards)
- Only **ONE active ball type** at a time
- Multi-shot fires multiple balls of the **SAME type**
- Must manually switch active ball type

**Example:**
```
Owned: [Fire L3] [Ice L3] [Lightning L2] [Poison L1]
Active: Fire
One fire press → 1 Fire ball (or N Fire balls with multi-shot)
```

### GAP ANALYSIS

| Aspect | GoPit | BallxPit | Impact |
|--------|-------|----------|--------|
| **Ball slots** | 1 active | 4-5 simultaneous | **CRITICAL** |
| **Fire behavior** | One type | All types at once | **CRITICAL** |
| **Multi-shot** | Same type x N | Each type x N | **HIGH** |
| **Slot management** | N/A | Core strategy | **HIGH** |
| **Evolution benefit** | Power up | Free slot + power | **HIGH** |

### Why This Matters

1. **Completely different feel** - BallxPit is chaotic multi-ball mayhem
2. **Strategy layer** - Which balls to keep, which to evolve
3. **Synergies** - Fire + Ice + Lightning all hitting at once
4. **Character design** - Characters modify HOW all balls fire
5. **Evolution value** - Combining balls frees slots for more variety

### Recommendations

**P0 (Fundamental Change):**
1. [ ] **Implement ball slot system** - 4-5 slots, all fire at once
2. [ ] **Redesign multi-shot** - Each slot gets multi-shot bonus
3. [ ] **Add slot UI** - Show equipped balls in HUD

**Implementation Notes:**
```gdscript
# Proposed change to ball_spawner.gd:
func fire() -> void:
    for slot in ball_slots:  # Fire ALL equipped types
        if slot.ball_type != null:
            for i in range(ball_count):  # Multi-shot per slot
                _spawn_ball(dir, slot.ball_type)
```
