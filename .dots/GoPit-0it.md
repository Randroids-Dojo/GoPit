---
title: Complete Audio Pass
status: open
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:42:46.743197-06:00
---

# Complete Audio Pass

## Parent Epic
GoPit-aoo (Phase 5 - Polish & Release)

## Overview
Add comprehensive audio coverage including biome music, complete SFX, and audio polish.

## Requirements
1. Unique music track per biome
2. Boss fight music
3. SFX for all ball types
4. SFX for all status effects
5. UI feedback sounds
6. Victory/defeat fanfares

## Audio Inventory Needed
**Music:**
- The Pit (mysterious, underground)
- Frozen Depths (icy, ethereal)
- Burning Sands (intense, percussive)
- Final Descent (epic, dramatic)
- Boss fight (intense, looping)
- Victory fanfare
- Game over sting

**SFX Gaps:**
- Ball type sounds (fire whoosh, ice crack, etc)
- Status effect ticks
- Boss attack telegraphs
- Phase transition
- Fusion reactor pickup
- Level complete

## Files to Create/Modify
- NEW: assets/audio/music/*.ogg
- NEW: assets/audio/sfx/*.wav
- MODIFY: scripts/autoload/sound_manager.gd
- MODIFY: scripts/autoload/music_manager.gd

## Acceptance Criteria
- [ ] Each biome has unique music
- [ ] Boss fights have intense music
- [ ] All ball types have distinct sounds
- [ ] Status effects have audio feedback
- [ ] Complete UI sound coverage
- [ ] Audio levels balanced
