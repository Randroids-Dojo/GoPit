---
title: Fusion Reactor Drops & Ball Fusion
status: done
priority: 1
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:30:37.169404-06:00
---

# Fusion Reactor Drops & Ball Fusion

## Parent Epic
GoPit-zxr (Phase 2 - Ball Evolution System)

## Overview
Implement Fusion Reactor item drops that allow combining two L3 balls into an evolved ball with combined properties.

## Requirements
1. Fusion Reactors drop from enemies (rare)
2. Player collects reactor like a gem
3. When collected with 2+ L3 balls: show fusion UI
4. Fusion UI: select two L3 balls to combine
5. Result: Evolved ball with both effects + bonus
6. At least 5 fusion recipes implemented

## Fusion Recipes
| Ball A | Ball B | Result | Effect |
|--------|--------|--------|--------|
| Burn | Iron | **Bomb** | Explosion AoE on hit |
| Freeze | Lightning | **Blizzard** | AoE freeze + chain |
| Poison | Bleed | **Virus** | Spreading DoT + lifesteal |
| Burn | Poison | **Magma** | DoT pools on ground |
| Burn | Freeze | **Void** | Alternating effects |

## Implementation Approach

### Step 1: Create Fusion Reactor Drop
```gdscript
# scripts/entities/fusion_reactor.gd
class_name FusionReactor
extends Area2D

signal collected

func _ready() -> void:
    collision_layer = 32  # New layer for special pickups
    collision_mask = 16   # Player
    
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        collected.emit()
        _trigger_fusion_ui()
        queue_free()

func _trigger_fusion_ui() -> void:
    var fusion_ready := BallRegistry.get_fusion_ready_balls()
    if fusion_ready.size() >= 2:
        # Show fusion selection UI
        GameManager.trigger_fusion_selection(fusion_ready)
    else:
        # Not enough L3 balls - store reactor for later?
        # Or convert to random upgrade
        pass
```

### Step 2: Fusion Recipes Registry
```gdscript
# scripts/autoload/fusion_registry.gd
extends Node

const FUSION_RECIPES := {
    # Key: sorted array of [BallType, BallType]
    # Value: resulting evolved ball type
    [BallRegistry.BallType.BURN, BallRegistry.BallType.IRON]: "BOMB",
    [BallRegistry.BallType.FREEZE, BallRegistry.BallType.LIGHTNING]: "BLIZZARD",
    [BallRegistry.BallType.POISON, BallRegistry.BallType.BLEED]: "VIRUS",
    [BallRegistry.BallType.BURN, BallRegistry.BallType.POISON]: "MAGMA",
    [BallRegistry.BallType.BURN, BallRegistry.BallType.FREEZE]: "VOID",
}

const EVOLVED_BALL_DATA := {
    "BOMB": {
        "name": "Bomb Ball",
        "description": "Explodes on hit, damaging nearby enemies",
        "base_damage": 20,
        "base_speed": 700.0,
        "effect": "explosion"
    },
    "BLIZZARD": {
        "name": "Blizzard Ball",
        "description": "Freezes and chains to multiple enemies",
        "base_damage": 15,
        "base_speed": 850.0,
        "effect": "blizzard"
    },
    # ... more evolved balls
}

func can_fuse(ball_a: int, ball_b: int) -> bool:
    var key := [mini(ball_a, ball_b), maxi(ball_a, ball_b)]
    return key in FUSION_RECIPES

func get_fusion_result(ball_a: int, ball_b: int) -> String:
    var key := [mini(ball_a, ball_b), maxi(ball_a, ball_b)]
    return FUSION_RECIPES.get(key, "")

func get_evolved_ball_data(evolved_type: String) -> Dictionary:
    return EVOLVED_BALL_DATA.get(evolved_type, {})
```

