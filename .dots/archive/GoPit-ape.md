---
title: Add randomness to enemy spawn intervals
status: done
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:12:31.429763-06:00
---

## Problem
Enemies spawn at fixed intervals. Creates mechanical, predictable rhythm.

## Implementation Plan

### Add Variance to Spawn Timer
**Modify: `scripts/entities/enemies/enemy_spawner.gd`**

```gdscript
@export var spawn_variance: float = 0.5  # ±0.5 seconds

func _start_spawn_timer() -> void:
    var variance = randf_range(-spawn_variance, spawn_variance)
    var next_spawn = max(0.3, spawn_interval + variance)  # Min 0.3s
    spawn_timer.wait_time = next_spawn
    spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
    _spawn_enemy()
    _start_spawn_timer()  # Restart with new random interval
```

### Optional: Burst Spawning
Occasionally spawn multiple enemies at once:

```gdscript
@export var burst_chance: float = 0.1  # 10% chance
@export var burst_count_range: Vector2i = Vector2i(2, 3)

func _spawn_enemy() -> void:
    var count = 1
    if randf() < burst_chance:
        count = randi_range(burst_count_range.x, burst_count_range.y)
        # Brief delay between burst spawns
        for i in range(count):
            _do_spawn()
            if i < count - 1:
                await get_tree().create_timer(0.2).timeout
    else:
        _do_spawn()

func _do_spawn() -> void:
    var enemy = slime_scene.instantiate()
    # ... existing spawn logic
```

### Wave Scaling
Increase variance and burst chance with waves:

```gdscript
func set_spawn_interval(interval: float) -> void:
    spawn_interval = interval
    # Increase burst chance as game speeds up
    burst_chance = min(0.3, 0.1 + (2.0 - interval) * 0.1)
```

### Files to Modify
1. MODIFY: `scripts/entities/enemies/enemy_spawner.gd` - add variance and bursts
