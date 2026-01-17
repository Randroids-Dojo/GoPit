---
title: Consolidate hardcoded scene paths to use groups
status: open
priority: 1
issue-type: bug
assignee: randroid
created-at: 2026-01-08T19:57:14.902458-06:00
---

7 instances use hardcoded paths like get_tree().current_scene.get_node_or_null('GameArea/Enemies'). Should use group-based lookups like get_tree().get_first_node_in_group('enemies_container') for consistency and refactoring safety. Files: ball.gd:299-302,371-373, status_effect.gd
