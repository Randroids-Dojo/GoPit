---
title: EPIC: Phase 3 - Boss & Stages
status: open
priority: 2
issue-type: feature
assignee: randroid
created-at: 2026-01-05T23:19:25.263102-06:00
---

# Phase 3: Boss Fights & Biome System

## Overview
Add boss encounters and multiple biomes/stages to create level-based progression with a win condition.

## Success Criteria
- [ ] Boss base class with phases, patterns, HP bars
- [ ] At least 3 unique bosses implemented
- [ ] 3+ biomes with unique visuals and hazards
- [ ] Stage progression system (Pit → Ice → Desert → etc)
- [ ] Win condition: Beat final boss

## Reference
- [Ball x Pit Review](https://monstervine.com/2025/10/ball-x-pit-review/)
- [GDD.md Section 3.4](./GDD.md#34-boss-system-new)

## Technical Context
Current state:
- enemy_spawner.gd handles wave spawning
- enemy_base.gd is base class for enemies
- game_manager.gd tracks waves (endless)
- No boss or biome system exists

## Boss Design Pattern
Each stage has:
- Wave 10: Mini-boss (introduces mechanic)
- Wave 20: Stage boss (harder patterns)
- Wave 30: Final boss (multi-phase)

Boss Base Class needs:
- Large HP pool with visible HP bar
- Phase transitions (change patterns at HP thresholds)
- Telegraphed attacks (warning indicators)
- Add spawns during fight
- Invulnerability windows

## Biome System
Each biome needs:
- Unique background/tileset
- Stage-specific hazards
- Enemy variants (e.g., Ice Slime)
- Biome-specific music

## Child Tasks
1. Boss Base Class
2. First Boss: Slime King
3. Biome System Architecture
4. First Biome: The Pit (default)
5. Second Biome: Frozen Depths
6. Stage Progression & Win Condition

## Dependencies
Soft dependency on Phase 2 (balls should have variety for boss fights)
