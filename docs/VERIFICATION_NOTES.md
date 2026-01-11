# GoPit vs BallxPit - VERIFICATION NOTES

> **Purpose**: Code-verified differences, not assumptions
> **Method**: Direct code inspection and testing
> **Last Updated**: January 11, 2026

---

## 1. Ball Shooting Mechanics (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source Files:**
- `scripts/entities/ball_spawner.gd`
- `scripts/autoload/ball_registry.gd`
- `scripts/input/fire_button.gd`

**Key Code Findings:**

1. **SINGLE ACTIVE BALL TYPE** (`ball_registry.gd:81`):
   ```gdscript
   var active_ball_type: BallType = BallType.BASIC
   ```
   Only ONE ball type fires at a time. Player must switch between owned balls.

2. **COOLDOWN-BASED FIRING** (`fire_button.gd:11, 102`):
   ```gdscript
   @export var cooldown_duration: float = 0.5
   cooldown_timer = cooldown_duration / GameManager.character_speed_mult
   ```
   Fixed 0.5s cooldown, modified by character speed. NOT ball-return-based.

3. **MULTI-SHOT IS SAME TYPE** (`ball_spawner.gd:45-52`):
   ```gdscript
   for i in range(ball_count):
       # ... spread calculation ...
       _spawn_ball(dir)
   ```
   Multi-shot fires multiple balls of the SAME type in spread pattern.

4. **MAX 30 SIMULTANEOUS BALLS** (`ball_spawner.gd:10`):
   ```gdscript
   @export var max_balls: int = 30
   ```
   Oldest balls despawned to make room.

5. **AUTOFIRE OFF BY DEFAULT** (`fire_button.gd:19`):
   ```gdscript
   var autofire_enabled: bool = false
   ```

### BallxPit Behavior (Research)

1. **4-5 BALL SLOTS** - Fire ALL equipped ball types simultaneously
2. **BALL-RETURN FIRING** - Can only fire when balls return to player
3. **CATCHING = FASTER FIRE** - Manual catch = instant return (30-40% more DPS)
4. **AUTOFIRE PRIMARY** - Toggle OFF for precision

### CRITICAL DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Ball slots** | 1 (switch between) | 4-5 (simultaneous) | **FUNDAMENTAL** |
| **Fire gating** | Cooldown timer (0.5s) | Ball return | **FUNDAMENTAL** |
| **Catching** | Not implemented | Instant ball return | Missing skill ceiling |
| **Autofire default** | OFF | ON | Different feel |
| **Multi-shot** | Same type spread | Same type spread | Matches |
| **Ball limit** | 30 | Unknown | Similar |

### Beads Tracking This Gap

- **GoPit-6zk**: Implement ball slot system (4-5 types fire simultaneously) - P0
- **GoPit-ay9**: Add ball return mechanic (remove despawn on max bounces) - P1

---

## 2. Ball Bounce and Return (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source File:** `scripts/entities/ball.gd`

**Key Code Findings:**

1. **MAX 10 BOUNCES THEN DESPAWN** (`ball.gd:19, 189-192`):
   ```gdscript
   var max_bounces: int = 10

   # In _physics_process:
   _bounce_count += 1
   if _bounce_count > max_bounces:
       despawn()
       return
   ```
   Ball is DESTROYED after 10 bounces. No return to player.

2. **NO BOUNCE DAMAGE SCALING** - Damage is fixed throughout ball's lifetime:
   ```gdscript
   var actual_damage := damage  # No bounce multiplier
   ```
   No code that increases damage based on `_bounce_count`.

3. **NO CATCHING MECHANIC** - Ball just despawns on max bounces:
   ```gdscript
   func despawn() -> void:
       despawned.emit()
       queue_free()
   ```
   No code for player catching balls.

4. **RICOCHET UPGRADE** increases max_bounces (`ball_spawner.gd:152`):
   ```gdscript
   func add_ricochet(amount: int) -> void:
       max_bounces += amount
   ```
   But this just delays despawn - still no return.

### BallxPit Behavior (Research)

1. **BALLS RETURN TO PLAYER** - Fall to bottom of screen, player catches
2. **+5% DAMAGE PER BOUNCE** - Ricochet is a STRATEGY, not limitation
3. **CATCHING = INSTANT RETURN** - Manual catch speeds up fire rate
4. **NO MAX BOUNCES** - Balls persist until caught

### CRITICAL DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Ball lifecycle** | Despawn after 10 bounces | Return to player | **FUNDAMENTAL** |
| **Bounce damage** | No scaling | +5% per bounce | **FUNDAMENTAL** |
| **Catching** | Not implemented | Instant return | Missing skill ceiling |
| **Ricochet value** | Delays despawn | Increases damage | Inverted incentive |

### Verified Answers
- [x] What happens when ball hits max bounces? → **DESPAWNS (destroyed)**
- [x] Is there any ball return mechanic? → **NO**
- [x] Do balls gain damage per bounce? → **NO**

### Beads Tracking This Gap

- **GoPit-ay9**: Add ball return mechanic (remove despawn on max bounces) - P1
- **GoPit-gdj**: Add bounce damage scaling (+5% per bounce) - P1

---

