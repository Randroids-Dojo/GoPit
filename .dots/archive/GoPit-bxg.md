---
title: Add additional enemy types (Bat, Crab)
status: done
priority: 3
issue-type: feature
assignee: randroid
created-at: 2026-01-05T02:15:32.724693-06:00
---

## Problem
Only slimes exist. Gameplay becomes repetitive.

## Implementation Plan

### Enemy Type: Bat
**File: `scripts/entities/enemies/bat.gd`** (new)

```gdscript
extends EnemyBase
## Bat enemy - zigzags horizontally while descending

@export var zigzag_frequency: float = 2.0  # oscillations per second
@export var zigzag_amplitude: float = 100.0  # pixels left/right

var time_alive: float = 0.0
var start_x: float = 0.0

func _ready():
    super._ready()
    start_x = global_position.x
    max_hp = 8  # Slightly weaker
    speed = 150  # Faster descent
    xp_value = 12

func _physics_process(delta):
    time_alive += delta
    
    # Zigzag motion
    var offset = sin(time_alive * zigzag_frequency * TAU) * zigzag_amplitude
    global_position.x = start_x + offset
    
    # Descend
    velocity = Vector2(0, speed)
    move_and_slide()

func _draw():
    # Purple bat shape
    draw_circle(Vector2.ZERO, 10, Color(0.6, 0.3, 0.8))
    # Wings
    draw_polygon([Vector2(-20, 0), Vector2(-10, -8), Vector2(-5, 0)], [Color(0.5, 0.2, 0.7)])
    draw_polygon([Vector2(20, 0), Vector2(10, -8), Vector2(5, 0)], [Color(0.5, 0.2, 0.7)])
```

### Enemy Type: Crab
**File: `scripts/entities/enemies/crab.gd`** (new)

```gdscript
extends EnemyBase
## Crab enemy - moves side to side, tanky

@export var horizontal_speed: float = 80.0
@export var pause_duration: float = 0.5

var horizontal_direction: int = 1
var pause_timer: float = 0.0
const MARGIN: float = 60.0

func _ready():
    super._ready()
    max_hp = 25  # Tanky
    hp = max_hp
    speed = 50  # Slow descent
    xp_value = 20
    horizontal_direction = 1 if randf() > 0.5 else -1

func _physics_process(delta):
    if pause_timer > 0:
        pause_timer -= delta
        return
    
    # Horizontal movement
    global_position.x += horizontal_direction * horizontal_speed * delta
    
    # Bounce off edges
    if global_position.x < MARGIN:
        horizontal_direction = 1
        pause_timer = pause_duration
    elif global_position.x > 720 - MARGIN:
        horizontal_direction = -1
        pause_timer = pause_duration
    
    # Slow descent
    velocity = Vector2(0, speed)
    move_and_slide()

func _draw():
    # Orange crab shape
    draw_circle(Vector2.ZERO, 15, Color(0.9, 0.4, 0.2))
    # Claws
    draw_circle(Vector2(-18, 0), 6, Color(0.8, 0.3, 0.1))
    draw_circle(Vector2(18, 0), 6, Color(0.8, 0.3, 0.1))
```

### Spawner Integration
**Modify: `scripts/entities/enemies/enemy_spawner.gd`**

```gdscript
var bat_scene = preload("res://scenes/entities/enemies/bat.tscn")
var crab_scene = preload("res://scenes/entities/enemies/crab.tscn")

const ENEMY_WEIGHTS := {
    "slime": 60,  # 60% chance
    "bat": 25,    # 25% chance
    "crab": 15    # 15% chance
}

func _spawn_enemy():
    var enemy_type = _weighted_random_enemy()
    var enemy: EnemyBase
    
    match enemy_type:
        "slime":
            enemy = slime_scene.instantiate()
        "bat":
            enemy = bat_scene.instantiate()
        "crab":
            enemy = crab_scene.instantiate()
    
    # Apply wave scaling and spawn...

func _weighted_random_enemy() -> String:
    var total = 0
    for weight in ENEMY_WEIGHTS.values():
        total += weight
    
    var roll = randi() % total
    var cumulative = 0
    
    for enemy_type in ENEMY_WEIGHTS:
        cumulative += ENEMY_WEIGHTS[enemy_type]
        if roll < cumulative:
            return enemy_type
    
    return "slime"
```

### Scene Files
Create matching .tscn files for each new enemy.

### Files to Create/Modify
1. NEW: `scenes/entities/enemies/bat.tscn`
2. NEW: `scripts/entities/enemies/bat.gd`
3. NEW: `scenes/entities/enemies/crab.tscn`
4. NEW: `scripts/entities/enemies/crab.gd`
5. MODIFY: `scripts/entities/enemies/enemy_spawner.gd` - spawn variety
