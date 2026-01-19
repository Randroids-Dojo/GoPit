---
title: EPIC: Phase 5 - Polish & Release
status: open
priority: 3
issue-type: feature
assignee: randroid
created-at: 2026-01-05T23:19:25.78436-06:00
---

# Phase 5: Polish & Release Readiness

## Overview
Final polish pass including audio, visual effects, mobile optimization, and release preparation.

## Success Criteria
- [ ] Unique music per biome
- [ ] Complete SFX coverage
- [x] Particle effects for all actions **DONE** (ball trails + status effect particles)
- [x] Tutorial for new players **DONE** (first-time hints for level-up and shop)
- [ ] Mobile performance optimized (60fps)
- [x] Web export working **DONE** (CI verification added)
- [x] All tests passing

## Reference
- [GDD.md Section 7](./GDD.md#7-development-roadmap)

## Technical Context
Current state:
- sound_manager.gd has basic SFX
- music_manager.gd plays single track
- camera_shake.gd, hit_particles.gd exist
- tutorial_overlay.gd has basic tutorial
- PlayGodot tests exist in tests/

## Audio Needs
Per biome:
- Background music track
- Ambient sounds
- Boss fight music

SFX gaps to fill:
- Ball type-specific sounds
- Status effect sounds
- Boss attack sounds
- UI feedback sounds

## Visual Polish
- ~~Ball trails per type~~ **DONE**
- ~~Status effect particles~~ **DONE**
- ~~Boss attack telegraphs~~ **DONE**
- ~~Screen transitions between biomes~~ **DONE**
- ~~Victory/defeat animations~~ **DONE**
- ~~UI animations (level-up flourish)~~ **DONE**

**All visual polish complete (GoPit-5tv closed)**

## Performance
- Profile on mobile devices
- Optimize particle systems
- Batch draw calls
- Memory management for long sessions

## Child Tasks
1. ~~GoPit-64u - Add audio settings with volume controls~~ **CLOSED**
2. GoPit-0it - Complete Audio Pass (includes biome music & SFX)
3. ~~GoPit-5tv - Visual Effects Polish~~ **CLOSED** (6/6 items done)
4. GoPit-29a - Mobile Optimization & Testing

**Created from research (COMPLETED):**
- ~~GoPit-implement-add-first-bd018b35 - Tutorial hints for level-up and shop~~ **CLOSED**
- ~~GoPit-implement-add-web-162122e6 - Web export CI verification~~ **CLOSED**

**Note:** Ultimate ability (GoPit-a0p) was intentionally removed per BallxPit alignment - feature in stale salvo-firing branch.

## Dependencies
Depends on all prior phases being feature-complete
