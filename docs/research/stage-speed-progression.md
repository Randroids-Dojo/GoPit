# BallxPit Stage Speed Progression Research

## Executive Summary

Ball x Pit uses a dual progression system:
1. **Speed/Difficulty Levels**: 11 tiers (Normal, Fast, Fast+1 through Fast+9) that scale enemy stats
2. **Stage Progression**: 8 biomes unlocked via "gear" currency earned by character completion

## Speed Level System

### All 11 Difficulty Tiers

| Level | Name | XP Multiplier | Enemy Scaling |
|-------|------|---------------|---------------|
| 1 | Normal | 1.0x | 1.0x HP/DMG |
| 2 | Fast | 1.25x | 1.5x HP/DMG, +50% spawn |
| 3 | Fast+ | ~1.35x | ~2.0x HP/DMG |
| 4 | Fast+2 | 1.5x | 2.5x HP/DMG, +150% spawn |
| 5 | Fast+3 | 2.0x | 4.0x+ HP/DMG, +250% spawn |
| 6-11 | Fast+4 to Fast+9 | Unknown | Exponential scaling |

**Sources**: [Steam Discussion](https://steamcommunity.com/app/2062430/discussions/0/624436409752737592/), [Game Modes Guide](https://ballxpit.org/guides/game-modes-comparison/)

### How Speed Levels Work

1. **Sequential Unlock**: Clear Normal to unlock Fast, clear Fast to unlock Fast+, etc.
2. **Per-Stage**: Each stage has its own speed level progression
3. **Per-Character**: Each character tracks their own completion per stage per speed
4. **Cascading Completion**: Beating Fast+9 counts as completing all lower difficulties for that character

**Key Quote**: "Finishing a run on a higher speed automatically unlocks the completion for every speed below that one if the character hasn't already done it."

### Scaling Formula

The scaling appears to be multiplicative:
- Enemy HP: ~1.5x per difficulty tier (compound)
- Enemy Damage: ~1.5x per difficulty tier (compound)
- Spawn Rate: Additive 50% per tier
- Run Duration: Decreases (Normal ~15-20min, Fast+3 ~6-9min)

### In-Game Speed Toggle (Separate System)

Ball x Pit also has a **gameplay speed** toggle (1, 2, 3 via keyboard or R1/RB):
- Speed 1: Slow motion for bosses/learning
- Speed 2: Normal gameplay speed
- Speed 3: Fast-forward for farming

This is DIFFERENT from the difficulty system.

## Stage Progression System

### All 8 Stages/Biomes

| Stage | Name | Gear Cost | Notes |
|-------|------|-----------|-------|
| 1 | The Bone x Yard | Free | Starting stage |
| 2 | The Snowy x Shores | 2 gears | |
| 3 | The Liminal x Desert | 2 gears | |
| 4 | The Fungal x Forest | 2 gears | |
| 5 | The Gory x Grasslands | 3 gears | |
| 6 | The Smoldering x Depths | 4 gears | |
| 7 | The Heavenly x Gates | 4 gears | |
| 8 | The Vast x Void | 5 gears | Final stage |

**Total Gears Needed**: 22 gears to unlock all stages

**Source**: [GameRant Stage Guide](https://gamerant.com/ball-x-pit-all-characters-stage-list-unlocks/)

### Gear Acquisition

- **1 gear** per stage completion with a NEW character
- Each character can only earn 1 gear per stage (first completion only)
- **Matchmaker building** allows 2 characters per run = 2 gears if both are new

### Stage Unlock Flow

```
Complete Stage 1 with 2 chars → 2 gears → Unlock Stage 2
Complete Stage 2 with 2 chars → 2 gears → Unlock Stage 3
... and so on
```

## Character Completion Tracking

### What's Tracked

- Which characters have completed each stage (any difficulty)
- Which difficulty tier each character has beaten per stage
- Gear earned (binary: has character beaten this stage before?)

### UI Implementation (Current BallxPit)

Current UI shows:
- Green checkmark on character portrait if they've beaten the stage
- No at-a-glance indicator of WHICH difficulty tier they've cleared

**Community Feedback**: Players want "a UI function on the completion checkmark that has N, F, or a number to tell at a glance" which difficulty was cleared.

**Source**: [Steam Level Selection Discussion](https://steamcommunity.com/app/2062430/discussions/0/689741692082922242/)

### Data Structure (Inferred)

```
character_progress = {
    "character_id": {
        "stage_1": {
            "completed": true,
            "highest_difficulty": 5,  // Fast+3
            "gear_earned": true
        },
        "stage_2": { ... }
    }
}
```

## New Game Plus (NG+)

- Unlocks after completing all 8 biomes on Normal
- +50% HP/damage to all enemies and bosses
- Checkpoints removed
- Resource costs 2-3x higher

**Source**: [NG+ Guide](https://ballxpit.org/guides/new-game-plus/)

## Recommended Implementation for GoPit

### Speed Level System

1. **10 difficulty tiers per stage** (matching BallxPit's Fast through Fast+9)
   - Normal mode could be a separate "practice" mode or tier 0
   - Or simplify to 5-6 tiers for initial implementation

2. **Scaling formula per tier**:
   ```gdscript
   enemy_hp_mult = pow(1.5, difficulty_tier)
   enemy_damage_mult = pow(1.5, difficulty_tier)
   spawn_rate_mult = 1.0 + (0.5 * difficulty_tier)
   xp_mult = 1.0 + (0.25 * difficulty_tier)  # Cap at 2.0x
   ```

3. **Sequential unlock**: Must beat tier N to attempt tier N+1

### Stage System

1. **8 stages** with escalating gear costs (2, 2, 2, 3, 4, 4, 5)
2. **Gear = first-time stage completion per character**
3. **Elevator/portal upgrade** UI to spend gears

### Character Completion Tracking

1. **Per-character, per-stage, per-difficulty** progress matrix
2. **UI indicators**:
   - Checkmark = any completion
   - Number/badge = highest difficulty cleared
   - Color coding (bronze/silver/gold) for difficulty ranges

3. **MetaManager storage**:
   ```gdscript
   var character_stage_progress: Dictionary = {
       "Rookie": {
           0: {"highest_tier": 3, "first_clear": true},
           1: {"highest_tier": 1, "first_clear": true},
       }
   }
   ```

### Matchmaker Mode (2-Character)

- Allow selecting 2 characters for a run
- Both earn gear if first-time completion
- Doubles progression rate

## Open Questions

1. **Does GoPit want all 10 speed tiers or fewer?**
   - Recommendation: Start with 5 (Normal, Fast, Fast+2, Fast+3, Fast+4)
   - Add more later if needed

2. **Should gear be character-bound or global pool?**
   - BallxPit: Character earns gear → goes to global pool
   - Keeps gear acquisition character-dependent but spending global

3. **NG+ implementation priority?**
   - Can be deferred; focus on speed tiers first

## Sources

- [Steam: How many difficulty levels?](https://steamcommunity.com/app/2062430/discussions/0/624436409752737592/)
- [Steam: Level Selection Discussion](https://steamcommunity.com/app/2062430/discussions/0/689741692082922242/)
- [BallxPit.org: Game Modes Comparison](https://ballxpit.org/guides/game-modes-comparison/)
- [BallxPit.org: Fast Mode Guide](https://ballxpit.org/guides/fast-mode/)
- [BallxPit.org: NG+ Guide](https://ballxpit.org/guides/new-game-plus/)
- [GameRant: Characters & Stage Unlocks](https://gamerant.com/ball-x-pit-all-characters-stage-list-unlocks/)