### Step 3: Fusion Selection UI
```gdscript
# scripts/ui/fusion_overlay.gd
extends Control

signal fusion_completed(evolved_ball_type: String)

var _available_balls: Array = []
var _selected_balls: Array = []

func show_fusion(fusion_ready_balls: Array) -> void:
    _available_balls = fusion_ready_balls
    _selected_balls.clear()
    _update_ui()
    visible = true
    get_tree().paused = true

func _update_ui() -> void:
    # Show cards for each L3 ball
    # Highlight selected balls
    # Show fusion preview when 2 selected
    pass

func _on_ball_selected(ball_type: int) -> void:
    if ball_type in _selected_balls:
        _selected_balls.erase(ball_type)
    else:
        if _selected_balls.size() < 2:
            _selected_balls.append(ball_type)
    
    _update_fusion_preview()

func _update_fusion_preview() -> void:
    if _selected_balls.size() == 2:
        var result := FusionRegistry.get_fusion_result(_selected_balls[0], _selected_balls[1])
        if result:
            # Show "= BOMB BALL" preview
            pass
        else:
            # Show "No valid fusion"
            pass

func _on_fuse_pressed() -> void:
    if _selected_balls.size() != 2:
        return
    
    var result := FusionRegistry.get_fusion_result(_selected_balls[0], _selected_balls[1])
    if result:
        # Remove the two L3 balls from inventory
        BallRegistry.owned_balls.erase(_selected_balls[0])
        BallRegistry.owned_balls.erase(_selected_balls[1])
        
        # Add evolved ball
        BallRegistry.add_evolved_ball(result)
        
        fusion_completed.emit(result)
        _close()

func _close() -> void:
    get_tree().paused = false
    visible = false
```

### Step 4: Evolved Ball Behavior
```gdscript
# Add to ball.gd
var is_evolved: bool = false
var evolved_type: String = ""

func _apply_evolved_effect(enemy: Node2D) -> void:
    match evolved_type:
        "BOMB":
            _explode(enemy.global_position)
        "BLIZZARD":
            _blizzard_effect(enemy)
        "VIRUS":
            _virus_effect(enemy)
        "MAGMA":
            _spawn_magma_pool(enemy.global_position)
        "VOID":
            _void_effect(enemy)

func _explode(pos: Vector2) -> void:
    # Spawn explosion effect
    # Damage all enemies in radius
    var explosion_radius := 100.0
    var explosion_damage := damage
    # ... implementation
```

### Step 5: Reactor Spawn in Enemy Spawner
```gdscript
# In enemy death handler
func _on_enemy_died(enemy: EnemyBase) -> void:
    # Existing gem spawn
    _spawn_gem(enemy.global_position, enemy.xp_value)
    
    # Rare fusion reactor drop
    var reactor_chance := 0.02  # 2% base chance
    reactor_chance += GameManager.current_wave * 0.001  # Increases with wave
    
    if randf() < reactor_chance:
        _spawn_fusion_reactor(enemy.global_position)
```

## Files to Create/Modify
- NEW: scripts/entities/fusion_reactor.gd
- NEW: scenes/entities/fusion_reactor.tscn
- NEW: scripts/autoload/fusion_registry.gd
- NEW: scripts/ui/fusion_overlay.gd
- NEW: scenes/ui/fusion_overlay.tscn
- MODIFY: scripts/autoload/ball_registry.gd (add evolved balls)
- MODIFY: scripts/entities/ball.gd (evolved effects)
- MODIFY: scripts/game/game_controller.gd
- MODIFY: project.godot (autoloads)

## Testing
```python
async def test_fusion_reactor_spawns(game):
    """Fusion reactor should occasionally drop"""
    pass

async def test_fusion_ui_appears(game):
    """Fusion UI shows when reactor collected with 2+ L3 balls"""
    pass

async def test_valid_fusion_creates_evolved_ball(game):
    """Fusing Burn + Iron should create Bomb"""
    pass
```

## Acceptance Criteria
- [ ] Fusion reactors drop from enemies (rare)
- [ ] Collecting reactor with 2+ L3 balls shows fusion UI
- [ ] Can select two L3 balls to fuse
- [ ] Valid combinations create evolved balls
- [ ] Invalid combinations show "no recipe"
- [ ] At least 5 fusion recipes working
- [ ] Evolved balls have unique effects
- [ ] Original balls removed after fusion
