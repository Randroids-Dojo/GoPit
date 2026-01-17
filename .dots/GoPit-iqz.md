---
title: Fix void ball alternation state bug
status: open
priority: 1
issue-type: bug
assignee: randroid
created-at: 2026-01-08T19:57:15.135295-06:00
---

ball.gd:521-534 - _void_use_burn is per-ball instance. With multiple void balls hitting enemies in same frame, alternation becomes inconsistent. Fix: Use counter-based approach or per-enemy tracking.
