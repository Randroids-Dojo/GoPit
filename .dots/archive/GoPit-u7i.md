---
title: Increase player size (radius 20→35px)
status: done
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-06T22:41:20.916632-06:00
---

Increase player visibility for mobile play.

## Changes
- player.tscn: CircleShape2D radius 20→35
- player.gd: player_radius export 20→35
- player.gd: Adjust bounds_min.y from 200→280 (account for larger TopBar)
- player.gd: Adjust indicator_length proportionally

## Result
Player will be ~9.7% of screen width (70px diameter on 720px viewport)
