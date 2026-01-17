---
title: Increase ball size slightly (radius 12→14px)
status: done
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-06T22:41:21.791649-06:00
---

Slight increase to ball visibility while keeping smaller than player.

## Changes
- ball.tscn: CircleShape2D radius 12→14
- ball.gd: radius export 12→14
- Level size multipliers remain same (1.0/1.1/1.2)

## Result
Balls 28px diameter at L1, up to 33.6px at L3 - visible but not overwhelming
