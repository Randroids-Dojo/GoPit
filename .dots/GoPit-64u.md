---
title: Add audio settings with volume controls
status: open
priority: 2
issue-type: feature
assignee: randroid
created-at: 2026-01-05T02:02:57.527844-06:00
---

## Problem
Players cannot mute or adjust volume. Critical for mobile (public places, night time).

## Implementation Plan

### Phase 1: Settings Data
**Modify: `scripts/autoload/sound_manager.gd`**

```gdscript
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0
var is_muted: bool = false

func set_master_volume(value: float):
    master_volume = clamp(value, 0.0, 1.0)
    AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
    _save_settings()

func set_sfx_volume(value: float):
    sfx_volume = clamp(value, 0.0, 1.0)
    var bus_idx = AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))
    _save_settings()

func toggle_mute():
    is_muted = !is_muted
    AudioServer.set_bus_mute(0, is_muted)
    _save_settings()

func _save_settings():
    var data = {
        "master": master_volume,
        "sfx": sfx_volume,
        "music": music_volume,
        "muted": is_muted
    }
    var file = FileAccess.open("user://audio_settings.save", FileAccess.WRITE)
    file.store_string(JSON.stringify(data))

func _load_settings():
    if FileAccess.file_exists("user://audio_settings.save"):
        # Load and apply settings
        pass
```

### Phase 2: Settings UI
**File: `scenes/ui/settings_overlay.tscn`** (new)

```
SettingsOverlay (CanvasLayer)
└── Panel
    └── VBoxContainer
        ├── TitleLabel ("Settings")
        ├── MasterVolumeSlider + Label
        ├── SFXVolumeSlider + Label
        ├── MusicVolumeSlider + Label
        ├── MuteToggle (CheckButton)
        └── CloseButton
```

### Phase 3: Quick Mute Button on HUD
**Modify: `scenes/game.tscn`**

Add small speaker icon in top-right corner that toggles mute on tap.

### Files to Create/Modify
1. MODIFY: `scripts/autoload/sound_manager.gd` - volume controls
2. NEW: `scenes/ui/settings_overlay.tscn`
3. NEW: `scripts/ui/settings_overlay.gd`
4. MODIFY: `scenes/game.tscn` - add mute button to HUD
5. MODIFY: `scripts/ui/hud.gd` - handle mute button

### Audio Bus Setup (prerequisite)
Requires audio buses: Master, SFX, Music
