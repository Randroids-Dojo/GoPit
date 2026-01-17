---
title: EPIC: Phase 4 - Character System
status: done
priority: 2
issue-type: feature
assignee: randroid
created-at: 2026-01-05T23:19:25.524139-06:00
---

# Phase 4: Multiple Playable Characters

## Overview
Implement character selection with unique starting balls, stats, and passive abilities.

## Success Criteria
- [ ] Character selection screen before game start
- [ ] 6 unique characters implemented
- [ ] Each character has unique starting ball
- [ ] Character stats affect gameplay (HP, damage, speed, etc)
- [ ] Character-specific passive abilities

## Reference
- [Ball x Pit Characters](https://store.steampowered.com/app/2062430/BALL_x_PIT/)
- [GDD.md Section 4.2](./GDD.md#42-characters-new)

## Technical Context
Current state:
- Single implicit "player" with fixed stats
- game_manager.gd has player_hp, max_hp
- ball_spawner.gd has ball_damage, ball_speed
- No character selection exists

## Character Roster

| Character | Starting Ball | Passive | Stats Focus |
|-----------|---------------|---------|-------------|
| Rookie | Basic | None | Balanced |
| Pyro | Burn | +20% fire damage | Strength |
| Frost Mage | Freeze | Frozen +50% dmg | Intelligence |
| Tactician | Iron | +2 baby balls | Leadership |
| Gambler | Random | 3x crit damage | Dexterity |
| Vampire | Bleed | Lifesteal | Endurance |

## Stat System
- Endurance: Max HP (base 100)
- Strength: Ball damage multiplier
- Leadership: Baby ball count/rate
- Speed: Movement velocity
- Dexterity: Crit chance
- Intelligence: Status effect duration

## Implementation Approach
1. Create Character resource type
2. Character selection scene
3. GameManager loads selected character
4. Stats applied to relevant systems

## Child Tasks
1. Character Resource & Data
2. Character Selection UI
3. Stat System Integration
4. Implement 6 Characters
5. Character Unlock System

## Dependencies
- Depends on Phase 1 (baby balls for Tactician)
- Depends on Phase 2 (status effects for starting balls)
