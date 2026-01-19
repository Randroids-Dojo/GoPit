---
title: EPIC: Phase 2 - Ball Evolution System
status: done
priority: 1
issue-type: feature
assignee: randroid
created-at: 2026-01-05T23:19:24.999062-06:00
---

# Phase 2: Ball Evolution System

## Overview
Implement the full ball status effect and fusion system inspired by BallxPit's 100+ ball evolutions.

## Success Criteria
- [ ] 6 base status effects implemented (Burn, Freeze, Poison, Bleed, Lightning, Iron)
- [ ] Ball leveling system (L1 → L2 → L3)
- [ ] Fusion Reactor drops spawn
- [ ] At least 5 fusion combinations working
- [ ] Evolution stones for single-ball evolutions

## Reference
- [Ball x Pit Tactics Guide](https://md-eksperiment.org/en/post/20251224-ball-x-pit-2025-pro-tactics-for-character-builds-boss-fights-and-efficient-bases)
- [GDD.md Section 3.2](./GDD.md#32-ball-system)

## Technical Context
Current implementation:
- ball.gd has BallType enum: NORMAL, FIRE, ICE, LIGHTNING
- Fire/Ice/Lightning have basic effects
- level_up_overlay.gd handles upgrades
- No ball leveling or fusion system exists

## Key Mechanics
Ball Fusion Formula:
- Two L3 balls + Fusion Reactor = Evolved Ball
- Example: Burn L3 + Iron L3 = Bomb Ball

Status Effect Details:
- Burn: 5 dmg/sec for 3 sec
- Freeze: 50% slow for 2 sec
- Poison: 3 dmg/sec, spreads on death
- Bleed: Stacking 2 dmg/sec, lifesteal synergy
- Lightning: Chains to 2 nearby enemies
- Iron: +50% damage, knockback

## Child Tasks
1. Status Effect System
2. Ball Leveling (L1-L3)
3. Fusion Reactor Drops
4. Ball Fusion UI & Logic
5. Evolution Stones

## Dependencies
Depends on Phase 1 completion (player must move to collect fusion reactors)
