---
title: "implement: Add boss fight music mode to MusicManager"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-19T11:05:52.842396-06:00\\\"\""
closed-at: "2026-01-19T11:14:11.234691-06:00"
close-reason: Added boss fight music mode with faster tempo, heavier drums, and suppressed melody. Tests pass.
blocks:
  - GoPit-implement-add-per-2623a39b
---

## Description

When a boss wave is reached, switch to an intense boss music mode. When boss is defeated, return to normal biome music.

## Context

Depends on biome music parameters being implemented (GoPit-implement-add-per-2623a39b).

`StageManager.boss_wave_reached` and `StageManager.stage_completed` signals are already available.

## Implementation

### 1. Add boss fight state and mode

```gdscript
var is_boss_fight: bool = false
var _pre_boss_tempo: float = 120.0

func set_boss_mode(enabled: bool) -> void:
    is_boss_fight = enabled
    if enabled:
        _pre_boss_tempo = _beat_timer.wait_time
        _beat_timer.wait_time *= 0.8  # 20% faster tempo
        _drum_player.volume_db += 3.0  # Louder drums
        _melody_player.volume_db -= 6.0  # Suppress melody
    else:
        _beat_timer.wait_time = _pre_boss_tempo
        _drum_player.volume_db -= 3.0
        _melody_player.volume_db += 6.0
```

### 2. Add signal connections

In _ready():
```gdscript
StageManager.boss_wave_reached.connect(_on_boss_wave_reached)
StageManager.stage_completed.connect(_on_stage_completed)

func _on_boss_wave_reached(_stage: int) -> void:
    set_boss_mode(true)

func _on_stage_completed(_stage: int) -> void:
    set_boss_mode(false)
```

### 3. Modify drum pattern for boss mode

In _on_beat(), optionally use heavier drum pattern:
```gdscript
var _boss_drum_pattern: Array[int] = [1, 1, 2, 1, 1, 1, 2, 1]  # Double kicks
```

## Affected Files

- MODIFY: scripts/autoload/music_manager.gd

## After

- GoPit-implement-add-per-2623a39b

## Verify

- [ ] ./test.sh passes
- [ ] Reach boss wave (every 10 waves) - music intensifies (faster tempo, louder drums)
- [ ] Defeat boss - music returns to biome style
- [ ] Boss music feels more urgent and dramatic
- [ ] Transition is smooth (no audio pops)
