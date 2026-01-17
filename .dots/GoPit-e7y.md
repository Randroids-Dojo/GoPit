---
title: Gem Collection via Player Movement
status: done
priority: 0
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:21:41.022741-06:00
---

# Gem Collection via Player Movement

## Parent Epic
GoPit-3ky (Phase 1 - Core Alignment)

## Overview
Change gem collection from "enter player zone area" to "player walks over gem", with magnetism upgrade pulling gems toward player.

## Current State
- gem.gd: Gems are Area2D on collision layer 8
- Gems collected when entering player_zone (Area2D at bottom)
- game_controller.gd: _on_player_zone_area_entered() handles collection
- GameManager.gem_magnetism_range exists but gems don't move to player
- Gems despawn after ~15 seconds

## Requirements
1. Gems only collected when player touches them directly
2. Remove automatic collection at player zone wall
3. Magnetism upgrade: gems within range move toward player
4. Gems still despawn if not collected (10 seconds)
5. Visual "pull" effect when magnetism active

## Implementation Approach

### Step 1: Update gem.gd for Player Detection
```gdscript
# gem.gd modifications

var _player: Node2D = null
var _being_attracted: bool = false
const ATTRACTION_SPEED: float = 400.0

func _ready() -> void:
    # ... existing code ...
    # Find player reference
    _player = get_tree().get_first_node_in_group("player")
    
    # Set collision to detect player (not player_zone)
    collision_layer = 8  # gems
    collision_mask = 16  # player

func _physics_process(delta: float) -> void:
    _check_magnetism(delta)
    _check_player_collision()

func _check_magnetism(delta: float) -> void:
    if not _player:
        return
    
    var mag_range := GameManager.gem_magnetism_range
    if mag_range <= 0:
        return
    
    var distance := global_position.distance_to(_player.global_position)
    if distance < mag_range:
        _being_attracted = true
        var direction := (_player.global_position - global_position).normalized()
        # Move faster as gem gets closer
        var speed := ATTRACTION_SPEED * (1.0 + (mag_range - distance) / mag_range)
        position += direction * speed * delta
    else:
        _being_attracted = false

func _check_player_collision() -> void:
    if not _player:
        return
    
    var distance := global_position.distance_to(_player.global_position)
    if distance < 25:  # Collection radius
        _collect()

func _collect() -> void:
    collected.emit(self)
    SoundManager.play(SoundManager.SoundType.GEM_COLLECT)
    queue_free()
```

### Step 2: Remove Player Zone Collection
In game_controller.gd, modify or remove:
```gdscript
func _on_player_zone_area_entered(area: Area2D) -> void:
    # OLD: Collect gems that enter zone
    # NEW: Only handle enemies here, gems collected by player directly
    
    # Remove gem collection logic from here
    # Gems now handle their own collection via player contact
    pass
```

### Step 3: Visual Magnetism Effect
When gem is being attracted, show pull line:
```gdscript
func _draw() -> void:
    # Draw gem sprite
    draw_circle(Vector2.ZERO, 8, Color(0.2, 0.9, 0.3))
    
    # Draw attraction line when being pulled
    if _being_attracted and _player:
        var to_player := _player.global_position - global_position
        draw_line(Vector2.ZERO, to_player, Color(0.5, 1.0, 0.5, 0.3), 2.0)

func _physics_process(delta: float) -> void:
    # ... existing code ...
    if _being_attracted:
        queue_redraw()
```

### Step 4: Ensure Player Has Collision
Player needs to be in group "player" and have collision layer 16:
```gdscript
# In player.gd _ready()
add_to_group("player")
collision_layer = 16
collision_mask = 4 | 8  # enemies + gems
```

### Step 5: Update Magnetism Upgrade
In level_up_overlay.gd, _apply_magnetism() already increases range:
```gdscript
func _apply_magnetism() -> void:
    GameManager.gem_magnetism_range += 200.0
```
This should work with the new system.

## Files to Modify
- MODIFY: scripts/entities/gem.gd (major changes)
- MODIFY: scripts/game/game_controller.gd (remove zone collection)
- MODIFY: scripts/entities/player.gd (ensure collision setup)
- Verify: scripts/ui/level_up_overlay.gd (magnetism upgrade)

## Testing
```python
async def test_gem_not_collected_at_wall(game):
    """Gems should NOT auto-collect when reaching bottom wall"""
    # Spawn gem at top, let it fall to bottom
    # Verify it's still there (not collected)
    pass

async def test_gem_collected_on_player_contact(game):
    """Gems collected when player touches them"""
    # Spawn gem
    # Move player to gem position
    # Verify gem collected and XP gained
    pass

async def test_gem_magnetism(game):
    """Gems move toward player when magnetism upgrade active"""
    # Apply magnetism upgrade
    # Spawn gem within range
    # Verify gem moves toward player
    pass

async def test_gem_despawn(game):
    """Gems despawn after timeout if not collected"""
    # Spawn gem, don't collect
    # Wait 10+ seconds
    # Verify gem is gone
    pass
```

## Acceptance Criteria
- [ ] Gems do NOT auto-collect at screen bottom
- [ ] Gems collected when player character touches them
- [ ] Magnetism upgrade causes gems to move toward player
- [ ] Gems within magnetism range show visual pull effect
- [ ] Gems despawn after ~10 seconds if not collected
- [ ] XP correctly awarded on collection
- [ ] Gem collection sound plays on pickup

## Design Notes
- This encourages player to move and engage
- Risk/reward: move toward gems but expose yourself
- Magnetism becomes more valuable upgrade
- Consider: gem value could decay over time?
