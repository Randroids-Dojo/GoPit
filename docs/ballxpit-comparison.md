# BallxPit vs GoPit Comparison Analysis

> **Document Version**: 2.0
> **Last Updated**: January 2026
> **Status**: Complete (Initial Analysis)
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

1. [Executive Summary](#executive-summary)
2. [Ball Shooting Mechanics](#ball-shooting-mechanics)
3. [Player Movement](#player-movement)
4. [Enemy Spawning and Movement](#enemy-spawning-and-movement)
5. [Level Progression and Difficulty](#level-progression-and-difficulty)
6. [Fusion vs Fission vs Upgrade System](#fusion-vs-fission-vs-upgrade-system)
7. [Character Selection](#character-selection)
8. [Gem Collection and XP](#gem-collection-and-xp)
9. [Boss Fights](#boss-fights)
10. [Recommendations](#recommendations)

---

## Executive Summary

### Quick Stats Comparison

| Metric | GoPit | BallxPit | Gap |
|--------|-------|----------|-----|
| Characters | 6 | 16+ | -10 |
| Stages | 4 | 8 | -4 |
| Bosses | 1 | 8 | -7 |
| Evolution recipes | 5 | 40+ | -35 |
| Ball types | 7 | 14+ | -7 |
| Enemy types | 3 | Many | Large |

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

**Level-Up Choices (pick 1 of 3):**
1. New ball type (from unowned)
2. Level up existing ball (L1->L2 or L2->L3)
3. Passive upgrade (11 types)

### What BallxPit Does (Confirmed)

Based on guides:

1. **Three Level-Up Options**:
   - **Fission**: Upgrades multiple balls to L3 at once (early game priority)
   - **Fusion**: Combines two L3 balls into one with mixed features
   - **Evolution**: Transforms L3 balls into powerful new types (can further evolve)

2. **Evolution vs Fusion**:
   - "Evolutions tend to be much more potent"
   - Evolutions can be combined further
   - Fusions are simpler combinations

3. **Known Evolutions**:
   - Burn + Iron = Bomb
   - Poison + Bleed = Virus
   - Freeze + Lightning = Blizzard
   - Burn + Poison = Magma
   - Plus: Vampire Lord, Nuclear Bomb, etc.

4. **In-Game Encyclopedia**: Fills in as you discover evolutions

### Comparison

| Feature | GoPit | BallxPit | Match |
|---------|-------|----------|-------|
| Ball leveling | L1-L3 | L1-L3 | Yes |
| Fusion recipes | 5 evolved types | Many more | Partial |
| Generic fusion | Yes | Yes (weaker than evolution) | Yes |
| Fission as level-up | No (drop only) | Yes (level-up option) | **Gap** |
| Level-up choices | 3 cards | 3 cards (Fission/Fusion/Evolution) | Partial |

### Critical Gap: Fission as Level-Up Option

**BallxPit**: Fission appears as a level-up card choice, upgrades multiple balls to L3 at once. This is a primary early-game strategy.

**GoPit**: Fission is only available via random Fusion Reactor drops. Level-up only offers:
- New ball type
- Level up existing ball
- Passive upgrade

**Recommendation**: Add Fission as a level-up card option (instead of Fusion Reactor drops)

### Recommendations

1. [ ] **Add Fission to level-up choices** - Critical alignment gap
2. [ ] **Add more evolution recipes** - Target 10-15 evolutions
3. [ ] **Add in-game encyclopedia** - Track discovered evolutions
4. [ ] **Balance evolution vs fusion power** - Evolutions should be stronger

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

## Analysis Complete

This document represents a comprehensive comparison between Ball x Pit and GoPit across all major game systems. The analysis identified **12 actionable gaps** tracked as beads, prioritized for implementation.

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
