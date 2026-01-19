---
title: Add procedural background music
status: done
priority: 2
issue-type: feature
assignee: randroid
created-at: 2026-01-05T02:02:57.247416-06:00
---

## Problem
Game is silent except for SFX. Feels empty and less engaging.

## Implementation Plan

### Approach: Extend SoundManager with procedural music generation

**Modify: `scripts/autoload/sound_manager.gd`**

```gdscript
# Add music generation alongside existing SFX

var music_player: AudioStreamPlayer
var current_tempo: float = 120.0  # BPM
var current_wave: int = 1
var beat_timer: float = 0.0

# Pentatonic scale for pleasant procedural music
const SCALE = [0, 2, 4, 7, 9, 12, 14, 16]  # C pentatonic
const BASE_FREQ = 130.81  # C3

func _ready():
    # ... existing code ...
    _setup_music_player()
    
func _setup_music_player():
    music_player = AudioStreamPlayer.new()
    music_player.bus = "Music"
    add_child(music_player)

func _process(delta):
    if GameManager.current_state == GameManager.GameState.PLAYING:
        _update_music(delta)

func _update_music(delta):
    beat_timer += delta
    var beat_duration = 60.0 / current_tempo
    
    if beat_timer >= beat_duration:
        beat_timer -= beat_duration
        _play_beat()

func _play_beat():
    # Generate bass note on beat 1, 3
    # Generate melody note with probability
    # Intensity increases with wave
    pass

func set_wave_intensity(wave: int):
    current_wave = wave
    current_tempo = 100 + wave * 5  # Faster tempo each wave
```

### Audio Bus Setup
Add to project settings:
- Master bus
- SFX bus (child of Master)
- Music bus (child of Master)

### Wave-based Intensity
- Wave 1-2: Calm ambient (slow tempo, sparse notes)
- Wave 3-5: Building (medium tempo, bass + melody)
- Wave 6+: Intense (fast tempo, full arrangement)

### Files to Modify
1. MODIFY: `scripts/autoload/sound_manager.gd` - add music generation
2. MODIFY: `project.godot` - add audio buses
3. MODIFY: `scripts/game/game_controller.gd` - call set_wave_intensity()

### Alternative: Pre-made loops
If procedural is too complex, use layered audio loops that fade in/out based on wave intensity.
