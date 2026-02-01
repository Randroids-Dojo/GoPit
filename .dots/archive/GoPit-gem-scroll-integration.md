---
title: Integrate gems with world scroll system
status: closed
priority: 3
issue-type: implement
created-at: "\"2026-01-27\""
closed-at: "2026-02-01T04:35:37.161286+00:00"
---

## Overview

Make gems interact with the world scroll system so they feel like part of the scrolling world rather than independent drifting objects.

## Context

BallxPit gems are world-relative - they scroll with the environment and create pressure to collect before they leave the screen. GoPit gems drift up independently, which doesn't feel integrated with any scroll concept.

See: `docs/research/level-scrolling-comparison.md`

## Current Behavior

In `gem.gd`:
```gdscript
GemMovementMode.DRIFT_UP:
    position.y -= base_speed * delta  # Fixed 150 px/sec upward
```

## Proposed Behavior

Gems should move relative to world scroll:

```gdscript
func _physics_process(delta: float) -> void:
    var world_scroll := GameManager.get_world_scroll_speed()

    match _movement_mode:
        GemMovementMode.DRIFT_UP:
            # Gem drifts up, but world scrolls down (visually)
            # Net effect: gem moves up relative to player slower than pure drift
            var net_movement := base_speed - (world_scroll * 0.3)
            position.y -= net_movement * delta

        GemMovementMode.STATIONARY:
            # Gem "stays in place" in world coords = moves down with scroll
            position.y += world_scroll * delta

        GemMovementMode.FALL_DOWN:
            # Gem falls toward player (current classic behavior)
            position.y += base_speed * delta
```

### World-Relative Mode (New)

Add a new mode for authentic BallxPit behavior:

```gdscript
GemMovementMode.WORLD_RELATIVE:
    # Gem is stationary in world coords
    # As world scrolls up (player descends), gem appears to rise
    position.y += GameManager.get_world_scroll_speed() * delta
```

This creates the pressure: gems drift off the top of screen if not collected.

## Difficulty Integration

Higher difficulties = faster scroll = faster gem loss:

| Difficulty | Scroll Speed | Gem Drift (relative) |
|------------|--------------|---------------------|
| Normal | 50 px/sec | 100 px/sec net up |
| Fast | 60 px/sec | 90 px/sec net up |
| Fast+3 | 90 px/sec | 60 px/sec net up |
| Fast+9 | 130 px/sec | 20 px/sec net up |

At highest difficulties, gems barely rise relative to player - must chase them!

## Implementation Steps

1. Add `WORLD_RELATIVE` movement mode to gem.gd
2. Integrate world scroll speed into gem movement
3. Update default mode based on game design preference
4. Test gem collection pressure at various difficulties

## Files to Modify

- `scripts/entities/gem.gd` - movement integration
- `scripts/autoload/game_manager.gd` - ensure scroll speed accessible

## Balance Considerations

- Gems shouldn't be impossible to collect
- Magnetism range may need adjustment at high difficulties
- Consider brief "hover" period after spawn before scroll applies

## Testing

```python
async def test_gem_scroll_integration(game):
    # Set high difficulty
    await game.call(GAME_MANAGER, "set_difficulty_level", [5])

    # Spawn gem and track position
    start_y = await get_gem_y(game)
    await asyncio.sleep(1.0)
    end_y = await get_gem_y(game)

    # Gem should have drifted less than at normal difficulty
    # (scroll speed subtracts from drift speed)
```

## Acceptance Criteria

- [ ] Gem movement incorporates world scroll speed
- [ ] Higher difficulties create more collection pressure
- [ ] Gems feel integrated with scrolling world
- [ ] Magnetism still works appropriately
- [ ] No gems become uncollectable
