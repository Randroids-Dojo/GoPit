---
title: EPIC: Phase 1 - Core Alignment
status: done
priority: 0
issue-type: feature
assignee: randroid
created-at: 2026-01-05T23:19:24.757556-06:00
---

# Phase 1: Core Alignment with BallxPit

## Overview
Align GoPit's core mechanics with Ball x Pit's fundamental gameplay loop. This phase addresses the most critical gaps between current implementation and target design.

## Success Criteria
- [ ] Player can move freely in the play area
- [ ] Autofire can be toggled on/off
- [ ] Enemies show warning before attacking
- [ ] Gems require player to walk over them
- [ ] Baby balls auto-generate and fire

## Reference
- [Ball x Pit Steam](https://store.steampowered.com/app/2062430/BALL_x_PIT/)
- [GDD.md Section 3.1](./GDD.md#31-player-character)

## Technical Context
Current architecture:
- game_controller.gd - Main game loop
- ball_spawner.gd - Ball firing logic  
- enemy_base.gd - Enemy behavior
- gem.gd - Gem collection
- Player zone is Area2D at bottom of screen

## Child Tasks
1. Player Free Movement
2. Autofire Toggle
3. Enemy Warning System
4. Gem Collection Rework
5. Baby Ball System

## Priority
P0 - Critical foundation for all other features
