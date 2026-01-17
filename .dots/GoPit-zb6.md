---
title: Add high score persistence
status: done
priority: 3
issue-type: feature
assignee: randroid
created-at: 2026-01-05T02:15:33.254257-06:00
---

## Problem
No persistence between sessions. Players can't track their best runs.

## Implementation Plan

### High Score Data Structure
**Modify: `scripts/autoload/game_manager.gd`** (or create new autoload)

```gdscript
var high_scores := {
    "highest_wave": 0,
    "highest_level": 0,
    "most_enemies_killed": 0,
    "longest_survival": 0.0,
    "highest_combo": 0,
    "total_runs": 0
}

func _ready():
    _load_high_scores()

func _load_high_scores():
    if FileAccess.file_exists("user://highscores.save"):
        var file = FileAccess.open("user://highscores.save", FileAccess.READ)
        var data = JSON.parse_string(file.get_as_text())
        if data:
            for key in high_scores:
                if key in data:
                    high_scores[key] = data[key]

func _save_high_scores():
    var file = FileAccess.open("user://highscores.save", FileAccess.WRITE)
    file.store_string(JSON.stringify(high_scores))

func check_high_scores():
    var new_records: Array[String] = []
    
    if current_wave > high_scores.highest_wave:
        high_scores.highest_wave = current_wave
        new_records.append("Wave")
    
    if player_level > high_scores.highest_level:
        high_scores.highest_level = player_level
        new_records.append("Level")
    
    if stats.enemies_killed > high_scores.most_enemies_killed:
        high_scores.most_enemies_killed = stats.enemies_killed
        new_records.append("Enemies")
    
    if stats.time_survived > high_scores.longest_survival:
        high_scores.longest_survival = stats.time_survived
        new_records.append("Time")
    
    if stats.highest_combo > high_scores.highest_combo:
        high_scores.highest_combo = stats.highest_combo
        new_records.append("Combo")
    
    high_scores.total_runs += 1
    _save_high_scores()
    
    return new_records

func end_game():
    var new_records = check_high_scores()
    # ... existing code ...
    # new_records can be passed to game over screen
```

### Game Over Screen Updates
**Modify: `scripts/ui/game_over_overlay.gd`**

```gdscript
@onready var new_record_label: Label = $Panel/VBoxContainer/NewRecordLabel
@onready var high_score_container: VBoxContainer = $Panel/VBoxContainer/HighScores

func _on_game_over():
    visible = true
    
    # Display current run stats...
    
    # Check for new records
    var new_records = GameManager.check_high_scores()
    if new_records.size() > 0:
        new_record_label.visible = true
        new_record_label.text = "NEW RECORD: " + ", ".join(new_records)
        _animate_new_record()
    else:
        new_record_label.visible = false
    
    # Show all-time high scores
    _display_high_scores()

func _display_high_scores():
    var hs = GameManager.high_scores
    $HighWave.text = "Best Wave: %d" % hs.highest_wave
    $HighLevel.text = "Best Level: %d" % hs.highest_level
    $HighEnemies.text = "Most Kills: %d" % hs.most_enemies_killed
    $TotalRuns.text = "Total Runs: %d" % hs.total_runs

func _animate_new_record():
    var tween = create_tween().set_loops(3)
    tween.tween_property(new_record_label, "modulate", Color.YELLOW, 0.3)
    tween.tween_property(new_record_label, "modulate", Color.WHITE, 0.3)
```

### Files to Modify
1. MODIFY: `scripts/autoload/game_manager.gd` - high score tracking
2. MODIFY: `scenes/ui/game_over_overlay.tscn` - add high score display
3. MODIFY: `scripts/ui/game_over_overlay.gd` - display high scores
