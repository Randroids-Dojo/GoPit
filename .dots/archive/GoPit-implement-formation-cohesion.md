---
title: Implement formation cohesion movement
status: closed
priority: 3
issue-type: implement
created-at: "\"2026-01-27\""
closed-at: "2026-02-01T05:02:30.811115+00:00"
---

## Overview

Make enemy formations move as cohesive units that maintain relative positions during descent, rather than individual enemies descending independently.

## Context

BallxPit formations descend as organized groups, maintaining their V-shape or line pattern. GoPit spawns formations at the same Y but enemies immediately descend independently, breaking the visual pattern.

See: `docs/research/level-scrolling-comparison.md`

## Current Behavior

In `enemy_spawner.gd`:
- Formations spawn all enemies at same Y position
- Each enemy has its own `speed` and descends via `velocity = Vector2.DOWN * speed`
- Formation breaks apart almost immediately

## Proposed Solution

### 1. Formation Leader System

Designate one enemy as formation leader, others follow:

```gdscript
class_name FormationGroup
extends Node2D

var leader: EnemyBase
var followers: Array[EnemyBase] = []
var offsets: Array[Vector2] = []  # Relative positions

func _physics_process(delta: float) -> void:
    if not is_instance_valid(leader):
        _dissolve_formation()
        return

    # Update follower positions relative to leader
    for i in range(followers.size()):
        if is_instance_valid(followers[i]):
            followers[i].global_position = leader.global_position + offsets[i]
```

### 2. Alternative: Shared Descent Controller

All formation enemies share a descent controller:

```gdscript
# In enemy_spawner.gd
func _spawn_formation(type: Formation, count: int) -> void:
    var positions := _calculate_formation_positions(type, count)
    var shared_y := spawn_y_offset
    var shared_speed := _get_enemy_speed()

    var formation_enemies: Array[EnemyBase] = []
    for pos in positions:
        var enemy := _spawn_enemy_at(pos)
        enemy.use_formation_movement = true
        enemy.formation_y_ref = shared_y
        formation_enemies.append(enemy)

    # Store formation for coordinated movement
    _active_formations.append({
        "enemies": formation_enemies,
        "base_y": shared_y,
        "speed": shared_speed
    })
```

### 3. Formation Dissolution Rules

Formation breaks apart when:
- Leader dies (if using leader system)
- Any enemy reaches ATTACKING state
- Enemies enter danger zone
- Formation damaged to < 50% members

After dissolution, remaining enemies move independently.

## Implementation Steps

1. Add `FormationGroup` node or tracking system
2. Modify enemy spawner to create formation groups
3. Add formation movement logic
4. Implement dissolution triggers
5. Visual polish (formation outline, leader indicator)

## Files to Modify

- `scripts/entities/enemies/enemy_spawner.gd` - formation creation
- `scripts/entities/enemies/enemy_base.gd` - formation movement mode
- **Create:** `scripts/entities/enemies/formation_group.gd`

## Visual Considerations

- Optional: Draw subtle lines connecting formation members
- Optional: Leader enemy has slight glow/size difference
- Formation maintains pattern during descent
- Satisfying "break apart" effect on dissolution

## Testing

```python
async def test_formation_maintains_shape(game):
    # Spawn LINE formation
    await game.call(ENEMY_SPAWNER, "spawn_formation", ["LINE", 5])
    await asyncio.sleep(0.5)

    # Get all enemy positions
    enemies = await game.call(ENEMIES_CONTAINER, "get_children")

    # Verify they're still in a horizontal line (same Y)
    y_positions = [e.position.y for e in enemies]
    assert max(y_positions) - min(y_positions) < 10  # Within 10px
```

## Acceptance Criteria

- [ ] Formations maintain relative positions during descent
- [ ] Formation dissolves appropriately (death, attack mode)
- [ ] Visual pattern is recognizable and satisfying
- [ ] No performance issues with multiple active formations
- [ ] Individual enemies work normally after dissolution
