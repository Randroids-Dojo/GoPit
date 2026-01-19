---
title: Add ball limit for performance
status: closed
priority: 4
issue-type: task
assignee: randroid
created-at: 2026-01-05T02:13:41.289161-06:00
closed-at: 2026-01-18
---

## Description

~~Limit the number of balls that can exist simultaneously to prevent performance issues.~~

## Status: ALREADY IMPLEMENTED

After code review, both ball limit and object pooling are already implemented:

### Ball Limit
`ball_spawner.gd:18`:
```gdscript
@export var max_balls: int = 50  ## Maximum total balls (main + baby) for performance
```

`ball_spawner.gd:289-295` - `_enforce_ball_limit()` method despawns oldest balls when limit reached.

### Object Pooling
`PoolManager` autoload handles pooling for:
- Balls (`get_ball()`, `release_ball()`)
- Gems (`get_gem()`)
- Damage numbers (`get_damage_number()`, `release_damage_number()`)

Ball instances have `has_meta("pooled")` check in despawn logic to return to pool instead of queue_free.

## Resolution

Both requested features are already implemented. Closing as complete.
