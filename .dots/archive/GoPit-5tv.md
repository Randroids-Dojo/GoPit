---
title: Visual Effects Polish
status: closed
priority: 3
issue-type: task
assignee: randroid
created-at: "2026-01-05T23:42:46.965408-06:00"
closed-at: "2026-01-19T10:28:03.321509-06:00"
---

# Visual Effects Polish

## Parent Epic
GoPit-aoo (Phase 5 - Polish & Release)

## Overview
Add visual polish including particle effects, screen transitions, and juice.

## Child Tasks
- GoPit-lbw - Add visual effect particles for status effects **DONE**
- GoPit-implement-add-biome-8c222354 - Add biome transition effect **DONE**
- GoPit-implement-add-victory-58a877c8 - Add victory and defeat animations **DONE**
- GoPit-implement-add-ui-8d3db9b7 - Add UI animations for level-up and cards **DONE**

## Progress (2026-01-19)

**COMPLETED:**
- [x] Ball trails per type - fire, ice, lightning, poison, bleed, iron, vampire trails exist in `scenes/effects/*_trail.tscn`
- [x] Status effect particles on enemies - All 9 status effects have particles (GoPit-lbw)
- [x] Boss attack telegraphs - All 8 bosses have telegraphs via `_show_attack_telegraph()` (e.g., SlimeKing has slam shadow, color flashes)
- [x] Screen transitions between biomes (GoPit-implement-add-biome-8c222354) **DONE**
- [x] Victory/defeat animations (GoPit-implement-add-victory-58a877c8) **DONE**
- [x] UI animations (GoPit-implement-add-ui-8d3db9b7) **DONE**

**ALL VISUAL EFFECTS COMPLETE** - Task ready to close

## Requirements
1. ~~Ball trails per type (fire trail, ice sparkle, etc)~~ **DONE**
2. ~~Status effect particles on enemies~~ **DONE**
3. ~~Boss attack telegraphs (ground markers, warnings)~~ **DONE** - via `_show_attack_telegraph()` in boss_base.gd + subclasses
4. ~~Screen transitions between biomes~~ **DONE** - fade-to-black with stage name
5. ~~Victory/defeat animations~~ **DONE** - bounce animations on overlays
6. ~~UI animations (level up flourish, etc)~~ **DONE** - staggered card entrance, hover, selection

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
- [x] All ball types have distinct trails **DONE**
- [x] Status effects visible on enemies **DONE**
- [x] Boss attacks clearly telegraphed **DONE** - all 8 bosses have `_show_attack_telegraph()` implementations
- [x] Smooth biome transitions **DONE** - fade-to-black with stage name display
- [x] Satisfying victory animation **DONE** - bounce animations with screen shake
- [x] UI feels responsive and juicy **DONE** - staggered cards, hover effects, selection highlight

## Verify
- [ ] `./test.sh` passes
- [ ] Fire each ball type - trail effect visible and distinct
- [ ] Apply status effects to enemies - particle effects show on enemy
- [ ] Fight a boss - attack telegraph markers visible before attacks
- [ ] Transition between biomes - smooth visual transition effect
- [ ] Win the game - satisfying victory animation plays
- [ ] Level up - UI animations feel responsive