## 3. Enemy Spawning (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source Files:**
- `scripts/entities/enemies/enemy_spawner.gd`
- `scripts/entities/enemies/enemy_base.gd`

**Key Code Findings:**

1. **3 ENEMY TYPES** (`enemy_spawner.gd:8, 18-19`):
   ```gdscript
   slime_scene  # Wave 1+
   bat_scene    # Wave 2+
   crab_scene   # Wave 4+
   ```

2. **WAVE-BASED INTRODUCTION** (`enemy_spawner.gd:74-94`):
   - Wave 1: Slime only
   - Wave 2-3: Slime (70%), Bat (30%)
   - Wave 4+: Slime (50%), Bat (30%), Crab (20%)

3. **SPAWN TIMING** (`enemy_spawner.gd:9-15`):
   ```gdscript
   spawn_interval: float = 2.0
   spawn_variance: float = 0.5  # ±0.5s random
   burst_chance: float = 0.1    # 10% for 2-3 enemies
   ```

4. **ENEMY STATE MACHINE** (`enemy_base.gd:13`):
   ```gdscript
   enum State { DESCENDING, WARNING, ATTACKING, DEAD }
   ```
   - DESCENDING: Move down at `speed`
   - WARNING: 1.0s with "!" + shake (`WARNING_DURATION = 1.0`)
   - ATTACKING: Lunge at 600 speed toward player

5. **WAVE SCALING** (`enemy_base.gd:66-73`):
   ```gdscript
   # HP: +10% per wave
   max_hp = int(max_hp * (1.0 + (wave - 1) * 0.1))
   # Speed: +5% per wave (capped at 2x)
   speed = speed * min(2.0, 1.0 + (wave - 1) * 0.05)
   # XP: +5% per wave
   xp_value = int(xp_value * (1.0 + (wave - 1) * 0.05))
   ```

6. **ATTACK SELF-DAMAGE** (`enemy_base.gd:19, 324`):
   ```gdscript
   ATTACK_SELF_DAMAGE: int = 3  # HP lost per attack attempt
   hp -= ATTACK_SELF_DAMAGE
   ```

### BallxPit Behavior (Research)

1. **10+ ENEMY TYPES** - Far more variety
2. **BIOME-SPECIFIC ENEMIES** - Desert has lasers, forest has mushrooms
3. **RANGED ENEMIES** - Some enemies shoot projectiles
4. **UNIQUE PATTERNS** - Digging, teleporting, summoning
5. **24 BOSSES** - 3 per stage across 8 stages

### CRITICAL DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Enemy types** | 3 | 10+ | Less variety |
| **Boss count** | 1 (Slime King) | 24 | Content gap |
| **Ranged enemies** | None | Multiple | Different patterns |
| **Biome-specific** | No | Yes | Missing theme |
| **Warning system** | 1s exclamation + shake | Similar | **MATCHES** |
| **Wave scaling** | HP +10%, Speed +5% | Similar | **MATCHES** |

### Beads Tracking This Gap

- Enemy variety gaps tracked in existing beads

---

## 4. Level Speed/Difficulty (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source Files:**
- `scripts/autoload/game_manager.gd`
- `scripts/autoload/stage_manager.gd`

**Key Code Findings:**

1. **NO GAME SPEED TOGGLE** - Searched all scripts:
   ```bash
   grep -r "game_speed|speed_level|time_scale" scripts/
   # No matches found
   ```
   No equivalent to BallxPit's R1/RB speed control.

2. **4 STAGES** (`stage_manager.gd:26-32`):
   ```gdscript
   stages = [
       preload("res://resources/biomes/the_pit.tres"),
       preload("res://resources/biomes/frozen_depths.tres"),
       preload("res://resources/biomes/burning_sands.tres"),
       preload("res://resources/biomes/final_descent.tres"),
   ]
   ```

3. **WAVES PER STAGE** (`stage_manager.gd:43`):
   ```gdscript
   var waves_per_stage: int = current_biome.waves_before_boss  # default 10
   ```

4. **WIN CONDITION** (`stage_manager.gd:51-60`):
   ```gdscript
   func complete_stage() -> void:
       current_stage += 1
       if current_stage >= stages.size():
           game_won.emit()
   ```

5. **NO DIFFICULTY MODES** - No Normal/Fast/Fast+2/Fast+3 options.

6. **NO NG+ MODE** - After victory, game ends or enters `is_endless_mode`.

### BallxPit Behavior (Research)

1. **3 SPEED LEVELS** - R1/RB toggles Speed 1/2/3
2. **SPEED AFFECTS REWARDS** - Fast modes give +25-50% rewards
3. **8 STAGES** - Twice as many as GoPit
4. **NG+ MODE** - Replays with +50% HP/damage, no checkpoints
5. **DYNAMIC SPEED CONTROL** - Change mid-game for strategy

### CRITICAL DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Speed toggle** | None | 3 levels (R1/RB) | **MISSING** |
| **Stage count** | 4 | 8 | Content gap |
| **NG+ mode** | None | Unlocks after 8 stages | Missing endgame |
| **Difficulty modes** | None | Normal/Fast/Fast+2/Fast+3 | Less player control |
| **Win condition** | After stage 4 boss | After stage 8 boss | Matches concept |

