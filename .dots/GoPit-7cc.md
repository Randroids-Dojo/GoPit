---
title: Add visual feedback for DoT damage
status: closed
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-08T19:57:15.585949-06:00
closed-at: 2026-01-18
---

## Description

~~Add visual feedback for DoT (damage over time) effects to make them feel more impactful.~~

## Status: ALREADY IMPLEMENTED

After code review, the DoT feedback is already implemented in `enemy_base.gd`:

**`_take_dot_damage()` (line 655-670):**
- Flash effect via `_flash_dot()` - uses dominant effect color
- Screen shake via `CameraShake.shake(1.0, 10.0)` - subtle shake
- Damage numbers with color (orange: `Color(1, 0.5, 0.2)`)

**`_take_on_hit_damage()` (line 673-687):**
- Flash effect via `_flash_dot()` - effect-colored flash
- Screen shake via `CameraShake.shake(2.0, 8.0)` - moderate shake
- Damage numbers with bleed color (`Color(0.9, 0.2, 0.3)`)

**`_flash_dot()` (line 690-700):**
- Gets dominant effect color
- Lightens it for flash
- Tweens modulate property

## Resolution

The original issue cited incorrect line numbers and outdated information. DoT feedback is complete and working. Closing as already implemented.

## Note

The only potential improvement would be adding particle bursts on DoT ticks, but that could impact performance with many enemies. Consider this a "nice to have" rather than required.
