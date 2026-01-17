---
title: Player Free Movement System
status: done
priority: 0
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:21:40.215201-06:00
---

# Player Free Movement System

## Parent Epic
GoPit-3ky (Phase 1 - Core Alignment)

## Overview
Replace the fixed player position with a freely movable player character that can navigate the entire play area.

## Current State
- Player has no visible sprite or movement
- "Player zone" is an Area2D at the bottom of screen (y=1200)
- Joystick currently only controls aim direction
- Gems/enemies interact with player_zone Area2D

## Requirements
1. Create visible player character sprite
2. Player can move anywhere in the game area (not just bottom)
3. Movement controlled by left virtual joystick
4. Separate aim direction from movement direction
5. Player has collision body for gem/enemy interaction
6. Movement speed: ~300 pixels/second (tunable)

## Implementation Approach

### Step 1: Create Player Scene
Create new scene: scenes/entities/player.tscn
- CharacterBody2D root
- CollisionShape2D (circle, radius ~20)
- Sprite or custom _draw() for visuals
- Script: scripts/entities/player.gd

### Step 2: Player Script
```gdscript
class_name Player
extends CharacterBody2D

signal damaged(amount: int)

@export var move_speed: float = 300.0

func _physics_process(delta: float) -> void:
    # Get movement input from joystick
    var input_dir := _get_movement_input()
    velocity = input_dir * move_speed
    move_and_slide()

func _get_movement_input() -> Vector2:
    # Connect to joystick signal or read directly
    pass
```

### Step 3: Modify Control Scheme
Option A: Single joystick (move + aim)
- Joystick moves player
- Fire direction = movement direction (or last moved direction)

Option B: Twin stick (recommended for BallxPit feel)
- Left joystick = movement
- Fire button + drag = aim direction
- Or: auto-aim at nearest enemy

### Step 4: Update game_controller.gd
- Instantiate player in GameArea
- Wire joystick to player movement
- Update references from player_zone to player node
- Keep player_zone for backward compatibility or remove

### Step 5: Update Collision Layers
Current layers:
- 1: Walls
- 2: Balls  
- 4: Enemies
- 8: Gems
- 16: Player (add this)

Player collision:
- Layer: 16 (player)
- Mask: 4 (enemies) + 8 (gems)

## Files to Modify
- NEW: scenes/entities/player.tscn
- NEW: scripts/entities/player.gd
- MODIFY: scripts/game/game_controller.gd
- MODIFY: scripts/input/virtual_joystick.gd (if needed)
- MODIFY: project.godot (collision layers)

## Testing
After implementation, these tests should pass:
```python
async def test_player_movement(game):
    # Get initial position
    pos1 = await game.get_property("/root/Game/GameArea/Player", "position")
    
    # Simulate joystick input
    await game.call("/root/Game/UI/HUD/.../VirtualJoystick", "set_direction", [Vector2(1, 0)])
    await asyncio.sleep(0.5)
    
    # Verify player moved right
    pos2 = await game.get_property("/root/Game/GameArea/Player", "position")
    assert pos2['x'] > pos1['x']
```

## Acceptance Criteria
- [ ] Player sprite visible on screen
- [ ] Player moves with joystick input
- [ ] Player stays within game boundaries
- [ ] Player can collect gems by touching them
- [ ] Player takes damage when enemy touches them
- [ ] Movement feels responsive (no lag)

## Notes
- Consider adding player invincibility frames after taking damage
- May need to adjust gem magnetism to work with moving player
- BallxPit player moves at moderate speed - not too fast
