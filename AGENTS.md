# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

## Godot UI Best Practices

### Mouse/Touch Event Handling

**CRITICAL**: When creating overlay UI elements (tutorials, popups, HUD elements), you MUST explicitly set `mouse_filter` on ALL Control nodes to prevent blocking input to elements underneath.

```
mouse_filter values:
- 0 (MOUSE_FILTER_STOP)   - Captures events, blocks pass-through (DEFAULT for Control nodes!)
- 1 (MOUSE_FILTER_PASS)   - Receives events AND passes to nodes below
- 2 (MOUSE_FILTER_IGNORE) - Ignores events, passes to nodes below
```

**Rules:**
1. **Overlay containers** (ColorRect backgrounds, Panel, etc.) should use `mouse_filter = 2` unless they need to block interaction
2. **ALL child Control nodes** inherit default `MOUSE_FILTER_STOP` - you must explicitly set `mouse_filter = 2` on each one that shouldn't capture input
3. **When positioning UI over interactive elements** (buttons, joysticks), verify the overlay and ALL its children have appropriate mouse_filter settings
4. **Test on mobile** - touch events behave the same as mouse but bugs are more noticeable when you can't click around an overlay

**Common mistake:**
```gdscript
# Parent has mouse_filter = 2, but child Control still blocks!
[node name="Overlay" type="ColorRect"]
mouse_filter = 2  # Good

[node name="ChildControl" type="Control" parent="Overlay"]
# BAD: No mouse_filter set, defaults to STOP and blocks input!
```

**Correct:**
```gdscript
[node name="ChildControl" type="Control" parent="Overlay"]
mouse_filter = 2  # Explicitly set to IGNORE
```

