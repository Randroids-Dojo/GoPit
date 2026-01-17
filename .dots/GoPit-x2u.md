---
title: Ball Leveling System (L1-L3)
status: done
priority: 1
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:30:36.949927-06:00
---

# Ball Leveling System (L1-L3)

## Parent Epic
GoPit-zxr (Phase 2 - Ball Evolution System)

## Overview
Implement ball leveling where each ball type can be upgraded from Level 1 to Level 3, with L3 balls eligible for fusion.

## Current State
- level_up_overlay.gd has upgrade_stacks tracking
- Ball types exist but no formal "level" concept
- Upgrades increase global stats (damage, speed) not per-ball-type

## Requirements
1. Each ball type tracks its own level (1-3)
2. Level 2: +50% damage and stats
3. Level 3: +100% damage, fusion-eligible
4. Level-up UI shows current ball levels
5. Can't upgrade past L3 (offer fusion instead)
6. Visual distinction per level

## Implementation Approach

### Step 1: Create Ball Type Registry
```gdscript
# scripts/autoload/ball_registry.gd (new autoload)
extends Node

enum BallType { BASIC, BURN, FREEZE, POISON, BLEED, LIGHTNING, IRON }

class BallData:
    var type: BallType
    var level: int = 1
    var base_damage: int
    var base_speed: float
    
    func get_damage() -> int:
        return int(base_damage * _get_level_multiplier())
    
    func get_speed() -> float:
        return base_speed * _get_level_multiplier()
    
    func _get_level_multiplier() -> float:
        match level:
            1: return 1.0
            2: return 1.5
            3: return 2.0
        return 1.0
    
    func can_level_up() -> bool:
        return level < 3
    
    func is_fusion_ready() -> bool:
        return level >= 3

# Owned ball types for current run
var owned_balls: Dictionary = {}  # BallType -> BallData

func _ready() -> void:
    GameManager.game_started.connect(_reset_for_new_run)

func _reset_for_new_run() -> void:
    owned_balls.clear()
    # Start with basic ball at L1
    add_ball(BallType.BASIC)

func add_ball(type: BallType) -> void:
    if type in owned_balls:
        # Already owned, try to level up
        level_up_ball(type)
        return
    
    var data := BallData.new()
    data.type = type
    data.level = 1
    data.base_damage = _get_base_damage(type)
    data.base_speed = _get_base_speed(type)
    owned_balls[type] = data

func level_up_ball(type: BallType) -> bool:
    if type not in owned_balls:
        return false
    
    var ball: BallData = owned_balls[type]
    if ball.can_level_up():
        ball.level += 1
        return true
    return false

func get_ball_level(type: BallType) -> int:
    if type in owned_balls:
        return owned_balls[type].level
    return 0

func get_fusion_ready_balls() -> Array[BallType]:
    var ready: Array[BallType] = []
    for type in owned_balls:
        if owned_balls[type].is_fusion_ready():
            ready.append(type)
    return ready

func _get_base_damage(type: BallType) -> int:
    match type:
        BallType.BASIC: return 10
        BallType.BURN: return 8
        BallType.FREEZE: return 6
        BallType.POISON: return 7
        BallType.BLEED: return 8
        BallType.LIGHTNING: return 9
        BallType.IRON: return 15
    return 10

func _get_base_speed(type: BallType) -> float:
    match type:
        BallType.IRON: return 600.0  # Slower but hits harder
        BallType.LIGHTNING: return 900.0  # Fast
        _: return 800.0
```

### Step 2: Update Level Up UI
```gdscript
# In level_up_overlay.gd

func _randomize_upgrades() -> void:
    _available_upgrades.clear()
    var pool: Array = []
    
    # Add new ball types not yet owned
    for ball_type in BallRegistry.BallType.values():
        if ball_type not in BallRegistry.owned_balls:
            pool.append({"type": "new_ball", "ball_type": ball_type})
    
    # Add level-ups for owned balls < L3
    for ball_type in BallRegistry.owned_balls:
        var data: BallRegistry.BallData = BallRegistry.owned_balls[ball_type]
        if data.can_level_up():
            pool.append({"type": "level_up", "ball_type": ball_type, "to_level": data.level + 1})
    
    # Add passive upgrades
    for upgrade_type in UPGRADE_DATA:
        # ... existing logic ...
        pool.append({"type": "passive", "upgrade": upgrade_type})
    
    pool.shuffle()
    _available_upgrades = pool.slice(0, 3)
```

### Step 3: Visual Ball Level Indicators
```gdscript
# In ball.gd
var ball_level: int = 1

func _draw() -> void:
    # Draw ball with level-based visual
    var size_mult := 1.0 + (ball_level - 1) * 0.15  # L2=1.15x, L3=1.3x
    var actual_radius := radius * size_mult
    
    draw_circle(Vector2.ZERO, actual_radius, ball_color)
    
    # Level indicator rings
    if ball_level >= 2:
        draw_arc(Vector2.ZERO, actual_radius + 2, 0, TAU, 24, Color.WHITE, 1.5)
    if ball_level >= 3:
        draw_arc(Vector2.ZERO, actual_radius + 5, 0, TAU, 24, Color.GOLD, 2.0)
```

### Step 4: Update Ball Spawner
```gdscript
# ball_spawner.gd should use BallRegistry for stats
func _spawn_ball(direction: Vector2) -> void:
    var ball := ball_scene.instantiate()
    
    # Get stats from registry
    var ball_data := BallRegistry.owned_balls.get(current_ball_type)
    if ball_data:
        ball.damage = ball_data.get_damage()
        ball.speed = ball_data.get_speed()
        ball.ball_level = ball_data.level
    
    # ... rest of spawn logic ...
```

## Files to Create/Modify
- NEW: scripts/autoload/ball_registry.gd
- MODIFY: project.godot (add autoload)
- MODIFY: scripts/ui/level_up_overlay.gd
- MODIFY: scripts/entities/ball.gd
- MODIFY: scripts/entities/ball_spawner.gd

## Testing
```python
async def test_ball_level_up(game):
    """Ball should level from 1 to 2 to 3"""
    pass

async def test_level_affects_damage(game):
    """L2 = 1.5x damage, L3 = 2x damage"""
    pass

async def test_cant_level_past_3(game):
    """L3 balls can't be leveled further"""
    pass
```

## Acceptance Criteria
- [ ] Balls track individual levels
- [ ] Level 2 grants +50% stats
- [ ] Level 3 grants +100% stats
- [ ] UI shows ball levels
- [ ] Can't upgrade past L3
- [ ] L3 balls visually distinct
- [ ] Ball registry persists for run duration
