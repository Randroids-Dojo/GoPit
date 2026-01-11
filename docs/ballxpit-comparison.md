# BallxPit vs GoPit Comparison Analysis

> **Document Version**: 1.1
> **Last Updated**: January 2026
> **Status**: In Progress
> **Related Epic**: GoPit-68o

This document provides a detailed comparison between the real **Ball x Pit** game (by Kenny Sun / Devolver Digital) and our implementation **GoPit**. The goal is to identify differences and alignment opportunities.

## Research Sources

- [Ball x Pit Tactics Guide 2025](https://md-eksperiment.org/en/post/20251224-ball-x-pit-2025-pro-tactics-for-character-builds-boss-fights-and-efficient-bases)
- [Ball x Pit Ultimate Beginner's Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-ultimate-beginners-guide/)
- [Ball x Pit Evolutions Guide](https://steelseries.com/blog/ball-x-pit-evolutions-and-guide)
- [Ball X Pit Autofire Guide](https://spot.monster/games/game-guides/ball-x-pit-autofire-guide-2/)

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

### Current Alignment Status

| Category | Alignment | Priority |
|----------|-----------|----------|
| Ball Shooting | Partial | Medium |
| Player Movement | Good | Low |
| Enemy Behavior | Good | Low |
| Level Progression | Partial | Medium |
| Fusion/Fission System | Good | Low |
| Character Selection | Good | Low |
| Gem Collection | Good | Low |
| Boss Fights | Basic | Medium |

### Key Findings from Research

Based on analysis of BallxPit guides and documentation:

1. **Positioning > Precision**: BallxPit emphasizes smart positioning over precise aiming. "Precision aiming matters less than smart positioning."
2. **Autofire is Primary**: Autofire is the default mode, manual firing (F key) is used mainly for bosses
3. **Ball Catching**: Players can manually catch balls to reset them faster (2-3s saved per ball)
4. **Fission/Fusion/Evolution**: Three distinct upgrade paths at level-up
   - **Fission**: Upgrades multiple balls to L3 (early game)
   - **Fusion**: Combines two L3 balls (mid-game)
   - **Evolution**: Transforms balls into new types (late-game)
5. **Character Attack Directions**: Some characters have unique firing directions (e.g., The Shade fires from back of screen)

### Key Gaps Identified

1. **Autofire as default**: BallxPit uses autofire as primary mode; we have it as toggle
2. **Ball catching mechanic**: Not implemented - players can catch balls in BallxPit
3. **Character-specific firing directions**: Some BallxPit characters fire from different directions
4. **Boss variety**: Only Slime King implemented, need more boss types
5. **Fission as level-up option**: Our Fission is fusion_registry drop, not level-up choice

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

| Gap | Current GoPit | BallxPit | Recommendation |
|-----|---------------|----------|----------------|
| **Fission in Level-Up** | Drop-only | Level-up option | Add Fission card type |
| **Autofire Default** | Toggle (off by default) | Primary mode | Make autofire default ON |
| **Ball Catching** | Not implemented | Manually catch for DPS | Consider adding |
| **Character Firing** | All same direction | Unique per character | Add 1-2 unique characters |

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
2. [ ] **Document all evolutions** - Build complete recipe list
3. [ ] **Map all characters** - Document unique mechanics

---

## Appendix: File Reference

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

*Document maintained as part of BallxPit alignment effort (GoPit-68o)*
