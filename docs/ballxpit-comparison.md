# BallxPit vs GoPit Comparison Analysis

> **Document Version**: 2.5
> **Last Updated**: January 11, 2026
> **Status**: In Progress - Continuous Analysis (24 Appendices)
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
- W2: [Visual Feedback and Polish](#appendix-w2-visual-feedback-and-polish-new) ⭐ NEW

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

### CRITICAL: Ball Return System (FUNDAMENTAL DIFFERENCE)

**BallxPit Ball Economy** ([Steam Discussions](https://steamcommunity.com/app/2062430/discussions/0/624436409752930018/), [Ball x Pit Tips](https://ballxpit.org/guides/tips-tricks/)):
- Balls **persist and bounce** until hitting bottom of screen OR caught
- **Cannot fire new balls** until existing balls return to player
- **Catching balls** = instant return (vs 2-3s waiting for bottom bounce)
- **Active catching = 30-40% more DPS** - skilled play rewarded
- Fire rate = how quickly returned balls can be launched
- Baby balls also must return before new ones fire

**GoPit Current System:**
- Balls despawn after `max_bounces` (10 bounces default)
- **Fixed cooldown timer** (0.5s) between shots regardless of balls
- No ball returning - new balls spawn on timer
- Fire rate = cooldown_duration setting
- No catching mechanic

**Impact:**
This is perhaps the MOST fundamental difference. BallxPit's system:
1. Creates strategic ball positioning (bounce behind enemies)
2. Rewards active play (catching = more DPS)
3. Makes fire rate feel different
4. Creates tension (balls out = vulnerable)

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| **Ball economy** | Cooldown timer | **Return-based** | **❌ CRITICAL** |
| **Ball lifecycle** | Despawn after bounces | Return at bottom | **❌ CRITICAL** |
| **Fire gating** | Cooldown timer | Ball availability | **❌ CRITICAL** |
| **Catching** | Not implemented | Instant ball return | **❌ Missing** |
| Ball types | 7 base types | 18+ types | Partial |
| Ball levels | L1-L3 | L1-L3 | ✅ Yes |
| Autofire | Toggle option | Primary mode | Partial |
| Status effects | 6 types | 10+ types | Partial |

### Recommendations

1. [ ] **CRITICAL: Implement ball return system** - Balls return at bottom, not despawn
2. [ ] **Add ball catching mechanic** - Catch = instant return
3. [ ] **Change fire gating to ball availability** - Only fire when balls returned
4. [ ] **Make autofire default ON** - BallxPit's primary mode
5. [ ] **Add more ball types** - Target 18+ like BallxPit

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

### Critical Gap: Baby Ball Trait Inheritance (P1)

**BallxPit:** ALL baby balls inherit traits from parent ball type:
- Ball type (Fire/Ice/Lightning/etc.)
- Status effects (burn, freeze, chain lightning)
- Visual appearance (color, particle trails)
- Evolved/fused effects (if parent is evolved/fused)

**Examples:**
- Brood Mother + Laser = baby balls shoot beams
- Brood Mother + Fire = baby balls apply burn
- Spider Queen spawns egg sacs on 25% of hits

**GoPit Code Analysis:**

From `baby_ball_spawner.gd` lines 68-78:
```gdscript
var ball := ball_scene.instantiate()
ball.is_baby_ball = true  # Only this flag is set
ball.damage = int(base_damage * baby_ball_damage_multiplier)
# NO ball_type, evolved_type, or fused_effects inheritance
```

From `ball.gd` lines 91-92:
```gdscript
# No trail for normal balls or baby balls
if ball_type == BallType.NORMAL or is_baby_ball:
    return  # Explicitly skips particle trails
```

**GoPit Baby Balls Are Always Generic:**
- Always BallType.NORMAL (blue)
- No status effects applied
- No particle trails
- No evolved/fused effects
- Only inherit damage (at 50%)

### Gaps to Address

| Gap | Priority | Bead |
|-----|----------|------|
| Baby ball trait inheritance | **P1** | GoPit-r1r |
| Baby ball count cap | P2 | - |
| Brood Mother ball type | P2 | - |
| Leadership damage scaling | P2 | - |
| Egg sac drop mechanic | P3 | - |

### Recommendations

1. [ ] **P1: Add trait inheritance** - Baby balls must copy ball_type, evolved_type, fused_effects from parent
2. [ ] **P1: Enable particle trails** - Remove `is_baby_ball` skip in `ball.gd`
3. [ ] **P2: Add baby ball count limit** - Cap based on Leadership stat
4. [ ] **P2: Add Brood Mother ball type** - Spawns babies on enemy hit
5. [ ] **P2: Scale baby damage with Leadership** - Not just spawn rate
6. [ ] **P3: Add egg sac drop mechanic** - Like Spider Queen evolution

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

**Ball Catching (CRITICAL MECHANIC):**

Research: [Ball x Pit Tips & Tricks](https://ballxpit.org/guides/tips-tricks/)

- Players can manually catch balls with their hitbox
- **Catching = instant reset** vs 2-3 seconds waiting for bounce at bottom
- **"Ball X Pit is NOT an idle game!"** - active catching is core gameplay
- **30-40% more shots per minute** from active catching
- **Can double DPS** with proper catching technique
- Shieldbearer character: +100% damage to caught balls
- Bottled Tornado passive: synergizes with catch mechanic
- **Mini-boss strategy**: Attack up close, catch immediately after

**DPS Math:**
- 10 minute run with passive play: ~200 balls fired
- 10 minute run with active catching: ~280-320 balls fired
- Over full run: 60-90 seconds of damage time saved

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

**Structural:**
1. **Mini-boss system** - BallxPit has 2 mini-bosses + 1 final boss per stage
2. **Boss count** - BallxPit has 8 unique main bosses
3. **Speed controls** - BallxPit allows slowing game to 1x for boss observation

**Mechanical:**
4. **Weak Points** - No targeted damage mechanic (BallxPit: 2x damage to weak spots)
5. **Armor Phases** - No invulnerability windows (Lord of Owls only hittable when grounded)
6. **Environmental Integration** - No stage-specific hazards (ice walls in Ice boss fight)
7. **Attack Pattern Variety** - Skeleton King has 5 distinct attack patterns

**Strategic:**
8. **Precision Requirement** - Any hit does same damage
9. **Observation Phase** - BallxPit recommends 30s observation before attacking
10. **Positioning Rewards** - Trapping balls behind boss for repeated bounces

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

### Notable BallxPit Passives (Missing from GoPit)

**Gameplay-Changing Passives:**
| Passive | Effect | Why It Matters |
|---------|--------|----------------|
| **Fleet Feet** | Full speed while shooting | Removes shooting slowdown penalty |
| **Eye of the Beholder** | 10% dodge chance | Adds RNG survival layer |
| **Archer's Effigy** | Spawns stone archer ally | Adds AI companions |
| **Stone Effigy** | Spawns blocking ally | Changes arena dynamics |
| **Crown of Thorns** | Destroys 2 enemies on melee hit | Rewards aggressive positioning |
| **Bottled Tornado** | Baby balls on special catch | Synergizes with catching mechanic |
| **Ethereal Cloak** | Balls pierce until wall | Fundamentally changes ball behavior |
| **Hourglass** | 150% damage but decays | High-risk/reward bouncing |

**Ball-Type Synergies:**
| Passive | Requires | Effect |
|---------|----------|--------|
| Cursed Elixir | Poison ball | Zombify enemies |
| Frozen Spike | Freeze ball | Chain freeze damage |
| Midnight Oil | Burn ball | Fire on fire stacking |
| Voodoo Doll | Curse ball | Instant kill chance |

These show BallxPit's design philosophy: passives SYNERGIZE with ball types, creating build paths.

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

### BallxPit Meta-Progression: New Ballbylon

Research: [BallxPit.org Buildings Guide](https://ballxpit.org/guides/buildings-guide/)

**70+ Buildings across 6 Categories:**

| Category | Count | Function |
|----------|-------|----------|
| **Production** | 4 | Generate wheat, wood, stone, gold |
| **Character Unlock** | 16 | Each character has unique house |
| **Stat Buildings** | 6 | Permanent D→S rank stat upgrades |
| **Upgrade Buildings** | 4 | Game-changing mechanics |
| **Buff Buildings** | 2 | Area-effect bonuses |
| **Utility** | 2 | Market, Offline Farm |

**Key Upgrade Buildings:**
| Building | Effect | Game Impact |
|----------|--------|-------------|
| **Matchmaker** | 2-character runs | Massive synergy potential |
| **Bag Maker** | Extra ball slot | More damage output |
| **Antique Shop** | Guaranteed passive | Build consistency |
| **Evolution Chamber** | Advanced fusions | Stronger evolved balls |
| **Jeweler** | Higher starter ball level | Faster power spike |

**Resource Loop:**
1. Run pit → Earn blueprints + resources
2. Build structures in New Ballbylon
3. Bounce characters to harvest/construct
4. Unlock new characters, stats, mechanics
5. Stronger runs → Better rewards → Repeat

**Worker Assignment System:**
Research: [Deltia's Gaming - Worker Assignment](https://deltiasgaming.com/ball-x-pit-worker-assignment/)

Workers can be assigned to buildings for passive resource collection:
1. Build the specific building (e.g., Farm)
2. Place resource fields (e.g., wheat farms) touching the building's grid
3. Select building → Click "Assigned Worker" box
4. Choose a character from available roster
5. Assigned worker automatically harvests resources while you're in the pit

**Worker Strategy:**
- Assign characters that don't contribute much to harvesting
- Some characters are valuable for runs (e.g., The Cogitator adds 2s to harvest clock)
- Workers reduce active harvesters but provide constant passive income
- Upgrading buildings = more output + reduced cooldown

**Harvest Menus (4 Total):**
| Menu | Function |
|------|----------|
| **Build** | Select and place tiles (wheat, wood, stone fields) |
| **Harvest** | Click to collect resources (requires cooldown) |
| **Rearrange** | Move existing tiles for better organization |
| **Expand** | Increase placeable area (starts at 200 coins) |

**Gold Farming (Critical):**
- 7 Gold Mines in U-formation = 1,500+ gold/harvest
- Spa building = instant re-harvest for gold
- 25K-35K gold/hour with optimal setup
- Worker assignment provides background income during runs

**Key Differences from GoPit:**
- Visual city that grows over time
- Resource management layer (4 currencies)
- Buildings physically constructed by bouncing
- Character unlocks tied to specific buildings
- Buff buildings affect nearby structures
- Worker assignment for passive income

### Gap Analysis

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| Building count | 0 | 70+ | **CRITICAL** |
| Permanent upgrades | 5 types | 6 stat ranks + buildings | Large |
| Visual progression | No base | City grows over time | Medium |
| Resource variety | 1 (coins) | 4 (wheat, wood, stone, gold) | Medium |
| Character unlock | Achievements | Buildings | Medium |
| 2-character runs | No | Matchmaker building | Large |
| Extra ball slots | No | Bag Maker building | Large |
| Offline progression | No | Offline Farm building | Low |

### Recommendations

**P2 (High Impact):**
1. [ ] **Add 2-character mode** - Like Matchmaker building effect
2. [ ] **Add extra ball slot upgrade** - Like Bag Maker
3. [ ] **Expand upgrade count** - 10-15 permanent upgrades

**P3 (Medium Impact):**
4. [ ] **Add character unlock shop** - Buy unlocks with coins
5. [ ] **Consider visual progression** - Trophy room or simple base
6. [ ] **Add guaranteed passive start** - Like Antique Shop

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
- [BallxPit Speedrun Strategies](https://ballxpit.org/guides/speedrun-strategies/)
- [Boss Battle Strategies](https://ballxpit.org/guides/boss-battle-strategies/)

### BallxPit Wave Structure

**Boss Timing:**
- Bosses appear every **10 waves** (Wave 10, 20, 30, 40, 50+)
- Each level has **3 bosses total**: 2 mini-bosses + 1 final boss
- Defeating stage bosses rewards **guaranteed Fusion upgrades**

**Wave Progression Gates:**
| Wave | Requirements | Notes |
|------|--------------|-------|
| 1-9 | None | Early game, focus on AoE evolutions |
| 10 | 1-2 ball evolutions | First boss gate |
| 20 | 2-3 ball evolutions + 2-3 passives | Mid-game |
| 30+ | All 8 passive evolutions | **HARD GATE** - cannot progress without |
| 40+ | Perfect ball evolution + S-Rank stats | Elite territory |
| 50+ | Optimized build | End-game campaign |

### BallxPit Speed Control System

**Speed Toggle (R1/RB/R key):**
| Speed | Enemy Scaling | Loot Quality | Usage |
|-------|---------------|--------------|-------|
| Speed 1 (Normal) | 1x | Standard | Bosses, new enemies, learning |
| Speed 2 (Fast) | 1.5x | +25% | Waves 1-10, farming |
| Speed 3 (Fast+2) | 2.5x | +50% | Competitive play, speedruns |

**Speed Affects:**
- Enemy movement speed
- Enemy spawn rates
- Projectile speed
- Overall game pacing

**CRITICAL: Dynamic Speed Control**
- "Speed does NOT pause during upgrades" - DPS loss during selection
- Speedrunners: Speed 3 for farming, Speed 1 for bosses
- "Speed 3 during laser-heavy levels = instant death"
- Even world-record holders slow down for difficult sections

### Run Completion Times

| Mode | Target Time | Notes |
|------|------------|-------|
| Normal | 15-20 min | Learning/testing |
| Fast | 10-13 min | Efficient farming |
| Fast+2 | 8-10 min | Competitive play |
| Fast+3 | 6-8 min | World record territory |

- Current world record: **7:53** (Any% NG+ Fast+)
- Standard runs average: **12-15 minutes**

### BallxPit Difficulty Modes

**Game Mode Progression:**
- Normal, Fast, Fast+2, Fast+3
- Exponential scaling in Fast modes
- Each mode affects: enemy movement, spawn rates, projectile speed

**New Game Plus (NG+):**
- Unlocks after completing all 8 biomes on normal
- +50% enemy HP and damage globally
- **Checkpoints REMOVED** (restart from Wave 1 on death)
- Building costs 2-3x normal
- Runs extend from 30-60 min to **60-90 min**
- Sustain builds become mandatory (Mosquito King, Soul Sucker prioritized)
- Pure damage strategies fail at this level

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

**Wave Structure:**
- 10 waves per stage
- 5 enemies per wave
- 1 boss per stage (4 stages total)
- No speed control, no difficulty modes, linear scaling only

### CRITICAL GAPS

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| **Speed control** | None | 3 speeds (toggleable) | **P1** |
| **Wave gates** | None | Evolution requirements | P2 |
| Difficulty modes | None | 4+ modes (Fast/Fast+) | P2 |
| Post-boss spike | None | ~3x HP | P2 |
| Run duration control | Fixed | Dynamic (player controls) | P2 |
| Scaling type | Linear | Exponential | P3 |
| NG+ mode | None | Full second difficulty tier | P3 |

### Recommendations

1. [ ] **Add speed control (P1)** - 3 speeds with R key toggle, affects all game pacing
2. [ ] **Add post-boss HP spike** - Difficulty phases
3. [ ] **Add wave evolution gates** - Require minimum evolutions at Wave 10, 20, etc.
4. [ ] **Target 10-15 min runs** - BallxPit's sweet spot for engagement
5. [ ] **Consider NG+ mode** - For post-game challenge

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

### BallxPit Spawning (Confirmed)

**Research Sources:** [Boss Battle Guide](https://ballxpit.org/guides/boss-battle-guide/), [TheGamer Boss Ranking](https://www.thegamer.com/ball-x-pit-hardest-area-bosses-to-beat/)

**Level Structure:**
- 8 unique levels/biomes
- Each level has: 2 mini-bosses + 1 final boss = 3 boss fights per level
- Guaranteed Fusion upgrade after mini-bosses 1 and 2

**Boss Fights Confirmed:**
| Boss | Level | Mechanic |
|------|-------|----------|
| Skeleton King | Bone X Yard | Spawns adds, weak point on crown |
| Shroom Swarm | Fungal Forest | Multi-enemy shared HP bar, formations |
| Dragon Prince | Smoldering Depths | Low HP, fire attacks |
| Twisted Serpent | Unknown | Multi-phase, layer destruction |
| Lord of Owls | Unknown | Flying + enemy clusters |
| Sabertooth | Unknown | Rectangular tiger monster |
| Hydra Boss | Unknown | Multiple heads, final core phase |

**Boss Patterns:**
- Telegraphed attack patterns (spend 30s observing before attacking)
- Adds/minion spawns during boss fights
- Shroom Swarm: Forms rows, retreats, spawns mini-enemies
- Skeleton King: Reduced bullet frequency during add spawns

**Stage-Specific Enemies:**
- Desert: Sandstorms, digging mechanics
- Fungal Forest: Shrooms that push forward
- Each biome has unique enemy behaviors

### GAPS

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| Spawn patterns | Random | Formations | P2 |
| Stage enemies | Same all stages | Unique per biome | P3 |
| Enemy variety | 3 types | 10+ types | P2 |
| Mini-bosses | None | 2 per level | P2 |
| Final bosses | 1 total | 8 (one per level) | P2 |
| Boss phases | Limited | Multi-phase | P2 |
| Add spawns | None | During boss fights | P2 |

### Recommendations

1. [ ] **Add spawn formations** - Lines, V-shapes, clusters
2. [ ] **Add stage-specific enemies** - Ice/fire/poison variants per biome
3. [ ] **Add mini-boss system** - 2 mini-bosses before final boss per stage
4. [ ] **Expand to 8 bosses** - One unique boss per stage
5. [ ] **Add add-spawn during bosses** - Minions during boss fights

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

## Appendix W2: Visual Feedback and Polish (NEW)

Research sources:
- [Settings Optimization Guide](https://ballxpit.org/guides/settings-optimization/)
- [BALL x PIT Review - Steam Deck HQ](https://steamdeckhq.com/game-reviews/ball-x-pit/)

### BallxPit Visual Feedback Systems

**Screen Shake:**
- Triggers on: enemy hits, explosions, boss attacks, evolution activation
- Toggle option in settings (accessibility)
- Recommended OFF for Fast+2/Fast+3 modes for visual clarity
- Recommended OFF for handheld devices (Steam Deck, Switch)

**Damage Numbers:**
- Displayed on all hits
- Maximum cap: 9,999 damage per hit (visual cap)
- Color-coded by damage type (burn=orange, freeze=blue, etc.)
- Stack with multiple hits visible simultaneously

**Particle Intensity:**
- Can be overwhelming in late-game ("sensory overload" in reviews)
- 100+ balls + particles + effects on screen simultaneously
- No known particle reduction setting

**Visual Clarity Concerns:**
- Players report "struggled to keep track of their own projectiles amid the particle storm"
- Screen fills with enemies, orbs, and visual effects
- Fast modes increase visual chaos

### GoPit Visual Feedback Systems

**Damage Numbers (`scripts/effects/damage_number.gd`):**
- Floating text, rises 60px over 0.6s
- Fades out with 0.2s delay
- Random offset (-10 to +10 px) for stacking
- Color-coded per damage type
- No damage cap (can show any value)

**Hit Particles (`scripts/effects/hit_particles.gd`):**
- GPU particles, one-shot
- Auto-free after emission complete
- Minimal particle system

**Camera Shake (`scripts/effects/camera_shake.gd`):**
- Autoload with global `shake(intensity, decay)` function
- Intensity decays over time (lerp to 0)
- **No settings toggle** (always on)

**Current Usage:**
- Shake on: enemy death, boss attacks, level-up
- Missing: ball fire, wall bounce, evolution activation

### Gap Analysis

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| Screen shake toggle | No | Yes | P3 |
| Damage cap display | No cap | 9,999 | Low |
| Evolution activation VFX | Basic | Full screen flash | P3 |
| Boss weak point feedback | None | Color change + particles | P2 |
| Ball type particle trails | None | Unique per ball | P3 |
| Hit flash on enemies | None | Brief white flash | P2 |

### Recommendations

1. [ ] **Add screen shake toggle** - Settings → Accessibility
2. [ ] **Add hit flash on enemies** - Brief white overlay on damage
3. [ ] **Add ball type trails** - Particle trail matching ball color/type
4. [ ] **Enhance evolution VFX** - Full screen flash + sound
5. [ ] **Add boss phase feedback** - Visual indicator of phase transitions

---

## Analysis Complete

This document represents a comprehensive comparison between Ball x Pit and GoPit across all major game systems. The analysis identified **25+ actionable gaps** tracked as beads, prioritized for implementation.

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


## Appendix Y: Bounce Damage Scaling - Missing Mechanic (NEW)

### BallxPit Bounce Damage

**CRITICAL: BallxPit rewards skilled play with bounce damage!**

**How BallxPit Works:**
- **+5% damage per bounce** (confirmed from research)
- Balls that ricochet multiple times become MORE powerful
- Creates risk/reward: let ball bounce more for higher damage
- Encourages aiming for multi-bounce trajectories
- Maximum bonus unclear but likely capped

**Example:**
```
Base damage: 10
After 1 bounce: 10 * 1.05 = 10.5 → 10
After 5 bounces: 10 * 1.25 = 12.5 → 12
After 10 bounces: 10 * 1.50 = 15
```

### GoPit Current Implementation

**Location:** `scripts/entities/ball.gd:188-199`

```gdscript
# Ball.gd - current bounce handling
if collider.collision_layer & 1:  # walls layer
    _bounce_count += 1
    if _bounce_count > max_bounces:
        despawn()
        return
    direction = direction.bounce(collision.get_normal())
    SoundManager.play(SoundManager.SoundType.HIT_WALL)

# Later when hitting enemy:
var actual_damage := damage  # FIXED - no bounce scaling!
```

**What GoPit tracks:**
- `_bounce_count` - incremented on wall hits
- `max_bounces` - despawn limit (default 10, +5 per Ricochet upgrade)

**What's missing:**
- NO damage increase per bounce
- Bounces only affect lifetime, not power

### GAP ANALYSIS

| Aspect | GoPit | BallxPit | Impact |
|--------|-------|----------|--------|
| **Track bounces** | ✅ Yes | ✅ Yes | - |
| **Bounce damage bonus** | ❌ No | ✅ +5%/bounce | **HIGH** |
| **Skill expression** | Low | High | **MEDIUM** |
| **Ricochet value** | Survivability only | Power + survivability | **HIGH** |

### Why This Matters

1. **Skill expression** - BallxPit rewards players who aim for multi-bounces
2. **Ricochet upgrade value** - More bounces = both more time AND more damage
3. **Enemy positioning** - Far enemies take more damage (more bounces to reach)
4. **Satisfying feedback** - "Big bounce combo" moments feel rewarding
5. **Strategy depth** - Choose: direct hit (fast) vs ricochet (powerful)

### Implementation Recommendation

**Priority: P1 (High)**

```gdscript
# Proposed change to ball.gd hit handling:
const BOUNCE_DAMAGE_BONUS := 0.05  # +5% per bounce

func _get_bounce_damage() -> int:
    var bounce_mult := 1.0 + (_bounce_count * BOUNCE_DAMAGE_BONUS)
    return int(damage * bounce_mult)

# In enemy hit handler:
var actual_damage := _get_bounce_damage()  # NOT just damage
```

**Visual feedback ideas:**
- Ball glows brighter with more bounces
- Hit number shows "(+2 bounce)" bonus
- Particle intensity increases


## Appendix Z: Baby Ball Mechanics - Missing Type Inheritance (NEW)

### BallxPit Baby Balls

**In BallxPit, baby balls are POWERFUL and TYPED:**
- Each ball SLOT spawns its own baby balls
- Baby balls **inherit the parent ball's type and effects**
- Fire slot → Fire baby balls (with burn)
- Ice slot → Ice baby balls (with slow)
- With 5 slots, you have 5 streams of different baby balls

**Example with 3 filled slots:**
```
[Fire L2] → Fire baby balls every ~1.5s
[Ice L2] → Ice baby balls every ~1.5s  
[Lightning L2] → Lightning baby balls every ~1.5s
= 3 different typed baby balls hitting enemies constantly
```

### GoPit Current Implementation

**Location:** `scripts/entities/baby_ball_spawner.gd`

```gdscript
func _spawn_baby_ball() -> void:
    var ball := ball_scene.instantiate()
    ball.is_baby_ball = true
    ball.damage = int(base_damage * baby_ball_damage_multiplier)
    ball.set_direction(direction)
    # NOTE: No ball_type set! Always generic basic balls
```

**What GoPit does:**
- Single spawn timer (2.0s base)
- Targets nearest enemy
- 50% damage multiplier
- Always spawns **BASIC** balls (no type)
- No status effects from baby balls

### GAP ANALYSIS

| Aspect | GoPit | BallxPit | Impact |
|--------|-------|----------|--------|
| **Baby ball type** | Always basic | Inherits slot type | **HIGH** |
| **Streams per slot** | 1 total | 1 per slot | **HIGH** |
| **Status effects** | ❌ None | ✅ Inherits | **HIGH** |
| **Ball level scaling** | ❌ No | ✅ Yes | **MEDIUM** |

### Why This Matters

1. **Ball diversity value** - Each new ball type = more baby ball variety
2. **Passive DPS scaling** - Multiple typed baby balls = constant status effects
3. **Strategy synergy** - Status effect combos happen automatically
4. **Late-game power** - 5 different baby ball streams is massive DPS

### Implementation Recommendation

**Priority: P1 (After ball slot system)**

This depends on GoPit-6zk (ball slot system). Once slots exist:

```gdscript
# Each slot spawns its own baby balls
func _spawn_baby_balls_from_slots() -> void:
    for slot in ball_slots:
        if slot.ball_type != null:
            var baby := _create_baby_ball()
            baby.set_ball_type(slot.ball_type)  # Inherit type!
            baby.ball_level = slot.level
```

**Also needed:**
- Baby ball rate per slot (or shared timer)
- Type-specific baby ball visuals
- Status effect application from baby balls


## Appendix AA: Visual Feedback and Juice Comparison (NEW)

### GoPit Current Implementation

**What GoPit HAS:**
| Feature | Location | Quality |
|---------|----------|---------|
| Screen shake | `camera_shake.gd` | ✅ Good |
| Damage numbers | `damage_number.gd` | ✅ Basic |
| Hit flash | `enemy_base.gd:153` | ✅ Good |
| Hit particles | `hit_particles.tscn` | ✅ Good |
| Combo counter | `hud.gd`, `game_manager.gd` | ✅ Good |
| Pop animations | Various | ✅ Good |
| Particle trails | Ball types | ✅ Good |

**What GoPit LACKS:**
| Feature | Description | Impact |
|---------|-------------|--------|
| Crit numbers | Red/special crit damage | MEDIUM |
| Hit stop | Brief freeze on big hits | LOW |
| Bounce damage indicator | Show bonus per bounce | MEDIUM (if bounce damage added) |
| Kill streak announcer | "TRIPLE KILL!" etc | LOW |

### Comparison to BallxPit

BallxPit has similar juice elements:
- Floating damage numbers
- Screen shake on big hits
- Enemy flash on hit
- Particle effects on special balls

**Key differences:**
1. BallxPit may have more pronounced crit effects
2. BallxPit likely has bounce damage visual feedback
3. Both games have adequate "game feel"

### Assessment

**GoPit's juice is ADEQUATE** - no urgent work needed here. Priority should be on core mechanics (ball slots, bounce damage) rather than additional polish.

**Low priority improvements:**
- Red crit numbers with "CRIT!" prefix
- Hit stop on boss kills (50ms)
- Bounce damage indicator (if bounce damage added)


## Appendix AB: Enemy Spawning and Wave Structure (NEW)

### GoPit Current Implementation

**Location:** `scripts/entities/enemies/enemy_spawner.gd`

**Spawn Pattern:**
- Timer-based (variable interval with random variance)
- Random X position along top of screen
- Enemy type based on wave number:
  - Wave 1: Slimes only
  - Wave 2-3: 70% Slimes, 30% Bats
  - Wave 4+: 50% Slimes, 30% Bats, 20% Crabs
- Burst spawn chance (10-30% depending on difficulty)

**Wave Structure:**
- 10 waves per stage (configurable per biome)
- 5 enemies killed = wave complete
- Boss at end of each stage
- 4 total stages

**Code summary:**
```gdscript
# enemy_spawner.gd
func spawn_enemy() -> EnemyBase:
    var spawn_x := randf_range(spawn_margin, _screen_width - spawn_margin)
    enemy.global_position = Vector2(spawn_x, spawn_y_offset)
    # Pure random X, always from top
```

### BallxPit Expected Behavior

**Based on typical bullet-heaven conventions:**

1. **Formation Spawns:**
   - Lines of enemies (horizontal, diagonal)
   - Clusters (tight groups)
   - Waves (curved patterns)
   - Circles around player

2. **Spawn Origins:**
   - Top, bottom, left, right
   - Corners
   - Encirclement (all sides)

3. **Wave Choreography:**
   - Specific enemy compositions per wave
   - Boss telegraphs and minion spawns
   - Rest periods between intense waves

4. **Scaling:**
   - Enemy speed increases with level/iteration
   - Health scaling
   - Spawn rate increases

### GAP ANALYSIS

| Aspect | GoPit | BallxPit (Expected) | Impact |
|--------|-------|---------------------|--------|
| **Spawn origin** | Top only | All directions | **HIGH** |
| **Patterns** | Random X | Formations/choreographed | **HIGH** |
| **Wave design** | Generic | Hand-crafted | **MEDIUM** |
| **Enemy density** | Burst chance | Controlled waves | **MEDIUM** |
| **Spawn variety** | Timer-driven | Event-driven | **MEDIUM** |

### Why This Matters

1. **Visual interest** - Formations look better than random spawns
2. **Strategic depth** - Knowing spawn patterns enables positioning
3. **Difficulty curves** - Hand-crafted waves allow better pacing
4. **Memorability** - "That wave with the diagonal slimes" moments

### Recommendations

**P2 Priority** (after core mechanics):

1. **Add spawn origins** - Enable left/right/bottom spawns
2. **Add formation system** - Define enemy patterns (line, V, circle)
3. **Wave designer** - JSON/resource-based wave definitions
4. **Directional spawns** - Enemies can enter from any edge

**Proposed Wave Structure:**
```gdscript
class WaveDefinition:
    var enemy_groups: Array[EnemyGroup]
    var spawn_delay: float
    var spawn_direction: String  # "top", "left", "all", etc.

class EnemyGroup:
    var enemy_type: PackedScene
    var count: int
    var formation: String  # "line", "cluster", "v_shape"
    var spawn_offset: float
```


## Appendix AC: XP Economy and Leveling Curve (NEW)

### GoPit Current Implementation

**XP Sources:**
| Enemy | Base XP | Scaling |
|-------|---------|---------|
| Slime | 10 | +5% per wave |
| Bat | 12 (1.2x) | +5% per wave |
| Crab | 13 (1.3x) | +5% per wave |
| Slime King | 100 | Fixed |
| Slime Minion | 25 | Fixed |

**XP Multipliers:**
- Combo 3-4: 1.5x XP
- Combo 5+: 2.0x XP
- Character XP bonus (Tactician): 1.x multiplier

**Level Requirements (Linear):**
```
Level 2: 100 XP
Level 3: 150 XP  (+50)
Level 4: 200 XP  (+50)
Level 5: 250 XP  (+50)
...
Formula: 100 + (level - 1) * 50
```

**Code:** `game_manager.gd:419-420`
```gdscript
func _calculate_xp_requirement(level: int) -> int:
    return 100 + (level - 1) * 50
```

### BallxPit Expected Behavior

**Typical roguelike XP curves:**
1. **Exponential** - Each level requires significantly more
2. **Polynomial** - Grows faster than linear but not exponential
3. **Soft cap** - Plateaus at high levels

**Example curves:**
```
Linear (GoPit):    100, 150, 200, 250, 300...
Polynomial:        100, 160, 230, 310, 400...
Exponential:       100, 150, 225, 340, 510...
```

### Analysis

**GoPit's linear curve:**
- **Pros:** Predictable, easy to balance
- **Cons:** Later levels feel same as early levels

**Potential issues:**
- Level 20 = 1,050 XP needed (easily farmable)
- No "power spike" moments from fast early levels
- Late game may feel too easy to level up

### Recommendations

**P3 Priority** (balance tuning):

1. **Consider polynomial curve:**
```gdscript
func _calculate_xp_requirement(level: int) -> int:
    return int(80 * pow(level, 1.3))
# Gives: 80, 197, 344, 514, 705, 917...
```

2. **Or soft-cap curve:**
```gdscript
func _calculate_xp_requirement(level: int) -> int:
    return 100 + (level - 1) * 50 + int(pow(level, 1.5) * 5)
# Adds acceleration factor
```

**Note:** This is balance tuning, not a fundamental gap. GoPit's linear curve is functional, just may feel "flat" compared to games with more dynamic progression.


## Appendix AD: In-Game Drops and Pickups (NEW)

### GoPit Current Drops

| Drop | Source | Effect |
|------|--------|--------|
| XP Gem | All enemies | Grants XP |
| Health Gem | Vampire passive (20% chance) | Heals player |
| Fusion Reactor | Random on kill (~2% + wave bonus) | Enables fusion |

**No temporary power-ups during gameplay** - all upgrades come from level-up cards.

### BallxPit Expected Behavior

Many ball games have in-game pickups:
- **Magnet** - Temporarily attract all gems
- **Shield** - Brief invulnerability
- **Speed boost** - Faster ball speed temporarily
- **Multi-shot** - Temporary extra balls
- **Bomb** - Clear screen of enemies
- **Freeze** - Pause all enemies

### Analysis

**GoPit's approach:**
- Permanent upgrades via level-up cards
- Clean, simple loop (kill → XP → level → upgrade)
- Fusion reactor adds special moment

**Potential gap:**
- No "exciting drop" moments during gameplay
- No emergency saves (shield, clear screen)
- Less variety in gameplay loop

### Recommendations

**P3 Priority** (optional enhancement):

Consider adding rare temporary powerups:
1. **Magnet pickup** - 10s of gem attraction
2. **Overdrive** - 5s of rapid fire
3. **Time warp** - 5s of enemy slow-mo

These would drop rarely (1-2% chance) and add excitement without fundamentally changing balance.

**Note:** This is a "nice to have" - GoPit's current system is clean and functional. Adding pickups increases complexity.


## Appendix AE: Tutorial and Onboarding (NEW)

### GoPit Current Implementation

**Location:** `scripts/ui/tutorial_overlay.gd`

**Tutorial Steps:**
1. MOVE - "Drag LEFT joystick to MOVE"
2. AIM - "Drag RIGHT joystick to AIM"
3. FIRE - "Tap FIRE to shoot!"
4. HIT - "Hit enemies before they reach you!"
5. COMPLETE - Save state, fade out

**Features:**
- Step-by-step hints with highlight rings
- Pulse animation on highlighted controls
- Saves completion to user settings
- Only shows on first play

**Current Status:** DISABLED (line 107-108)
```gdscript
# EMERGENCY: Tutorial disabled by default due to input blocking bug
return true  # Treat as completed (skip tutorial)
```

### BallxPit Expected Behavior

Mobile games typically have:
- Interactive tutorials that pause gameplay
- Pop-up tips during first few levels
- Progressive feature unlocks with explanations
- "Did you know?" hints

### Assessment

**GoPit's tutorial is adequate** once the input blocking bug is fixed. The step-by-step approach is standard and effective.

**Recommendation:** Fix the mouse_filter input blocking bug (P2) and re-enable tutorial.


## Appendix AF: Aim/Trajectory System (NEW)

### GoPit Current Implementation

**Location:** `scripts/input/aim_line.gd`

**Features:**
- Dashed line showing aim direction
- Max length: 400 pixels
- Ghost state when joystick released (fades to 30% alpha)
- Updates in real-time with joystick input

**What it DOESN'T have:**
- Bounce prediction (where ball will reflect)
- Multiple bounce preview
- Collision preview with enemies

**Code:**
```gdscript
# aim_line.gd - simple straight line
func _update_line(start_pos: Vector2) -> void:
    # Creates dashed line in current_direction
    # NO bounce simulation
```

### BallxPit Expected Behavior

BallxPit likely has:
- **Bounce preview** - Shows where ball will reflect off walls
- **Multiple bounces** - Shows 2-3 bounces ahead
- **Hit preview** - Maybe highlights enemies in trajectory

### GAP ANALYSIS

| Feature | GoPit | BallxPit (Expected) | Impact |
|---------|-------|---------------------|--------|
| **Aim direction** | ✅ Yes | ✅ Yes | - |
| **Bounce preview** | ❌ No | ✅ Yes | **HIGH** |
| **Multi-bounce** | ❌ No | ✅ Maybe | MEDIUM |
| **Ghost aim** | ✅ Yes | ❌ Unknown | - |

### Why This Matters

1. **Skill ceiling** - Bounce preview enables skilled bank shots
2. **Strategy** - Plan ricochets to hit enemies behind cover
3. **Satisfaction** - Predict and execute complex shots
4. **Learning** - Helps players understand ball physics

### Recommendations

**P1 Priority** (important for skill expression):

```gdscript
# Proposed trajectory prediction
func _calculate_trajectory() -> Array[Vector2]:
    var points: Array[Vector2] = []
    var pos := start_position
    var dir := aim_direction
    var bounces := 0
    var max_bounces := 2
    
    while bounces <= max_bounces:
        # Raycast to find wall collision
        var result := space_state.intersect_ray(query)
        if result:
            points.append(result.position)
            dir = dir.bounce(result.normal)
            pos = result.position
            bounces += 1
        else:
            points.append(pos + dir * max_length)
            break
    
    return points
```

**Visual treatment:**
- First segment: Bright white dashed line
- Second bounce: Slightly dimmer
- Third bounce: Faint outline


## Appendix AG: Ultimate Ability System (NEW)

### GoPit Current Implementation

**Locations:**
- `scripts/ui/ultimate_button.gd` - UI with charge ring
- `scripts/effects/ultimate_blast.gd` - Effect execution
- `scripts/autoload/game_manager.gd` - Charge tracking

**How it works:**
1. **Charge mechanic:** Builds from kills (CHARGE_PER_KILL in GameManager)
2. **UI:** Ring fills up, pulses when ready
3. **Activation:** Tap button when charged
4. **Effect:** Screen flash + camera shake + kill ALL enemies

**Code summary:**
```gdscript
# ultimate_blast.gd
func execute() -> void:
    _play_sound()
    _create_flash()      # White screen overlay
    _shake_camera()      # Big shake (25.0 intensity)
    _kill_all_enemies()  # 9999 damage to all
```

### BallxPit Comparison

**CONFIRMED: BallxPit does NOT have ultimate abilities.**

Research indicates BallxPit is entirely gameplay-driven through balls and evolutions:
- No tap-to-activate special abilities
- No charge meter for screen-clear
- No ultimate button UI

**Screen-clearing in BallxPit is achieved via:**
1. **Bomb evolution** (Burn + Iron) - 150-300 AoE damage per hit
2. **Nuclear Bomb** (Bomb + Poison) - 300-500 AoE + radiation stacking
3. **High-DPS builds** - Machine gun effect via Empty Nester character

Sources:
- [GAM3S.GG Special Balls Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-all-special-balls/)
- [BallxPit.org Combos Guide](https://ballxpit.org/guides/combos-synergies/)

### Assessment

**GoPit's ultimate is an ORIGINAL feature (not in BallxPit):**
- Clear charging feedback (ring fills)
- Satisfying activation (flash + shake)
- Powerful effect (clear screen)
- Strategic save-or-use decisions

**Design Decision Required:**
1. **Keep ultimate** - Adds strategic depth, satisfying "panic button"
2. **Remove ultimate** - More faithful to BallxPit, rely on evolutions
3. **Hybrid** - Keep ultimate but require specific balls/evolutions to unlock

**Potential enhancements if keeping:**
- Character-specific ultimates (Pyro = fire explosion, Frost = freeze all)
- Partial charge use (50% for smaller effect)
- Evolved balls contribute more charge

**Priority:** P4 (design decision) - This is an intentional deviation from BallxPit.


## Appendix AH: Pause Menu and Settings (NEW)

### GoPit Current Implementation

**Location:** `scripts/ui/pause_overlay.gd`

**Options:**
1. Resume - Continue playing
2. Sound: ON/OFF - Toggle all audio
3. Quit - Return to start (reload scene)

**Missing settings:**
| Setting | Status | Common in Mobile Games |
|---------|--------|------------------------|
| Music volume | ❌ Missing | Very common |
| SFX volume | ❌ Missing | Very common |
| Vibration toggle | ❌ Missing | Common |
| Game speed | ❌ Missing | Common in roguelikes |
| Sensitivity | ❌ Missing | Common for joysticks |
| Credits/About | ❌ Missing | Standard |

### BallxPit Expected Settings

Mobile games typically have:
- Separate music/SFX sliders
- Vibration toggle (haptics)
- Language selection
- Cloud save toggle
- Privacy/data settings
- Social links (Discord, etc.)

### Game Flow Comparison

**GoPit:**
```
Launch → Character Select → Game → Game Over → Character Select
```

**Missing:**
- No dedicated main menu
- No mode selection
- No daily challenge/endless mode
- No leaderboards screen

### Recommendations

**P3 Priority** (polish):

1. **Split audio controls:**
```gdscript
var music_volume: float = 1.0
var sfx_volume: float = 1.0
```

2. **Add game speed option:**
```
[ 0.5x ] [ 1.0x ] [ 1.5x ] [ 2.0x ]
```

3. **Add main menu:**
- Play (→ Character Select)
- Shop (→ Meta Shop)
- Settings
- Daily Challenge (future)

**Note:** These are quality-of-life improvements. Core gameplay is priority.


## Appendix AI: Game Modes Comparison (NEW)

### GoPit Current Modes

**Only one mode:** Standard run (4 stages → final boss → win)

**No alternative modes:**
- No endless/survival mode
- No daily challenge
- No boss rush
- No practice mode

### BallxPit Expected Modes

Many roguelikes offer:
1. **Story/Campaign** - Finite stages with ending
2. **Endless** - Survive as long as possible
3. **Daily Challenge** - Same seed for all players, leaderboard
4. **Boss Rush** - Fight bosses back-to-back

### GAP ANALYSIS

| Mode | GoPit | BallxPit (Expected) | Complexity |
|------|-------|---------------------|------------|
| Campaign | ✅ Yes | ✅ Yes | - |
| Endless | ❌ No | ✅ Maybe | LOW |
| Daily | ❌ No | ✅ Maybe | HIGH |
| Boss Rush | ❌ No | ❌ Unknown | MEDIUM |

### Why This Matters

1. **Replayability** - Different modes keep game fresh
2. **Engagement** - Daily challenges bring players back
3. **Competition** - Leaderboards drive engagement
4. **Skill expression** - Endless shows mastery

### Recommendations

**P3 Priority** (future feature):

**Easy win - Endless Mode:**
```gdscript
# Just disable stage completion, scale infinitely
var is_endless_mode: bool = false

func _advance_wave() -> void:
    if is_endless_mode:
        # Skip boss, just increase difficulty
        _scale_difficulty()
    else:
        # Normal stage progression
        _check_boss_wave()
```

**Benefits:**
- Minimal code change
- High replayability value
- Good for score competition


## Appendix AJ: Persistence and Stats Tracking (NEW)

### GoPit Current Implementation

**Location:** `scripts/autoload/meta_manager.gd`

**Persisted Data (local JSON):**
```json
{
  "coins": 500,
  "runs": 15,
  "best_wave": 25,
  "upgrades": {"hp": 2, "damage": 1}
}
```

**Run Stats (in-memory only):**
- Time survived
- Enemies killed
- Damage dealt
- Gems collected
- High score wave/level (GameManager)

**What GoPit Has:**
| Feature | Status |
|---------|--------|
| Local save | ✅ Yes |
| Best wave tracking | ✅ Yes |
| Total runs | ✅ Yes |
| Upgrade progress | ✅ Yes |
| Run stats display | ✅ Yes |

**What GoPit Lacks:**
| Feature | Status |
|---------|--------|
| Cloud save | ❌ No |
| Online leaderboards | ❌ No |
| Friends comparison | ❌ No |
| Detailed stat history | ❌ No |
| Achievement unlocks | ❌ Partial |

### BallxPit Expected Features

Mobile games typically have:
- Cloud save (Play Games / Game Center)
- Global leaderboards
- Weekly/daily leaderboards
- Achievement badges with rewards
- Friends list integration

### Assessment

**GoPit's local persistence is adequate for MVP.**

**Recommendations:**

**P4 Priority** (future/optional):
1. Cloud save integration (platform-specific)
2. Simple leaderboard (server required)
3. Achievement badges displayed in UI

**Note:** Online features require backend infrastructure. Focus on core gameplay first.

---

## Appendix AL: Status Effect Deep Dive (NEW)

### GoPit Status Effect Implementation

**Location:** `scripts/effects/status_effect.gd`

| Effect | Duration | DPS | Max Stacks | Special |
|--------|----------|-----|------------|---------|
| **Burn** | 3.0s × INT | 5 (2.5/0.5s) | 1 (refresh) | None |
| **Freeze** | 2.0s × INT | 0 | 1 | 50% slow |
| **Poison** | 5.0s × INT | 3 (1.5/0.5s) | 1 | Spreads on death |
| **Bleed** | Infinite | 2/stack (1.0/0.5s) | 5 | Stacks |

### BallxPit Status Effects (from research)

| Effect | Max Stacks | Mechanic |
|--------|------------|----------|
| **Burn** | 3 | 4-8 DPS per stack |
| **Freeze** | 1 | +25% damage taken |
| **Poison** | 5 | 1-4 DPS per stack |
| **Bleed** | 8 | Damage on EVERY HIT per stack |

### CRITICAL GAPS

| Gap | GoPit | BallxPit | Impact |
|-----|-------|----------|--------|
| **Freeze +25% damage** | Not implemented | Core mechanic | **HIGH** |
| **Burn stacking** | Refresh only | 3 stacks = 3x DPS | **MEDIUM** |
| **Bleed on-hit** | DoT only | +dmg per hit per stack | **HIGH** |
| **Poison stacks** | 1 | 5 | **MEDIUM** |
| **Bleed stacks** | 5 | 8 | **LOW** |

### Recommendations

**P1 Priority:**
1. [ ] Add +25% damage amplification to Freeze effect
2. [ ] Change Bleed to add on-hit damage, not just DoT

**P2 Priority:**
3. [ ] Enable Burn stacking (max 3)
4. [ ] Enable Poison stacking (max 5)
5. [ ] Increase Bleed max stacks to 8

---

## Appendix AM: Fission System Deep Dive (NEW)

### GoPit Fission Implementation

**Location:** `scripts/autoload/fusion_registry.gd:304-343`

**Current Behavior:**
```gdscript
var num_upgrades := randi_range(1, 3)  // Only 1-3 items!

for i in num_upgrades:
    if upgradeable.size() > 0 and (unowned.size() == 0 or randf() < 0.6):
        BallRegistry.level_up_ball(ball_type)  // Balls only!
    elif unowned.size() > 0:
        BallRegistry.add_ball(ball_type)

// Fallback: XP bonus (not Gold)
GameManager.add_xp(xp_bonus)
```

### BallxPit Fission System

**From research:**
- Upgrades **up to 5 items** per fission
- Upgrades **balls AND passives**
- If all maxed: **Gold** bonus (not XP)
- Primary early-game farming strategy

### GAP ANALYSIS

| Feature | GoPit | BallxPit | Impact |
|---------|-------|----------|--------|
| **Max upgrades** | 1-3 | Up to 5 | **HIGH** |
| **Targets** | Balls only | Balls + Passives | **HIGH** |
| **Maxed fallback** | XP | Gold | **MEDIUM** |
| **Strategy value** | Low | Primary early-game | **HIGH** |

### Recommendations

**P2 Priority:**
1. [ ] Increase fission cap to 5 items (GoPit-c7z)
2. [ ] Add passives to fission pool (GoPit-c1v)
3. [ ] Change fallback from XP to meta-currency (Gold/Coins)

---

## Appendix AN: Character Passive Verification (NEW)

### GoPit Character Passives (6 Characters)

| Character | Passive | Implementation Status |
|-----------|---------|----------------------|
| **Rookie** | +10% XP gain | Stats only (1.0 all) |
| **Pyro** | +20% fire dmg, +25% vs burning | Partial (no burn amp check) |
| **Frost Mage** | +50% vs frozen, +30% freeze duration | Freeze duration works |
| **Tactician** | +2 baby balls, +30% spawn rate | Leadership stat (1.6) |
| **Gambler** | 3x crit damage, +15% crit | Dexterity stat (1.6) |
| **Vampire** | 5% lifesteal, 20% health gem | Health gem works |

### Key Findings

**All GoPit characters use STAT MULTIPLIERS only:**
- No unique firing patterns
- No unique ball behaviors
- No special mechanics

**BallxPit characters have UNIQUE MECHANICS:**
- The Shade: Fires from BACK of screen
- The Cohabitants: Mirrored double shots
- The Spendthrift: All balls in wide arc
- The Repentant: +5% damage per bounce

### Recommendations

**P2 Priority:**
1. [ ] Add character with unique firing (GoPit-oyz)
2. [ ] Implement Pyro's burn amplification check
3. [ ] Consider "The Repentant" style bounce damage character

---

## Appendix AO: Enemy Attack Timing Verification (NEW)

### GoPit Enemy Attack Constants

**Location:** `scripts/entities/enemies/enemy_base.gd:17-19`

```gdscript
const WARNING_DURATION: float = 1.0  // Seconds to show warning
const ATTACK_SPEED: float = 600.0    // Speed when lunging at player
const ATTACK_SELF_DAMAGE: int = 3    // HP lost per attack attempt
```

### Attack State Machine

1. **DESCENDING** → Move down at `speed`
2. **WARNING** → 1.0s warning with "!" and shake
3. **ATTACKING** → Lunge at ATTACK_SPEED (600)
4. **After Attack** → Snap back to pre-attack position, self-damage 3 HP

### BallxPit Comparison

**Matches:**
- Warning exclamation mark
- Shake animation during warning
- Lunge attack pattern

**Unknown:**
- Exact warning duration in BallxPit
- Self-damage mechanic in BallxPit
- Snap-back behavior

### Assessment

GoPit's enemy attack system appears well-aligned with BallxPit conventions. The warning/attack pattern is a common roguelike pattern.

---

*Document maintained as part of BallxPit alignment effort (GoPit-68o)*
*Analysis ongoing - 3700+ lines covering all major systems*
*Last updated: January 2026*


## Appendix AK: Player Damage and Invincibility (NEW)

### GoPit Current Implementation

**Location:** `scripts/autoload/game_manager.gd:265-276`

**Damage handling:**
```gdscript
func take_damage(amount: int) -> void:
    player_hp = max(0, player_hp - amount)
    SoundManager.play(SoundManager.SoundType.PLAYER_DAMAGE)
    player_damaged.emit(amount)
    # Reset combo on damage
    _reset_combo()
    # Big screen shake on player damage
    CameraShake.shake(15.0, 3.0)
```

**No invincibility frames** - Player can be hit multiple times rapidly.

### Enemy Attack Pattern (enemy_base.gd)

GoPit has a sophisticated attack warning system:
1. **WARNING phase** (1 second): Exclamation mark, enemy shakes
2. **ATTACK phase**: Enemy lunges toward player
3. **Self-damage**: Enemies lose 3 HP per attack attempt
4. **Reset**: Enemy returns to original position after attack

**This is GOOD design** - Clear telegraphing allows player reaction.

### Potential Issue

**No i-frames after hit** means:
- Multiple enemies can hit simultaneously
- Burst damage from overlapping attacks
- Player can die very quickly if surrounded

### BallxPit Expected Behavior

Most action games have:
- 0.5-1.0 second invincibility after damage
- Visual flash/blink during i-frames
- Knockback to separate from enemies

### Recommendations

**P2 Priority:**

```gdscript
var damage_cooldown: float = 0.0
const INVINCIBILITY_DURATION: float = 0.5

func take_damage(amount: int) -> void:
    if damage_cooldown > 0:
        return  # Still invincible
    
    player_hp -= amount
    damage_cooldown = INVINCIBILITY_DURATION
    # Start blinking effect
    _start_invincibility_blink()
```

**Note:** Current system works because enemy warnings give time to dodge. Consider adding i-frames only if rapid-hit scenarios become frustrating.


## Appendix AL: Gem Collection Mechanics (NEW)

### GoPit Current Implementation

**Location:** `scripts/entities/gem.gd`

**Collection:**
| Parameter | Value |
|-----------|-------|
| Auto-collect radius | 40 pixels |
| Fall speed | 150 px/s |
| Despawn time | 10 seconds |
| Magnetism speed | 400 px/s |

**Magnetism system:**
- Range increases with upgrades (GameManager.gem_magnetism_range)
- Pull strength increases as gem gets closer
- Visual line drawn to gem when attracted

**Health gems:**
- Pink color (vs green for XP)
- Heal 10 HP on collect
- No XP value
- Dropped by Vampire passive (20% on kill)

### BallxPit Expected Behavior

Similar mechanics expected:
- Gems/orbs drop from enemies
- Magnetism upgrades pull from range
- Some games have "collect all" abilities

### Assessment

**GoPit's gem system is solid:**
- ✅ Auto-collection works
- ✅ Magnetism upgrade meaningful
- ✅ Health gem variant exists
- ✅ Visual feedback (sparkle, glow when attracted)

**Minor improvements:**
- Vacuum effect on level-up (collect all on screen)
- Gem size scaling with value (bigger = more XP)
- "Critical gem" drop (rare, high XP)

**Priority:** P4 (polish) - Current system works well.


## Appendix AM: Ball Slot System Visual Guide (NEW)

### Current GoPit vs Target BallxPit Style

```
CURRENT GOPIT:
┌──────────────────────────────────────────────────────────┐
│  OWNED BALLS: [Fire L3] [Ice L2] [Lightning L1] [Poison] │
│                   ▲                                       │
│               ACTIVE (only one fires)                    │
│                                                          │
│  FIRE → 🔥 🔥 🔥  (only Fire balls, even with multi-shot)│
└──────────────────────────────────────────────────────────┘

TARGET BALLXPIT STYLE:
┌──────────────────────────────────────────────────────────┐
│  SLOTS: [🔥L3] [❄️L2] [⚡L1] [☠️L1] [empty]              │
│            │      │      │      │                        │
│            ▼      ▼      ▼      ▼                        │
│  FIRE → 🔥 ❄️ ⚡ ☠️  (ALL types fire simultaneously!)    │
│         🔥 ❄️ ⚡ ☠️  (× multi-shot = 12+ balls!)        │
└──────────────────────────────────────────────────────────┘
```

### HUD Slot Display (Needed)

```
┌────────────────────────────────────────────────────────┐
│ [HP████████░░]  Wave 5                    [⚡Ultimate] │
│                                                        │
│ SLOTS: [🔥L3] [❄️L2] [⚡L1] [☠️L1] [ + ]  ← ADD THIS   │
│                                                        │
│ [XP████░░░░░░░░░░] Level 3                            │
└────────────────────────────────────────────────────────┘
```

### Fusion Frees Slots

```
Before fusion:  [Fire L3] [Ice L3] [⚡L1] [☠️L1] [full]
                    │         │
                    └────┬────┘
                         ▼
After fusion:   [Void]  [EMPTY] [⚡L1] [☠️L1] [empty]
                   ↑       ↑
              evolved   FREED for new ball type!
```

### Implementation Priority

This is **GoPit-6zk (P0)** - the most critical change needed.


## Appendix AN: Enemy Scaling and Difficulty Curve (NEW)

### GoPit Current Scaling

**Location:** `scripts/entities/enemies/enemy_base.gd:66-73`

**Per-Wave Scaling:**
| Stat | Formula | Wave 1 | Wave 5 | Wave 10 | Wave 20 |
|------|---------|--------|--------|---------|---------|
| HP | +10%/wave | 100% | 140% | 190% | 290% |
| Speed | +5%/wave (cap 2x) | 100% | 120% | 145% | 200% |
| XP Value | +5%/wave | 100% | 120% | 145% | 195% |

**Spawn Rate (game_controller.gd:245):**
| Wave | Spawn Interval |
|------|----------------|
| 1 | 2.0s |
| 5 | 1.6s |
| 10 | 1.1s |
| 15 | 0.6s |
| 16+ | 0.5s (minimum) |

**Enemy Types by Wave:**
- Wave 1: Slimes only
- Wave 2-3: 70% Slimes, 30% Bats
- Wave 4+: 50% Slimes, 30% Bats, 20% Crabs

### Scaling Code

```gdscript
# enemy_base.gd
func _scale_with_wave() -> void:
    var wave: int = GameManager.current_wave
    # Scale HP: +10% per wave
    max_hp = int(max_hp * (1.0 + (wave - 1) * 0.1))
    # Scale speed: +5% per wave (capped at 2x)
    speed = speed * min(2.0, 1.0 + (wave - 1) * 0.05)
    # Scale XP: +5% per wave
    xp_value = int(xp_value * (1.0 + (wave - 1) * 0.05))
```

### BallxPit Expected Behavior

Typical roguelike scaling:
- **Exponential HP growth** in later waves
- **Enemy variety increases** with stage
- **New mechanics** introduced per stage (not just stat buffs)
- **Stage-specific hazards** (environmental damage)

### GAP ANALYSIS

| Aspect | GoPit | BallxPit (Expected) | Impact |
|--------|-------|---------------------|--------|
| HP scaling | Linear +10% | Possibly exponential | LOW |
| Speed cap | 2x max | Unknown | OK |
| Enemy variety | 3 types | 8-10+ types | **HIGH** |
| New mechanics | None | Per-stage hazards | MEDIUM |
| Difficulty spikes | Smooth | Boss checkpoints | OK |

### Recommendations

**P3 Priority** (balance tuning):

1. **Consider steeper late-game scaling:**
```gdscript
# Exponential HP after wave 10
if wave > 10:
    max_hp = int(max_hp * pow(1.15, wave - 10))
```

2. **Add more enemy types** (P2 beads exist)

3. **Stage-specific modifiers:**
- The Pit: Normal
- Frozen Depths: Enemies 20% slower, 20% more HP
- Burning Sands: Enemies 20% faster, 10% less HP


## Appendix AO: Key Timing Values Reference (NEW)

### Combat Timings

| System | Value | Location |
|--------|-------|----------|
| Fire cooldown | 0.5s base | fire_button.gd:11 |
| Ball speed | 800 px/s | ball.gd:12 |
| Ball max bounces | 10 default | ball.gd:19 |
| Baby ball interval | 2.0s base | baby_ball_spawner.gd:8 |
| Enemy attack warning | 1.0s | enemy_base.gd:17 |
| Enemy attack speed | 600 px/s | enemy_base.gd:18 |
| Enemy descent speed | 100 px/s base | enemy_base.gd:45 |

### Status Effect Durations

| Effect | Duration | Tick Rate | Location |
|--------|----------|-----------|----------|
| Burn | 3.0s | 0.5s | status_effect.gd |
| Freeze | 2.0s | N/A (slow) | status_effect.gd |
| Poison | 4.0s | 0.5s | status_effect.gd |
| Bleed | 3.0s | 0.3s | status_effect.gd |

### UI Timings

| Element | Duration | Location |
|---------|----------|----------|
| Damage number float | 0.6s | damage_number.gd:13 |
| Screen shake decay | 5.0 rate | camera_shake.gd:6 |
| Combo timeout | 2.0s | game_manager.gd:31 |
| Gem despawn | 10.0s | gem.gd:11 |
| Fusion reactor despawn | 15.0s | fusion_reactor.gd:11 |

### Wave/Stage Timings

| Event | Value | Location |
|-------|-------|----------|
| Enemies per wave | 5 kills | game_controller.gd:45 |
| Waves per stage | 10 | biome.gd:10 |
| Spawn interval start | 2.0s | enemy_spawner.gd:9 |
| Spawn interval min | 0.5s | game_controller.gd:245 |
| Boss intro duration | 2.0s | boss_base.gd:36 |

### Comparison Notes

These timings create GoPit's gameplay feel:
- **0.5s fire cooldown** = 2 shots/second (with autofire)
- **1.0s warning** = enough time to dodge attacks
- **2.0s baby ball** = steady passive DPS

**Potential adjustments:**
- Fire cooldown could be faster (0.3s) for more action
- Baby ball could scale more with upgrades
- Warning time could decrease in later waves

**Priority:** P4 (fine-tuning) - Current values are reasonable.


## Appendix AP: Stage/Biome System Implementation (NEW)

### GoPit's Current Biome Structure

**Biome Resource (`resources/biomes/biome.gd`):**
```gdscript
@export var biome_name: String
@export var background_color: Color
@export var wall_color: Color
@export var waves_before_boss: int = 10
# COMMENTED OUT / Future:
# @export var hazard_scenes: Array[PackedScene]
# @export var enemy_variants: Dictionary
# @export var music_track: AudioStream
```

**Current Stages (4 total):**

| Stage | Name | Waves | Background | Wall Color |
|-------|------|-------|------------|------------|
| 1 | The Pit | 10 | Dark purple | Purple-gray |
| 2 | Frozen Depths | 10 | Blue-gray | Ice blue |
| 3 | Burning Sands | 10 | (check) | (check) |
| 4 | Final Descent | 10 | (check) | (check) |

**Stage Manager Logic:**
- Tracks `current_stage` and `wave_in_stage`
- Emits `boss_wave_reached` when `wave_in_stage >= waves_before_boss`
- `complete_stage()` advances to next stage
- Emits `game_won` when all stages complete

### BallxPit Stage System (Inferred)

- **8 stages** (vs GoPit's 4)
- Variable waves per stage (easier stages have fewer)
- Stage-specific enemy variants
- Environmental hazards per biome
- Stage unlock requirements

### Key Gaps

1. [ ] **No hazard system** - `hazard_scenes` is commented out
2. [ ] **No enemy variants** - `enemy_variants` is commented out  
3. [ ] **No stage music** - `music_track` is commented out
4. [ ] **Fixed 10 waves per stage** - Should vary (5-7 for early, 10-12 for late)
5. [ ] **Only 4 stages** - Need 4 more to match BallxPit's 8
6. [ ] **No unlock requirements** - All stages available immediately

---

## Appendix AQ: Character Stat System Implementation (NEW)

### GoPit's Character Resource

**Stats (all multipliers relative to 1.0 baseline):**

| Stat | Display | Range | Effect |
|------|---------|-------|--------|
| Endurance | HP | 0.5-2.0 | HP multiplier |
| Strength | DMG | 0.5-2.0 | Damage multiplier |
| Leadership | TEAM | 0.5-2.0 | Baby ball spawn rate |
| Speed | SPD | 0.5-2.0 | Movement speed |
| Dexterity | CRIT | 0.5-2.0 | Crit chance multiplier |
| Intelligence | INT | 0.5-2.0 | Effect duration multiplier |

**Current Characters (6):**

| Character | END | STR | LEAD | SPD | DEX | INT | Starting Ball | Passive |
|-----------|-----|-----|------|-----|-----|-----|---------------|---------|
| Rookie | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | Iron | +10% XP |
| Pyro | 0.8 | 1.4 | 0.9 | 1.0 | 1.0 | 0.9 | Burn | +20% fire, burning enemies +25% damage taken |
| Frost Mage | ? | ? | ? | ? | ? | ? | Freeze | ? |
| Tactician | ? | ? | ? | ? | ? | ? | ? | ? |
| Gambler | ? | ? | ? | ? | ? | ? | ? | ? |
| Vampire | ? | ? | ? | ? | ? | ? | ? | ? |

### BallxPit Character Differences

BallxPit characters have **unique firing mechanics**, not just stat modifiers:
- The Repentant: Bounce damage specialist
- The Shade: Reverse firing direction
- The Itchy Finger: 2x fire rate
- The Shieldbearer: Catch bonus damage

### Key Gaps

1. [ ] **Passives are stat-based only** - No unique mechanics
2. [ ] **No firing mechanic variations** - All characters fire the same way
3. [ ] **Unlock system not functional** - `unlock_requirement` field exists but unused (GoPit-98r)
4. [ ] **Only 6 characters** - BallxPit has 10+


---

## Appendix AR: Enemy System Implementation (NEW)

### GoPit's Current Enemy Types

| Enemy | HP Mult | Speed Mult | XP Mult | Movement Pattern |
|-------|---------|------------|---------|------------------|
| Slime | 1.0x | 1.0x | 1.0x | Straight down |
| Crab | 1.5x | 0.6x | 1.3x | Side-to-side, slow descent |
| Bat | 1.0x | 1.3x | 1.2x | Zigzag pattern |

**Total: 3 enemy types** (vs BallxPit's 5-6)

### Enemy Spawner Logic

**Wave-Based Variety Introduction:**
```
Wave 1: 100% Slime
Wave 2-3: 70% Slime, 30% Bat
Wave 4+: 50% Slime, 30% Bat, 20% Crab
```

**Spawn Timing:**
- Base interval: 2.0 seconds
- Variance: ±0.5 seconds
- Burst chance: 10% (scales to 30%)
- Burst count: 2-3 enemies

### Missing Features

1. [ ] **Only 3 enemy types** - Need Golem, Swarm, Archer, Bomber (GoPit-h0n9)
2. [ ] **No spawn formations** - All random X position (GoPit-oasd)
3. [ ] **No stage-specific variants** - Ice Slime, Fire Crab, etc. (GoPit-qxg)
4. [ ] **No enemy-specific attacks** - All just approach player
5. [ ] **Hardcoded viewport width** - `720.0` in crab.gd

### BallxPit Enemy Comparison

| Feature | GoPit | BallxPit |
|---------|-------|----------|
| Enemy types | 3 | 5-6 |
| Spawn formations | No | Lines, V-shapes, clusters |
| Stage variants | No | Ice/fire/poison variants |
| Unique attacks | No | Ranged, charge, etc. |


---

## Appendix AS: Boss System Implementation (NEW)

### BossBase Architecture

**States:**
```gdscript
enum BossPhase { INTRO, PHASE_1, PHASE_2, PHASE_3, DEFEATED }
enum AttackState { IDLE, TELEGRAPH, ATTACKING, COOLDOWN }
```

**Core Features:**
- Phase transitions at HP thresholds (default: 100%, 66%, 33%, 0%)
- Invulnerability during intro and phase transitions
- Attack pattern system with telegraph + execution + cooldown
- Add spawning capability (`spawn_adds()`)
- Visual feedback (flashing, camera shake)

**Timing:**
| Phase | Duration |
|-------|----------|
| Intro | 2.0s |
| Phase Transition | 1.5s |
| Attack Telegraph | 1.0s |
| Attack Cooldown | 2.0-2.5s |

### Slime King (Only Boss)

**Stats:**
- HP: 500
- XP: 100
- Slam Damage: 30
- Slam Radius: 120px

**Attack Patterns by Phase:**
| Phase | Attacks |
|-------|---------|
| 1 | Slam, Summon |
| 2 | Slam, Summon, Split |
| 3 | Slam, Summon, Rage |

**Visual:**
- Phase 1: Green
- Phase 2: Yellow
- Phase 3: Red (enraged)

### Missing vs BallxPit

1. [ ] **Only 1 boss** - Need 4-8 (GoPit-8wcp)
2. [ ] **No weak points** - Single hitbox (GoPit-9ss)
3. [ ] **No bullet patterns** - Just ground slams
4. [ ] **No armor phases** - Always damageable outside transitions
5. [ ] **Basic telegraphs** - Just color flash, no visual area indicators

### Boss Features Present ✅

- ✅ Phase transitions (3 phases)
- ✅ Invulnerability during transitions
- ✅ Attack state machine
- ✅ Add spawning (summon slimes)
- ✅ Camera shake on defeat
- ✅ HP bar integration


---

## Appendix AT: Meta-Progression System Implementation (NEW)

### Pit Coins Earning Formula

```gdscript
earned := wave * 10 + level * 25
```

**Examples:**
- Wave 5, Level 3: 50 + 75 = 125 coins
- Wave 10, Level 5: 100 + 125 = 225 coins

### Permanent Upgrades (5 total)

| ID | Name | Effect | Base Cost | Multiplier | Max Level |
|----|------|--------|-----------|------------|-----------|
| hp | Pit Armor | +10 HP per level | 100 | 2.0x | 5 |
| damage | Ball Power | +2 damage per level | 150 | 2.0x | 5 |
| fire_rate | Rapid Fire | -0.05s cooldown per level | 200 | 2.0x | 5 |
| coin_bonus | Coin Magnet | +10% coins per level | 250 | 2.5x | 4 |
| starting_level | Head Start | Start at higher level | 500 | 3.0x | 3 |

**Cost Scaling Example (Pit Armor):**
- Level 1: 100 coins
- Level 2: 200 coins
- Level 3: 400 coins
- Level 4: 800 coins
- Level 5: 1600 coins
- **Total to max: 3,100 coins**

### Persistence

**Saved to `user://meta.save`:**
- `coins`: Current Pit Coins balance
- `runs`: Total runs completed
- `best_wave`: Highest wave reached
- `upgrades`: Dictionary of upgrade levels

### BallxPit Comparison

| Feature | GoPit | BallxPit |
|---------|-------|----------|
| Permanent upgrades | 5 | 10-15 |
| Character unlocks | No shop | Shop purchase |
| Visual progression | None | Base building |
| Run stats tracked | 3 | Many more |

### Missing Features

1. [ ] **Only 5 upgrades** - Need 10-15 total
2. [ ] **No character unlock shop** - Characters just unlocked/locked
3. [ ] **No visual progression** - No trophy room or base
4. [ ] **Limited stats** - Only coins, runs, best wave
5. [ ] **No achievements** - No milestone rewards


---

## Appendix AU: HUD Implementation (NEW)

### HUD Elements

| Element | Display | Location |
|---------|---------|----------|
| HP Bar | Current/Max HP | Top left |
| Wave Label | "Stage Wave/Total" | Top center |
| Mute Button | Speaker icon toggle | Top right |
| Pause Button | Pause icon | Top right |
| XP Bar | Progress to next level | Below top bar |
| Level Label | "Lv.X" | Next to XP bar |
| Combo Label | "Xx COMBO!" | Center (appears on combo) |

### Combo System Display

- Shows at 2+ combo
- Color coding:
  - White: Normal (< 1.5x)
  - Yellow: 1.5x-2.0x multiplier
  - Red: 2.0x+ multiplier
- Pop animation on increment

### Wave Display Format

```gdscript
"%s %d/%d" % [stage_name, wave_in_stage, waves_before_boss]
# Example: "The Pit 3/10"
```

---

## Appendix AV: Game Controller Flow (NEW)

### Main Scene Wiring

**Input Chain:**
```
Move Joystick → Player.set_movement_input()
Aim Joystick → BallSpawner.set_aim_direction() + AimLine.show_line()
Fire Button → BallSpawner.fire()
Auto Toggle → FireButton.set_autofire()
Ultimate Button → UltimateBlast.execute()
```

**Event Flow on Enemy Death:**
```
Enemy.died →
  ├── _spawn_gem(position, xp_value)
  ├── _maybe_spawn_fusion_reactor(position) [2%+ chance]
  ├── _check_wave_progress()
  ├── GameManager.record_enemy_kill()
  └── GameManager.add_ultimate_charge()
```

### Wave Progression

```gdscript
enemies_per_wave = 5  # Fixed count
enemies_killed_this_wave += 1
if enemies_killed_this_wave >= enemies_per_wave:
    _advance_wave()  # +1 wave, decrease spawn interval by 0.1s
```

### Boss Spawn Trigger

```gdscript
StageManager.boss_wave_reached.connect(_on_boss_wave_reached)
# When wave_in_stage >= waves_before_boss:
#   - Stop enemy spawning
#   - Stop baby ball spawner
#   - Spawn boss
```

### Fusion Reactor Drop Chance

```gdscript
var chance := 0.02 + GameManager.current_wave * 0.001
# Wave 1: 2.1%
# Wave 10: 3.0%
# Wave 50: 7.0%
```

### Auto-Pause on Focus Loss

```gdscript
if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
    if GameManager.current_state == GameManager.GameState.PLAYING:
        pause_overlay.show_pause()
```

### Ball Cleanup

Balls despawning if `y < -50` or `y > viewport_height + 50`


---

## Appendix AW: Music System Implementation (NEW)

### Procedural Music Architecture

GoPit uses **fully procedural audio** - no pre-recorded music files. Everything is generated in real-time.

**Parameters:**
- Sample Rate: 44100 Hz
- BPM: 120
- Beat Duration: 0.5 seconds
- Bar Length: 4 beats

### Music Layers

| Layer | Volume | Purpose |
|-------|--------|---------|
| Bass | -8 dB | Root foundation |
| Drums | -6 dB | Rhythm drive |
| Melody | -10 dB | Occasional accents |

### Patterns

**Bass Pattern (8 beats):**
```
[0, 0, 7, 5, 0, 0, 3, 5]  # Semitones from A2 (110 Hz)
```

**Drum Pattern (8 beats):**
```
[1, 3, 2, 3, 1, 3, 2, 3]  # 1=kick, 2=snare, 3=hihat
```

### Intensity System

```gdscript
set_intensity(wave_number)  # Clamped 1.0-5.0
# Bass: -12dB to -4dB
# Drums: -10dB to -2dB
# Melody appears at intensity >= 2.0 (20% chance per beat)
```

### Sound Synthesis

**Kick Drum:**
- Pitch sweep: 150Hz → 50Hz
- Duration: 0.15s
- Envelope: exponential decay

**Snare:**
- Noise + 200Hz tone
- Duration: 0.12s

**Hi-Hat:**
- High-frequency noise only
- Duration: 0.05s

**Bass Notes:**
- Sine + slight sawtooth
- Sub-octave reinforcement
- Duration: ~0.22s

**Melody:**
- Minor pentatonic scale
- Two octaves above root
- Sine with vibrato

### BallxPit Comparison

| Feature | GoPit | BallxPit |
|---------|-------|----------|
| Audio type | Procedural | Pre-recorded (likely) |
| Music style | Electronic/minimal | Unknown |
| Adaptive intensity | Yes | Unknown |
| File size | 0 bytes | Likely MB of audio |

### Unique Approach

GoPit's procedural audio is actually a **differentiator** - zero audio file dependencies, infinitely scalable, and technically interesting. However:

1. [ ] **No biome-specific music** - Same music in all stages
2. [ ] **No boss music** - No special track for boss fights
3. [ ] **Limited variety** - Single pattern loops


---

## Appendix AX: Visual Feedback Systems (NEW)

### Damage Feedback

**Damage Vignette (`damage_vignette.gd`):**
- Red overlay flash on player damage
- Flash duration: 0.15s
- Max alpha: 0.4
- Low HP warning at ≤30% health (pulsing)

**Damage Numbers (`damage_number.gd`):**
- Float up 60px over 0.6s
- Fade out with 0.2s delay
- Random horizontal spread ±10px
- White for damage, green for XP

### Danger Indicators

**Danger Indicator (`danger_indicator.gd`):**
- Red pulsing bar at screen bottom
- Tracks number of enemies in danger zone
- Pulse: 0.5 → 0.2 alpha over 0.3s loops
- Fades out when danger clears

### Ultimate Blast

**Ultimate Blast (`ultimate_blast.gd`):**
- White flash (0.8 alpha, 0.5s fade)
- Camera shake (intensity 25, decay 4)
- Kills all enemies (9999 damage)
- Duration: 0.6s total

### Particle Effects

**Hit Particles (`hit_particles.gd`):**
- GPU particles (one-shot)
- Auto-cleanup on completion

### Screen Shake

**Camera Shake (`camera_shake.gd`):**
- Random offset within intensity bounds
- Exponential decay (lerp to 0)
- Threshold: 0.1 to stop

### Visual Effects Summary

| Effect | Trigger | Duration |
|--------|---------|----------|
| Damage flash | Player hit | 0.15s |
| Low HP pulse | HP ≤ 30% | Continuous |
| Danger indicator | Enemy near | While active |
| Ultimate flash | Ultimate used | 0.5s |
| Damage numbers | Any damage/XP | 0.6s |
| Hit particles | Ball hits enemy | ~0.3s |
| Camera shake | Various | Variable |

### Missing Effects (vs BallxPit)

1. [ ] **No hit flash on enemies** - Brief white overlay (GoPit-4nsz)
2. [ ] **No ball type trails** - Particle trails per ball type (GoPit-2nle)
3. [ ] **No boss phase VFX** - Transition effects (GoPit-906t)
4. [ ] **No evolution flash** - Full-screen effect for evolutions
5. [ ] **Screen shake toggle missing** - Accessibility option (GoPit-671)


---

## Appendix AY: Status Effect Implementation (NEW)

### Status Effect Types

| Type | Duration | DPS | Tick | Max Stacks | Special |
|------|----------|-----|------|------------|---------|
| Burn | 3.0s × INT | 5.0 | 0.5s | 1 | Refreshes on reapply |
| Freeze | 2.0s × INT × bonus | 0 | - | 1 | 50% slow |
| Poison | 5.0s × INT | 3.0 | 0.5s | 1 | - |
| Bleed | ∞ | 2.0/stack | 0.5s | 5 | Permanent, stacks |

**Note:** Duration scales with character Intelligence stat

### Effect Colors

| Type | Color (RGB multiplier) |
|------|------------------------|
| Burn | (1.5, 0.6, 0.2) Orange |
| Freeze | (0.5, 0.8, 1.3) Ice Blue |
| Poison | (0.4, 1.2, 0.4) Green |
| Bleed | (1.3, 0.3, 0.3) Red |

### Implementation Details

**Damage Calculation:**
```gdscript
# Bleed damage per tick:
damage = damage_per_tick * stacks  # 1.0 * stacks per 0.5s

# Other effects:
damage = damage_per_tick  # Fixed per tick
```

**Freeze Slow:**
```gdscript
slow_multiplier = 0.5  # Enemy speed × 0.5
```

### BallxPit Comparison Gaps

1. [ ] **Freeze missing +25% damage amp** (GoPit-efld)
   - BallxPit: Frozen enemies take 25% more damage
   - GoPit: Only slows, no damage amplification

2. [ ] **Bleed missing on-hit damage** (GoPit-69fj)
   - BallxPit: Each hit on bleeding enemy deals extra damage
   - GoPit: Only DoT (damage over time)

3. [ ] **Burn doesn't stack** (GoPit-ete)
   - BallxPit: 3 stacks max
   - GoPit: 1 stack, refreshes duration

4. [ ] **Poison doesn't stack** (GoPit-m84)
   - BallxPit: 5 stacks max
   - GoPit: 1 stack

5. [ ] **Bleed max stacks too low** (GoPit-vfvv)
   - BallxPit: 8 stacks
   - GoPit: 5 stacks

### Status Effect Proc Sources

| Ball Type | Effect | Chance |
|-----------|--------|--------|
| Burn | BURN | 100% |
| Freeze | FREEZE | 100% |
| Poison | POISON | 100% |
| Bleed | BLEED | 100% |
| Iron | None | - |
| Lightning | None | - |


---

## Appendix AZ: Player System Implementation (NEW)

### Player Stats

| Parameter | Value |
|-----------|-------|
| Move Speed | 300 px/s (× character speed mult) |
| Radius | 35 px |
| Collision Layer | 16 (player) |
| Collision Mask | 12 (enemies + gems) |

### Movement Bounds

```gdscript
bounds_min = Vector2(30, 280)   # Left wall, below TopBar
bounds_max = Vector2(690, 1150) # Right wall, above input area
```

### Visual

- Blue circle body (0.3, 0.7, 1.0)
- Light blue outline (0.5, 0.9, 1.0)
- Direction indicator line (last aim direction)

### Damage Flash

```gdscript
modulate = Color(1.5, 0.5, 0.5)  # Red tint
# Fade back over 0.2s
```

### Missing Features

1. [ ] **No invincibility frames** - Can be hit repeatedly (GoPit-joa)
2. [ ] **No dodge/dash ability** - BallxPit may have evasion
3. [ ] **Fixed player size** - No size upgrades

---

## Appendix BA: Gem System Implementation (NEW)

### Gem Types

| Type | Color | XP | Special |
|------|-------|-----|---------|
| XP Gem | Green (0.2, 0.9, 0.5) | 10 | Standard drop |
| Health Gem | Pink (1.0, 0.4, 0.5) | 0 | Heals 10 HP |

### Movement Parameters

| Parameter | Value |
|-----------|-------|
| Fall Speed | 150 px/s |
| Magnetism Speed | 400 px/s |
| Collection Radius | 40 px |
| Despawn Time | 10s |

### Magnetism System

```gdscript
# Range from GameManager.gem_magnetism_range (upgraded via Magnetism passive)
if distance < magnetism_range:
    pull_strength = 1.0 - (distance / magnetism_range)
    speed = lerp(150, 400, pull_strength)
    # Draw green line to player
```

### Visual Effects

- Diamond shape with sparkle animation
- Glow effect when being attracted
- Highlight sparkle in corner

### BallxPit Comparison

| Feature | GoPit | BallxPit |
|---------|-------|----------|
| Gem types | 2 (XP, Health) | Unknown |
| Magnetism | Upgradeable range | Unknown |
| Auto-collect | No | May have |
| Combo system | Yes (separate) | Unknown |

### Missing Features

1. [ ] **No coin gems** - Meta-currency from gems
2. [ ] **No gem magnet auto-pickup** - Always requires proximity
3. [ ] **Limited gem variety** - Only XP and health


---

## Appendix BB: Game Over and Run Statistics (NEW)

### Game Over Display

**Stats Shown:**
| Stat | Description |
|------|-------------|
| Level | Player level reached |
| Wave | Wave number reached |
| Enemies | Total enemies killed |
| Damage | Total damage dealt |
| Gems | Gems collected |
| Time | MM:SS survived |
| Best Wave | High score wave |
| Best Level | High score level |
| Coins | Pit Coins earned this run |

### High Score Tracking

```gdscript
if GameManager.current_wave >= GameManager.high_score_wave:
    best_text = " (NEW BEST!)"
```

### Coins Earned Formula

```gdscript
earned = wave * 10 + level * 25
# Example: Wave 10, Level 5 = 100 + 125 = 225 coins
```

### Post-Game Options

1. **Shop Button** → Opens MetaShop for permanent upgrades
2. **Restart Button** → Reloads scene, returns to character select

### Run Stats Tracked

```gdscript
GameManager.stats = {
    "enemies_killed": int,
    "damage_dealt": int,
    "gems_collected": int,
    "time_survived": float,
    "balls_fired": int
}
```

### Persistence

| Data | Where Stored |
|------|--------------|
| High scores | GameManager (runtime) |
| Pit Coins | MetaManager → user://meta.save |
| Total runs | MetaManager → user://meta.save |
| Best wave | MetaManager → user://meta.save |

### Missing Features

1. [ ] **No detailed stats history** - Only current run + best
2. [ ] **No achievement unlocks** - No milestones shown (GoPit-mno)
3. [ ] **No leaderboard** - No global or friend rankings
4. [ ] **No replay option** - Can't watch run replay


---

## Appendix BC: Ball Types Complete Reference (NEW)

### Current Ball Types (7 total)

| Type | Damage | Speed | Color | Effect |
|------|--------|-------|-------|--------|
| Basic | 10 | 800 | Blue (0.3, 0.7, 1.0) | None |
| Burn | 8 | 800 | Orange (1.0, 0.5, 0.1) | Burn DoT |
| Freeze | 6 | 800 | Cyan (0.5, 0.9, 1.0) | 50% slow |
| Poison | 7 | 800 | Green (0.4, 0.9, 0.2) | Poison DoT |
| Bleed | 8 | 800 | Dark Red (0.9, 0.2, 0.3) | Stacking damage |
| Lightning | 9 | 900 | Yellow (1.0, 1.0, 0.3) | Chain damage |
| Iron | 15 | 600 | Metallic (0.7, 0.7, 0.75) | Knockback |

### Level Scaling

| Level | Stat Multiplier | Notes |
|-------|-----------------|-------|
| L1 | 1.0x | Base stats |
| L2 | 1.5x | +50% damage and speed |
| L3 | 2.0x | +100%, fusion-ready |

**Example (Burn L3):**
- Damage: 8 × 2.0 = 16
- Speed: 800 × 2.0 = 1600

### Ball Type Distribution

| Effect Type | Ball Types |
|-------------|------------|
| DoT (Damage over Time) | Burn, Poison, Bleed |
| Control | Freeze (slow) |
| Burst | Lightning (chain), Iron (knockback) |
| None | Basic |

### BallxPit Ball Types (for reference)

BallxPit has **18+ ball types** including:
- Wind (pass-through + slow)
- Ghost (pass-through)
- Vampire (lifesteal)
- Dark (self-destruct 3x damage)
- Charm (mind control)
- Cell (clones on bounce)
- Laser (row/column clear)

### Missing Ball Types (Beads Created)

| Ball Type | Effect | Bead |
|-----------|--------|------|
| Wind | Pass-through + slow | GoPit-7ot |
| Ghost | Pass-through enemies | GoPit-4lk |
| Vampire | Lifesteal | GoPit-05b0 |
| Dark | 3x damage self-destruct | GoPit-x8mu |
| Brood Mother | Spawns babies on hit | GoPit-kohr |
| Cell | Clones on bounce | GoPit-mxf1 |
| Laser | Row/column AoE | GoPit-dc3m |
| Charm | Mind control | GoPit-lihc |

### Ownership Model

- **Per-run**: Balls reset each game
- **Starting ball**: Set by character choice
- **Acquisition**: Level-up cards or fission
- **Active selection**: One ball type at a time

### Critical Gap: Ball Slot System

**GoPit:** Fires ONE active ball type per shot
**BallxPit:** Fires 4-5 ball types SIMULTANEOUSLY

This is tracked in bead **GoPit-6zk** (P0 priority).


---

## Appendix BD: Executive Summary - Priority Alignment Roadmap (NEW)

### Document Overview

This comparison document contains **63 appendices** covering every aspect of GoPit's implementation compared to BallxPit. Key findings are summarized below.

### Top 5 Critical Gaps

| Priority | Gap | Impact | Bead |
|----------|-----|--------|------|
| **P0** | Ball slot system | Fundamental gameplay difference | GoPit-6zk |
| **P1** | Bounce damage scaling | Core damage mechanic missing | GoPit-kslj |
| **P1** | Ball return mechanic | Balls despawn instead of return | GoPit-ay9 |
| **P1** | Baby ball inheritance | Babies don't inherit ball type | GoPit-r1r |
| **P1** | Bounce trajectory preview | Aim line doesn't show bounces | GoPit-2ep |

### Systems Comparison Summary

| System | GoPit | BallxPit | Alignment |
|--------|-------|----------|-----------|
| Ball types | 7 | 18+ | 🔴 39% |
| Ball slots | 1 | 4-5 | 🔴 20% |
| Evolutions | 5 | 15+ | 🟡 33% |
| Characters | 6 | 10+ | 🟡 60% |
| Stages | 4 | 8 | 🟡 50% |
| Enemy types | 3 | 5-6 | 🟡 50% |
| Boss types | 1 | 8 | 🔴 13% |
| Permanent upgrades | 5 | 10-15 | 🟡 33% |
| Status effects | 4 | 6+ | 🟡 67% |

### What GoPit Does Well ✅

1. **Procedural audio** - Unique differentiator (no audio files)
2. **Visual feedback** - Damage vignette, particles, shake
3. **Meta-progression** - Pit Coins and permanent upgrades exist
4. **Boss system** - Phases and attacks implemented
5. **Combo system** - XP multiplier on consecutive kills

### Implementation Recommendations

**Phase 1 - Core Mechanics (P0-P1):**
1. Implement ball slot system (4-5 simultaneous types)
2. Add bounce damage scaling (+5% per bounce)
3. Add ball return mechanic
4. Fix baby ball type inheritance
5. Add bounce trajectory preview

**Phase 2 - Content Expansion (P2):**
1. Add 10+ new ball types
2. Add 10+ evolution recipes
3. Add 4+ boss types
4. Fix status effect stacking
5. Add more enemy types

**Phase 3 - Polish (P3):**
1. Add 4 more stages
2. Expand character roster to 10+
3. Add achievement system
4. Add environmental hazards
5. Sound variations

### Beads Summary

| Priority | Count | Focus |
|----------|-------|-------|
| P0 | 1 | Ball slots |
| P1 | 6 | Core mechanics |
| P2 | ~35 | Features & fixes |
| P3 | ~27 | Content & polish |
| **Total** | **69** | All tracked |

### Files Analyzed

- 50+ GDScript files read and documented
- All autoloads (GameManager, StageManager, etc.)
- All UI scripts (overlays, HUD, controls)
- All entity scripts (player, enemies, balls, gems)
- All effect scripts (particles, shake, status)
- All data scripts (characters, biomes, upgrades)

### Conclusion

GoPit has a solid foundation but requires significant work on the **ball slot system** (the #1 fundamental difference) and **bounce mechanics** to align with BallxPit's core gameplay loop. Content expansion (ball types, bosses, stages) can follow once core mechanics are aligned.


---

## Appendix BE: Boss HP Bar UI (NEW)

### Boss HP Bar Features

**Display Elements:**
- Boss name label
- HP progress bar with current/max text
- Phase markers (circles indicating phases 1-3)

### Phase Marker Colors

| State | Color |
|-------|-------|
| Completed | Dim gray (0.2, 0.2, 0.2) |
| Current | Bright red (0.9, 0.2, 0.2) |
| Future | Yellow (0.8, 0.7, 0.2) |

### Visual Feedback

- **On phase change:** HP bar flashes white
- **On boss defeat:** HP bar turns green, fades out
- **Fade in:** 0.3s opacity animation
- **Fade out:** 0.5s opacity animation

### Signal Connections

```gdscript
boss.phase_changed.connect(_on_phase_changed)
boss.boss_defeated.connect(_on_boss_defeated)
```

---

## Appendix BF: Codebase Analysis Completion (NEW)

### Files Analyzed: 44/44 GDScript Files ✅

**Autoloads (7):**
- ✅ game_manager.gd
- ✅ stage_manager.gd
- ✅ ball_registry.gd
- ✅ fusion_registry.gd
- ✅ meta_manager.gd
- ✅ sound_manager.gd
- ✅ music_manager.gd

**UI Scripts (15):**
- ✅ hud.gd, boss_hp_bar.gd
- ✅ character_select.gd
- ✅ level_up_overlay.gd, fusion_overlay.gd
- ✅ pause_overlay.gd, game_over_overlay.gd
- ✅ stage_complete_overlay.gd, tutorial_overlay.gd
- ✅ meta_shop.gd, wave_announcement.gd
- ✅ fire_button.gd, ultimate_button.gd
- ✅ virtual_joystick.gd, aim_line.gd

**Entity Scripts (10):**
- ✅ player.gd, ball.gd, ball_spawner.gd
- ✅ baby_ball_spawner.gd, gem.gd
- ✅ fusion_reactor.gd
- ✅ enemy_base.gd, enemy_spawner.gd
- ✅ slime.gd, crab.gd, bat.gd

**Boss Scripts (2):**
- ✅ boss_base.gd, slime_king.gd

**Effects (7):**
- ✅ status_effect.gd, camera_shake.gd
- ✅ damage_number.gd, damage_vignette.gd
- ✅ danger_indicator.gd, hit_particles.gd
- ✅ ultimate_blast.gd

**Data/Resources (3):**
- ✅ permanent_upgrades.gd
- ✅ biome.gd (resource)
- ✅ character.gd (resource)

**Main Controller (1):**
- ✅ game_controller.gd

### Resource Files Analyzed

- 4 biome .tres files
- 6 character .tres files

### Documentation Complete

All game systems have been analyzed and documented in **66 appendices** totaling **5,200+ lines** of comparison documentation.

---

## Appendix BG: Autofire Mechanics Deep Comparison (NEW)

Research sources:
- [ScreenRant - Should You Use Autofire?](https://screenrant.com/ball-x-pit-should-you-use-autofire/)
- [Deltia's Gaming - Autofire Guide](https://deltiasgaming.com/ball-x-pit-autofire-guide/)
- [Spot Monster - Autofire Guide](https://spot.monster/games/game-guides/ball-x-pit-autofire-guide-2/)

### Critical Architecture Difference

**BallxPit autofire is fundamentally tied to the ball-return system:**

```
BALLXPIT FIRING CYCLE:
┌──────────────────────────────────────────────────────┐
│  1. Ball fired → bounces → hits bottom OR caught    │
│  2. Ball returns to player (appears in queue)       │
│  3. WITH AUTOFIRE: fires immediately when available │
│  4. WITHOUT AUTOFIRE: waits for player input        │
│  5. Repeat                                          │
└──────────────────────────────────────────────────────┘

Fire Rate = How quickly balls return + autofire setting
```

**GoPit autofire uses a simple cooldown timer:**

```
GOPIT FIRING CYCLE:
┌──────────────────────────────────────────────────────┐
│  1. Ball fired → bounces → despawns after max_bounces│
│  2. Cooldown timer starts (0.5s default)            │
│  3. WITH AUTOFIRE: fires immediately when cooldown  │
│  4. WITHOUT AUTOFIRE: waits for button press        │
│  5. Repeat                                          │
└──────────────────────────────────────────────────────┘

Fire Rate = Cooldown timer (fixed, no ball dependency)
```

### BallxPit Autofire Behavior

**Toggle Controls:**
- Default: F key or Mouse Scroll
- Remappable in settings

**When Autofire is ON:**
- Balls fire automatically "as soon as they're collected/returned"
- Both regular and special balls fire in queue order
- Player focuses on movement and dodge
- "Constant damage to enemies"

**When Autofire is OFF:**
- Game displays "current ball queue"
- Player chooses when to fire
- Better for precise shots at concentrated enemies
- Essential for certain characters (Empty Nester, Makeshift Sisyphus)

**Strategic Implications:**
- Autofire ON: "waiting for ball return" = can't spam fire
- Having balls "ready" for crucial moments requires autofire OFF
- Toggle mid-combat is expected gameplay

### GoPit Autofire Behavior

**Location:** `scripts/input/fire_button.gd`

```gdscript
var autofire_enabled: bool = false  # OFF by default

func _process(delta: float) -> void:
    # Autofire: automatically fire when ready
    if autofire_enabled and is_ready and GameManager.current_state == GameManager.GameState.PLAYING:
        _try_fire()
```

**Toggle Controls:**
- Button in HUD (visual toggle)
- No keyboard shortcut

**When Autofire is ON:**
- Fires every `cooldown_duration` seconds (0.5s default)
- No ball availability check - cooldown only
- Character speed multiplier affects cooldown

**When Autofire is OFF:**
- Manual button press required
- Same cooldown applies

### Comparison Table

| Feature | GoPit | BallxPit | Impact |
|---------|-------|----------|--------|
| **Fire gating** | Cooldown timer | Ball availability | **CRITICAL** |
| **Autofire default** | OFF | ON (primary mode) | Different feel |
| **Toggle key** | None (button only) | F / Scroll | Accessibility |
| **Ball queue display** | No | Yes (when manual) | Missing |
| **Strategy** | Always can fire | Wait for returns | Different |
| **Catching effect** | N/A | Faster fire rate | Missing mechanic |

### Gameplay Impact

**BallxPit feels:**
- Strategic (manage ball availability)
- Rewarding (catching = faster DPS)
- Tense (balls out = vulnerable window)
- Thoughtful (save balls for precise shots)

**GoPit feels:**
- Consistent (always same fire rate)
- Simple (no ball management)
- Less dynamic (no catch reward)
- Less tension (always ready to fire)

### Characters Affected by Autofire

**BallxPit:**
- **Empty Nester**: Must turn autofire OFF (fewer balls, precision needed)
- **Makeshift Sisyphus**: Autofire OFF recommended (limited ball count)
- Most characters: Autofire ON works fine

**GoPit:**
- No character-specific autofire considerations
- All characters use same fire rate mechanics

### Recommendations

| Priority | Change | Reason |
|----------|--------|--------|
| **P1** | Implement ball-return system | Foundation for autofire fix |
| **P2** | Change autofire default to ON | Match BallxPit |
| **P2** | Add keyboard toggle (F key) | Match controls |
| **P2** | Add ball queue UI when manual | Show pending balls |
| **P3** | Add character-specific autofire notes | For Empty Nester-style chars |

### Related Beads

- **GoPit-ay9**: Ball return mechanic (P1) - Prerequisite for proper autofire
- **GoPit-7n5**: Autofire default ON (P2)
- **GoPit-6zk**: Ball slot system (P0) - Affects ball availability

---

## Appendix BH: Level Select and Stage Progression System (NEW)

Research sources:
- [GameRant - All Characters & Stage List](https://gamerant.com/ball-x-pit-all-characters-stage-list-unlocks/)
- [Ball x Pit Beginner Guide](https://ballxpit.space/ball-x-pit-beginner-guide)
- [Wikipedia - Ball x Pit](https://en.wikipedia.org/wiki/Ball_x_Pit)

### BallxPit Stage System

**8 Themed Stages:**
| # | Stage Name | Theme |
|---|-----------|-------|
| 1 | The Bone x Yard | Skeleton/undead (default) |
| 2 | The Snowy x Shores | Ice/cold |
| 3 | The Liminal x Desert | Desert/sand |
| 4 | The Fungal x Forest | Mushroom/organic |
| 5 | The Gory x Grasslands | Nature/green |
| 6 | The Smoldering x Depths | Fire/lava |
| 7 | The Heavenly x Gates | Sky/celestial |
| 8 | The Vast x Void | Space/final |

**Unlock Mechanism - Elevator System:**
```
STAGE UNLOCK FLOW:
┌───────────────────────────────────────────────────────────┐
│  1. Complete any stage with a character → earn 1 gear     │
│  2. Different character = different gear                  │
│  3. Gears upgrade elevator to unlock new stages           │
│  4. Stage 2 needs ~2 gears, Stage 8 needs ~5+ gears       │
│  5. 16 characters × 8 stages = 128 possible gear unlocks  │
└───────────────────────────────────────────────────────────┘
```

**Level Select Screen Features:**
- Stage preview with biome visuals
- Lock indicators for unavailable stages
- Gear progress display
- Character completion tracking per stage
- Choose starting stage before run

### GoPit Current Stage System

**4 Biomes (from stage_manager.gd):**
| # | Biome Resource | Name |
|---|---------------|------|
| 1 | the_pit.tres | The Pit (Caverns) |
| 2 | frozen_depths.tres | Frozen Depths |
| 3 | burning_sands.tres | Burning Sands |
| 4 | final_descent.tres | Final Descent |

**Current Implementation:**
```gdscript
# stage_manager.gd - Linear progression only
func _load_stages() -> void:
    stages = [
        preload("res://resources/biomes/the_pit.tres"),
        preload("res://resources/biomes/frozen_depths.tres"),
        preload("res://resources/biomes/burning_sands.tres"),
        preload("res://resources/biomes/final_descent.tres"),
    ]

func complete_stage() -> void:
    current_stage += 1  # Linear advance only
    if current_stage >= stages.size():
        game_won.emit()
```

**What GoPit is Missing:**
1. **No level select screen** - Goes straight to character select
2. **No stage unlock system** - All stages linear in single run
3. **No gear/currency for stage progression**
4. **No replay incentive** - No tracking of character×stage completions
5. **No choose-your-starting-stage** option

### Critical Difference: Meta-Progression

**BallxPit City Builder (New Ballbylon):**
- 70+ unique buildings
- Build character houses to unlock characters
- Buildings grant permanent stat boosts
- Separate progression loop from combat
- Visual base that grows over time
- Blueprints earned by completing runs

**GoPit Meta Shop:**
```gdscript
# meta_shop.gd - Simple upgrade menu
var upgrade_categories := [
    "Max Health",
    "Move Speed",
    "Fire Rate",
    "Ball Damage",
    "XP Multiplier"
]
```
- Menu-based upgrades only
- No visual base building
- No character unlock buildings
- Less engaging progression feel

### Comparison Table

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Total stages** | 4 | 8 | **-4 stages** |
| **Stage selection** | None (linear) | Full level select | **MISSING** |
| **Unlock system** | None | Gear + elevator | **MISSING** |
| **Character×stage tracking** | None | Full matrix | **MISSING** |
| **Meta-progression style** | Menu upgrades | City builder | **Major gap** |
| **Replay incentive** | Low | High (completion %) | **MISSING** |
| **Starting stage choice** | Always stage 1 | Any unlocked | **MISSING** |

### Recommendations

| Priority | Feature | Description |
|----------|---------|-------------|
| **P2** | Add level select screen | Show all stages, locked/unlocked |
| **P2** | Implement gear currency | Earned per character×stage completion |
| **P2** | Stage unlock progression | Require gears to access later stages |
| **P2** | Add 4 more stages | Match BallxPit's 8 stages |
| **P3** | Character completion tracking | Track which chars beat which stages |
| **P3** | Consider city builder | Major feature but high effort |

### Implementation Notes

**Level Select Screen would need:**
```
UI Elements:
- Stage cards/buttons (8 total)
- Gear count display
- Progress percentage
- Lock overlays for unavailable stages
- Character completion icons per stage

Flow Change:
Main Menu → Character Select → Level Select → Game
(instead of)
Main Menu → Character Select → Game (always stage 1)
```

**Minimum Viable Level Select:**
1. Show all stages as buttons
2. Gray out locked stages
3. Display gear count
4. Track highest stage reached per character
5. Allow selecting any unlocked stage as starting point

### Related Beads

- **GoPit-26ll**: Add 4 more stages (P2)
- **GoPit-kohr**: Implement meta-progression city builder (P3)
- **GoPit-ptho**: Level select screen implementation (P2)
- **GoPit-euwy**: Gear currency system (P2)

---

## Appendix BI: Fission/Fusion/Evolution Deep Comparison (NEW)

Research sources:
- [Deltia's Gaming - Fission, Fusion, Evolution Guide](https://deltiasgaming.com/ball-x-pit-fission-fusion-and-evolution-guide/)
- [Steam Community - Fission Chances Discussion](https://steamcommunity.com/app/2062430/discussions/0/595163560549971834/)
- [Ball X Pit Wiki - Balls](https://ballpit.fandom.com/wiki/Balls)

### BallxPit Equipment Slot System

**8 Equipment Slots Total:**
| Slot Type | Count | Max Level | Notes |
|-----------|-------|-----------|-------|
| Ball slots | 4 | L3 | Different ball types fired SIMULTANEOUSLY |
| Perk slots | 4 | L3 | Passive abilities |

This is the **fundamental architecture difference** - BallxPit fires 4 ball types at once, GoPit fires 1.

### BallxPit Fission (Confirmed Details)

**From Deltia's Gaming:**
> "Fission serves the primary purpose of randomly upgrading any of your currently equipped balls or perks by one level. There is a maximum cap of five items you can upgrade through a single Fission."

**Key Mechanics:**
```
FISSION MECHANICS:
┌───────────────────────────────────────────────────────────┐
│  • Upgrades balls AND/OR perks (8 slots total)            │
│  • Random 1-5 upgrades per Fission                        │
│  • Each upgrade = +1 level (max L3)                       │
│  • Number depends on: slot count × current levels         │
│  • If all 8 slots maxed → Fission option DISAPPEARS       │
│  • Only reappears after Fusion/Evolution frees a slot     │
└───────────────────────────────────────────────────────────┘
```

**Candle Maker Building Upgrades:**
- Default range: 1-5 upgrades
- Upgrade 1: Range becomes 2-5
- Upgrade 2: Range becomes 3-5

### BallxPit Fusion (Confirmed Details)

**From Deltia's Gaming:**
> "Fusion is the process of combining two balls and their properties to create something entirely new, unique, and more powerful. The requirement for this is that both balls must be at their maximum level of 3. Once the balls are fused, they can no longer be used for fusion again."

**Key Mechanics:**
- Requires: 2 balls at L3
- Creates: New fused ball with combined properties
- Result: Fused ball CANNOT be fused again
- Opens: One slot (2 L3 balls → 1 fused ball)

### BallxPit Evolution (Confirmed Details)

**From Deltia's Gaming:**
> "Evolution is used to combine two balls to create a new evolved ball. What differentiates this from Fusion is that you cannot combine any two balls at random. Both balls need to be compatible and at their maximum level of 3."

**Key Differences: Fusion vs Evolution:**
| Aspect | Fusion | Evolution |
|--------|--------|-----------|
| Ball requirement | Any 2 L3 balls | Specific recipe |
| Result | Combined properties | New unique ball |
| Slot effect | Frees 1 slot | Frees 1 slot |
| Total recipes | Any combo | 42 specific recipes |

### GoPit Implementation Analysis

**Fission (fusion_registry.gd:304-334):**
```gdscript
func apply_fission() -> Dictionary:
    # Random number of upgrades (1-3)  ← WRONG: Should be 1-5
    var num_upgrades := randi_range(1, 3)

    for i in num_upgrades:
        # 60% chance to level up owned ball, 40% chance new ball
        # NOTE: No perk upgrades - only balls
```

**Critical Gaps:**
| Aspect | GoPit | BallxPit | Status |
|--------|-------|----------|--------|
| **Upgrade range** | 1-3 | 1-5 | **WRONG** |
| **Upgrades perks** | No | Yes | **MISSING** |
| **Ball slots** | 1 active | 4 simultaneous | **CRITICAL** |
| **When all maxed** | Gives XP | Option hidden | Different |
| **Building upgrades** | N/A | Candle Maker | **MISSING** |

**Fusion Implementation:**
- ✅ Requires 2 L3 balls
- ✅ Creates combined ball with both effects
- ⚠️ Single active ball (not 4 slots)

**Evolution Implementation:**
- ✅ Recipe-based combinations
- ✅ Creates unique evolved balls
- ❌ Only 4 evolved types vs BallxPit's 42

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P0** | Implement 4-ball slot system | Core architecture change |
| **P1** | Increase fission range to 1-5 | Match BallxPit |
| **P2** | Add perk system | 4 perk slots, fission upgrades them |
| **P2** | Add 38+ more evolved balls | Match BallxPit's 42 |
| **P3** | Add Candle Maker building | Improves fission range |

---

## Appendix BJ: Fast Mode and Difficulty Scaling (NEW)

Research sources:
- [Ball x Pit Fast Mode Guide](https://ballxpit.org/guides/fast-mode/)
- [New Game Plus Guide](https://ballxpit.org/guides/new-game-plus/)
- [Steam Community - Speed Scaling](https://steamcommunity.com/app/2062430/discussions/0/624436409752945056/)

### BallxPit Speed/Difficulty System

**4 Speed Tiers (toggleable mid-game):**
| Speed | Multiplier | Spawn Rate | Loot Quality | Run Time |
|-------|------------|------------|--------------|----------|
| Normal | 1.0x | Standard | Standard | 15-20 min |
| Fast | 1.5x | Faster | +25% | 10-13 min |
| Fast+2 | 2.5x | Aggressive | +50% | 8-10 min |
| Fast+3 | 4.0x+ | Overwhelming | +100% | 6-8 min |

**Toggle Controls:**
- PS5: R1
- Xbox: RB
- PC: R key

**Strategic Speed Switching:**
```
RECOMMENDED SPEED STRATEGY:
┌───────────────────────────────────────────────────────────┐
│  Waves 1-10:  Speed 3 (farming easy waves quickly)        │
│  Waves 10-15: Speed 2 (moderate difficulty)               │
│  Boss waves:  Speed 1 (reaction time for dodging)         │
│  Laser sections: Speed 1 (precision needed)               │
└───────────────────────────────────────────────────────────┘
```

### New Game Plus Scaling

- All enemies: +50% HP
- All enemies: +50% damage
- Scales exponentially in late-game

### GoPit Current Difficulty System

**No speed toggle system.**

```gdscript
# game_manager.gd
var character_speed_mult: float = 1.0  # Affects character only, not game

# Difficulty scales implicitly via wave count
# No player-controllable speed/difficulty setting
```

### Comparison Table

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Speed toggle** | None | 4 levels (R key) | **MISSING** |
| **Loot scaling** | None | +25% to +100% | **MISSING** |
| **Risk/reward** | Fixed | Player choice | **MISSING** |
| **NG+ mode** | None | +50% HP/damage | **MISSING** |
| **Mid-game adjustment** | None | Dynamic switching | **MISSING** |

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P2** | Add speed toggle (1x, 1.5x, 2x) | Core gameplay feature |
| **P2** | Scale loot with speed | Risk/reward balance |
| **P2** | Add NG+ mode | Post-victory challenge |

---

## Appendix BK: Status Effect Stacking Mechanics (NEW)

Research sources:
- [Advanced Mechanics Guide](https://ballxpit.org/guides/advanced-mechanics/)

### BallxPit Status Effect Stack Caps

| Effect | Max Stacks | Damage Amp | Notes |
|--------|------------|------------|-------|
| Radiation | 5 | +10%/stack | +50% total at max |
| Frostburn | 4 | +25% flat | Not per stack |
| Bleed | 24 | N/A | Hemorrhage at 12+ |
| Burn | 5 | N/A | DoT |
| Poison | 8 | N/A | DoT |
| Disease | 8 | N/A | DoT, 6s duration |

**Hemorrhage Mechanic (Critical):**
```
At 12+ bleed stacks:
→ Triggers Hemorrhage explosion
→ Deals 20% of enemy's CURRENT HP as damage
→ More valuable on full-health targets
→ Stacks with damage amplification (+75% amp = 35% current HP)
```

### Damage Amplification Math

```
Nuclear Bomb (radiation): +50% damage taken
Frozen Flame (frostburn): +25% damage taken
Combined: +75% amplification

Example: 36 base damage × 1.75 = 63 damage
Applies to ALL damage sources including DoTs
```

### GoPit Status Effect Gaps

| Mechanic | BallxPit | GoPit | Status |
|----------|----------|-------|--------|
| **Stack caps** | Defined per effect | None | **MISSING** |
| **Damage amp (Freeze)** | +25% | None | **GoPit-efld** |
| **Radiation** | +10%/stack | N/A | **MISSING** |
| **Hemorrhage** | 20% HP at 12 stacks | None | **MISSING** |

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P1** | Add Freeze damage amp | GoPit-efld |
| **P2** | Add stack caps | Prevent infinite stacking |
| **P2** | Add Hemorrhage | 12+ bleed = % HP damage |

---

## Appendix BL: Passive/Perk System Comparison (NEW)

Research sources:
- [GameRant - All Passives List](https://gamerant.com/ball-x-pit-all-passives-list/)
- [Ball X Pit Wiki - Passives](https://ballpit.fandom.com/wiki/Passives)

### BallxPit Passive System Overview

**Scale:**
- **51 Base Passives**
- **8 Evolved Passives**
- **59 Total Passives**
- **4 passive slots** (alongside 4 ball slots)

**How Passives Work:**
```
PASSIVE ACQUISITION:
┌───────────────────────────────────────────────────────────┐
│  1. Level up → offered passive choices                    │
│  2. Select passive → goes into one of 4 slots             │
│  3. Fission can upgrade passives to L2, L3                │
│  4. Some passives can EVOLVE at Fusion Reactor            │
│  5. Max 3 evolved passives per run                        │
└───────────────────────────────────────────────────────────┘
```

### BallxPit Passive Categories

| Category | Count | Examples |
|----------|-------|----------|
| Offensive | 9 | War Horn, Dynamite, Silver Bullet |
| Defensive | 5 | Breastplate, Crown of Thorns |
| Mobility | 5 | Fleet Feet, Radiant Feather |
| Summoned Allies | 5 | Turret, Archer's Effigy |
| Status Effects | 5 | Frozen Spike, Voodoo Doll |
| Other | 22 | Baby Rattle, Gemspring, etc. |

### 8 Evolved Passives (Recipes)

| Evolved Passive | Recipe | Effect |
|-----------------|--------|--------|
| **Soul Reaver** | Vampiric Sword + Everflowing Goblet | Lifesteal + overhealing |
| **Wings of the Anointed** | Radiant Feather + Fleet Feet | +20% move, +40% ball speed |
| **Deadeye's Cross** | 4 Hilted Daggers | 60% base crit |
| **Cornucopia** | Baby Rattle + War Horn | Resource generation |
| **Gracious Impaler** | Reacher's Spear + Deadeye's Amulet | Instant kill synergy |
| **Phantom Regalia** | Ghostly Corset + Ethereal Cloak | +50% piercing |
| **Odiferous Shell** | Wretched Onion + Breastplate | Defense + AoE |
| **Tormenters Mask** | Spiked Collar + Crown of Thorns | Thorns damage |

### GoPit: NO Passive System

**GoPit has no separate passive slots:**
- Characters have 1 built-in passive
- No passive choices on level up
- Fission only upgrades balls
- No passive evolution

### Comparison

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Passive slots** | 0 | 4 | **CRITICAL** |
| **Base passives** | 0 | 51 | **CRITICAL** |
| **Evolved passives** | 0 | 8 | **MISSING** |
| **Fission upgrades** | Balls only | Balls + Passives | **MISSING** |

### Notable BallxPit Passives

- **War Horn**: +20% baby ball damage
- **Bouncing Speed**: Balls start 70% speed, +20% per bounce (max 200%)
- **Gem Baby Ball**: 25% chance to shoot baby ball on gem pickup
- **Fire Synergy**: +10-20 fire damage to burning enemies

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P1** | Add 4 passive slots | Core system |
| **P1** | Create 20+ base passives | Minimum viable |
| **P2** | Add passive evolution | 4+ evolved passives |
| **P2** | Fission upgrades passives | Match BallxPit |

---

## Appendix BM: Character System Comparison (NEW)

Research sources:
- [GameRant - All Characters](https://gamerant.com/ball-x-pit-all-characters-stage-list-unlocks/)
- [Ball X Pit Wiki - Characters](https://ballpit.fandom.com/wiki/Characters)

### BallxPit: 16 Characters

| Character | Ability |
|-----------|---------|
| **The Warrior** | None (starter) |
| **The Itchy Finger** | 2x fire rate, move while shooting |
| **The Repentant** | +5% dmg/bounce, balls return |
| **The Cohabitants** | Mirrored balls, half damage |
| **The Cogitator** | Auto-chooses upgrades |
| **The Embedded** | Balls pierce until walls |
| **The Shade** | 10% crit, shoot from behind |
| **The Shieldbearer** | Shield reflects, +100% dmg/reflect |
| **The Spendthrift** | All balls at once, wide arc |
| **The Juggler** | Lob balls, bounce on ground |
| **The Empty Nester** | Multiple special balls, no babies |
| **The Flagellant** | Balls bounce off bottom |
| **The Makeshift Sisyphus** | 4x AOE/status, no direct dmg |
| **The Physicist** | Gravity affects balls |
| **The Tactician** | Turn-based combat |
| **The Radical** | AI plays automatically |

**Key: Many characters CHANGE FUNDAMENTAL GAMEPLAY**

### GoPit: 6 Characters

| Character | Passive | Starting Ball |
|-----------|---------|---------------|
| **Rookie** | +10% XP gain | Basic |
| **Pyro** | +20% fire dmg, +25% burn amp | Burn |
| **Frost Mage** | +50% frozen dmg, +30% duration | Freeze |
| **Tactician** | +2 babies, +30% spawn | Basic |
| **Vampire** | 5% lifesteal, 20% health gem | Basic |
| **Gambler** | 3x crit, +15% crit chance | Bleed |

**Key: All characters use SAME core mechanics**

### Critical Difference

**BallxPit gameplay-altering abilities:**
- Turn-based mode (Tactician)
- AI auto-play (Radical)
- No baby balls (Empty Nester, Sisyphus)
- Gravity physics (Physicist)
- Shield reflection (Shieldbearer)

**GoPit abilities are stat modifiers only:**
- Damage multipliers
- Crit bonuses
- Healing effects
- No fundamental gameplay changes

### Comparison

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Characters** | 6 | 16 | **-10** |
| **Gameplay-changing** | 0 | ~6 | **MISSING** |
| **Starting ball types** | 4 | 15+ | **-11** |
| **Unlock via building** | No | Yes | **MISSING** |

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P2** | Add 10 characters | Match count |
| **P2** | Add gameplay-altering chars | Not just stats |
| **P3** | Turn-based character | Like Tactician |
| **P3** | Auto-play character | Like Radical |

---

## Appendix BN: Controls and Input System Comparison (NEW)

Research sources:
- [Deltia's Gaming - Ball x Pit Controls](https://deltiasgaming.com/ball-x-pit-controls/)

### BallxPit Gameplay Controls

| Action | Primary | Alternate |
|--------|---------|-----------|
| Move Up | W | Up Arrow |
| Move Left | A | Left Arrow |
| Move Down | S | Down Arrow |
| Move Right | D | Right Arrow |
| Pause | Esc | - |
| **Shoot** | Space | Left Click |
| **Autofire Toggle** | F | Scroll Click |
| **Increase Game Speed** | + | - |
| **Decrease Game Speed** | - | - |

### BallxPit Base Management Controls

| Action | Control |
|--------|---------|
| Dismantle Building | Right Click |
| Highlight Upgradeable | Tab |
| Rotate Building | R |
| Zoom In | + |
| Zoom Out | - |

### BallxPit Harvest Controls

| Action | Control |
|--------|---------|
| Speed Up Harvest | Right Click |
| Cancel Harvest | Esc |
| View Workers | E |

### GoPit Controls

**Current implementation (fire_button.gd):**
- Touch/tap: Fire button
- Touch/tap: Autofire toggle button
- Touch joysticks: Movement and aiming
- **No keyboard shortcuts**
- **No game speed controls**

### Comparison Table

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **WASD movement** | No | Yes | Mobile-focused |
| **Keyboard shoot** | No | Space/Click | **MISSING** |
| **Autofire hotkey** | No | F key | **MISSING** |
| **Speed control** | No | +/- keys | **MISSING** |
| **Remappable keys** | No | Yes | **MISSING** |
| **Base management** | N/A | Full system | N/A (no city builder) |

### Critical Insight: Two Game Modes

**BallxPit has THREE distinct control schemes:**
1. **Gameplay** - Combat/wave survival
2. **Base Management** - City builder mode
3. **Harvest** - Resource gathering

**GoPit is combat-only** with no base/harvest systems.

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P2** | Add keyboard controls | WASD, Space, F |
| **P2** | Add speed +/- controls | Match BallxPit |
| **P3** | Add key remapping | Accessibility |
| **P3** | Consider city builder | Major scope |

---

## Appendix BO: City Builder and Base Management (NEW)

### BallxPit City Builder Overview

**"New Ballbylon"** - A full city builder between combat runs:

**Scale:**
- **70+ unique buildings**
- Building placement, rotation, dismantling
- Upgradeable buildings (D→C→B→A→S ranks)
- Workers for resource harvesting
- Visual base that grows over time

### Building Categories

**Stat Buildings (6):**
| Building | Stat | Effect |
|----------|------|--------|
| Intelligence Building | Intelligence | AOE damage |
| Strength Building | Strength | Direct damage |
| Endurance Building | Endurance | HP/defense |
| Leadership Building | Leadership | Baby ball power |
| Dexterity Building | Dexterity | Crit/accuracy |
| Speed Building | Speed | Movement/fire rate |

**Character Houses:**
- Build specific houses to unlock characters
- Blueprints from completing stages
- Each character has unique house

**Special Buildings:**
- **Candle Maker**: Improves Fission range (2-5 → 3-5)
- **Fusion Reactor upgrades**: Improve fusion options
- Various utility buildings

### Harvest System

- Workers assigned to resource gathering
- Right-click to speed up harvest
- Resources used to build/upgrade
- Economy loop between combat and building

### GoPit Meta-Progression

**Current (meta_shop.gd):**
```
Menu-based upgrades only:
- Max Health
- Move Speed
- Fire Rate
- Ball Damage
- XP Multiplier
```

**No:**
- Visual base
- Building placement
- Workers/harvest
- House-based character unlocks

### Comparison

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Visual base** | No | Yes | **MISSING** |
| **Buildings** | 0 | 70+ | **CRITICAL** |
| **Building upgrades** | N/A | D→S ranks | **MISSING** |
| **Workers/harvest** | No | Yes | **MISSING** |
| **Character houses** | No | Yes | **MISSING** |
| **Stat buildings** | No | 6 types | **MISSING** |

### Implementation Complexity

**City builder is a MAJOR feature:**
- Separate game mode/scene
- Save/load building state
- Resource economy
- Worker AI
- Building placement grid

**Minimum Viable Alternative:**
- Upgrade menu (current approach)
- Add building "unlock" displays
- Visual "town" background that grows

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P3** | Add visual base (static) | Grows with upgrades |
| **P3** | Add character houses | Visual unlock display |
| **P4** | Full city builder | Major feature, low priority |

### Related Beads

- **GoPit-kohr**: City builder meta-progression (P3)

---

## Appendix BP: Achievement System and Game Structure (NEW)

Research sources:
- [Deltia's Gaming - All Achievements](https://deltiasgaming.com/ball-x-pit-achievements/)

### BallxPit: 63 Total Achievements

The achievement list reveals the full game structure.

### Stage Achievements (16)

**8 First Completions + 8 Conquests (10 chars each):**
| Stage | First Complete | Conquest |
|-------|---------------|----------|
| BONExYARD | ✓ | 10 characters |
| SNOWYxSHORES | ✓ | 10 characters |
| LIMINALxDESERT | ✓ | 10 characters |
| GORYxGRASSLANDS | ✓ | 10 characters |
| FUNGALxFOREST | ✓ | 10 characters |
| SMOLDERINGxDEPTHS | ✓ | 10 characters |
| HEAVENLYxGATES | ✓ | 10 characters |
| VASTxVOID | ✓ | 10 characters |

### Character Achievements (16)

Complete all stages with each character:
- True Warrior, Repentance, Itch Scratched, Cogitate
- Master General, All Spent, Embedder, Radicalized
- Golden Years, Long Shadow, Unpacked, Gravity's Rainbow
- Brick Breaker, Herculean, Masochist, Entertainer

### Resource Achievements (8)

**4 Resource Types:**
| Resource | Total | Single Harvest |
|----------|-------|----------------|
| Gold | 5000 | 1000 |
| Wheat | 1000 | 100 |
| Wood | 1000 | 100 |
| Stone | 1000 | 100 |

### Building Achievements (10)

- Trophy, Monument, Worker's Guild, Evolution Chamber
- Relic Collector, Bag Maker, Carpenter
- Structural Power (+5 stat bonus)
- Land Grabber (5 expansions)
- Neighborhood (15 housing)

### Evolution Achievements (5)

Nuclear Bomb, Nosferatu, Satan, Soul Reaver, Deadeye's Cross

### Milestones

- **Legion Slayer**: 100,000 kills
- **S Rank**: Max stat scaling
- **Scholar**: Complete Encyclopedia
- **Ballbylon Has Risen**: Complete game

### GoPit: No Achievements

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Achievements** | 0 | 63 | **CRITICAL** |
| **Stage tracking** | None | 16 | **MISSING** |
| **Character tracking** | None | 16 | **MISSING** |

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P3** | Add achievement system | Track milestones |
| **P3** | Track char×stage matrix | Completion tracking |

---

## Appendix BQ: Save System and Stage Progression Details (NEW)

Research sources:
- [Deltia's Gaming - Save Slots Guide](https://deltiasgaming.com/ball-x-pit-save-slots/)

### Stage Unlock System (Confirmed)

**Gear Requirements:**
```
STAGE PROGRESSION:
┌───────────────────────────────────────────────────────────┐
│  1. Complete a stage with Character A → earn 1 gear       │
│  2. Complete SAME stage with Character B → earn 2nd gear  │
│  3. 2 gears unlock the NEXT stage                         │
│  4. Each stage boss awards a Trophy Building blueprint    │
└───────────────────────────────────────────────────────────┘
```

**This means:**
- You MUST complete each stage with 2 different characters to progress
- Incentivizes trying multiple characters early
- Natural tutorial for character variety

### Stage Bosses (Confirmed)

| Stage | Boss | Reward |
|-------|------|--------|
| BONExYARD | Skeleton King | Boneyard Trophy Building |
| SNOWYxSHORES | Icebound Queen | Snowy Trophy Building |
| (Others) | (Unknown) | Trophy Buildings |

### Trophy Buildings

- Each stage has a corresponding Trophy Building
- Blueprint awarded on first boss defeat
- Provides permanent bonuses when built
- Completing stage with ALL characters maximizes benefit

### Save Slot System

**BallxPit supports multiple save files:**
- Create new saves from main menu
- Delete saves with confirmation
- Tutorial can be skipped (Esc)
- Base tutorial is required

**GoPit has single implicit save:**
- Auto-save only
- No save slot management
- No manual save/load

### Comparison

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Gear unlock** | None | 2 per stage | **MISSING** |
| **Stage bosses** | 1 (Slime King) | 8 unique | **-7 bosses** |
| **Trophy buildings** | None | 8 | **MISSING** |
| **Save slots** | 1 implicit | Multiple | **MISSING** |
| **Progression gate** | Linear | Gear-gated | Different |

### Key Insight: Forced Character Variety

BallxPit's 2-gear requirement FORCES players to:
- Try at least 2 characters per stage
- Discover character strengths/weaknesses
- Engage with the full roster

GoPit allows single-character runs with no variety incentive.

### GoPit Boss Implementation

**Current (slime_king.gd):**
- Only 1 boss: Slime King
- Appears at end of first biome
- No boss-specific rewards

**Missing:**
- 7 more unique bosses
- Trophy building system
- Boss-specific blueprints

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P1** | Add gear requirement (2 per stage) | Force character variety |
| **P2** | Add 7 more bosses | One per stage |
| **P3** | Add trophy building rewards | Boss completion bonuses |
| **P3** | Add save slot management | Multiple saves |

---

## Appendix BR: Blueprint and Building Harvest System (NEW)

Research sources:
- [Deltia's Gaming - Blueprints Guide](https://deltiasgaming.com/ball-x-pit-blueprints/)

### Level Structure (Confirmed)

**Each level has 3 bosses:**
```
LEVEL STRUCTURE:
┌───────────────────────────────────────────────────────────┐
│  Mini-boss 1 → Blueprint drop                             │
│  Mini-boss 2 → Blueprint drop                             │
│  Final Boss  → Blueprint drop (first kill = Trophy)       │
└───────────────────────────────────────────────────────────┘
```

**8 levels × 3 bosses = 24 boss encounters total**

### Blueprint Types

| Type | Source | Purpose |
|------|--------|---------|
| **Trophy** | First final boss kill | Special building |
| **Warfare** | Subsequent boss kills | Combat buildings |
| **Housing** | Subsequent boss kills | Character houses |

### Building Categories

**Warfare Buildings:**
- Combat stat boosts
- Unlock combat abilities

**Housing Buildings:**
- Unlock new characters
- Each character has specific house

**Trophy Buildings:**
- Unique per-stage rewards
- Special bonuses

### Harvest Mechanic (KEY INSIGHT)

**Buildings require "harvesting" to activate:**
```
HARVEST PROCESS:
┌───────────────────────────────────────────────────────────┐
│  1. Construct building with blueprint + resources         │
│  2. Place building where workers can reach                │
│  3. Click "Harvest" button                                │
│  4. Workers BOUNCE BALLS at building                      │
│  5. Hit building enough times → unlocks abilities         │
└───────────────────────────────────────────────────────────┘
```

**The ball-bouncing mechanic extends to the city builder!**
- Workers aim and shoot at buildings
- Buildings "unlock" through hits
- Same core mechanic, different context

### GoPit Comparison

| Feature | GoPit | BallxPit | Gap |
|---------|-------|----------|-----|
| **Mini-bosses** | 0 | 2 per level | **MISSING** |
| **Boss count** | 1 total | 24 total | **-23** |
| **Blueprints** | None | 3 types | **MISSING** |
| **Building harvest** | N/A | Ball-bounce | Unique |
| **Building activation** | N/A | Hit-based | Unique |

### Design Philosophy

BallxPit uses its **core mechanic everywhere**:
- Combat: Bounce balls at enemies
- Boss fights: Bounce balls at bosses
- City builder: Bounce balls at buildings
- Harvesting: Workers bounce balls

**This creates unified game feel across all systems.**

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P2** | Add 2 mini-bosses per stage | Match structure |
| **P3** | Consider ball-based meta UI | Thematic consistency |

---

## Appendix BS: Shop and Currency Systems (NEW)

Research sources:
- [BallxPit Harvest Guide](https://ballxpit.org/guides/harvest-guide/)
- [BallxPit Resource Farming](https://ballxpit.org/guides/resource-farming/)
- [Deltia's Gold Mine Guide](https://deltiasgaming.com/ball-x-pit-gold-mine-guide/)

### BallxPit Economy Overview

**Four Core Resources:**

| Resource | Earning Method | Spending | Priority |
|----------|----------------|----------|----------|
| **Gold** | Gold Mines (7 optimal) | Buildings, Market purchases, upgrades | **PRIMARY** |
| **Wheat** | Wheat Fields (3-5) | Early construction, character houses | Early game |
| **Wood** | Forests (2-3) | All construction (10-50+ per building) | Mid game |
| **Stone** | Quarries (2-4) | Upgrades, S-Rank stat buildings (300-500) | Late game |

**Economy Phases:**
- **Early (Waves 1-15):** Wheat/Wood/Stone farming, first gold mines
- **Mid (Waves 15-30):** Gold priority (7 mines = 1,500+ gold/harvest), Market unlocked
- **Late (Waves 30+):** Gold = ONLY currency, 13-16 chars on mines, 25K-35K gold/hour

**The Market:**
- Unlocks mid-game (500 gold + resources)
- Transforms economy: buy any resource with gold
- Makes wheat/wood/stone farming obsolete

### In-Run Currency: XP Only

**BallxPit has NO in-run shop:**
- Upgrades from level-ups (XP → choose upgrade)
- Fusion Reactors dropped by enemies
- Guaranteed Fusion after stage bosses
- No vendor, no in-run purchases

### GoPit Economy

**Single Currency: Pit Coins**
- Earned: `wave * 10 + level * 25`

**Permanent Upgrades (5 total):**
| Upgrade | Effect | Max Level |
|---------|--------|-----------|
| Pit Armor | +10 HP | 5 |
| Ball Power | +2 damage | 5 |
| Rapid Fire | -0.05s cooldown | 5 |
| Coin Magnet | +10% coins | 4 |
| Head Start | Start at level X | 3 |

### CRITICAL GAPS

| Feature | GoPit | BallxPit | Priority |
|---------|-------|----------|----------|
| **Resource variety** | 1 (coins) | 4 (gold/wheat/wood/stone) | P2 |
| **Meta upgrades** | 5 types | 70+ buildings | **CRITICAL** |
| **Harvest system** | None | Full minigame | P2 |
| **Market building** | None | Currency conversion | P3 |
| **In-run shop** | None | None | ✅ Aligned |
| **XP → Level-up** | Yes | Yes | ✅ Aligned |

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P2** | Expand meta upgrades | 15-20 permanent upgrades |
| **P2** | Add resource variety | 2-3 resource types |
| **P3** | Add harvest minigame | Between-run engagement |

---

## Appendix BU: Gameplay Strategy and Ball Catching Mechanic

Research source:
- [5 Tips to Survive Rounds](https://ballxpit.org/guides/5-tips-to-survive-rounds/)

### The Ball Catching Skill Gap

**CRITICAL DISCOVERY:** BallxPit has a skill-based ball catching mechanic that GoPit completely lacks.

```
╔══════════════════════════════════════════════════════════════════╗
║  BALLXPIT: Balls RETURN to player and must be CAUGHT             ║
║  GOPIT:    Balls despawn after max_bounces (no return)           ║
╚══════════════════════════════════════════════════════════════════╝
```

### How Ball Return Works in BallxPit

1. **Fire balls forward** → they bounce off walls and enemies
2. **Balls return toward player** after hitting back wall
3. **Player must CATCH returning balls** to reload them
4. **Missing a catch = downtime** → balls continue bouncing until caught

**This creates a rhythm-action skill layer:**
- Fast players can rapid-fire by staying in ball path
- Slow reactions = wasted offensive time
- Positioning affects catch timing

### Pro Positioning Strategy

From the survival guide:

| Tip | Strategy | Why It Works |
|-----|----------|--------------|
| **Stay at TOP** | Position near top of screen | Balls return faster, enemies below you |
| **Shoot BEHIND** | Aim through gaps in enemy lines | Hit back-row enemies, multi-bounce damage |
| **Wait for potions** | Let health drops fall before collecting | Don't waste healing at full HP |
| **Level special balls** | Prioritize special ball upgrades | Synergy with bounce damage |

### The Catch Mechanic Creates Gameplay Depth

**Without catching (GoPit):**
- Fire and forget
- No positioning skill
- Passive gameplay

**With catching (BallxPit):**
- Active ball management
- Position affects DPS
- Skill ceiling for advanced players
- Missing catches = punishment

### GoPit Current State

```gdscript
# From ball.gd - balls just despawn
func _on_bounce():
    bounces += 1
    if bounces >= max_bounces:
        queue_free()  # No return to player!
```

### CRITICAL GAP

| Mechanic | GoPit | BallxPit | Priority |
|----------|-------|----------|----------|
| **Ball return** | ❌ None | ✅ Full | **P1** |
| **Catch mechanic** | ❌ None | ✅ Skill-based | **P1** |
| **Position matters** | ⚠️ Minimal | ✅ Strategic | **P1** |
| **Miss penalty** | ❌ None | ✅ Lost DPS | **P1** |

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P1** | Implement ball return | Balls travel back toward player after back wall |
| **P1** | Add catch hitbox | Player catches balls to reload |
| **P1** | Add catch feedback | Visual/audio on successful catch |
| **P2** | Add miss tracking | Stats for catch rate |

**This reinforces GoPit-ay9 as P1 priority - ball return isn't just about visual consistency, it's a core skill mechanic.**

---

## Appendix BV: New Game Plus (NG+) System

Research source:
- [New Game Plus Guide](https://ballxpit.org/guides/new-game-plus/)

### BallxPit NG+ Overview

**Unlock Requirements:**
- Complete all 8 biomes on Normal difficulty
- Defeat final boss of biome 8
- Reach Wave 50+

### NG+ Difficulty Changes

| Aspect | Normal Mode | NG+ Mode | Change |
|--------|-------------|----------|--------|
| Enemy HP | 100% | 150% | +50% |
| Enemy Damage | 100% | 150% | +50% |
| Checkpoints | Every 10 waves | **NONE** | Removed entirely |
| Boss Fight Duration | 2-3 minutes | 4-5 minutes | ~2x longer |
| Resource Costs | 1x | 2-3x | Major increase |

### The Checkpoint Removal

**Critical difference:**
- Normal: Die at Wave 40 → Restart from Wave 40
- NG+: Die at Wave 40 → **Restart from Wave 1**

This transforms the game from "progress-saving" to "roguelike permadeath."

### Resource Scaling in NG+

| Resource Strategy | Normal | NG+ |
|-------------------|--------|-----|
| Gold Mines | 7 | 9-10 minimum |
| Gold Buffer | 2,000 | 5,000+ |
| Upgrade Priority | Flexible | Critical |

### GoPit NG+ Status

**Current State:** No NG+ system exists.

GoPit has:
- ❌ No difficulty scaling post-completion
- ❌ No checkpoint system (so can't "remove" it)
- ❌ No replayability incentive

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P3** | Add NG+ mode | Unlock after completing all stages |
| **P3** | Implement +50% enemy scaling | Match BallxPit formula |
| **P3** | Add achievement integration | "Flawless NG+ Run" |

---

## Appendix BW: Advanced Stacking and Damage Amplification

Research source:
- [Advanced Mechanics Guide](https://ballxpit.org/guides/advanced-mechanics/)

### Complete Status Effect Stacking Caps

| Effect | Max Stacks | Damage/Effect | Notes |
|--------|-----------|---------------|-------|
| **Radiation** | 5 | +10%/stack (max +50%) | Multiplicative to ALL damage |
| **Disease** | 8 | 3-6 dmg/sec + 15% spread | Spreads to nearby enemies |
| **Frostburn** | 4 | 8-12 dmg/sec + 25% amp | 20-second duration |
| **Bleed** | 24 | 2 stacks/sec (Leech) | Triggers Hemorrhage at 12 |
| **Burn** | 5 | 10-20 dmg/sec | Standard DOT |
| **Poison** | 8 | Standard DOT | - |

### The Damage Amplification System

**BallxPit uses layered multiplicative scaling:**

```
Base Damage × (1 + Radiation%) × (1 + Frostburn%) = Final Damage

Example:
36 base × 1.50 (5 radiation) × 1.25 (4 frostburn) = 67.5 damage
```

### Optimal Stack Strategy

**Key insight:** Once at max stacks, switch targets.

```
# WRONG: Continue attacking same enemy
Enemy A: 5 radiation (capped) → wasted stacks

# RIGHT: Switch after cap
Enemy A: 5 radiation → Switch to Enemy B
Enemy B: 5 radiation → Switch to Enemy C
= 3 enemies with max damage amp
```

### Duration Management

| Effect | Duration | Reapplication |
|--------|----------|---------------|
| Radiation | **Infinite** | Never needed |
| Frostburn | 20 seconds | Every 15-18s |
| Bleed | Until consumed | At 12+ for Hemorrhage |
| Disease | Persistent | Until spread complete |

### Hemorrhage Deep Dive

```
╔══════════════════════════════════════════════════════════════════╗
║  HEMORRHAGE: 12+ bleed stacks → 20% CURRENT HP damage            ║
║  Consumes all stacks. Best applied at FULL enemy health.         ║
╚══════════════════════════════════════════════════════════════════╝
```

**This creates skill expression:**
- Noobs: Apply bleed, forget about it
- Pros: Stack to exactly 12, trigger, restack

### GoPit Status Effect Comparison

| System | GoPit | BallxPit |
|--------|-------|----------|
| Stacking caps | ❌ None defined | ✅ Per-effect caps |
| Radiation amplification | ❌ Missing | ✅ +50% multiplicative |
| Hemorrhage mechanic | ❌ Missing | ✅ 20% HP burst |
| Duration tracking | ⚠️ Basic | ✅ Per-effect |
| Target switching reward | ❌ None | ✅ Strategic |

### Building Upgrade Priority

BallxPit has a specific stat priority:

| Priority | Stat | Effect | Why |
|----------|------|--------|-----|
| 1 | Intelligence | AOE/baby ball damage | Scales all AOE |
| 2 | Strength | Character damage | Direct DPS |
| 3 | Endurance | HP | Survivability |
| 4 | Leadership | Companion scaling | Situational |
| 5 | Dexterity | Crit/dodge | Low impact |
| 6 | Speed | Movement | Minimal |

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P1** | Implement stacking caps | Define max per effect |
| **P1** | Add damage amplification | Radiation → multiplicative |
| **P1** | Add Hemorrhage | 12 bleed → 20% HP burst |
| **P2** | Add duration system | Per-effect timers |
| **P2** | Add target-switch reward | Incentivize spreading |

---

## Appendix BX: Baby Ball Mechanics Comparison

Research sources:
- [Balls Wiki](https://ballpit.fandom.com/wiki/Balls)
- [Character Unlock Guide](https://ballxpit.org/guides/character-unlock-guide/)

### BallxPit Baby Ball System

**Core Concept:** Baby balls are white, basic projectiles that provide passive DPS. Leadership stat affects both count and damage.

**Baby Ball Generation Methods:**

| Special Ball | Generation Trigger | Amount |
|-------------|-------------------|--------|
| **Brood Mother** | On hit | 25% chance → 1 ball |
| **Egg Sac** | On hit | 2-4 balls |
| **Maggot** | On infested enemy death | 1-2 balls |
| **Overgrowth** | On detonation | Multiple |
| **Bandage** (item) | On heal | Baby balls released |

**Baby Ball Specialist Characters:**
- **Empty Nester**: No baby balls - fires multiple copies of special balls instead
- **Baby Ball Character**: Unlocked via Cozy Home Blueprint, starts with Brood Mother

### GoPit Baby Ball System

**Current Implementation:** (`scripts/entities/baby_ball_spawner.gd`)

```gdscript
# Timer-based auto-spawner
@export var base_spawn_interval: float = 2.0
@export var baby_ball_damage_multiplier: float = 0.5
@export var baby_ball_scale: float = 0.6

# Leadership affects spawn rate
var rate = base_spawn_interval / (1.0 + leadership_bonus)
```

**GoPit Features:**
- Timer-based spawn (every 2s base)
- Leadership stat reduces interval
- 50% damage of main balls
- Auto-targets nearest enemy
- Silent fire (no audio spam)

### System Comparison

| Aspect | GoPit | BallxPit |
|--------|-------|----------|
| Spawn Method | Timer-based | **Event-based** (hit/kill) |
| Leadership Effect | Spawn rate only | Count + damage |
| Generation Sources | 1 (spawner) | 5+ (special balls) |
| Skill Expression | Low (passive) | High (ball choice) |
| Swarm Builds | ❌ Not possible | ✅ Core strategy |
| Inherit Ball Effects | ❌ No | ✅ Yes (Holy Laser, etc.) |

### The Inheritance Problem

**BallxPit's killer feature:** Baby balls inherit special ball effects.

```
Maggot + Holy Laser Evolution:
  → Enemy dies from Maggot
  → Spawns 1-2 baby balls
  → Baby balls have Holy Laser
  → Each baby ball fires cross lasers
  → Screen fills with lasers
```

**GoPit:** Baby balls are always plain damage balls.

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **P2** | Add event-based baby ball spawning | On-hit, on-kill triggers |
| **P2** | Add baby ball inheritance | Baby balls get parent's effect |
| **P2** | Add swarm-focused special balls | Brood Mother, Egg Sac equivalents |
| **P3** | Add Leadership → damage scaling | Match BallxPit formula |

**GoPit has the foundation - needs event-based triggers and effect inheritance.**

---

## Appendix BY: Endless Mode Comparison (GoPit Advantage)

Research sources:
- [Steam Discussion: endless/infinite mode?](https://steamcommunity.com/app/2062430/discussions/0/624436409752778228/)
- [Steam Discussion: Game needs endless mode BAD](https://steamcommunity.com/app/2062430/discussions/0/595163560549886518/)

### BallxPit Endless Mode Status

**BallxPit does NOT have endless mode.**

From Steam community:
> "If by endless/infinite mode you mean a run going endlessly, then no. Every run follows the same pattern, just the difficulty ramps up."

**Community requests include:**
- "This game is missing the most important thing... infinite replayability"
- "We need endless mode where enemies are mixed from different stages and scale infinitely"
- "2 mini-bosses/bosses could fight you at once"

BallxPit uses **NG+** for post-game content instead of endless mode.

### GoPit Endless Mode Implementation

**GoPit HAS endless mode!** (`scripts/autoload/game_manager.gd`)

```gdscript
var is_endless_mode: bool = false

func enable_endless_mode() -> void:
    ## Called when player chooses to continue after victory
    is_endless_mode = true
    current_state = GameState.PLAYING
```

**How it works:**
1. Player completes all stages → Victory screen
2. Player chooses "Continue" or "Endless"
3. Game continues with infinite wave progression
4. Enemies continue spawning and scaling

### Feature Parity Summary

| Feature | GoPit | BallxPit | Status |
|---------|-------|----------|--------|
| **Endless Mode** | ✅ Implemented | ❌ Missing | **GoPit ahead** |
| NG+ System | ❌ Missing | ✅ Implemented | BallxPit ahead |
| Mixed Enemy Waves | ⚠️ Basic | ❌ Requested | GoPit ahead |
| Multi-Boss Fights | ❌ Not implemented | ❌ Requested | Neither |

### This is a RARE GoPit advantage

Most comparisons show BallxPit ahead. **Endless mode is an area where GoPit leads.**

### Recommendations

| Priority | Change | Description |
|----------|--------|-------------|
| **Keep** | Endless mode | Maintain this advantage |
| **P2** | Add endless leaderboards | Track high scores/waves |
| **P2** | Add mixed biome enemies | Community-requested feature |
| **P3** | Add multi-boss waves | Community-requested feature |

---

## Appendix BT: FINAL EXECUTIVE SUMMARY

### Documentation Status

- **83 appendices** (A through BY)
- **82 open beads** tracking all gaps
- **6,500+ lines** of comparison

### The #1 Fundamental Difference

```
╔══════════════════════════════════════════════════════════════════╗
║  BALLXPIT: Fires 4-5 ball types SIMULTANEOUSLY per shot          ║
║  GOPIT:    Fires 1 ball type per shot                            ║
╚══════════════════════════════════════════════════════════════════╝
```

This affects everything: builds, combos, fission value, strategic depth.

### Priority Summary

| Priority | Key Items | Beads |
|----------|-----------|-------|
| **P0** | Ball slot system | GoPit-6zk |
| **P1** | Passive system, gear req, fission fix, bounce damage | ~10 |
| **P2** | Speed toggle, characters, balls, mini-bosses | ~30 |
| **P3+** | Achievements, city builder, saves | ~40 |

### Scale Gap

| System | GoPit | BallxPit | Gap |
|--------|-------|----------|-----|
| Ball slots | 1 | 4-5 | **CRITICAL** |
| Passives | 0 | 59 | -59 |
| Characters | 6 | 16 | -10 |
| Bosses | 1 | 24 | -23 |
| Buildings | 0 | 70+ | -70+ |

### What GoPit Does Well

✅ Procedural music/sound (unique)
✅ Touch-first mobile design
✅ Clean UI and effects
✅ Solid foundation for expansion

### Recommended Implementation Order

1. **Ball slot system** (P0) ← Start here
2. **Ball return mechanic** (P1)
3. **Passive system** (P1)
4. **Level select + gears** (P1)
5. **More content** (P2+)

---

**Comparison complete. 82 beads ready for implementation.**

