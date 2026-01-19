---
title: Fix void ball alternation state bug
status: open
priority: 1
issue-type: bug
assignee: randroid
created-at: 2026-01-08T19:57:15.135295-06:00
---

## Parent Epic
GoPit-u6z (Code Review Cleanup)

## Description

Fix void ball effect alternation so it works consistently with multiple void balls hitting enemies in the same frame.

## Context

Void balls alternate between burn and freeze effects. The current implementation uses a static boolean `_void_use_burn` that is toggled after each hit. When multiple void balls hit enemies in the same physics frame, each hit toggles the state leading to inconsistent alternation patterns (e.g., burn-burn-burn instead of burn-freeze-burn).

## Affected Files

- `scripts/entities/ball.gd:1156-1176` - `_void_use_burn` static var and `_do_void_effect()` function

## Current Implementation (Problematic)

```gdscript
static var _void_use_burn: bool = true

func _do_void_effect(enemy: Node2D) -> void:
    if enemy.has_method("apply_status_effect"):
        if _void_use_burn:
            enemy.apply_status_effect(StatusEffect.new(StatusEffect.Type.BURN))
        else:
            enemy.apply_status_effect(StatusEffect.new(StatusEffect.Type.FREEZE))
    _void_use_burn = not _void_use_burn
```

## Proposed Fix

Use an incrementing counter instead of boolean toggle:

```gdscript
static var _void_hit_count: int = 0

func _do_void_effect(enemy: Node2D) -> void:
    if enemy.has_method("apply_status_effect"):
        if _void_hit_count % 2 == 0:
            enemy.apply_status_effect(StatusEffect.new(StatusEffect.Type.BURN))
        else:
            enemy.apply_status_effect(StatusEffect.new(StatusEffect.Type.FREEZE))
    _void_hit_count += 1

    # Visual uses NEXT state (what will happen on next hit)
    var void_color := Color(0.3, 0.0, 0.5) if _void_hit_count % 2 == 0 else Color(0.0, 0.3, 0.5)
```

Counter approach is deterministic and produces consistent alternation regardless of timing.

## Verify

- [ ] `./test.sh` passes
- [ ] Spawn multiple void balls and verify burn/freeze effects alternate correctly
- [ ] Visual feedback color matches the effect that was applied (not next effect)
