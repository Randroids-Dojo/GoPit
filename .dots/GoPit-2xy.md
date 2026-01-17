---
title: Adjust UI positioning for new sizes
status: done
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-06T22:41:22.01272-06:00
---

Update positioning to accommodate larger elements.

## Changes
- game.tscn XPBarContainer: Adjust offset_top from -200 to -220
- game.tscn ComboLabel: Move offset_top from 400 to 480
- game.tscn DangerIndicator: Adjust offset_top from -220 to -240
- player.gd: Update bounds to match new TopBar height

## Dependencies
Should be done after TopBar and player size changes
