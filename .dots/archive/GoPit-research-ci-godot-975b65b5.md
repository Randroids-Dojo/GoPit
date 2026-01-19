---
title: "research: CI Godot version upgrade from 4.4.1 to 4.5+"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-19T11:15:25.299088-06:00\\\"\""
closed-at: "2026-01-19T11:16:33.535319-06:00"
close-reason: Research complete. Created implementation spec GoPit-implement-update-ci-0cb84250 for CI Godot version upgrade.
---

## Context

The project's `project.godot` requires Godot 4.5 (`config/features=PackedStringArray("4.5", "GL Compatibility")`), but CI workflows use Godot 4.4.1 for web export builds. This version mismatch is documented in `docs/known-issues.md` as a TODO.

## Research Questions

1. Is Godot 4.5.x stable released?
2. Does the `chickensoft-games/setup-godot` action support 4.5.x?
3. Are there breaking changes between 4.4.1 and 4.5.x that affect the project?
4. What is the recommended upgrade path?

## Findings

### Godot 4.5 Release Status

**Godot 4.5.1-stable** was released on October 15, 2025. This is a maintenance release fixing stability and usability issues. The project can safely upgrade to this version.

Sources:
- [Godot 4.5 Released - GameFromScratch](https://gamefromscratch.com/godot-4-5-released/)
- [Godot Releases - GitHub](https://github.com/godotengine/godot/releases)

### CI Action Support

The `chickensoft-games/setup-godot@v2` action supports flexible Godot 4.x versioning:
- Version format: `4.5.1` (or `4.5.1-stable`)
- Simply update the `version` parameter in CI workflow

### Affected Files

`.github/workflows/ci.yml`:
- Line 91: `version: 4.4.1` (build-and-deploy job)
- Line 174: `version: 4.4.1` (preview-deploy job)

### Breaking Changes Assessment

Reviewed the project's compatibility:
- Project uses `gl_compatibility` renderer (supported in both versions)
- No C#/.NET code (avoids potential SDK mismatches)
- Scene format should be forwards-compatible (4.4.1 -> 4.5.x)

**Risk: LOW** - The upgrade is straightforward.

### Recommendation

Create an implementation spec to:
1. Update CI workflow version from `4.4.1` to `4.5.1`
2. Verify web export still works
3. Update `docs/known-issues.md` to mark this resolved

## Deliverable

Created: GoPit-implement-update-ci-godot-version
