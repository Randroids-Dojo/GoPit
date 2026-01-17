---
title: Increase enemy sizes (slime 20→28px, etc)
status: done
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-06T22:41:21.349177-06:00
---

Make enemies feel more threatening and visible.

## Changes
- slime.tscn: CircleShape2D radius 20→28
- bat.tscn: CircleShape2D radius 15→22
- crab.tscn: CapsuleShape2D radius 18→25, height 40→55
- Update visual rendering in enemy scripts if needed

## Result
Enemies ~7-8% of screen width, larger than player for threat presence
