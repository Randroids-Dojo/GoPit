---
title: "research: Evaluate tutorial expansion needs"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T03:18:18.411577-06:00"
---

## Context

The existing tutorial (tutorial_overlay.gd) covers basic controls:
- MOVE - drag left joystick
- AIM - drag right joystick  
- FIRE - tap fire button
- HIT - hit enemies

## Research Questions

1. What additional tutorial steps might help new players?
   - Level-up system? (selecting upgrades)
   - Meta shop? (spending pit coins)
   - Autofire toggle?
   - Ultimate ability? (once implemented)

2. Are there common failure points for new players?
   - Review game over stats/analytics
   - Check player feedback if any

3. Should tutorial be skippable?
   - Currently auto-completes on first enemy hit
   - May be too brief for complex mechanics

## Affected Files
- scripts/ui/tutorial_overlay.gd
- scenes/ui/tutorial_overlay.tscn

## Deliverable
Create implement: spec for tutorial improvements if research shows they're needed.
