---
title: Add pitch variation to sound effects
status: done
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:12:31.707031-06:00
---

## Problem
Same procedural sounds repeat constantly. Gets annoying with high fire rate.

## Implementation Plan

### Add Pitch Variation to Play Function
**Modify: `scripts/autoload/sound_manager.gd`**

```gdscript
@export var pitch_variance: float = 0.1  # ±10% pitch variation

func play(sound_type: SoundType) -> void:
    var player := _get_available_player()
    if not player:
        return
    
    # Generate the sound
    player.stream = _generate_sound(sound_type)
    
    # Apply random pitch variation
    player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
    
    player.play()
```

### Per-Sound Variance Settings
Different sounds benefit from different variance amounts:

```gdscript
const SOUND_SETTINGS := {
    SoundType.FIRE: {"pitch_variance": 0.15, "volume_variance": 0.1},
    SoundType.HIT_WALL: {"pitch_variance": 0.2, "volume_variance": 0.15},
    SoundType.HIT_ENEMY: {"pitch_variance": 0.1, "volume_variance": 0.1},
    SoundType.ENEMY_DEATH: {"pitch_variance": 0.05, "volume_variance": 0.05},
    SoundType.GEM_COLLECT: {"pitch_variance": 0.2, "volume_variance": 0.1},
    SoundType.PLAYER_DAMAGE: {"pitch_variance": 0.05, "volume_variance": 0.0},  # Consistent for recognition
    SoundType.LEVEL_UP: {"pitch_variance": 0.0, "volume_variance": 0.0},  # Always same
    SoundType.GAME_OVER: {"pitch_variance": 0.0, "volume_variance": 0.0}
}

func play(sound_type: SoundType) -> void:
    var settings = SOUND_SETTINGS.get(sound_type, {})
    var pitch_var = settings.get("pitch_variance", 0.1)
    var vol_var = settings.get("volume_variance", 0.1)
    
    player.pitch_scale = randf_range(1.0 - pitch_var, 1.0 + pitch_var)
    player.volume_db = randf_range(-vol_var * 6, vol_var * 6)  # ±0.6dB at 0.1 variance
```

### Alternative: Multiple Sound Variants
Pre-generate 3 variants of each sound at startup:

```gdscript
var sound_variants: Dictionary = {}  # SoundType -> Array[AudioStreamWAV]

func _ready():
    for sound_type in SoundType.values():
        sound_variants[sound_type] = []
        for i in range(3):
            sound_variants[sound_type].append(_generate_sound(sound_type))

func play(sound_type: SoundType) -> void:
    var variants = sound_variants[sound_type]
    var stream = variants[randi() % variants.size()]
    # ...
```

### Files to Modify
1. MODIFY: `scripts/autoload/sound_manager.gd` - add pitch/volume variance
