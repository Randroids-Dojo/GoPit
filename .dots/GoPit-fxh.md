---
title: Add passive ability validation logging
status: closed
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-08T19:57:15.816043-06:00
closed-at: 2026-01-18
---

## Description

~~Add validation logging when passive ability names don't match known passives.~~

## Status: ALREADY IMPLEMENTED

After code review, validation logging is already implemented in `game_manager.gd:368-378`:

```gdscript
func _set_passive_from_name(passive_name: String) -> void:
    if passive_name.is_empty():
        active_passive = Passive.NONE
        return

    if passive_name in VALID_PASSIVES:
        active_passive = VALID_PASSIVES[passive_name]
    else:
        # Log warning for unrecognized passive name (likely a typo in Character resource)
        push_warning("GameManager: Unrecognized passive name '%s'. Check Character resource for typos. Valid passives: %s" % [passive_name, VALID_PASSIVES.keys()])
        active_passive = Passive.NONE
```

The warning includes:
- The unrecognized passive name
- A list of valid passive names for easy comparison

## Resolution

Already implemented. Closing as complete.
