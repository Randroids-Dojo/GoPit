---
title: Add enemy approach warning
status: done
priority: 2
issue-type: feature
assignee: randroid
created-at: 2026-01-05T01:48:08.8142-06:00
---

## Problem
Players are caught off-guard when enemies deal damage. No warning when enemies approach.

## Implementation Plan

### Approach: Warning zone detection + visual/audio cues

### Phase 1: Warning Zone Detection
**Modify: `scripts/entities/enemies/enemy_base.gd`**

```gdscript
signal approaching_danger_zone
signal left_danger_zone

const DANGER_ZONE_Y: float = 1000.0  # 200px above player zone at 1200

var in_danger_zone: bool = false

func _physics_process(delta):
    # Existing movement...
    
    # Check danger zone
    var now_in_danger = global_position.y >= DANGER_ZONE_Y
    if now_in_danger and not in_danger_zone:
        in_danger_zone = true
        approaching_danger_zone.emit()
    elif not now_in_danger and in_danger_zone:
        in_danger_zone = false
        left_danger_zone.emit()
```

### Phase 2: Screen Edge Warning
**File: `scripts/effects/danger_indicator.gd`** (new)

```gdscript
extends Control
## Shows pulsing red indicator at bottom of screen when enemies are near

var danger_count: int = 0
var pulse_tween: Tween

@onready var indicator: ColorRect = $Indicator

func _ready():
    indicator.color = Color(1, 0, 0, 0)
    
func add_danger():
    danger_count += 1
    if danger_count == 1:
        _start_pulsing()

func remove_danger():
    danger_count = max(0, danger_count - 1)
    if danger_count == 0:
        _stop_pulsing()

func _start_pulsing():
    if pulse_tween:
        pulse_tween.kill()
    pulse_tween = create_tween().set_loops()
    pulse_tween.tween_property(indicator, "color:a", 0.5, 0.3)
    pulse_tween.tween_property(indicator, "color:a", 0.2, 0.3)

func _stop_pulsing():
    if pulse_tween:
        pulse_tween.kill()
    var fade = create_tween()
    fade.tween_property(indicator, "color:a", 0.0, 0.2)
```

### Scene Structure
**File: `scenes/ui/danger_indicator.tscn`**

```
DangerIndicator (Control) [anchors: bottom, full width]
└── Indicator (ColorRect)
    - size: full width x 20px
    - color: red with 0 alpha
    - position: bottom of screen
```

### Phase 3: Enemy Visual Change
**Modify: `scripts/entities/enemies/enemy_base.gd`**

```gdscript
func _on_enter_danger_zone():
    # Tint enemy red
    modulate = Color(1.5, 0.5, 0.5)
    
    # Optional: speed up slightly
    speed *= 1.1

func _on_exit_danger_zone():
    modulate = Color.WHITE
```

### Phase 4: Audio Warning
**Modify: `scripts/autoload/sound_manager.gd`**

Add low-frequency pulse sound for danger:
```gdscript
enum SoundType { ..., DANGER_PULSE }

var danger_pulse_timer: float = 0.0

func _process(delta):
    if danger_count > 0:
        danger_pulse_timer += delta
        if danger_pulse_timer >= 0.5:  # Pulse every 0.5s
            danger_pulse_timer = 0
            play(SoundType.DANGER_PULSE)
```

### Wire Up in Game Controller
**Modify: `scripts/game/game_controller.gd`**

```gdscript
@onready var danger_indicator: Control = $UI/DangerIndicator

func _on_enemy_spawned(enemy: EnemyBase) -> void:
    enemy.died.connect(_on_enemy_died)
    enemy.approaching_danger_zone.connect(func(): danger_indicator.add_danger())
    enemy.left_danger_zone.connect(func(): danger_indicator.remove_danger())
```

### Files to Create/Modify
1. NEW: `scenes/ui/danger_indicator.tscn`
2. NEW: `scripts/effects/danger_indicator.gd`
3. MODIFY: `scenes/game.tscn` - add danger indicator
4. MODIFY: `scripts/entities/enemies/enemy_base.gd` - danger zone signals, visual
5. MODIFY: `scripts/game/game_controller.gd` - wire danger signals
6. MODIFY: `scripts/autoload/sound_manager.gd` - add DANGER_PULSE sound
