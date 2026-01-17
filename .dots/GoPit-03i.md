---
title: Complete character speed stat implementation
status: open
priority: 2
issue-type: bug
assignee: randroid
created-at: 2026-01-08T19:57:15.362181-06:00
---

Speed stat only affects player movement (player.gd:30). Missing from: ball firing speed, baby ball speed, enemy scaling. Commit 963fb50 said 'Speed: Player movement now uses character_speed_mult' but this is incomplete.
