---
title: Enemy Warning & Attack System
status: done
priority: 0
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:21:40.741107-06:00
---

# Enemy Warning & Attack System

## Parent Epic
GoPit-3ky (Phase 1 - Core Alignment)

## Overview
Replace instant damage when enemies reach bottom with BallxPit-style warning → shake → attack sequence.

## Current State
- enemy_base.gd moves enemies downward
- Damage occurs instantly when enemy enters player_zone Area2D
- game_controller.gd: _on_player_zone_body_entered() deals damage immediately
- danger_indicator.gd shows warning when enemies near bottom
- No attack animation or delay exists

## Requirements
1. When enemy reaches attack range (not wall):
   - Show red exclamation point (!) above enemy
   - Enemy stops moving and shakes/vibrates
   - After ~1 second warning, enemy leaps at player
   - Damage dealt on contact with player (not wall)
   - Enemy despawns after attack (hit or miss)
2. Player can dodge attacks by moving
3. Multiple enemies can be in "attack mode" simultaneously

## BallxPit Reference
In BallxPit:
- Enemies show "!" warning icon
- Shake animation for ~1 second
- Leap/lunge toward player's current position
- Miss if player moved away
- Creates dodge-focused gameplay

## Implementation Approach

### Step 1: Add Attack States to enemy_base.gd
```gdscript
enum State { DESCENDING, WARNING, ATTACKING, DEAD }

var current_state: State = State.DESCENDING
var _warning_timer: float = 0.0
var _attack_target: Vector2

const WARNING_DURATION: float = 1.0
const ATTACK_SPEED: float = 800.0
const ATTACK_RANGE_Y: float = 1000.0  # When to start warning

func _physics_process(delta: float) -> void:
    match current_state:
        State.DESCENDING:
            _move(delta)
            if global_position.y >= ATTACK_RANGE_Y:
                _enter_warning_state()
        State.WARNING:
            _do_warning(delta)
        State.ATTACKING:
            _do_attack(delta)

func _enter_warning_state() -> void:
    current_state = State.WARNING
    _warning_timer = WARNING_DURATION
    _show_exclamation()
    _start_shake()

func _do_warning(delta: float) -> void:
    _warning_timer -= delta
    _update_shake()
    if _warning_timer <= 0:
        _enter_attack_state()

func _enter_attack_state() -> void:
    current_state = State.ATTACKING
    _hide_exclamation()
    _stop_shake()
    # Target player's current position
    _attack_target = _get_player_position()
    _play_attack_sound()

func _do_attack(delta: float) -> void:
    var direction := (_attack_target - global_position).normalized()
    velocity = direction * ATTACK_SPEED
    move_and_slide()
    
    # Despawn if off-screen or reached target
    if global_position.y > 1400 or global_position.distance_to(_attack_target) < 20:
        queue_free()
```

### Step 2: Visual Effects
Exclamation mark:
```gdscript
var _exclamation: Sprite2D  # Or Label with "!"

func _show_exclamation() -> void:
    _exclamation = Sprite2D.new()  # Or preload scene
    _exclamation.texture = preload("res://assets/sprites/exclamation.png")
    _exclamation.position = Vector2(0, -40)
    add_child(_exclamation)
    # Pulse animation
    var tween := create_tween().set_loops()
    tween.tween_property(_exclamation, "scale", Vector2(1.2, 1.2), 0.2)
    tween.tween_property(_exclamation, "scale", Vector2(1.0, 1.0), 0.2)

func _hide_exclamation() -> void:
    if _exclamation:
        _exclamation.queue_free()
```

Shake effect:
```gdscript
var _shake_offset: Vector2 = Vector2.ZERO
var _shake_intensity: float = 5.0

func _start_shake() -> void:
    # Handled in _update_shake

func _update_shake() -> void:
    _shake_offset = Vector2(
        randf_range(-_shake_intensity, _shake_intensity),
        randf_range(-_shake_intensity, _shake_intensity)
    )
    position += _shake_offset  # Apply to visual only

func _stop_shake() -> void:
    _shake_offset = Vector2.ZERO
```

### Step 3: Damage on Player Contact
Remove wall-based damage, add contact-based:
```gdscript
# In enemy attack state, check collision with player
func _do_attack(delta: float) -> void:
    # ... movement code ...
    
    # Check if hit player
    var player := _get_player_node()
    if player and global_position.distance_to(player.global_position) < 30:
        _deal_damage_to_player()
        queue_free()
```

Or use collision detection:
- Enemy collision mask includes player layer (16)
- On collision with player during ATTACKING state, deal damage

### Step 4: Update game_controller.gd
Remove or modify _on_player_zone_body_entered:
```gdscript
func _on_player_zone_body_entered(body: Node2D) -> void:
    # OLD: Instant damage when reaching zone
    # NEW: Enemies handle their own attack logic
    pass  # Or remove this entirely
```

## Files to Modify
- MODIFY: scripts/entities/enemies/enemy_base.gd (major changes)
- MODIFY: scripts/game/game_controller.gd (remove instant damage)
- NEW: assets/sprites/exclamation.png (or use Label)
- OPTIONAL: scenes/effects/exclamation.tscn

## Testing
```python
async def test_enemy_warning_before_attack(game):
    # Spawn enemy, wait for it to reach attack range
    spawner = "/root/Game/GameArea/Enemies/EnemySpawner"
    await game.call(spawner, "spawn_enemy")
    
    # Wait for enemy to descend
    await asyncio.sleep(3.0)
    
    # Check enemy is in WARNING state (not instant death)
    enemies = "/root/Game/GameArea/Enemies"
    count = await game.call(enemies, "get_child_count")
    # Enemy should still exist during warning phase

async def test_player_can_dodge_attack(game):
    # Position player, let enemy attack
    # Move player away during warning
    # Verify no damage taken
    pass

async def test_enemy_despawns_after_attack(game):
    # Let enemy complete attack sequence
    # Verify enemy is removed from scene
    pass
```

## Acceptance Criteria
- [ ] Enemies stop and show "!" when reaching attack range
- [ ] Enemies visibly shake during warning phase
- [ ] Warning lasts ~1 second
- [ ] Enemy leaps toward player position after warning
- [ ] Player can dodge by moving during warning
- [ ] Damage only occurs on contact with player
- [ ] Enemy despawns after attack completes
- [ ] Multiple enemies can attack simultaneously

## Notes
- This fundamentally changes the feel of the game
- Creates skill-based dodge gameplay
- Consider difficulty: longer warning = easier
- May need to tune ATTACK_RANGE_Y based on player speed
