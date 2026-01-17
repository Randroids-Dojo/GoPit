---
title: Expand upgrade variety to 8+ types
status: done
priority: 2
issue-type: feature
assignee: randroid
created-at: 2026-01-05T01:48:09.081238-06:00
---

## Problem
Only 3 upgrade types exist. All shown every level-up. No interesting choices or build diversity.

## Implementation Plan

### Phase 1: Expand Upgrade Data
**Modify: `scripts/ui/level_up_overlay.gd`**

```gdscript
enum UpgradeType {
    DAMAGE,
    FIRE_RATE,
    MAX_HP,
    MULTI_SHOT,
    BALL_SPEED,
    PIERCING,
    RICOCHET,
    CRITICAL,
    MAGNETISM,
    HEAL
}

const UPGRADE_DATA := {
    UpgradeType.DAMAGE: {
        "name": "Power Up",
        "description": "+5 Ball Damage",
        "icon": "⚔️",
        "apply": "_apply_damage_upgrade",
        "max_stacks": 10
    },
    UpgradeType.FIRE_RATE: {
        "name": "Quick Fire",
        "description": "-0.1s Cooldown",
        "icon": "⚡",
        "apply": "_apply_fire_rate_upgrade",
        "max_stacks": 4  # Min cooldown 0.1s
    },
    UpgradeType.MAX_HP: {
        "name": "Vitality",
        "description": "+25 Max HP",
        "icon": "❤️",
        "apply": "_apply_hp_upgrade",
        "max_stacks": 10
    },
    UpgradeType.MULTI_SHOT: {
        "name": "Multi Shot",
        "description": "Fire 2 balls (spread)",
        "icon": "🔱",
        "apply": "_apply_multi_shot",
        "max_stacks": 3  # Up to 4 balls
    },
    UpgradeType.BALL_SPEED: {
        "name": "Velocity",
        "description": "+100 Ball Speed",
        "icon": "💨",
        "apply": "_apply_speed_upgrade",
        "max_stacks": 5
    },
    UpgradeType.PIERCING: {
        "name": "Piercing",
        "description": "Ball pierces 1 enemy",
        "icon": "🎯",
        "apply": "_apply_piercing",
        "max_stacks": 3
    },
    UpgradeType.RICOCHET: {
        "name": "Ricochet",
        "description": "+2 wall bounces",
        "icon": "↩️",
        "apply": "_apply_ricochet",
        "max_stacks": 5
    },
    UpgradeType.CRITICAL: {
        "name": "Critical Hit",
        "description": "10% chance 2x damage",
        "icon": "💥",
        "apply": "_apply_critical",
        "max_stacks": 5  # Up to 50%
    },
    UpgradeType.MAGNETISM: {
        "name": "Magnetism",
        "description": "Gems attracted to you",
        "icon": "🧲",
        "apply": "_apply_magnetism",
        "max_stacks": 3
    },
    UpgradeType.HEAL: {
        "name": "Heal",
        "description": "Restore 30 HP",
        "icon": "💚",
        "apply": "_apply_heal",
        "max_stacks": 99  # Always available
    }
}

var upgrade_stacks: Dictionary = {}  # Track how many times each upgrade taken

func _randomize_upgrades() -> void:
    _available_upgrades.clear()
    var pool: Array[UpgradeType] = []
    
    # Add upgrades that haven't hit max stacks
    for upgrade_type in UPGRADE_DATA:
        var data = UPGRADE_DATA[upgrade_type]
        var current_stacks = upgrade_stacks.get(upgrade_type, 0)
        if current_stacks < data.get("max_stacks", 99):
            pool.append(upgrade_type)
    
    pool.shuffle()
    _available_upgrades = pool.slice(0, 3)
```

### Phase 2: New Upgrade Implementations
**Modify: `scripts/entities/ball_spawner.gd`**

```gdscript
var ball_count: int = 1
var ball_spread: float = 0.0

func fire() -> void:
    for i in range(ball_count):
        var spread_offset = (i - (ball_count - 1) / 2.0) * ball_spread
        var dir = aim_direction.rotated(spread_offset)
        _spawn_ball(dir)

func add_multi_shot():
    ball_count += 1
    ball_spread = 0.15  # radians between balls
```

**Modify: `scripts/entities/ball.gd`**

```gdscript
var pierce_count: int = 0
var max_bounces: int = 10  # Default wall bounces
var crit_chance: float = 0.0

func _on_hit_enemy(enemy):
    var actual_damage = damage
    if randf() < crit_chance:
        actual_damage *= 2
        # Visual crit indicator
    
    enemy.take_damage(actual_damage)
    
    if pierce_count > 0:
        pierce_count -= 1
        # Don't bounce, continue through
    else:
        direction = direction.bounce(collision_normal)
```

### Phase 3: Magnetism System
**Modify: `scripts/entities/gem.gd`**

```gdscript
var magnetism_range: float = 0.0  # Set by GameManager
var magnetism_speed: float = 500.0

func _physics_process(delta):
    if magnetism_range > 0:
        var player_zone_y = 1200  # Player zone Y position
        var distance_to_zone = player_zone_y - global_position.y
        
        if distance_to_zone < magnetism_range:
            # Accelerate toward player zone
            var pull_strength = 1.0 - (distance_to_zone / magnetism_range)
            fall_speed = lerp(fall_speed, magnetism_speed, pull_strength * delta * 5)
```

### Files to Modify
1. MODIFY: `scripts/ui/level_up_overlay.gd` - expand upgrade data
2. MODIFY: `scripts/entities/ball_spawner.gd` - multi-shot support
3. MODIFY: `scripts/entities/ball.gd` - pierce, crit, bounce tracking
4. MODIFY: `scripts/entities/gem.gd` - magnetism attraction
5. MODIFY: `scripts/autoload/game_manager.gd` - store upgrade stats

### Testing
- Verify 3 random upgrades shown each level-up
- Verify max stack limits work
- Verify each upgrade applies correctly
- Test upgrade synergies (multi-shot + piercing)
