---
title: Consolidate hardcoded scene paths to use groups
status: open
priority: 4
issue-type: refactor
assignee: randroid
created-at: 2026-01-08T19:57:14.902458-06:00
---

## Description

Remaining hardcoded scene paths should use group-based lookups for consistency and refactoring safety.

## Context

Most of the codebase has been converted to use groups (e.g., `get_tree().get_first_node_in_group('enemies_container')`). Only 3 instances remain in game_controller.gd, all in test helper functions.

**Note:** The original issue mentioned ball.gd and status_effect.gd but those have already been fixed.

## Affected Files

- `scripts/game/game_controller.gd:715` - `spawn_test_boss()` fallback
- `scripts/game/game_controller.gd:737` - `spawn_test_enemy()` fallback
- `scripts/game/game_controller.gd:752` - `get_enemy_spawner_path()` returns hardcoded path

## Implementation Notes

1. Lines 715 and 737 are fallbacks when `@onready` hasn't run - consider using groups instead
2. Line 752 returns a path string for PlayGodot tests - may need to stay as-is for test compatibility
3. Low priority since these are test helpers, not production gameplay code

## Verify

- [ ] `./test.sh` passes (tests use these helper methods)
- [ ] No hardcoded `GameArea/` paths remain in ball.gd or status_effect.gd
- [ ] Refactored methods still work for spawning test enemies/bosses
