---
title: Win Condition & Stage Progression
status: active
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:37:53.624766-06:00
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
- [ ] Beating final boss triggers victory
- [ ] Victory screen shows run stats
- [ ] Can continue to endless mode after win
- [ ] Completion tracked in save data
- [ ] Stage transitions work correctly