### Beads Tracking This Gap

- Speed toggle tracked in existing beads (P2 priority)

---

## 5. Fission/Fusion/Upgrade (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source Files:**
- `scripts/autoload/fusion_registry.gd`
- `scripts/ui/level_up_overlay.gd`

**Key Code Findings:**

1. **LEVEL-UP CARDS - NO FISSION OPTION** (`level_up_overlay.gd:21-25`):
   ```gdscript
   enum CardType {
       PASSIVE,      # Traditional stat upgrades
       NEW_BALL,     # Acquire a new ball type
       LEVEL_UP_BALL # Level up an owned ball
   }
   ```
   **FISSION IS NOT A LEVEL-UP CARD!** It only triggers from drops.

2. **FISSION ONLY VIA DROPS** (`fusion_registry.gd:304-343`):
   ```gdscript
   func apply_fission() -> Dictionary:
       # Random number of upgrades (1-3)
       var num_upgrades := randi_range(1, 3)
   ```
   - Upgrades 1-3 items (NOT 5 like BallxPit)
   - Triggered by Fusion Reactor drop, not level-up choice

3. **MAXED FALLBACK = XP** (`fusion_registry.gd:316-321`):
   ```gdscript
   if upgradeable.size() == 0 and unowned.size() == 0:
       # All maxed - give XP bonus
       var xp_bonus := 100 + GameManager.current_wave * 10
       GameManager.add_xp(xp_bonus)
   ```
   BallxPit gives GOLD, GoPit gives XP.

4. **5 EVOLUTION RECIPES** (`fusion_registry.gd:20-27`):
   ```gdscript
   const EVOLUTION_RECIPES := {
       "BURN_IRON": BOMB,
       "FREEZE_LIGHTNING": BLIZZARD,
       "BLEED_POISON": VIRUS,
       "BURN_POISON": MAGMA,
       "BURN_FREEZE": VOID
   }
   ```
   BallxPit has 42+.

5. **NO MULTI-TIER EVOLUTION** - Evolved balls cannot combine further:
   ```gdscript
   "can_evolve": false  # Fused balls cannot further evolve
   ```
   BallxPit: Bomb + Poison = Nuclear Bomb, Satan = Incubus + Succubus

6. **11 PASSIVE UPGRADES** (`level_up_overlay.gd:6-18`):
   - DAMAGE, FIRE_RATE, MAX_HP, MULTI_SHOT, BALL_SPEED
   - PIERCING, RICOCHET, CRITICAL, MAGNETISM, HEAL, LEADERSHIP

### BallxPit Behavior (Research)

1. **FISSION IS A LEVEL-UP CARD** - Choose at level-up, not drop-only
2. **FISSION UPGRADES 5 ITEMS** - Not 1-3
3. **MAXED FALLBACK = GOLD** - Not XP
4. **42+ EVOLUTION RECIPES** - Far more variety
5. **MULTI-TIER EVOLUTIONS** - Evolved + Evolved = Advanced
6. **3-WAY EVOLUTION** - Nosferatu requires 3 evolved balls
7. **51+ PASSIVE UPGRADES** - Far more variety

### CRITICAL DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Fission in level-up** | NO (drop only) | YES (card option) | **CRITICAL** |
| **Fission upgrade count** | 1-3 | Up to 5 | Less impactful |
| **Maxed fallback** | XP bonus | Gold bonus | Different reward |
| **Evolution recipes** | 5 | 42+ | Content gap |
| **Multi-tier evolution** | None | Yes | Missing depth |
| **3-way evolution** | None | Nosferatu | Missing |
| **Passive upgrades** | 11 | 51+ | Content gap |

### Beads Tracking This Gap

- **GoPit-hfi**: Add Fission as level-up card (CRITICAL)
- **GoPit-a8bh**: Increase fission range from 1-3 to 1-5
- Evolution recipe expansion tracked in other beads

---

## 6. Level Select/Progression (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source Files:**
- `scripts/ui/character_select.gd`
- `scripts/autoload/stage_manager.gd`

**Key Code Findings:**

1. **NO LEVEL SELECT SCREEN** - Searched all scripts:
   ```bash
   grep -ri "level.?select|stage.?select" scripts/
   # No matches found
   ```
   Game always starts from Stage 1.

2. **CHARACTER SELECT ONLY** (`character_select.gd:1-2`):
   ```gdscript
   extends CanvasLayer
   ## Character selection screen - shown before game starts
   ```
   Flow: Character Select -> Game (Stage 1) -> Victory/Death

3. **6 CHARACTERS** (`character_select.gd:6-13`):
   ```gdscript
   const CHARACTER_PATHS := [
       "res://resources/characters/rookie.tres",
       "res://resources/characters/pyro.tres",
       "res://resources/characters/frost_mage.tres",
       "res://resources/characters/tactician.tres",
       "res://resources/characters/gambler.tres",
       "res://resources/characters/vampire.tres"
   ]
   ```

4. **LOCKED CHARACTERS** (`character_select.gd:105, 146-148`):
   ```gdscript
   if not character.is_unlocked:
       SoundManager.play(SoundManager.SoundType.BLOCKED)
       return
   locked_overlay.visible = not character.is_unlocked
   lock_label.text = "LOCKED\n" + character.unlock_requirement
   ```

