---
title: Add pause menu with mute option
status: done
priority: 1
issue-type: feature
assignee: randroid
created-at: 2026-01-05T01:48:08.029743-06:00
---

## Problem
Players cannot pause the game. On mobile, interruptions are constant (notifications, calls, switching apps).

## Implementation Plan

### Phase 1: Pause State in GameManager
**Modify: `scripts/autoload/game_manager.gd`**

```gdscript
# Already has PAUSED state, just need to wire it up

func toggle_pause():
    if current_state == GameState.PLAYING:
        pause_game()
    elif current_state == GameState.PAUSED:
        resume_game()
```

### Phase 2: Pause Overlay UI
**File: `scenes/ui/pause_overlay.tscn`** (new)

```
PauseOverlay (CanvasLayer) [process_mode=ALWAYS]
└── ColorRect (dim background, 0.5 alpha black)
    └── Panel (centered)
        └── VBoxContainer
            ├── Label ("PAUSED")
            ├── ResumeButton
            ├── SettingsButton
            └── QuitButton
```

**File: `scripts/ui/pause_overlay.gd`**

```gdscript
extends CanvasLayer

func _ready():
    visible = false
    process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
    # Handle back button on Android
    if event.is_action_pressed("ui_cancel"):
        _toggle_pause()

func _toggle_pause():
    visible = !visible
    if visible:
        GameManager.pause_game()
    else:
        GameManager.resume_game()

func _on_resume_pressed():
    _toggle_pause()

func _on_settings_pressed():
    # Show settings overlay
    pass

func _on_quit_pressed():
    get_tree().paused = false
    get_tree().reload_current_scene()
```

### Phase 3: Pause Button on HUD
**Modify: `scenes/game.tscn`**

Add pause button (hamburger/pause icon) in top-right corner of HUD.

**Modify: `scripts/ui/hud.gd`**

```gdscript
@onready var pause_button: Button = $TopBar/PauseButton
@onready var pause_overlay: CanvasLayer = $"../PauseOverlay"

func _ready():
    pause_button.pressed.connect(_on_pause_pressed)

func _on_pause_pressed():
    pause_overlay._toggle_pause()
```

### Phase 4: Auto-pause on App Background
**Modify: `scripts/game/game_controller.gd`**

```gdscript
func _notification(what):
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        if GameManager.current_state == GameManager.GameState.PLAYING:
            GameManager.pause_game()
            pause_overlay.visible = true
```

### Files to Create/Modify
1. NEW: `scenes/ui/pause_overlay.tscn`
2. NEW: `scripts/ui/pause_overlay.gd`
3. MODIFY: `scenes/game.tscn` - add pause button, pause overlay
4. MODIFY: `scripts/ui/hud.gd` - wire pause button
5. MODIFY: `scripts/game/game_controller.gd` - auto-pause on focus out

### Testing
- Verify pause freezes all gameplay
- Verify resume continues correctly
- Verify auto-pause on app background
- Verify back button works on Android
