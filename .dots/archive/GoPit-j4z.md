---
title: Enlarge TopBar and health bar
status: done
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-06T22:41:21.569742-06:00
---

Make HP bar more readable at a glance.

## Changes
- game.tscn TopBar: offset_bottom 70→90 (height 50→70px)
- game.tscn HPBar: Add custom_minimum_size height (e.g., 40px)
- game.tscn HPLabel: Increase font size if needed
- game.tscn PauseButton: Increase to 60x60

## Result
Health bar clearly visible, easier to track HP during gameplay