5. **NO GEAR/STAR REQUIREMENT** - No gear system for stage unlocking.

### BallxPit Behavior (Research)

1. **LEVEL SELECT SCREEN** - Choose which stage to start from
2. **GEAR REQUIREMENT** - Need X gears to unlock stages
3. **STAR RATING** - 1-3 stars per stage completion
4. **16 CHARACTERS** - More variety
5. **UNLOCK VIA BUILDINGS** - Characters unlocked in New Ballbylon
6. **CHECKPOINT SYSTEM** - Resume from cleared stages

### CRITICAL DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Level select** | NONE | Full stage picker | **CRITICAL** |
| **Gear system** | None | Stage unlock requirement | Missing |
| **Stage restart** | Only stage 1 | Any cleared stage | QoL gap |
| **Characters** | 6 | 16 | Content gap |
| **Star rating** | None | 1-3 stars | Missing feedback |
| **Checkpoints** | None | After each stage | Missing |

### Beads Tracking This Gap

- **GoPit-b1l**: Add level select screen
- **GoPit-m906**: Add gear requirement system

---

## Verification Status

| Area | Status | Bead |
|------|--------|------|
| Ball shooting | **VERIFIED** | GoPit-vprp |
| Ball bounce/return | **VERIFIED** | GoPit-bnw7 |
| Enemy spawning | **VERIFIED** | GoPit-iwlv |
| Level speed/difficulty | **VERIFIED** | GoPit-zji1 |
| Fission/fusion/upgrade | **VERIFIED** | GoPit-lldl |
| Level select/progression | **VERIFIED** | GoPit-bu9b |

---

## Summary of Verified Critical Differences

### FUNDAMENTAL (Game-changing)

1. **Ball Slots**: GoPit fires 1 type, BallxPit fires 4-5 simultaneously
2. **Fire Gating**: GoPit uses cooldown timer, BallxPit uses ball return
3. **Ball Lifecycle**: GoPit despawns after 10 bounces, BallxPit returns to player
4. **Bounce Damage**: GoPit none, BallxPit +5% per bounce

### CRITICAL (Major impact)

5. **Fission in Level-Up**: GoPit NO (drop-only), BallxPit YES (card option)
6. **Level Select**: GoPit NONE, BallxPit full stage picker
7. **Speed Toggle**: GoPit NONE, BallxPit 3 levels (R1/RB)

### CONTENT GAP

8. Stages: 4 vs 8
9. Characters: 6 vs 16
10. Evolution recipes: 5 vs 42+
11. Passive upgrades: 11 vs 51+
12. Enemy types: 3 vs 10+
13. Bosses: 1 vs 24

---

## 7. Baby Ball Mechanics (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source File:** `scripts/entities/baby_ball_spawner.gd`

**Key Code Findings:**

1. **TIMER-BASED SPAWNING** (`baby_ball_spawner.gd:8`):
   ```gdscript
   @export var base_spawn_interval: float = 2.0
   ```
   Fixed 2-second interval, modified by Leadership stat.

2. **50% DAMAGE REDUCTION** (`baby_ball_spawner.gd:9, 78`):
   ```gdscript
   @export var baby_ball_damage_multiplier: float = 0.5
   ball.damage = int(base_damage * baby_ball_damage_multiplier)
   ```
   BallxPit baby balls share FULL parent damage.

3. **NO TYPE INHERITANCE** - Searched for ball_type/set_ball_type:
   ```bash
   grep -n "ball_type|set_ball_type" baby_ball_spawner.gd
   # No matches found
   ```
   Baby balls are always NORMAL type, no effects.

4. **AUTO-TARGETING** (`baby_ball_spawner.gd:95-100`):
   ```gdscript
   func _get_target_direction() -> Vector2:
       var nearest := _find_nearest_enemy()
       if nearest:
           return _player.global_position.direction_to(nearest.global_position)
   ```

5. **LEADERSHIP SCALING** (`baby_ball_spawner.gd:49-58`):
   ```gdscript
   var total_bonus: float = (_leadership_bonus * char_mult) + passive_bonus
   var rate: float = base_spawn_interval / ((1.0 + total_bonus) * speed_mult)
   ```

### BallxPit Behavior (Research)

1. **TYPE INHERITANCE** - Baby balls inherit parent effects (Holy Laser, etc.)
2. **FULL DAMAGE** - Baby balls share parent damage (not reduced)
3. **EVOLUTION SPAWNING** - Spider Queen (25% on hit), Maggot (on death)
4. **BALL COUNT SCALING** - More parent balls = more baby balls

### CRITICAL DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Type inheritance** | NONE (always NORMAL) | YES (inherits effects) | **CRITICAL** |
| **Damage** | 50% reduced | Full parent damage | Lower value |
| **Spawn trigger** | Fixed timer (2s) | Evolution-specific | Different feel |
| **Ball count scaling** | No | Yes | Missing synergy |

### Beads Tracking This Gap

- Baby ball type inheritance needs new bead

---

## 8. Status Effect Mechanics (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source File:** `scripts/effects/status_effect.gd`

