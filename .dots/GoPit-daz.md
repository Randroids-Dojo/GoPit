---
title: Increase gem size (radius 8→14px)
status: done
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-06T22:41:21.129719-06:00
---

Make gems more visible and satisfying to collect.

## Changes
- gem.tscn: CircleShape2D radius 12→18 (collision)
- gem.gd: radius export 8→14 (visual)
- gem.gd: Adjust COLLECTION_RADIUS from 30→40
- gem.gd: Scale sparkle/glow effects proportionally

## Result
Gems will be ~3.9% of screen width (28px diameter) - much more visible
