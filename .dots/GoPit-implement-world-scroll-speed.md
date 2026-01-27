---
title: Implement world scroll speed system
status: open
priority: 1
issue-type: implement
created-at: "2026-01-27"
---

## Overview

Add a world scroll speed system that affects enemy descent rate and integrates with difficulty tiers. Currently enemies have a fixed base speed of 60 px/sec regardless of world scroll concept.

## Context

BallxPit's core mechanic is continuous world scrolling. Enemies descend WITH the scroll, not independently. Higher difficulty = faster scroll = shorter runs.

See: `docs/research/level-scrolling-comparison.md`

## Requirements

### 1. World Scroll Speed in GameManager

```gdscript
const BASE_WORLD_SCROLL_SPEED: float = 50.0  # px/sec

var world_scroll_speed: float = BASE_WORLD_SCROLL_SPEED

func get_world_scroll_speed() -> float:
    return world_scroll_speed * get_difficulty_scroll_multiplier()

func get_difficulty_scroll_multiplier() -> float:
    # Higher difficulties = faster world scroll
    # Normal: 1.0x, Fast: 1.2x, Fast+: 1.5x, etc.
    if selected_difficulty_level <= 1:
        return 1.0
    return 1.0 + (0.2 * (selected_difficulty_level - 1))
```

### 2. Enemy Descent Integration

Modify `enemy_base.gd` to combine base movement with world scroll:

```gdscript
func _physics_process(delta: float) -> void:
    match _state:
        State.DESCENDING:
            # Combine individual speed with world scroll
            var total_descent := speed + GameManager.get_world_scroll_speed()
            velocity = Vector2.DOWN * total_descent
```

**Current:** Enemies move at 60 px/sec independently
**New:** Enemies move at (60 + 50) = 110 px/sec total, scaling with difficulty

### 3. Gem Drift Integration

Modify `gem.gd` to incorporate world scroll:

```gdscript
GemMovementMode.DRIFT_UP:
    # Gems drift against world scroll (appear to float in place or slowly rise)
    var effective_drift := base_speed - GameManager.get_world_scroll_speed() * 0.5
    position.y -= effective_drift * delta
```

This creates pressure: gems drift up slower than world scrolls, so they effectively fall relative to player.

### 4. Run Duration Scaling

With scroll speed affecting all entities:

| Difficulty | Scroll Mult | Effective Enemy Descent | ~Run Duration |
|------------|-------------|-------------------------|---------------|
| Normal | 1.0x | 110 px/sec | 15-20 min |
| Fast | 1.2x | 120 px/sec | 12-15 min |
| Fast+ | 1.4x | 130 px/sec | 10-12 min |
| Fast+2 | 1.6x | 140 px/sec | 8-10 min |
| Fast+3 | 1.8x | 150 px/sec | 6-8 min |

## Implementation Steps

1. Add scroll speed constants/methods to `GameManager`
2. Modify `enemy_base.gd` to add world scroll to descent
3. Modify `gem.gd` to interact with world scroll
4. Update formation spawn timing to account for faster descent
5. Add tests to verify speed scaling

## Files to Modify

- `scripts/autoload/game_manager.gd` - add scroll speed system
- `scripts/entities/enemies/enemy_base.gd` - integrate scroll
- `scripts/entities/gem.gd` - integrate scroll
- `scripts/entities/enemies/enemy_spawner.gd` - adjust timing

## Testing

```python
async def test_world_scroll_affects_enemy_descent(game):
    await game.call(GAME_MANAGER, "set_difficulty_level", [1])
    normal_speed = await game.call(GAME_MANAGER, "get_world_scroll_speed")

    await game.call(GAME_MANAGER, "set_difficulty_level", [5])
    fast_speed = await game.call(GAME_MANAGER, "get_world_scroll_speed")

    assert fast_speed > normal_speed
```

## Acceptance Criteria

- [ ] World scroll speed configurable via GameManager
- [ ] Scroll speed scales with difficulty tier
- [ ] Enemy descent incorporates scroll speed
- [ ] Gem movement accounts for scroll
- [ ] Higher difficulties feel noticeably faster
