---
title: "implement: Add per-biome music parameters to MusicManager"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-19T11:05:40.780535-06:00\\\"\""
closed-at: "2026-01-19T11:10:40.739500-06:00"
close-reason: Added per-biome music parameters with 8 unique biome configurations (root, scale, tempo). Tests pass.
---

## Description

Add biome-specific music parameters (root note, scale, tempo) to the procedural music system so each of the 8 biomes has a distinct musical character.

## Context

The Audio Pass task (GoPit-0it) recommends Option A: extend the procedural system rather than adding real music tracks. The infrastructure is already in place:
- `MusicManager` has working procedural bass/drums/melody generation
- `StageManager.biome_changed` signal is already connected in game_controller.gd
- 8 biomes are defined: The Pit, Frozen Depths, Burning Sands, Final Descent, Toxic Marsh, Storm Spire, Crystal Caverns, The Abyss

## Implementation

### 1. Add biome music data to MusicManager

```gdscript
const BIOME_MUSIC := {
    "The Pit": {"root": 110.0, "scale": "minor", "tempo": 120, "intensity_base": 1.0},
    "Frozen Depths": {"root": 82.4, "scale": "lydian", "tempo": 90, "intensity_base": 0.8},
    "Burning Sands": {"root": 146.8, "scale": "phrygian", "tempo": 140, "intensity_base": 1.2},
    "Final Descent": {"root": 73.4, "scale": "locrian", "tempo": 100, "intensity_base": 1.0},
    "Toxic Marsh": {"root": 98.0, "scale": "dorian", "tempo": 105, "intensity_base": 0.9},
    "Storm Spire": {"root": 130.8, "scale": "mixolydian", "tempo": 135, "intensity_base": 1.3},
    "Crystal Caverns": {"root": 123.5, "scale": "major", "tempo": 110, "intensity_base": 1.0},
    "The Abyss": {"root": 65.4, "scale": "minor", "tempo": 130, "intensity_base": 1.5},
}

const SCALES := {
    "minor": [0, 2, 3, 5, 7, 8, 10],
    "lydian": [0, 2, 4, 6, 7, 9, 11],
    "phrygian": [0, 1, 3, 5, 7, 8, 10],
    "locrian": [0, 1, 3, 5, 6, 8, 10],
    "dorian": [0, 2, 3, 5, 7, 9, 10],
    "mixolydian": [0, 2, 4, 5, 7, 9, 10],
    "major": [0, 2, 4, 5, 7, 9, 11],
}
```

### 2. Add set_biome() method

```gdscript
var _current_biome: String = "The Pit"
var _current_scale: Array[int] = [0, 2, 3, 5, 7, 8, 10]

func set_biome(biome_name: String) -> void:
    if not biome_name in BIOME_MUSIC:
        return
    _current_biome = biome_name
    var params: Dictionary = BIOME_MUSIC[biome_name]
    _root_note = params["root"]
    _current_scale = SCALES[params["scale"]]
    _beat_timer.wait_time = 60.0 / params["tempo"] / 2.0  # Eighth notes
    current_intensity = params["intensity_base"]
```

### 3. Update _play_melody_note() to use current scale

Change from hardcoded minor pentatonic to _current_scale.

### 4. Connect to biome_changed signal

In _ready():
```gdscript
StageManager.biome_changed.connect(_on_biome_changed)

func _on_biome_changed(biome: Biome) -> void:
    set_biome(biome.biome_name)
```

## Affected Files

- MODIFY: scripts/autoload/music_manager.gd

## Verify

- [ ] ./test.sh passes  
- [ ] Play through Stage 1 - has original music feel
- [ ] Progress to Stage 2 (Frozen Depths) - music changes noticeably (slower, different key)
- [ ] Each biome has distinct musical character
- [ ] No audio glitches or pops during transitions
