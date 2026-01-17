---
title: Add low HP screen warning effect
status: done
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:13:40.766327-06:00
---

## Problem
HP bar is small and might be missed during action. No warning when HP is critically low.

## Implementation Plan

### Create Danger Vignette Effect
**File: `scripts/effects/low_hp_warning.gd`** (new)

```gdscript
extends ColorRect
## Persistent red vignette when HP is low

const LOW_HP_THRESHOLD: float = 0.25  # 25% HP

var pulse_tween: Tween
var is_warning: bool = false

func _ready():
    color = Color(0.8, 0, 0, 0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    GameManager.state_changed.connect(_on_state_changed)

func _process(_delta):
    if GameManager.current_state != GameManager.GameState.PLAYING:
        return
    
    var hp_ratio = float(GameManager.player_hp) / float(GameManager.max_hp)
    
    if hp_ratio <= LOW_HP_THRESHOLD and not is_warning:
        _start_warning()
    elif hp_ratio > LOW_HP_THRESHOLD and is_warning:
        _stop_warning()

func _start_warning():
    is_warning = true
    
    if pulse_tween:
        pulse_tween.kill()
    
    pulse_tween = create_tween().set_loops()
    pulse_tween.tween_property(self, "color:a", 0.3, 0.5)
    pulse_tween.tween_property(self, "color:a", 0.1, 0.5)
    
    # Optional: Add heartbeat sound
    # SoundManager.start_heartbeat()

func _stop_warning():
    is_warning = false
    
    if pulse_tween:
        pulse_tween.kill()
    
    var fade = create_tween()
    fade.tween_property(self, "color:a", 0.0, 0.3)
    
    # SoundManager.stop_heartbeat()

func _on_state_changed(_old, new):
    if new != GameManager.GameState.PLAYING:
        _stop_warning()
```

### Vignette Shader (Optional but nicer)
**File: `shaders/vignette.gdshader`**

```gdshader
shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.8, 0.0, 0.0, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float radius : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec2 uv = UV - 0.5;
    float dist = length(uv);
    float vignette = smoothstep(radius, radius + 0.3, dist);
    COLOR = vec4(color.rgb, vignette * intensity * color.a);
}
```

### Add to Game Scene
**Modify: `scenes/game.tscn`**

Add as child of UI CanvasLayer, covering full screen.

### Optional: Heartbeat Sound
**Modify: `scripts/autoload/sound_manager.gd`**

```gdscript
var heartbeat_player: AudioStreamPlayer
var heartbeat_timer: float = 0.0

func start_heartbeat():
    heartbeat_active = true

func stop_heartbeat():
    heartbeat_active = false

func _process(delta):
    if heartbeat_active:
        heartbeat_timer += delta
        if heartbeat_timer >= 0.8:  # Heartbeat rhythm
            heartbeat_timer = 0
            play(SoundType.HEARTBEAT)
```

### Files to Create/Modify
1. NEW: `scripts/effects/low_hp_warning.gd`
2. NEW: `shaders/vignette.gdshader` (optional)
3. MODIFY: `scenes/game.tscn` - add warning overlay
4. MODIFY: `scripts/autoload/sound_manager.gd` - heartbeat (optional)
