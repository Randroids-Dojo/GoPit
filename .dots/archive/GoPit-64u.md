---
title: Add audio settings with volume controls
status: closed
priority: 2
issue-type: feature
assignee: randroid
created-at: "\"2026-01-05T02:02:57.527844-06:00\""
closed-at: "2026-01-19T09:50:47.820473-06:00"
close-reason: Added settings overlay with master/SFX/music volume sliders accessible from pause menu
---

## Problem
Players cannot access a full settings UI to adjust volume sliders. The quick mute button is available but fine-grained control is missing.

## Current State (already implemented)

- **Phase 1: Settings Data** - DONE in `scripts/autoload/sound_manager.gd`
  - `master_volume`, `sfx_volume`, `music_volume` properties
  - `is_muted` property with toggle
  - Persistence via `user://audio_settings.save`
  - Audio bus integration (Master, SFX, Music buses)

- **Phase 3: Quick Mute Button** - DONE in `scenes/game.tscn`
  - Mute button exists at `/root/Game/UI/HUD/TopBar/MuteButton`
  - Toggles mute state on click
  - Tests pass in `tests/test_audio_settings.py`

## Implementation Progress (2026-01-19)

**COMPLETE - UNCOMMITTED FILES:**
- `scripts/ui/settings_overlay.gd` - Created (untracked)
- `scenes/ui/settings_overlay.tscn` - Created (untracked)
- `scenes/game.tscn` - Modified (added SettingsOverlay instance + button)
- `scripts/ui/pause_overlay.gd` - Already has settings integration (committed)

**READY TO COMMIT** - Just needs to add and commit the untracked files + game.tscn changes

---

## Remaining Work: Settings UI (Phase 2)

Create a settings overlay accessible from pause menu that exposes volume sliders.

### Files to Create
1. **CREATED: `scenes/ui/settings_overlay.tscn`** (uncommitted)
   ```
   SettingsOverlay (CanvasLayer)
   └── Panel (centered, ~400x500)
       └── VBoxContainer
           ├── TitleLabel ("Settings")
           ├── HBoxContainer (Master: Label + HSlider)
           ├── HBoxContainer (SFX: Label + HSlider)
           ├── HBoxContainer (Music: Label + HSlider)
           ├── HBoxContainer (Aim Sensitivity: Label + HSlider)
           ├── CheckButton (Mute toggle)
           └── CloseButton
   ```

2. **NEW: `scripts/ui/settings_overlay.gd`**
   - Connect sliders to SoundManager.set_master_volume(), set_sfx_volume(), set_music_volume()
   - Connect mute checkbox to SoundManager.toggle_mute()
   - Connect aim sensitivity slider to SoundManager.set_aim_sensitivity()
   - Initialize slider values from SoundManager on open

### Files to Modify
1. **MODIFY: `scenes/ui/pause_overlay.tscn`** - Add "Settings" button
2. **MODIFY: `scripts/ui/pause_overlay.gd`** - Handle settings button press, show overlay

### Integration Notes
- Settings overlay should appear above pause overlay (higher z_index or CanvasLayer)
- Pause menu needs "Settings" button between Resume and Quit
- Close button returns to pause menu
- Consider: should settings also be accessible from main menu?

## Verify

- [ ] `./test.sh` passes
- [ ] Master volume slider adjusts overall game volume
- [ ] SFX volume slider adjusts sound effects independently
- [ ] Music volume slider adjusts background music independently
- [ ] Mute toggle silences all audio
- [ ] Settings persist after app restart (test via: change volume, close game, reopen)
- [ ] Quick mute button on HUD toggles mute state
- [ ] Mute icon shows current state (muted vs unmuted)
