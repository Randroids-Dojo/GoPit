---
title: "research: Audit feature branches for cleanup or unmerged work"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T12:03:22.064602-06:00"
---

## Description

There are 100+ feature branches in the repository. With all 5 development phases complete, many of these are likely:
1. **Merged to main** - Can be safely deleted
2. **Superseded** - Work was implemented differently
3. **Abandoned** - Never completed, can be deleted
4. **Valuable unmerged** - Contains work worth extracting

## Context

Running `git branch -r | grep feature | wc -l` shows ~70 remote feature branches. Most are 1-5 commits ahead of main.

## Questions to Answer

1. Which branches have work that was never merged?
2. Are any of those unmerged commits valuable features that should be added?
3. Which branches can be safely deleted (already merged or abandoned)?
4. Should we create a branch cleanup script?

## Expected Deliverables

- List of branches categorized by status (merged, superseded, abandoned, valuable)
- `implement:` tasks for any valuable unmerged features
- `implement:` task for branch cleanup with list of branches to delete