**Key Code Findings:**

1. **4 EFFECT TYPES** (`status_effect.gd:5`):
   ```gdscript
   enum Type { BURN, FREEZE, POISON, BLEED }
   ```

2. **LOW STACK LIMITS** (`status_effect.gd:30-51`):
   - BURN: max_stacks = 1 (refreshes only), 3s duration, 5 DPS
   - FREEZE: max_stacks = 1, 2s duration, 50% slow
   - POISON: max_stacks = 1, 5s duration, 3 DPS
   - BLEED: max_stacks = 5, PERMANENT (INF), 2 DPS per stack

3. **NO DAMAGE AMPLIFICATION** - Effects only deal DoT or slow, no +% damage taken.

4. **INTELLIGENCE SCALING** (`status_effect.gd:28, 32`):
   ```gdscript
   var int_mult: float = GameManager.character_intelligence_mult
   duration = 3.0 * int_mult
   ```

### BallxPit Behavior (Research)

Source: [Ball x Pit Advanced Mechanics Guide](https://ballxpit.org/guides/advanced-mechanics/)

1. **6+ EFFECT TYPES** - Burn, Freeze, Poison, Bleed, Radiation, Frostburn, Disease
2. **HIGH STACK LIMITS**:
   - Bleed: 24 stacks (GoPit: 5)
   - Poison: 8 stacks (GoPit: 1)
   - Burn: 5 stacks (GoPit: 1)
   - Radiation: 5 stacks (new)
   - Frostburn: 4 stacks (new)
   - Disease: 8 stacks (new)

3. **DAMAGE AMPLIFICATION**:
   - Radiation: +10% damage taken per stack (max +50%)
   - Frostburn: +25% damage taken (flat)
   - This is MULTIPLICATIVE with other damage sources!

4. **HEMORRHAGE MECHANIC** - 12+ bleed stacks trigger 20% current HP nuke

### CRITICAL DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Effect types** | 4 | 6+ | Less variety |
| **Bleed stacks** | 5 | 24 | Much lower cap |
| **Poison stacks** | 1 | 8 | Refresh-only |
| **Damage amplification** | NONE | +50-75% | **CRITICAL** |
| **Hemorrhage** | NONE | 20% HP nuke at 12 stacks | Missing |

### Beads Tracking This Gap

- Status effect stack limits and damage amplification needs beads

---

## 9. Combo System (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source File:** `scripts/autoload/game_manager.gd`

**Key Code Findings:**

1. **KILL STREAK COMBO** (`game_manager.gd:29-31, 101`):
   ```gdscript
   var combo_count: int = 0
   var combo_timer: float = 0.0
   var combo_timeout: float = 2.0  # Seconds before combo resets
   # record_enemy_kill() calls _increment_combo()
   ```

2. **XP MULTIPLIER** (`game_manager.gd:117-122, 259`):
   ```gdscript
   func get_combo_multiplier() -> float:
       # 1x at 1-2 combo, 1.5x at 3-4, 2x at 5+
       if combo_count >= 5: return 2.0
       elif combo_count >= 3: return 1.5
       return 1.0
   # Applied to XP: final_xp = int(amount * get_combo_multiplier())
   ```

3. **RESET ON DAMAGE** (`game_manager.gd:270-271`):
   ```gdscript
   # Reset combo on damage
   _reset_combo()
   ```

### BallxPit Behavior (Research)

Based on extensive search, **BallxPit does NOT have a kill-streak combo system**.

The term "combo" in BallxPit refers to:
1. **Ball/Character synergies** - Evolution combinations
2. **Damage amplification stacking** - Radiation + Frostburn = 1.875x
3. **Build combos** - Specific character + ball + passive setups

Sources: [Ball x Pit Combos & Synergies Guide](https://ballxpit.org/guides/combos-synergies/)

### DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Kill streak combo** | YES (2s timeout) | NOT FOUND | GoPit advantage! |
| **XP multiplier** | 1x-2x based on streak | None for kills | GoPit advantage! |
| **Reset on damage** | Yes | N/A | Encourages safety |
| **Damage amp combos** | None | Yes (+50-75%) | Missing in GoPit |

### Analysis

GoPit has a **kill streak combo system that BallxPit may not have**. This is a potential **GoPit advantage** - it encourages rapid kills and adds a risk/reward element (taking damage resets combo).

However, BallxPit's damage amplification through status effect stacking (Radiation, Frostburn) serves a similar purpose - rewarding coordinated builds.

---

## 10. Meta Progression (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source Files:**
- `scripts/autoload/meta_manager.gd`
- `scripts/data/permanent_upgrades.gd`

**Key Code Findings:**

1. **1 CURRENCY** (`meta_manager.gd:10`):
   ```gdscript
   var pit_coins: int = 0
   ```
   Only Pit Coins, no multi-resource system.

2. **5 PERMANENT UPGRADES** (`permanent_upgrades.gd:44-95`):
   - hp (Pit Armor): +10 HP per level, max 5
   - damage (Ball Power): +2 damage, max 5
   - fire_rate (Rapid Fire): -0.05s cooldown, max 5
   - coin_bonus (Coin Magnet): +10% coins, max 4
   - starting_level (Head Start): Start at level X, max 3

3. **SIMPLE COST SCALING** (`permanent_upgrades.gd:34`):
   ```gdscript
   return int(base_cost * pow(cost_multiplier, current_level))
   ```
   2x cost per level, no resource complexity.

4. **LOCAL FILE SAVE** (`meta_manager.gd:7, 94-105`):
   ```gdscript
   const SAVE_PATH := "user://meta.save"
   # JSON save with coins, runs, best_wave, upgrades
   ```

5. **NO BUILDINGS** - Just upgrade purchases, no construction.

### BallxPit Behavior (Research)

Source: [Ball x Pit Buildings Guide](https://ballxpit.org/guides/buildings-guide/)

1. **4 CURRENCIES** - Gold, Wood, Stone, Wheat
2. **70+ BUILDINGS** in New Ballbylon
3. **BUILDING RANKS** - D → C → B → A → S (+40-50% permanent power)
4. **CHARACTER UNLOCKS** via buildings (Jeweler, Matchmaker, Gem Smith)
5. **RESOURCE HARVESTING** - 7-mine U-layout = 2,500+ gold
6. **BASE LAYOUT STRATEGY** - Placement matters for optimization

### CRITICAL DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Currencies** | 1 (Pit Coins) | 4 (Gold, Wood, Stone, Wheat) | Simpler |
| **Permanent upgrades** | 5 | 70+ buildings | **MASSIVE gap** |
| **Building system** | NONE | Yes (New Ballbylon) | Missing |
| **Resource harvesting** | NONE | Yes | Missing |
| **Rank progression** | Simple levels | D→S ranks | Less depth |
| **Character unlocks** | Via requirements | Via buildings | Different |

### Beads Tracking This Gap

- Building system tracked in existing beads (P3)
- Multiple currencies tracked in existing beads

---

## 11. Aim and Trajectory System (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source Files:**
- `scripts/input/aim_line.gd`
- `scripts/input/virtual_joystick.gd`

**Key Code Findings:**

1. **DASHED TRAJECTORY LINE** (`aim_line.gd:4-9, 54-70`):
   ```gdscript
   @export var max_length: float = 400.0
   @export var dash_length: float = 20.0
   @export var gap_length: float = 10.0
   # Creates dashed line effect
   ```
   Visual preview of where ball will go.

2. **GHOST STATE ON RELEASE** (`aim_line.gd:40-47`):
   ```gdscript
   func hide_line() -> void:
       is_active = false
       # Don't hide - fade to ghost state
       _fade_tween.tween_property(self, "default_color", ghost_color, 0.2)
   ```
   Line fades to gray when not aiming (helpful for quick-fire).

3. **VIRTUAL JOYSTICK** (`virtual_joystick.gd:7-9`):
   ```gdscript
   @export var base_radius: float = 80.0
   @export var knob_radius: float = 30.0
   @export var dead_zone: float = 0.05  # 5% dead zone
   ```
   Touch/mouse drag control for aiming.

4. **TOUCH + MOUSE SUPPORT** (`virtual_joystick.gd:34-57`):
   Supports both mouse drag and touch screen input.

5. **NO SENSITIVITY SETTING** - Dead zone is fixed at 5%.

### BallxPit Behavior (Research)

Source: [Ball x Pit Controls Guide](https://ballxpit.net/controls)

1. **2-AXIS CONTROL** - Separate movement + aim sticks
2. **ADJUSTABLE SENSITIVITY** - 30-90% range in settings
3. **SUBTLE AIM ASSIST** - For controller users
4. **KEY REMAPPING** - Full rebind support
5. **HYBRID CONTROL** - Controller move + mouse aim option

### DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Trajectory line** | Dashed + ghost state | Unknown | GoPit may be better |
| **Aim sensitivity** | Fixed (5% dead zone) | Adjustable 30-90% | Less customization |
| **Aim assist** | None | Subtle for controller | Missing |
| **Key remapping** | None | Full support | Missing |
| **Control modes** | Touch/mouse joystick | Controller + keyboard + mouse | Less options |

### Analysis

GoPit's dashed trajectory line with ghost state is potentially a **unique feature** that may not exist in BallxPit. This helps players see where their last shot went while lining up the next one.

---

## 12. Audio and Music System (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source Files:**
- `scripts/autoload/sound_manager.gd`
- `scripts/autoload/music_manager.gd`

**Key Code Findings:**

1. **FULLY PROCEDURAL AUDIO** (`sound_manager.gd:234-297`):
   ```gdscript
   func _generate_sound(sound_type: SoundType) -> AudioStreamWAV:
       var wav := AudioStreamWAV.new()
       wav.format = AudioStreamWAV.FORMAT_16_BITS
       # ... generates waveforms programmatically
   ```
   ALL sounds are synthesized at runtime using sine waves, noise, and envelopes. Zero audio file assets.

2. **21 SOUND TYPES** (`sound_manager.gd:42-71`):
   ```gdscript
   enum SoundType {
       FIRE, HIT_WALL, HIT_ENEMY, ENEMY_DEATH, GEM_COLLECT, PLAYER_DAMAGE,
       LEVEL_UP, GAME_OVER, WAVE_COMPLETE, BLOCKED,
       FIRE_BALL, ICE_BALL, LIGHTNING_BALL, POISON_BALL, BLEED_BALL, IRON_BALL,
       BURN_APPLY, FREEZE_APPLY, POISON_APPLY, BLEED_APPLY,
       FUSION_REACTOR, EVOLUTION, FISSION, ULTIMATE
   }
   ```

3. **PER-SOUND VARIANCE** (`sound_manager.gd:217-222`):
   ```gdscript
   player.pitch_scale = randf_range(1.0 - pitch_var, 1.0 + pitch_var)
   player.volume_db = randf_range(-vol_var * 6.0, vol_var * 6.0)
   ```
   Each sound plays with random pitch/volume variation for natural feel.

4. **PROCEDURAL MUSIC** (`music_manager.gd:1-28`):
   ```gdscript
   const BPM := 120.0
   var _bass_player: AudioStreamPlayer
   var _drum_player: AudioStreamPlayer
   var _melody_player: AudioStreamPlayer
   ```
   Three-layer music: bass, drums, melody - all synthesized in real-time.

5. **INTENSITY-BASED MUSIC** (`music_manager.gd:71-94`):
   ```gdscript
   func set_intensity(intensity: float) -> void:
       current_intensity = clampf(intensity, 1.0, 5.0)
       _bass_player.volume_db = lerpf(-12.0, -4.0, (intensity - 1.0) / 4.0)
   ```
   Music intensity (1.0-5.0) scales with wave progression. Melody only appears at intensity >= 2.0.

6. **SYNTHESIZED INSTRUMENTS**:
   - **Bass**: Sine + saw wave with sub octave (`music_manager.gd:122-155`)
   - **Kick**: Pitch-dropping sine (150Hz→50Hz) (`music_manager.gd:157-181`)
   - **Snare**: Noise + tonal component (`music_manager.gd:183-208`)
   - **Hihat**: High-frequency noise burst (`music_manager.gd:210-232`)
   - **Melody**: Sine with vibrato, minor pentatonic (`music_manager.gd:114-119`)

7. **VOLUME CONTROLS** (`sound_manager.gd:13-33`):
   ```gdscript
   var master_volume: float = 1.0
   var sfx_volume: float = 1.0
   var music_volume: float = 1.0
   var is_muted: bool = false
   ```
   Separate master, SFX, and music controls with persistence.

8. **8-CHANNEL POLYPHONY** (`sound_manager.gd:8`):
   ```gdscript
   const MAX_PLAYERS := 8
   ```
   Pool of 8 AudioStreamPlayers for simultaneous sounds.

### BallxPit Behavior (Research)

Based on gameplay videos and store descriptions:

1. **PRE-RECORDED AUDIO** - Professional studio-quality sound effects
2. **LICENSED MUSIC** - Multiple music tracks, possibly per-biome
3. **AUDIO VARIETY** - Different sounds per ball type, enemy type, impact type
4. **ADAPTIVE SOUNDTRACK** - Music responds to gameplay intensity
5. **POLISHED MIX** - Balanced levels, spatial audio for gameplay clarity

### DIFFERENCES

| Mechanic | GoPit | BallxPit | Impact |
|----------|-------|----------|--------|
| **Sound generation** | Procedural synthesis | Pre-recorded assets | **UNIQUE APPROACH** |
| **Music system** | Procedural 120 BPM | Composed tracks | **UNIQUE APPROACH** |
| **Audio file size** | ~0 bytes (no assets) | Large (audio files) | GoPit advantage |
| **Sound variety** | Infinite (random variance) | Fixed (asset-based) | Trade-off |
| **Polish level** | Retro/chiptune feel | Professional quality | Less polished |
| **Intensity scaling** | Yes (1.0-5.0) | Likely yes | Similar |
| **Per-ball sounds** | Yes (6 types) | Yes | Similar |
| **Status effect sounds** | Yes (4 types) | Yes | Similar |

### Analysis

GoPit's **fully procedural audio** is a **UNIQUE DIFFERENTIATOR**:

**Advantages:**
- Zero audio asset size (tiny game download)
- Infinite variation - no repetitive sounds
- Retro/chiptune aesthetic fits game style
- Dynamic music that scales with gameplay intensity

**Trade-offs:**
- Less polished than professional audio
- Limited to what can be synthesized (no voices, complex instruments)
- May sound "synthetic" to players expecting AAA audio

**Recommendation**: This is a **feature to emphasize**, not a gap to close. The procedural approach gives GoPit a unique audio identity.

### Beads Tracking This

- **GoPit-um2p**: VERIFY: Audio and music system - **COMPLETE**

---

## 13. UI/UX and HUD Layout (VERIFIED)

### GoPit Implementation (Code Evidence)

**Source Files:**
- `scripts/ui/hud.gd`
- `scripts/ui/character_select.gd`
- `scripts/ui/level_up_overlay.gd`
- `scenes/game.tscn`

**Key Code Findings:**

1. **HUD COMPONENTS** (`hud.gd:4-11`, `game.tscn:100-270`):
   ```
   TopBar:
   - HPBar (ProgressBar + label showing HP/MaxHP)
   - WaveLabel (e.g., "The Pit 3/10")
   - MuteButton (speaker icon toggle)
   - PauseButton

   XPBarContainer:
   - XPBar (ProgressBar)
   - LevelLabel (e.g., "Lv.5")

   ComboLabel (pop-up with animation)

   InputContainer (bottom):
   - Move Joystick (left)
   - Fire Button + Auto Toggle (center-left)
   - Ultimate Button (center-right)
   - Aim Joystick (right)
   ```

2. **COMBO DISPLAY** (`hud.gd:103-128`):
   ```gdscript
   if combo >= 2:
       combo_label.text = "%dx COMBO!" % combo
       if multiplier > 1.0:
           combo_label.text += " (%.1fx XP)" % multiplier
       // Color: white < yellow (1.5x) < red (2.0x)
   ```
   Pop-up combo counter with XP multiplier, color-coded.

3. **10 UI OVERLAYS** (from `game.tscn`):
   - HUD (always visible during play)
   - GameOverOverlay (score, stats, shop/restart)
   - LevelUpOverlay (3 upgrade cards)
   - FusionOverlay (Fission/Fusion/Evolution tabs)
   - PauseOverlay (resume, mute, quit)
   - TutorialOverlay (hints with highlight ring)
   - MetaShop (permanent upgrade purchase)
   - CharacterSelect (6 characters with stats)
   - StageCompleteOverlay (stage cleared)
   - BossHPBar (when boss active)
   - DamageVignette (red flash on damage)

4. **CHARACTER SELECT** (`character_select.gd:6-23`):
   ```gdscript
   const CHARACTER_PATHS := [
       "rookie.tres", "pyro.tres", "frost_mage.tres",
       "tactician.tres", "gambler.tres", "vampire.tres"
   ]
   ```
   6 characters with:
   - Portrait (colored placeholder with letter)
   - Name, description
   - Stat bars (HP, DMG, SPD, CRIT)
   - Passive ability display
   - Starting ball type
   - Locked overlay for unmet requirements

5. **LEVEL-UP CARDS** (`level_up_overlay.gd:22-25`):
   ```gdscript
   enum CardType {
       PASSIVE,       # Traditional stat upgrades
       NEW_BALL,      # Acquire new ball type
       LEVEL_UP_BALL  # Level up owned ball (L1->L2->L3)
   }
   ```
   3 cards from random pool of passives + ball upgrades.

6. **PORTRAIT-MODE LAYOUT** (`game.tscn` resolution):
   ```
   720x1280 (9:16 aspect ratio)
   ```
   Designed for mobile portrait orientation.

7. **TOUCH-FRIENDLY CONTROLS**:
   - Virtual joysticks with 80px base radius
   - Fire button with 50px radius
   - All buttons minimum 60px touch targets

### BallxPit Behavior (Research)

Based on gameplay videos and app store screenshots:

1. **BALL SLOT BAR** - 4-5 ball slots shown at top with equipped balls
2. **SPEED TOGGLE** - 1x/1.5x/2x/4x visible in HUD
3. **PERK SLOTS** - 4 equipped perks visible
4. **LEVEL SELECT** - Stage selection screen with unlock progression
5. **BUILDING VIEW** - City/farm area for meta-progression
6. **NG+ INDICATOR** - Shows current NG+ iteration
7. **GEAR CURRENCY** - Displayed alongside gold/XP
8. **LANDSCAPE MODE** - Many screenshots show landscape orientation

### DIFFERENCES

| Element | GoPit | BallxPit | Impact |
|---------|-------|----------|--------|
| **Ball slots display** | None (1 active) | 4-5 slot bar | Missing |
| **Speed toggle** | None | 1x-4x selector | Missing |
| **Perk/passive display** | None visible | 4 slots shown | Missing |
| **Level select** | None (linear) | Stage picker | Missing |
| **Building/city view** | None | Meta-progression hub | Missing |
| **Orientation** | Portrait only | Both orientations | Different |
| **Character count** | 6 | 16+ | Fewer options |
| **Combo display** | Yes (XP mult) | Unknown | GoPit feature |
| **Tutorial overlay** | Yes (highlight ring) | Unknown | GoPit feature |

### GoPit UI Advantages

1. **Combo system with visual feedback** - Color-coded, animated pop-up
2. **Tutorial highlight ring** - Points to UI elements for onboarding
3. **Damage vignette** - Red screen flash for damage feedback
4. **Clean portrait layout** - Optimized for mobile one-handed play
5. **Wave announcement** - "Stage X - Wave Y" splash text

### Missing UI Elements (Priority)

1. **Ball slot bar** - Critical for multi-ball system (P0 if multi-ball added)
2. **Speed toggle** - Common request for action games (P2)
3. **Level select screen** - Required for stage unlock system (P1)
4. **Perk/passive display** - If perk system added (P2)
5. **Building view** - If meta-progression expanded (P3)

### Beads Tracking This

- **GoPit-tl0a**: VERIFY: UI/UX and HUD layout - **COMPLETE**
- **GoPit-b1l**: Add level select UI screen - P1
- **GoPit-21cr**: Add speed toggle system - P2
