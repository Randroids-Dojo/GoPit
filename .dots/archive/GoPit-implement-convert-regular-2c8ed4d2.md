---
title: "implement: Convert regular enemy extends to path-based"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-18T23:51:41.935183-06:00\\\"\""
closed-at: "2026-01-18T23:56:39.544306-06:00"
close-reason: Converted 7 regular enemy scripts to path-based extends. 541/549 tests pass (1 unrelated failure).
---

## Parent Epic
GoPit-u6z (Code Review Cleanup)

## Description

Convert regular enemy scripts from class_name extends to path-based extends for CI/headless compatibility.

## Context

BossBase and MiniBossBase correctly use path-based extends:
```gdscript
extends "res://scripts/entities/enemies/enemy_base.gd"
```

But regular enemies (archer, bat, bomber, crab, golem, slime, swarm) use class_name extends:
```gdscript
extends EnemyBase  # PROBLEMATIC
```

This can fail in CI/headless mode because Godot registers classes alphabetically by filename. Since archer.gd, bat.gd, bomber.gd all come before enemy_base.gd, they may try to resolve EnemyBase before it's registered.

## Affected Files

- scripts/entities/enemies/archer.gd
- scripts/entities/enemies/bat.gd
- scripts/entities/enemies/bomber.gd
- scripts/entities/enemies/crab.gd
- scripts/entities/enemies/golem.gd
- scripts/entities/enemies/slime.gd
- scripts/entities/enemies/swarm.gd

## Implementation

Change line 2 of each file from:
```gdscript
extends EnemyBase
```
to:
```gdscript
extends "res://scripts/entities/enemies/enemy_base.gd"
```

## Verify

- [ ] `./test.sh` passes
- [ ] No scripts extend EnemyBase by class_name
- [ ] grep shows only path-based extends for custom classes
