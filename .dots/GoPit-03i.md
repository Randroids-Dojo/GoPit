---
title: Complete character speed stat implementation
status: open
priority: 4
issue-type: task
assignee: randroid
created-at: 2026-01-08T19:57:15.362181-06:00
---

## Description

Verify that character speed stat is fully implemented across all relevant systems.

## Context

The original issue reported that speed stat only affected player movement. After code review, the speed stat appears to be implemented in more places than originally noted.

## Current Implementation (Verified)

The `character_speed_mult` stat currently affects:

1. **Player movement** - `player.gd:44` via `GameManager.get_movement_speed_mult()`
2. **Ball speed** - `ball_spawner.gd:337-353` applies `speed_mult` to all fired balls
3. **Baby ball speed** - `ball_spawner.gd:403-416` applies `speed_mult` to baby balls
4. **Fire cooldown** - `fire_button.gd:131` divides cooldown by `character_speed_mult`

## Investigation Notes

- "Enemy scaling" mentioned in original issue likely refers to wave-based difficulty scaling (HP/speed per wave) which is a separate system, not tied to character stats
- The speed stat implementation appears complete for the intended design

## Recommended Action

Verify in-game that speed stat differences between characters are noticeable for:
- Movement speed
- Ball velocity
- Fire rate

If all working correctly, this task can be closed.

## Verify

- [ ] Low-speed character (e.g., Blazor speed=0.8) moves slower than high-speed character
- [ ] Ball speed visibly differs between characters
- [ ] Fire cooldown is shorter for fast characters
- [ ] `./test.sh` passes
