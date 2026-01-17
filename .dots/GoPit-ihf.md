---
title: Status Effect System
status: done
priority: 1
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:24:59.406832-06:00
---

# Status Effect System

## Parent Epic
GoPit-zxr (Phase 2 - Ball Evolution System)

## Overview
Implement a robust status effect system with 6 base effects that can be applied by balls and potentially combined.

## Current State
- ball.gd has BallType enum: NORMAL, FIRE, ICE, LIGHTNING
- _apply_ball_type_effect() has basic implementations
- Fire: visual tint only
- Ice: 50% slow for 1.5s
- Lightning: chain to 1 nearby enemy
- No formal status effect tracking on enemies

## Target Status Effects
| Effect | Damage | Duration | Visual | Special |
|--------|--------|----------|--------|---------|
| Burn | 5/sec | 3s | Orange particles | Stacks refresh |
| Freeze | 0 | 2s | Ice crystals | 50% slow |
| Poison | 3/sec | 5s | Green bubbles | Spreads on death |
| Bleed | 2/sec | ∞ | Red drips | Stacks up to 5x |
| Lightning | 0 | instant | Electric arc | Chain to 2 enemies |
| Iron | 0 | instant | None | +50% dmg, knockback |

## Requirements
1. StatusEffect base class for consistent behavior
2. Enemies can have multiple effects simultaneously
3. Effects have visual indicators on affected enemies
4. DoT effects tick at consistent intervals
5. Effect stacking rules (refresh vs stack)
6. Effect spreading (Poison on death)

## Implementation Approach

### Step 1: Create StatusEffect Base Class
```gdscript
# scripts/effects/status_effect.gd
class_name StatusEffect
extends RefCounted

enum Type { BURN, FREEZE, POISON, BLEED, LIGHTNING, IRON }

var type: Type
var duration: float
var damage_per_tick: float
var tick_interval: float = 0.5
var stacks: int = 1
var max_stacks: int = 1
var source: Node2D  # Ball that applied this

var _time_remaining: float
var _tick_timer: float

func _init(effect_type: Type) -> void:
    type = effect_type
    _configure_by_type()

func _configure_by_type() -> void:
    match type:
        Type.BURN:
            duration = 3.0
            damage_per_tick = 2.5  # 5 dps
            max_stacks = 1  # Refreshes duration
        Type.FREEZE:
            duration = 2.0
            damage_per_tick = 0
        Type.POISON:
            duration = 5.0
            damage_per_tick = 1.5  # 3 dps
            max_stacks = 1
        Type.BLEED:
            duration = INF  # Permanent until cleared
            damage_per_tick = 1.0  # 2 dps per stack
            max_stacks = 5
        Type.LIGHTNING:
            duration = 0  # Instant
        Type.IRON:
            duration = 0  # Instant

func apply(enemy: EnemyBase) -> void:
    _time_remaining = duration
    _tick_timer = 0
    _on_apply(enemy)

func update(delta: float, enemy: EnemyBase) -> bool:
    """Returns true if effect should continue, false if expired"""
    if duration <= 0:
        return false  # Instant effects don't persist
    
    _time_remaining -= delta
    _tick_timer += delta
    
    if _tick_timer >= tick_interval:
        _tick_timer = 0
        _on_tick(enemy)
    
    return _time_remaining > 0

func _on_apply(enemy: EnemyBase) -> void:
    match type:
        Type.FREEZE:
            enemy.apply_slow(0.5, duration)
        Type.IRON:
            # Knockback handled by ball collision

func _on_tick(enemy: EnemyBase) -> void:
    if damage_per_tick > 0:
        var total_damage := int(damage_per_tick * stacks)
        enemy.take_damage(total_damage)

func _on_expire(enemy: EnemyBase) -> void:
    match type:
        Type.POISON:
            _spread_poison(enemy)

func _spread_poison(enemy: EnemyBase) -> void:
    # Find nearby enemies and apply poison
    pass

func add_stack() -> void:
    stacks = mini(stacks + 1, max_stacks)

func refresh() -> void:
    _time_remaining = duration
```

### Step 2: Add Effect Manager to EnemyBase
```gdscript
# In enemy_base.gd
var _active_effects: Array[StatusEffect] = []

func apply_status_effect(effect: StatusEffect) -> void:
    # Check for existing effect of same type
    for existing in _active_effects:
        if existing.type == effect.type:
            if effect.max_stacks > 1:
                existing.add_stack()
            else:
                existing.refresh()
            return
    
    # New effect
    effect.apply(self)
    _active_effects.append(effect)
    _update_effect_visuals()

func _process_effects(delta: float) -> void:
    var expired: Array[StatusEffect] = []
    
    for effect in _active_effects:
        if not effect.update(delta, self):
            effect._on_expire(self)
            expired.append(effect)
    
    for effect in expired:
        _active_effects.erase(effect)
    
    if expired.size() > 0:
        _update_effect_visuals()

func _physics_process(delta: float) -> void:
    _process_effects(delta)
    # ... existing movement code ...
```

### Step 3: Visual Effect Indicators
```gdscript
func _update_effect_visuals() -> void:
    # Show icons/particles for active effects
    for effect in _active_effects:
        match effect.type:
            StatusEffect.Type.BURN:
                _show_burn_particles()
            StatusEffect.Type.FREEZE:
                modulate = Color(0.7, 0.9, 1.2)
            StatusEffect.Type.POISON:
                _show_poison_bubbles()
            StatusEffect.Type.BLEED:
                _show_bleed_drips(effect.stacks)
```

### Step 4: Update ball.gd to Use Effects
```gdscript
func _apply_ball_type_effect(enemy: Node2D, _base_damage: int) -> void:
    if not enemy is EnemyBase:
        return
    
    var effect: StatusEffect = null
    
    match ball_type:
        BallType.FIRE:
            effect = StatusEffect.new(StatusEffect.Type.BURN)
        BallType.ICE:
            effect = StatusEffect.new(StatusEffect.Type.FREEZE)
        BallType.LIGHTNING:
            _chain_lightning(enemy)  # Instant, no persist
        # Add more as implemented
    
    if effect:
        enemy.apply_status_effect(effect)
```

## Files to Create/Modify
- NEW: scripts/effects/status_effect.gd
- MODIFY: scripts/entities/enemies/enemy_base.gd
- MODIFY: scripts/entities/ball.gd
- NEW: scenes/effects/burn_particles.tscn
- NEW: scenes/effects/poison_bubbles.tscn

## Testing
```python
async def test_burn_deals_damage_over_time(game):
    """Burn effect should tick damage"""
    # Apply burn to enemy, track HP over 3 seconds
    pass

async def test_freeze_slows_enemy(game):
    """Freeze should reduce enemy speed"""
    pass

async def test_bleed_stacks(game):
    """Bleed should stack up to 5x"""
    pass

async def test_poison_spreads_on_death(game):
    """Poison should spread to nearby enemies on death"""
    pass
```

## Acceptance Criteria
- [ ] 6 status effects implemented
- [ ] DoT effects tick damage correctly
- [ ] Freeze slows enemy movement
- [ ] Bleed stacks up to 5x
- [ ] Poison spreads on enemy death
- [ ] Lightning chains to nearby enemies
- [ ] Visual indicators for each effect
- [ ] Multiple effects can be active simultaneously
