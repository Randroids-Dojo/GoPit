---
title: Character Stats Integration
status: done
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:41:00.304164-06:00
---

# Character Stats Integration

## Parent Epic
GoPit-ivv (Phase 4 - Character System)

## Overview
Wire character stats to all gameplay systems so chosen character affects HP, damage, speed, etc.

## Requirements
1. GameManager loads selected character
2. HP scales with Endurance stat
3. Ball damage scales with Strength
4. Movement speed scales with Speed stat
5. Crit chance affected by Dexterity
6. Status duration affected by Intelligence
7. Baby ball rate affected by Leadership
8. Passive abilities activate

## Implementation
```gdscript
# game_manager.gd modifications
var current_character: Character

func start_game_with_character(character: Character) -> void:
    current_character = character
    max_hp = int(100 * character.endurance)
    # ... apply other stats

# ball_spawner.gd
func get_damage() -> int:
    var base := ball_damage
    return int(base * GameManager.current_character.strength)

# player.gd
func get_move_speed() -> float:
    return base_speed * GameManager.current_character.speed
```

## Passive Ability System
```gdscript
# Each passive is a script that hooks into game events
# Example: Pyro passive
func _on_burn_damage(amount: int) -> int:
    return int(amount * 1.2)  # +20% fire damage
```

## Files to Modify
- MODIFY: scripts/autoload/game_manager.gd
- MODIFY: scripts/entities/ball_spawner.gd
- MODIFY: scripts/entities/player.gd
- MODIFY: scripts/entities/baby_ball_spawner.gd
- NEW: scripts/characters/passives/*.gd

## Acceptance Criteria
- [ ] All 6 stats affect gameplay
- [ ] Endurance changes max HP
- [ ] Strength changes ball damage
- [ ] Speed changes player movement
- [ ] Dexterity changes crit chance
- [ ] Intelligence changes effect duration
- [ ] Leadership changes baby ball rate
- [ ] Each character passive works
