---
title: "implement: Update CI Godot version to 4.5.1"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T11:16:12.022246-06:00"
---

## Description

Update CI workflow to use Godot 4.5.1, matching the project's declared version requirement in `project.godot`. This resolves a known version mismatch that may cause scene format issues during web export.

## Context

- Project requires: `config/features=PackedStringArray("4.5", "GL Compatibility")`
- CI currently uses: `version: 4.4.1`
- Known issue documented in `docs/known-issues.md` under "CI/CD Godot Version Mismatch"
- Research confirmed Godot 4.5.1-stable is available and supported by the CI action

## Affected Files

1. `.github/workflows/ci.yml` - Two version updates needed
2. `docs/known-issues.md` - Update status of the known issue

## Implementation Notes

### Step 1: Update CI Workflow

In `.github/workflows/ci.yml`, update both occurrences of the Godot version:

**Line 91 (build-and-deploy job):**
```yaml
# Before:
version: 4.4.1

# After:
version: 4.5.1
```

**Line 174 (preview-deploy job):**
```yaml
# Before:
version: 4.4.1

# After:
version: 4.5.1
```

### Step 2: Update Known Issues

In `docs/known-issues.md`, update the "CI/CD Godot Version Mismatch" section:

Replace the TODO section with:
```markdown
### Status
- **Fixed** (2026-01-19) - Updated CI to use Godot 4.5.1 matching project requirements
```

### Alternative: Use Latest 4.5.x

If desired, could use `4.5` without the patch version to get latest 4.5.x bugfix releases automatically. However, pinning to `4.5.1` is more predictable for CI reproducibility.

## Verify

- [ ] `./test.sh` passes (tests are unchanged)
- [ ] Push to a PR branch and verify:
  - [ ] Preview deployment succeeds
  - [ ] Web export builds without errors
  - [ ] Preview URL loads and game plays correctly
- [ ] After merge, verify production deploy succeeds
