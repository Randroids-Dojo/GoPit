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
- Ball trails per type
- Status effect particles
- Boss attack telegraphs
- Screen transitions between biomes
- Victory/defeat animations

## Performance
- Profile on mobile devices
- Optimize particle systems
- Batch draw calls
- Memory management for long sessions

## Child Tasks
1. GoPit-64u - Add audio settings with volume controls
2. GoPit-0it - Complete Audio Pass (includes biome music & SFX)
3. GoPit-5tv - Visual Effects Polish (2/6 items done: ball trails, status particles)
   - ~~GoPit-lbw - Add visual effect particles for status effects~~ **CLOSED**
4. GoPit-29a - Mobile Optimization & Testing

**Created from research (COMPLETED):**
- ~~GoPit-implement-add-first-bd018b35 - Tutorial hints for level-up and shop~~ **CLOSED**
- ~~GoPit-implement-add-web-162122e6 - Web export CI verification~~ **CLOSED**

**Note:** GoPit-a0p (Ultimate ability) is implemented in `feature/salvo-firing` branch - merge pending.

## Dependencies
Depends on all prior phases being feature-complete
