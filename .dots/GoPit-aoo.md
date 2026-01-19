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
- [x] Complete SFX coverage **DONE** (procedural audio for all ball types, status effects, fusion, UI)
- [x] Particle effects for all actions **DONE** (ball trails + status effect particles)
- [x] Tutorial for new players **DONE** (first-time hints for level-up and shop)
- [ ] Mobile performance optimized (60fps)
- [x] Web export working **DONE** (CI verification added)
- [x] All tests passing

## Reference
- [GDD.md Section 7](./GDD.md#7-development-roadmap)

## Technical Context (Updated 2026-01-19)

**Audio System:**
- `sound_manager.gd` - Comprehensive procedural SFX with 25+ sound types:
  - Ball types: FIRE_BALL, ICE_BALL, LIGHTNING_BALL, POISON_BALL, BLEED_BALL, IRON_BALL
  - Status effects: BURN_APPLY, FREEZE_APPLY, POISON_APPLY, BLEED_APPLY
  - Fusion: FUSION_REACTOR, EVOLUTION, FISSION
  - Combat: FIRE, HIT_WALL, HIT_ENEMY, ENEMY_DEATH, WEAK_POINT_HIT
  - UI/progression: GEM_COLLECT, PLAYER_DAMAGE, LEVEL_UP, GAME_OVER, WAVE_COMPLETE, BLOCKED
- `music_manager.gd` - Procedural music with bass/drums/melody, intensity scaling
- Audio buses: Master, SFX, Music with volume controls

**Rendering/Performance:**
- Object pooling: balls (20-50), gems (30-100), damage numbers (30-100)
- Renderer: gl_compatibility mode (mobile-optimized)
- Pool manager in `scripts/autoload/pool_manager.gd`

**Exports:**
- Web export configured with custom shell
- iOS/Android export presets NOT yet configured

## Remaining Audio Work
- [ ] Per-biome music variation (8 biomes need distinct musical feel)
- [ ] Boss fight music trigger
- [ ] Music crossfades between biomes

## Visual Polish
- ~~Ball trails per type~~ **DONE**
- ~~Status effect particles~~ **DONE**
- ~~Boss attack telegraphs~~ **DONE**
- ~~Screen transitions between biomes~~ **DONE**
- ~~Victory/defeat animations~~ **DONE**
- ~~UI animations (level-up flourish)~~ **DONE**

**All visual polish complete (GoPit-5tv closed)**

## Remaining Performance Work
- [ ] Add iOS/Android export presets
- [ ] Profile on real mobile devices
- [ ] Enemy pooling (optional - assess if needed based on profiling)

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
