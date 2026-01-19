---
title: "implement: Add web export verification"
status: closed
priority: 3
issue-type: task
created-at: "\"2026-01-19T03:18:28.021657-06:00\""
closed-at: "2026-01-19T03:41:18.479964-06:00"
close-reason: Added verify_web_export.sh script and docs/web-testing-checklist.md. CI already has web export configured.
---

## Description

Create a CI job or local script to verify web export builds correctly.

## Context

The game should work in browsers (Chrome, Safari, Firefox). Need to verify:
1. Export produces valid build
2. Game loads without errors
3. Touch controls work
4. Audio plays (may have browser autoplay restrictions)

## Affected Files

- NEW: .github/workflows/web-export.yml (or extend existing CI)
- `export_presets.cfg` - ALREADY EXISTS with Web preset configured
- NEW: scripts/verify_web_export.sh (optional local testing script)

## Current State

Web export preset already configured in `export_presets.cfg`:
- Output: `build/index.html`
- Uses custom shell: `html/shell.html`
- VRAM compression for desktop enabled
- PWA disabled

## Implementation Notes

1. Web export preset already exists - just need CI verification
2. Add CI job that runs: `godot --headless --export-release "Web" ./build/web/index.html`
3. Optionally add basic smoke test (load page, check for errors)
4. Document manual testing checklist for browsers

### CI Job Template

```yaml
web-export:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Setup Godot
      # Use appropriate action to install Godot
    - name: Export Web Build
      run: godot --headless --export-release "Web" ./build/web/index.html
    - name: Upload artifact
      uses: actions/upload-artifact@v4
      with:
        name: web-build
        path: build/web/
```

## Verify

- [ ] ./test.sh passes
- [ ] CI job exports web build without errors
- [ ] Manual test: game loads in Chrome
- [ ] Manual test: game loads in Safari
- [ ] Manual test: game loads in Firefox
- [ ] Touch controls responsive on mobile browser
