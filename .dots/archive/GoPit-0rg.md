---
title: Add wave transition announcement
status: done
priority: 2
issue-type: feature
assignee: randroid
created-at: 2026-01-05T01:48:08.54811-06:00
---

## Problem
Wave counter silently increments. Players don't notice progression or feel accomplishment.

## Implementation Plan

### Wave Announcement UI
**File: `scripts/ui/wave_announcement.gd`** (new)

```gdscript
extends CanvasLayer

@onready var wave_label: Label = $WaveLabel

func _ready():
    visible = false
    GameManager.wave_changed.connect(_on_wave_changed)

func _on_wave_changed(new_wave: int):
    _show_announcement(new_wave)

func _show_announcement(wave: int):
    wave_label.text = "WAVE %d" % wave
    visible = true
    wave_label.modulate.a = 0
    wave_label.scale = Vector2(0.5, 0.5)
    
    var tween = create_tween()
    # Fade in and scale up
    tween.tween_property(wave_label, "modulate:a", 1.0, 0.2)
    tween.parallel().tween_property(wave_label, "scale", Vector2(1.2, 1.2), 0.2)
    # Hold
    tween.tween_interval(0.8)
    # Fade out and scale down
    tween.tween_property(wave_label, "modulate:a", 0.0, 0.3)
    tween.parallel().tween_property(wave_label, "scale", Vector2(0.8, 0.8), 0.3)
    tween.tween_callback(func(): visible = false)
```

### Scene Structure
**File: `scenes/ui/wave_announcement.tscn`**

```
WaveAnnouncement (CanvasLayer)
└── CenterContainer (anchors: full rect)
    └── WaveLabel (Label)
        - font_size: 72
        - font: bold
        - outline_size: 4
        - outline_color: black
        - horizontal_alignment: CENTER
```

### Add Wave Sound
**Modify: `scripts/autoload/sound_manager.gd`**

Add new sound type:
```gdscript
enum SoundType { ..., WAVE_COMPLETE }

func _generate_wave_complete() -> AudioStreamWAV:
    # Rising arpeggio: C-E-G-C (major chord)
    # Duration: 0.4s
    # Celebratory feel
```

### Wire Up Signal
**Modify: `scripts/autoload/game_manager.gd`**

```gdscript
signal wave_changed(new_wave: int)

func advance_wave() -> void:
    current_wave += 1
    wave_changed.emit(current_wave)
```

**Modify: `scripts/game/game_controller.gd`**

```gdscript
func _advance_wave() -> void:
    enemies_killed_this_wave = 0
    GameManager.advance_wave()
    SoundManager.play(SoundManager.SoundType.WAVE_COMPLETE)
```

### Optional: Brief Slowmo
**Modify: `scripts/game/game_controller.gd`**

```gdscript
func _advance_wave() -> void:
    # Brief slowmo effect
    Engine.time_scale = 0.3
    await get_tree().create_timer(0.3 * 0.3).timeout  # Account for time scale
    Engine.time_scale = 1.0
    
    # Continue with wave advance...
```

### Files to Create/Modify
1. NEW: `scenes/ui/wave_announcement.tscn`
2. NEW: `scripts/ui/wave_announcement.gd`
3. MODIFY: `scenes/game.tscn` - instance wave_announcement
4. MODIFY: `scripts/autoload/game_manager.gd` - add wave_changed signal
5. MODIFY: `scripts/autoload/sound_manager.gd` - add WAVE_COMPLETE sound
6. MODIFY: `scripts/game/game_controller.gd` - play sound, optional slowmo
