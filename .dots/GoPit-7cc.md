---
title: Add visual feedback for DoT damage
status: open
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-08T19:57:15.585949-06:00
---

enemy_base.gd:366-372 - _take_dot_damage() only spawns small damage number. No hit flash, particles, or screen shake. Makes DoT feel less impactful than direct damage.
