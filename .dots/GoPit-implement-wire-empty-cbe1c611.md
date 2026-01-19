---
title: "implement: Wire Empty Nester 2x specials to ultimate ability"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T10:04:48.763044-06:00"
---

## Description

The Empty Nester passive should double the ultimate ability effect, but it's not currently wired up.

## Context

`GameManager.get_special_fire_multiplier()` (line 617 in game_manager.gd) returns 2 for Empty Nester, but `_on_ultimate_activated()` in game_controller.gd doesn't use it.

## Affected Files

- **MODIFY**: `scripts/game/game_controller.gd` (salvo-firing branch) - Update `_on_ultimate_activated()`

## Implementation

Option A - Fire blast twice:
```gdscript
func _on_ultimate_activated() -> void:
    var blast_scene: PackedScene = load("res://scenes/effects/ultimate_blast.tscn")
    var multiplier: int = GameManager.get_special_fire_multiplier()
    for i in range(multiplier):
        var blast: Node2D = blast_scene.instantiate()
        add_child(blast)
        blast.execute()
        if i < multiplier - 1:
            await get_tree().create_timer(0.2).timeout  # Brief delay between blasts
```

Option B - Pass damage multiplier to blast:
Modify `ultimate_blast.gd` to accept a damage multiplier parameter and deal 9999 * multiplier damage.

## Verify

- [ ] `./test.sh` passes in salvo-firing worktree
- [ ] Select Empty Nester character and charge ultimate
- [ ] Activate ultimate - effect should trigger twice (or deal 2x damage)
- [ ] Other characters still trigger single ultimate effect

