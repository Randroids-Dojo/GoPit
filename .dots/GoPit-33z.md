---
title: Add detailed stats to game over screen
status: done
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:12:31.978956-06:00
---

## Problem
Game over shows only level and wave. Missing interesting stats.

## Implementation Plan

### Phase 1: Track Stats in GameManager
**Modify: `scripts/autoload/game_manager.gd`**

```gdscript
# Session stats (reset each run)
var stats := {
    "enemies_killed": 0,
    "balls_fired": 0,
    "damage_dealt": 0,
    "gems_collected": 0,
    "time_survived": 0.0,
    "highest_combo": 0,
    "current_combo": 0,
    "combo_timer": 0.0
}

func _process(delta):
    if current_state == GameState.PLAYING:
        stats.time_survived += delta
        
        # Combo timeout
        if stats.combo_timer > 0:
            stats.combo_timer -= delta
            if stats.combo_timer <= 0:
                stats.current_combo = 0

func record_enemy_kill():
    stats.enemies_killed += 1
    stats.current_combo += 1
    stats.combo_timer = 2.0  # 2 second combo window
    stats.highest_combo = max(stats.highest_combo, stats.current_combo)

func record_ball_fired():
    stats.balls_fired += 1

func record_damage_dealt(amount: int):
    stats.damage_dealt += amount

func record_gem_collected():
    stats.gems_collected += 1

func _reset_stats():
    # Reset session stats
    for key in stats:
        if typeof(stats[key]) == TYPE_INT:
            stats[key] = 0
        else:
            stats[key] = 0.0
```

### Phase 2: Update Game Over UI
**Modify: `scenes/ui/game_over_overlay.tscn`**

```
GameOverOverlay
└── Panel
    └── VBoxContainer
        ├── GameOverLabel
        ├── StatsContainer (GridContainer, 2 columns)
        │   ├── Label ("Level:")
        │   ├── LevelValue
        │   ├── Label ("Wave:")
        │   ├── WaveValue
        │   ├── Label ("Enemies Killed:")
        │   ├── EnemiesValue
        │   ├── Label ("Damage Dealt:")
        │   ├── DamageValue
        │   ├── Label ("Time Survived:")
        │   ├── TimeValue
        │   ├── Label ("Best Combo:")
        │   ├── ComboValue
        └── RestartButton
```

**Modify: `scripts/ui/game_over_overlay.gd`**

```gdscript
func _on_game_over():
    visible = true
    
    level_label.text = str(GameManager.player_level)
    wave_label.text = str(GameManager.current_wave)
    enemies_label.text = str(GameManager.stats.enemies_killed)
    damage_label.text = str(GameManager.stats.damage_dealt)
    combo_label.text = str(GameManager.stats.highest_combo)
    
    var time = GameManager.stats.time_survived
    var minutes = int(time) / 60
    var seconds = int(time) % 60
    time_label.text = "%d:%02d" % [minutes, seconds]
```

### Phase 3: Wire Up Stat Recording
**Modify: `scripts/game/game_controller.gd`**

```gdscript
func _on_fire_pressed():
    ball_spawner.fire()
    GameManager.record_ball_fired()

func _on_enemy_died(enemy):
    GameManager.record_enemy_kill()
    # existing code...
```

**Modify: `scripts/entities/enemies/enemy_base.gd`**

```gdscript
func take_damage(amount: int):
    GameManager.record_damage_dealt(amount)
    # existing code...
```

### Files to Modify
1. MODIFY: `scripts/autoload/game_manager.gd` - add stats tracking
2. MODIFY: `scenes/ui/game_over_overlay.tscn` - expand UI
3. MODIFY: `scripts/ui/game_over_overlay.gd` - display all stats
4. MODIFY: `scripts/game/game_controller.gd` - record events
5. MODIFY: `scripts/entities/enemies/enemy_base.gd` - record damage
