---
title: "First Boss: Slime King"
status: closed
priority: 2
issue-type: task
assignee: randroid
created-at: "2026-01-05T23:37:53.159092-06:00"
closed-at: "2026-01-19T01:55:07.663607-06:00"
---

# First Boss: Slime King

## Parent Epic
GoPit-6p4 (Phase 3 - Boss & Stages)

## Overview
Implement the first boss encounter - Slime King, appearing at Wave 10 of The Pit biome.

## Boss Design
**Slime King** - A massive slime that splits and slams

| Stat | Value |
|------|-------|
| HP | 500 (scales with wave) |
| Size | 3x regular slime |
| XP Value | 100 |

### Phase 1 (100%-66% HP)
- **Slam Attack**: Jumps and lands on player position, AoE damage
- **Spawn Minions**: Summons 2-3 regular slimes

### Phase 2 (66%-33% HP)
- All Phase 1 attacks + faster
- **Split**: Creates 2 medium slimes that must also be killed
- Medium slimes have 100 HP each

### Phase 3 (33%-0% HP)
- All previous attacks + enraged
- **Rage Mode**: Faster movement, more frequent attacks
- **Toxic Pool**: Leaves poison pools when moving

### Defeat
- Explodes into gems (100 XP worth)
- Drops guaranteed Fusion Reactor
- Stage complete announcement

## Visual Design
- Large green slime (3x scale)
- Crown on top (simple shape)
- Eyes that track player
- Color shifts with phase (green → yellow → red)
- Shake animation during slam telegraph

## Implementation
```gdscript
class_name SlimeKing
extends BossBase

func _ready() -> void:
    boss_name = "Slime King"
    max_hp = 500
    phase_thresholds = [1.0, 0.66, 0.33, 0.0]
    
func _do_slam_attack() -> void:
    # Telegraph: shadow appears at player position
    # Jump up (off screen briefly)
    # Land at telegraph position
    # AoE damage in radius
    pass

func _do_summon_attack() -> void:
    # Spawn 2-3 slimes at random positions
    pass

func _do_split_attack() -> void:
    # Create 2 medium slimes at boss position
    # Boss shrinks temporarily
    pass
```

## Files to Create
- NEW: scripts/entities/enemies/bosses/slime_king.gd
- NEW: scenes/entities/enemies/bosses/slime_king.tscn

## Dependencies
- Requires Boss Base Class (GoPit-xxx)

## Acceptance Criteria
- [ ] Slime King spawns at wave 10
- [ ] 3 distinct phases with different attacks
- [ ] Slam attack with telegraph
- [ ] Minion summoning works
- [ ] Split mechanic in Phase 2
- [ ] Drops fusion reactor on defeat
- [ ] Victory triggers stage progress
