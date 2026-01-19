---
title: Boss Base Class & Framework
status: closed
priority: 2
issue-type: task
assignee: randroid
created-at: "2026-01-05T23:37:52.960919-06:00"
closed-at: "2026-01-19T01:55:08.713634-06:00"
---

# Boss Base Class & Framework

## Parent Epic
GoPit-6p4 (Phase 3 - Boss & Stages)

## Overview
Create a reusable boss base class with phase transitions, HP bars, attack patterns, and invulnerability windows.

## Requirements
1. BossBase extends EnemyBase with boss-specific features
2. Multi-phase boss fights (HP thresholds trigger phase changes)
3. Large HP bar displayed on screen
4. Telegraphed attacks with visual indicators
5. Invulnerability windows during phase transitions
6. Add spawning during fight
7. Victory/defeat handling

## Implementation Approach

### Boss State Machine
```gdscript
class_name BossBase
extends EnemyBase

enum BossPhase { INTRO, PHASE_1, PHASE_2, PHASE_3, DEFEATED }
enum AttackState { IDLE, TELEGRAPH, ATTACKING, COOLDOWN }

signal phase_changed(new_phase: BossPhase)
signal boss_defeated

var current_phase: BossPhase = BossPhase.INTRO
var attack_state: AttackState = AttackState.IDLE
var is_invulnerable: bool = false

# Phase thresholds (HP percentage)
var phase_thresholds := [1.0, 0.66, 0.33, 0.0]

func _ready() -> void:
    super._ready()
    _start_intro()

func take_damage(amount: int) -> void:
    if is_invulnerable:
        return
    super.take_damage(amount)
    _check_phase_transition()
```

### Attack Pattern System
```gdscript
# Each boss defines attack patterns per phase
var phase_attacks := {
    BossPhase.PHASE_1: ["slam", "summon"],
    BossPhase.PHASE_2: ["slam", "summon", "projectile"],
    BossPhase.PHASE_3: ["slam", "summon", "projectile", "rage"]
}

func _execute_attack(attack_name: String) -> void:
    attack_state = AttackState.TELEGRAPH
    _show_attack_telegraph(attack_name)
    await get_tree().create_timer(1.0).timeout
    
    attack_state = AttackState.ATTACKING
    match attack_name:
        "slam": _do_slam_attack()
        "summon": _do_summon_attack()
        "projectile": _do_projectile_attack()
        "rage": _do_rage_attack()
```

### HP Bar UI
```gdscript
# scenes/ui/boss_hp_bar.tscn
# Show at top of screen when boss active
func update_hp(current: int, max_val: int, boss_name: String) -> void:
    hp_bar.value = float(current) / max_val
    name_label.text = boss_name
    # Phase indicators
```

## Files to Create
- NEW: scripts/entities/enemies/boss_base.gd
- NEW: scenes/entities/enemies/boss_base.tscn
- NEW: scenes/ui/boss_hp_bar.tscn
- NEW: scripts/ui/boss_hp_bar.gd

## Acceptance Criteria
- [ ] BossBase class with phase system
- [ ] HP bar displays during boss fight
- [ ] Phase transitions at HP thresholds
- [ ] Invulnerability during transitions
- [ ] Attack telegraph system
- [ ] Add spawning capability
- [ ] Victory/defeat signals
