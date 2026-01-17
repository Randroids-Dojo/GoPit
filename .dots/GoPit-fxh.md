---
title: Add passive ability validation logging
status: open
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-08T19:57:15.816043-06:00
---

game_manager.gd:150-165 - Passive names matched via string comparison. Typo in Character resource passive_name field breaks abilities silently. Add validation/logging to warn on mismatch.
