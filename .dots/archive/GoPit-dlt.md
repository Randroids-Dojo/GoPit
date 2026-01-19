---
title: Win Condition & Stage Progression
status: closed
priority: 2
issue-type: task
assignee: randroid
created-at: "2026-01-05T23:37:53.624766-06:00"
closed-at: "2026-01-19T00:51:27.660061-06:00"
---

# Win Condition & Stage Progression

## Parent Epic
GoPit-6p4 (Phase 3 - Boss & Stages)

## Overview
Implement level-based win condition where defeating the final boss completes the game.

## Requirements
1. Game ends in victory when final boss defeated
2. Stage transitions between biomes
3. Victory screen with stats
4. Option to continue in endless mode after win
5. Track completion statistics

## Stage Flow
```
Start → The Pit (W1-30) → Boss → Frozen Depths (W31-60) → Boss → ...
                                                              ↓
                                      Final Descent (W91-100) → Final Boss → VICTORY
```

## Victory Handling
```gdscript
# game_manager.gd additions
signal game_victory

func trigger_victory() -> void:
    current_state = GameState.VICTORY
    _save_completion_stats()
    game_victory.emit()

# victory_screen.gd
func _show_stats() -> void:
    # Time survived
    # Enemies killed
    # Balls fired
    # Final level
    # Balls evolved
    # Option: Continue in Endless Mode
```

## Implementation
- Modify wave progression to check for stage completion
- Add victory state to GameManager
- Create victory screen UI
- Save completion to persistent storage

## Acceptance Criteria
- [x] Beating final boss triggers victory
- [x] Victory screen shows run stats
- [x] Can continue to endless mode after win
- [x] Completion tracked in save data
- [x] Stage transitions work correctly

## Implementation Status (Verified 2026-01-19)

All requirements are **IMPLEMENTED**:

### GameManager (game_manager.gd)
- `GameState.VICTORY` enum (line 10)
- `game_victory` signal (line 16)
- `trigger_victory()` function (line 409-415) - sets state, increments `total_victories`, emits signal
- `enable_endless_mode()` function (line 418-421) - allows continuing after win
- Victory count saved/loaded (lines 923, 945)

### StageManager (stage_manager.gd)
- 8 biomes loaded (lines 31-40)
- `game_won` signal (line 8)
- `complete_stage()` advances progression and emits `game_won` when all stages complete (lines 64-73)
- Biome transitions via `biome_changed` signal

### Victory Screen (stage_complete_overlay.gd)
- `show_victory()` method (lines 49-64) - displays "VICTORY!" with stats
- Stats shown: time, enemies killed, level (lines 67-81)
- "Play Again" and "Continue to Endless" buttons

### Save Data
- `total_victories` tracked and persisted (game_manager.gd:126, 411, 923, 945)

**This task is READY TO CLOSE.**
