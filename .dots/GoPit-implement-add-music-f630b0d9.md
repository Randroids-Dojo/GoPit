---
title: "implement: Add music crossfade between biomes"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T11:06:04.488591-06:00"
blocks:
  - GoPit-implement-add-per-2623a39b
---

## Description

Add smooth crossfade when transitioning between biomes to avoid jarring music changes.

## Context

Depends on biome music parameters (GoPit-implement-add-per-2623a39b).

## Implementation

### 1. Add crossfade state

```gdscript
var _crossfading: bool = false
var _crossfade_tween: Tween
```

### 2. Update set_biome() to crossfade

```gdscript
func set_biome(biome_name: String) -> void:
    if not biome_name in BIOME_MUSIC:
        return
    
    if _current_biome == biome_name:
        return
    
    _crossfade_to_biome(biome_name)


func _crossfade_to_biome(biome_name: String) -> void:
    if _crossfade_tween:
        _crossfade_tween.kill()
    
    _crossfading = true
    _crossfade_tween = create_tween()
    
    # Store target parameters
    var params: Dictionary = BIOME_MUSIC[biome_name]
    var target_root: float = params["root"]
    var target_tempo: float = 60.0 / params["tempo"] / 2.0
    var target_scale: Array[int] = SCALES[params["scale"]]
    
    # Fade out current (0.5s)
    _crossfade_tween.tween_property(_bass_player, "volume_db", -24.0, 0.5)
    _crossfade_tween.parallel().tween_property(_melody_player, "volume_db", -24.0, 0.5)
    
    # Switch parameters at midpoint
    _crossfade_tween.tween_callback(func():
        _current_biome = biome_name
        _root_note = target_root
        _current_scale = target_scale
        _beat_timer.wait_time = target_tempo
        current_intensity = params["intensity_base"]
    )
    
    # Fade in new (0.5s)
    _crossfade_tween.tween_property(_bass_player, "volume_db", -8.0, 0.5)
    _crossfade_tween.parallel().tween_property(_melody_player, "volume_db", -10.0, 0.5)
    
    _crossfade_tween.tween_callback(func(): _crossfading = false)
```

## Affected Files

- MODIFY: scripts/autoload/music_manager.gd

## After

- GoPit-implement-add-per-2623a39b

## Verify

- [ ] ./test.sh passes
- [ ] Complete a stage and transition to next biome
- [ ] Music fades out smoothly (no hard cut)
- [ ] Music fades back in with new biome parameters
- [ ] Total crossfade takes ~1 second
- [ ] No audio glitches during fade
