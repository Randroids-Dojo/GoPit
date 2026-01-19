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
Enhance audio system with per-biome music variation and ensure complete SFX coverage.

## Current State

**Already Implemented (SFX):**
- Ball type sounds: FIRE_BALL, ICE_BALL, LIGHTNING_BALL, POISON_BALL, BLEED_BALL, IRON_BALL
- Status effect sounds: BURN_APPLY, FREEZE_APPLY, POISON_APPLY, BLEED_APPLY
- Fusion sounds: FUSION_REACTOR, EVOLUTION, FISSION
- Core sounds: FIRE, HIT_WALL, HIT_ENEMY, ENEMY_DEATH, GEM_COLLECT, PLAYER_DAMAGE, LEVEL_UP, GAME_OVER, WAVE_COMPLETE, BLOCKED
- Combat feedback: WEAK_POINT_HIT
- All sounds use procedural generation via `_generate_*()` methods

**Already Implemented (Music):**
- Procedural music system with bass, drums, melody tracks
- Intensity scaling based on wave number (`set_intensity()`)
- Bass pattern with root note A2, drum pattern (kick/snare/hihat)
- Melody uses minor pentatonic scale

**Infrastructure Ready but Unused:**
- `resources/biomes/biome.gd` has commented `# @export var music_track: AudioStream`
- 8 biomes defined in `stage_manager.gd`: The Pit, Frozen Depths, Burning Sands, Final Descent, Toxic Marsh, Storm Spire, Crystal Caverns, The Abyss

## Requirements

### 1. Biome Music Variation (Choose One Approach)

**Option A: Extend Procedural System (Recommended)**
- Add biome-specific parameters to MusicManager (root note, scale, tempo, instrument mix)
- Each biome gets unique musical character through parameter changes
- Pros: No asset files needed, smaller build size, consistent with current approach
- Cons: Less musical variety than real recordings

**Option B: Add Real Music Tracks**
- Source/create 8 looping music tracks (one per biome)
- Enable `music_track` field in biome.gd
- Add crossfade logic to MusicManager
- Pros: Professional-sounding, more variety
- Cons: Larger build size, need audio assets

### 2. Boss Music
- Detect boss wave via `StageManager.boss_wave_reached` signal
- Switch to intense music mode (faster tempo, heavier drums, no melody)
- Return to biome music after boss defeated

### 3. Audio Polish
- Crossfade between biome/boss music (0.5-1s)
- Ensure volume levels balanced across all SFX
- Test on multiple devices for audio clipping

## Files to Modify

**For Option A (Procedural Biome Music):**
- MODIFY: `scripts/autoload/music_manager.gd` - Add biome parameters, boss mode
- MODIFY: `resources/biomes/biome.gd` - Add `@export var music_params: Dictionary`
- MODIFY: `resources/biomes/*.tres` - Add music parameters per biome
- MODIFY: `scripts/game/game_controller.gd` - Connect biome_changed signal

**For Option B (Real Music Tracks):**
- NEW: `assets/audio/music/*.ogg` - 8 biome tracks + boss track
- MODIFY: `resources/biomes/biome.gd` - Uncomment `music_track` field
- MODIFY: `resources/biomes/*.tres` - Reference music files
- MODIFY: `scripts/autoload/music_manager.gd` - Add track playback, crossfade

## Implementation Notes

**Biome Music Parameters (Option A):**
```gdscript
# Example biome music parameters
const BIOME_MUSIC = {
    "The Pit": {"root": 110.0, "scale": "minor", "tempo": 120, "intensity_base": 1.0},
    "Frozen Depths": {"root": 82.4, "scale": "lydian", "tempo": 90, "intensity_base": 0.8},
    "Burning Sands": {"root": 146.8, "scale": "phrygian", "tempo": 140, "intensity_base": 1.2},
    # etc.
}
```

**Boss Music Trigger:**
- Connect to `StageManager.boss_wave_reached`
- Set `is_boss_fight = true` in MusicManager
- Increase tempo, add heavier kick pattern
- On boss defeat, transition back

## Acceptance Criteria
- [ ] Each of the 8 biomes has distinct musical feel
- [ ] Boss fights trigger intense music variant
- [ ] Music transitions smoothly between biomes (no hard cuts)
- [ ] All existing SFX continue to work
- [ ] Audio levels balanced (no clipping, audible but not overwhelming)

## Verify
- [ ] `./test.sh` passes
- [ ] Play through Stage 1 (The Pit) - has base music feel
- [ ] Transition to Stage 2 (Frozen Depths) - music changes noticeably
- [ ] Reach boss wave - music intensifies
- [ ] Defeat boss - music returns to biome style
- [ ] Check all 8 biomes have distinct music character
- [ ] Navigate menus - existing UI sounds still work
- [ ] Win/lose game - appropriate audio plays
