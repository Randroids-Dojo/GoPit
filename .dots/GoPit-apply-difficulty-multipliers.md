---
title: Apply difficulty multipliers to gameplay
status: open
priority: 2
issue-type: implement
created-at: "2026-01-27"
---

## Overview

Wire up the existing difficulty multipliers in GameManager to actually affect enemy spawning, health, and damage. Currently the UI shows multipliers but they're not applied.

## Context

GameManager has these constants and methods defined but they're not used:
- `get_difficulty_spawn_rate_multiplier()`
- `get_difficulty_enemy_hp_multiplier()`
- `get_difficulty_enemy_damage_multiplier()`

The difficulty selection feels cosmetic without applying these.

See: `docs/research/level-scrolling-comparison.md`

## Current Constants

From `game_manager.gd`:
```gdscript
const DIFFICULTY_SCALE_PER_LEVEL: float = 1.5  # HP/damage compound
const DIFFICULTY_XP_BONUS_PER_LEVEL: float = 0.15  # +15% XP per level
const DIFFICULTY_SPAWN_RATE_PER_LEVEL: float = 0.2  # +20% spawn rate
```

| Level | HP Mult | Damage Mult | Spawn Rate | XP Mult |
|-------|---------|-------------|------------|---------|
| 1 | 1.0x | 1.0x | 1.0x | 1.0x |
| 2 | 1.5x | 1.5x | 1.2x | 1.15x |
| 3 | 2.25x | 2.25x | 1.4x | 1.30x |
| 5 | 5.06x | 5.06x | 1.8x | 1.60x |
| 10 | 38.4x | 38.4x | 2.8x | 2.35x |

## Requirements

### 1. Enemy HP Scaling

In `enemy_base.gd` `_ready()`:
```gdscript
func _ready() -> void:
    # Apply difficulty HP multiplier
    var hp_mult := GameManager.get_difficulty_enemy_hp_multiplier()
    hp = int(hp * hp_mult)
    max_hp = hp
```

### 2. Enemy Damage Scaling

In `enemy_base.gd` attack methods:
```gdscript
func _deal_damage_to_player() -> void:
    var base_damage := damage
    var scaled_damage := int(base_damage * GameManager.get_difficulty_enemy_damage_multiplier())
    player.take_damage(scaled_damage)
```

### 3. Spawn Rate Scaling

In `enemy_spawner.gd`:
```gdscript
func _get_spawn_interval() -> float:
    var base_interval := spawn_interval
    var spawn_mult := GameManager.get_difficulty_spawn_rate_multiplier()
    return base_interval / spawn_mult  # Faster spawn = shorter interval
```

### 4. XP Scaling (Already Implemented?)

Verify XP multiplier is applied in gem/XP reward system.

## Implementation Steps

1. Apply HP multiplier in `enemy_base.gd` `_ready()`
2. Apply damage multiplier in enemy attack methods
3. Apply spawn rate to `enemy_spawner.gd` interval
4. Verify XP multiplier works
5. Test each difficulty tier

## Files to Modify

- `scripts/entities/enemies/enemy_base.gd` - HP and damage scaling
- `scripts/entities/enemies/enemy_spawner.gd` - spawn rate
- `scripts/entities/enemies/boss_base.gd` - boss HP scaling
- `scripts/entities/enemies/mini_boss_base.gd` - mini-boss scaling

## Balance Considerations

- Level 10 = 38x HP is extreme; may need adjustment
- Spawn rate caps at 2.8x; monitor performance
- Consider damage cap to prevent one-shots

## Testing

```python
async def test_difficulty_affects_enemy_hp(game):
    # Set difficulty 1
    await game.call(GAME_MANAGER, "set_difficulty_level", [1])
    # Spawn enemy and check HP
    # ...

    # Set difficulty 5
    await game.call(GAME_MANAGER, "set_difficulty_level", [5])
    # Spawn enemy and verify HP is ~5x higher
```

## Acceptance Criteria

- [ ] Enemy HP scales with difficulty tier
- [ ] Enemy damage scales with difficulty tier
- [ ] Spawn rate increases at higher difficulties
- [ ] XP rewards scale with difficulty
- [ ] Game feels noticeably harder at higher tiers
- [ ] No crashes at extreme scaling (level 10)
