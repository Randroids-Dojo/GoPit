---
title: Add screen shake and damage feedback
status: done
priority: 1
issue-type: feature
assignee: randroid
created-at: 2026-01-05T01:48:08.29361-06:00
---

## Problem
When balls hit enemies and when player takes damage, feedback is minimal. Hits don't feel impactful.

## Implementation Plan

### Phase 1: Screen Shake System
**File: `scripts/effects/camera_shake.gd`** (new)

```gdscript
extends Camera2D

var shake_intensity: float = 0.0
var shake_decay: float = 5.0

func _process(delta):
    if shake_intensity > 0:
        offset = Vector2(
            randf_range(-shake_intensity, shake_intensity),
            randf_range(-shake_intensity, shake_intensity)
        )
        shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
    else:
        offset = Vector2.ZERO

func shake(intensity: float = 10.0, decay: float = 5.0):
    shake_intensity = max(shake_intensity, intensity)
    shake_decay = decay
```

### Phase 2: Damage Vignette Effect
**File: `scripts/effects/damage_vignette.gd`** (new)

```gdscript
extends ColorRect

var flash_duration: float = 0.15
var flash_timer: float = 0.0

func _ready():
    color = Color(1, 0, 0, 0)  # Transparent red
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func flash():
    flash_timer = flash_duration
    
func _process(delta):
    if flash_timer > 0:
        flash_timer -= delta
        color.a = (flash_timer / flash_duration) * 0.4
    else:
        color.a = 0
```

### Phase 3: Hit Particles
**File: `scenes/effects/hit_particles.tscn`** (new)

Use GPUParticles2D with:
- Burst emission (8-12 particles)
- Spread angle: 180 degrees (radial)
- Initial velocity: 100-200
- Gravity: 0
- Lifetime: 0.3s
- Color: Enemy color with fade out

### Phase 4: Floating Damage Numbers
**File: `scripts/effects/damage_number.gd`** (new)

```gdscript
extends Label

func _ready():
    var tween = create_tween()
    tween.tween_property(self, "position:y", position.y - 50, 0.5)
    tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
    tween.tween_callback(queue_free)

static func spawn(parent: Node, pos: Vector2, damage: int):
    var label = preload("res://scenes/effects/damage_number.tscn").instantiate()
    label.text = str(damage)
    label.position = pos
    parent.add_child(label)
```

### Phase 5: Wire Up Effects
**Modify: `scripts/entities/enemies/enemy_base.gd`**

```gdscript
func take_damage(amount: int) -> void:
    hp -= amount
    
    # Screen shake (small)
    CameraShake.shake(3.0)
    
    # Spawn hit particles
    var particles = preload("hit_particles.tscn").instantiate()
    particles.position = global_position
    get_tree().current_scene.add_child(particles)
    
    # Floating damage number
    DamageNumber.spawn(get_tree().current_scene, global_position, amount)
    
    # Existing flash effect...
```

**Modify: `scripts/autoload/game_manager.gd`**

```gdscript
signal player_damaged(amount: int)

func take_damage(amount: int) -> void:
    player_hp = max(0, player_hp - amount)
    player_damaged.emit(amount)
    
    # Trigger big screen shake
    CameraShake.shake(15.0, 3.0)
```

### Files to Create/Modify
1. NEW: `scripts/effects/camera_shake.gd` (autoload or attached to Camera2D)
2. NEW: `scripts/effects/damage_vignette.gd`
3. NEW: `scenes/effects/hit_particles.tscn`
4. NEW: `scenes/effects/damage_number.tscn`
5. NEW: `scripts/effects/damage_number.gd`
6. MODIFY: `scenes/game.tscn` - add Camera2D with shake, vignette ColorRect
7. MODIFY: `scripts/entities/enemies/enemy_base.gd` - trigger effects
8. MODIFY: `scripts/autoload/game_manager.gd` - emit player_damaged signal

### Testing
- Verify screen shake on enemy hit (small) and player damage (large)
- Verify vignette flash on player damage
- Verify particles spawn at hit location
- Verify damage numbers float up and fade
