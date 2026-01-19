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
# Complete biome music parameters - each biome gets distinct musical character
const BIOME_MUSIC = {
    # Stage 1 - Tutorial zone, accessible feel
    "The Pit": {"root": 110.0, "scale": "minor", "tempo": 120, "intensity_base": 1.0, "melody_octave": 2},

    # Stage 2 - Cold, ethereal, slower pace
    "Frozen Depths": {"root": 82.4, "scale": "lydian", "tempo": 90, "intensity_base": 0.8, "melody_octave": 3},

    # Stage 3 - Hot, aggressive, phrygian for tension
    "Burning Sands": {"root": 146.8, "scale": "phrygian", "tempo": 140, "intensity_base": 1.2, "melody_octave": 2},

    # Stage 4 - Ominous descent, locrian for dissonance
    "Final Descent": {"root": 73.4, "scale": "locrian", "tempo": 100, "intensity_base": 1.0, "melody_octave": 2},

    # Stage 5 - Swampy, unsettling, chromatic feel
    "Toxic Marsh": {"root": 98.0, "scale": "dorian", "tempo": 105, "intensity_base": 0.9, "melody_octave": 2},

    # Stage 6 - Electric, chaotic energy
    "Storm Spire": {"root": 130.8, "scale": "mixolydian", "tempo": 135, "intensity_base": 1.3, "melody_octave": 3},

    # Stage 7 - Mystical, crystalline
    "Crystal Caverns": {"root": 123.5, "scale": "major", "tempo": 110, "intensity_base": 1.0, "melody_octave": 3},

    # Stage 8 - Final stage, epic, heavy
    "The Abyss": {"root": 65.4, "scale": "minor", "tempo": 130, "intensity_base": 1.5, "melody_octave": 1},
}

# Scale definitions (intervals from root in semitones)
const SCALES = {
    "minor": [0, 2, 3, 5, 7, 8, 10],        # Natural minor
    "lydian": [0, 2, 4, 6, 7, 9, 11],       # Bright, dreamy
    "phrygian": [0, 1, 3, 5, 7, 8, 10],     # Spanish/tense
    "locrian": [0, 1, 3, 5, 6, 8, 10],      # Very dissonant
    "dorian": [0, 2, 3, 5, 7, 9, 10],       # Minor with raised 6th
    "mixolydian": [0, 2, 4, 5, 7, 9, 10],   # Major with flat 7th
    "major": [0, 2, 4, 5, 7, 9, 11],        # Standard major
}
```

**Boss Music Trigger:**
- Connect to `StageManager.boss_wave_reached` in MusicManager._ready()
- Set `is_boss_fight = true` in MusicManager
- Boss music modifications:
  - Tempo increase: +20% from biome tempo
  - Heavier kick pattern: Double kick on beats 1 and 3
  - Remove melody (drums + bass only for intensity)
  - Volume boost: +3dB on drums
- On `StageManager.stage_completed`, transition back to next biome music

**Signal Wiring:**
```gdscript
func _ready() -> void:
    # Existing setup...
    StageManager.biome_changed.connect(_on_biome_changed)
    StageManager.boss_wave_reached.connect(_on_boss_wave_reached)
    StageManager.stage_completed.connect(_on_stage_completed)

func _on_biome_changed(biome: Biome) -> void:
    _crossfade_to_biome(biome.biome_name)

func _on_boss_wave_reached(_stage: int) -> void:
    is_boss_fight = true
    _apply_boss_mode()

func _on_stage_completed(_stage: int) -> void:
    is_boss_fight = false
    # Next biome change will trigger _on_biome_changed
```

**Crossfade Implementation:**
```gdscript
var _crossfade_timer: Timer
var _crossfade_duration: float = 1.0
var _target_biome: String = ""

func _crossfade_to_biome(biome_name: String) -> void:
    # Store target and start fade-out
    _target_biome = biome_name
    # Tween current volume down over 0.5s
    # Change parameters
    # Tween volume back up over 0.5s
```

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
