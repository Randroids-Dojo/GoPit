---
title: Visual Effects Polish
status: open
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:42:46.965408-06:00
---

# Visual Effects Polish

## Parent Epic
GoPit-aoo (Phase 5 - Polish & Release)

## Overview
Add visual polish including particle effects, screen transitions, and juice.

## Requirements
1. Ball trails per type (fire trail, ice sparkle, etc)
2. Status effect particles on enemies
3. Boss attack telegraphs (ground markers, warnings)
4. Screen transitions between biomes
5. Victory/defeat animations
6. UI animations (level up flourish, etc)

## Visual Effects Needed
**Ball Trails:**
- Fire: orange ember trail
- Ice: blue frost particles
- Lightning: electric sparks
- Poison: green drips
- Evolved balls: enhanced trails

**Enemy Effects:**
- Burn: flames on body
- Freeze: ice crystals
- Poison: green bubbles
- Bleed: blood drips

**Boss Effects:**
- Attack telegraph markers
- Phase transition flash
- Damage flash
- Death explosion

**UI Polish:**
- Level up confetti
- Combo counter pulse
- XP bar fill animation
- Card selection glow

## Files to Create/Modify
- NEW: scenes/effects/*.tscn (various)
- MODIFY: scripts/entities/ball.gd (trails)
- MODIFY: scripts/entities/enemies/enemy_base.gd
- MODIFY: UI scripts for animations

## Acceptance Criteria
- [ ] All ball types have distinct trails
- [ ] Status effects visible on enemies
- [ ] Boss attacks clearly telegraphed
- [ ] Smooth biome transitions
- [ ] Satisfying victory animation
- [ ] UI feels responsive and juicy
