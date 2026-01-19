---
title: "implement: Clean up stale salvo-firing branch and worktree"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-19T11:46:28.074547-06:00\\\"\""
closed-at: "2026-01-19T12:01:41.126814-06:00"
close-reason: "Removed worktree and deleted branch feature/salvo-firing from local and remote. Verification: directory gone, not in git branch -a, not in git worktree list."
---

## Description

Remove the stale `feature/salvo-firing` branch and its associated worktree directory since the Ultimate Ability feature has been fully extracted to main.

## Context

The salvo-firing branch is 87 commits behind main and contains only 5 unique commits, mostly related to 'salvo-based ball firing' mechanics that were intentionally not merged. The Ultimate Ability feature was extracted to main separately and is now fully working with all 12 tests passing.

## Affected Files

- Delete: `GoPit-salvo-firing/` directory (git worktree)
- Delete: `feature/salvo-firing` branch (local + remote)

## Implementation

```bash
# Remove the worktree first
git worktree remove GoPit-salvo-firing --force

# Delete local branch
git branch -D feature/salvo-firing

# Delete remote branch
git push origin --delete feature/salvo-firing
```

## Verify

- [ ] `GoPit-salvo-firing/` directory no longer exists
- [ ] `git branch -a` does not list feature/salvo-firing
- [ ] `git worktree list` does not show GoPit-salvo-firing
