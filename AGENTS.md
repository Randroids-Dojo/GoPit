# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

---

## IMPORTANT: PlayGodot Testing (Read First!)

**This project uses PlayGodot for testing, NOT GdUnit4.**

PlayGodot is a game automation framework (like Playwright for games) that runs tests from Python, controlling a custom Godot fork with automation support.

### Quick Test Command

```bash
./test.sh                    # Run all tests
./test.sh tests/test_fire.py # Run specific file
```

Or manually:
```bash
source .venv/bin/activate
python3 -m pytest tests/ -v --tb=short
```

### If Tests Fail to Start

If you see "GODOT AUTOMATION FORK NOT FOUND":

1. **Check sibling directory**: The Godot fork should be at `../godot/bin/`
2. **Or create config file**: `echo '/path/to/godot/bin/godot.macos.editor.arm64' > .godot-path`
3. **Or set env var**: `export GODOT_PATH=/path/to/godot`

See [TESTING.md](TESTING.md) for full setup instructions.

---

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Testing Requirements

**CRITICAL: All code changes MUST be validated with PlayGodot tests before committing.**

### Running Tests

```bash
# Run all PlayGodot tests
./test.sh

# Or with pytest directly
python3 -m pytest tests/ -v --tb=short

# Run specific test file
python3 -m pytest tests/test_fire.py -v

# Run comprehensive playtest
python3 -m pytest tests/test_comprehensive_playtest.py -v
```

### Test Coverage Expectations

When implementing new features, you MUST:

1. **Run existing tests** to ensure no regressions
2. **Write new tests** for significant gameplay changes:
   - New mechanics (enemies, weapons, upgrades)
   - UI interactions (buttons, overlays)
   - Game state changes (level-up, game over)
3. **Update existing tests** if behavior changes intentionally

### Writing PlayGodot Tests

Tests live in `tests/` directory. Use this pattern:

```python
import asyncio
import pytest

@pytest.mark.asyncio
async def test_my_feature(game):
    """Test description."""
    # Interact with game
    await game.click("/root/Game/UI/SomeButton")
    await asyncio.sleep(0.2)

    # Verify results
    result = await game.call("/root/Game/SomeNode", "some_method")
    assert result == expected_value
```

### Common Node Paths

```python
PATHS = {
    "game": "/root/Game",
    "fire_button": "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton",
    "balls": "/root/Game/GameArea/Balls",
    "enemies": "/root/Game/GameArea/Enemies",
    "gems": "/root/Game/GameArea/Gems",
    "game_over_overlay": "/root/Game/UI/GameOverOverlay",
    "level_up_overlay": "/root/Game/UI/LevelUpOverlay",
}
```

### PlayGodot API Quick Reference

```python
# Click on UI element or coordinates
await game.click("/root/Game/UI/Button")
await game.click(300, 200)

# Call methods on nodes
result = await game.call("/root/Node", "method_name", [arg1, arg2])

# Get/set properties (returns dict for Vector2, e.g., {'x': 1.0, 'y': 2.0})
value = await game.get_property("/root/Node", "property_name")

# Get node info
node = await game.get_node("/root/Game")

# Wait for game state
await asyncio.sleep(0.5)
```

### Pre-Commit Checklist

Before committing ANY code changes:

- [ ] `python3 -m pytest tests/ -v` - All tests pass
- [ ] New features have corresponding tests
- [ ] No test regressions introduced

## Godot UI Best Practices

When creating UI overlays and panels:

1. **Overlay mouse_filter**: Visual-only overlays (like locked indicators, dim backgrounds) should use `mouse_filter = 2` (MOUSE_FILTER_IGNORE) so clicks pass through to interactive elements below.
   ```
   # In .tscn files:
   mouse_filter = 2

   # In GDScript:
   overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
   ```

2. **Common mouse_filter values**:
   - `0` (STOP) - Captures mouse events, doesn't propagate (default for buttons)
   - `1` (PASS) - Processes events but also passes to parent
   - `2` (IGNORE) - Ignores mouse events entirely (use for visual-only elements)

3. **Test UI interactions**: When adding overlays, verify that buttons/controls underneath remain clickable.

## Parallel Test Execution

PlayGodot tests now support **automatic parallel execution** via dynamic port allocation.

### How It Works

Each test session automatically gets a unique port:

1. **PLAYGODOT_PORT env var** - Explicit override (highest priority)
2. **pytest-xdist worker ID** - For parallel workers within a session
3. **Dynamic free port** - Auto-allocated for cross-session safety

### Running Tests in Parallel

```bash
# Sequential (auto port)
pytest tests/ -v

# Parallel within session (requires: pip install pytest-xdist)
pytest tests/ -n 4

# Multiple sessions (each gets unique port automatically)
# Terminal 1: pytest tests/test_fire.py -v
# Terminal 2: pytest tests/test_autofire.py -v

# Explicit port override
PLAYGODOT_PORT=7000 pytest tests/ -v
```

### Troubleshooting

If you encounter stale Godot processes:
```bash
pgrep -f godot        # Check for running Godot processes
pkill -9 -f godot     # Kill stale processes
```

## CI Monitoring (Automatic)

Claude Code automatically monitors GitHub Actions CI after:
1. **Creating a PR** (`gh pr create`) - monitors PR checks
2. **Merging a PR** (`gh pr merge`) - monitors deployment on main
3. **Pushing to main** (`git push origin main`) - monitors deployment

### How It Works

A PostToolUse hook (`.claude/hooks/monitor-ci.py`) triggers after Bash commands:
- Detects PR creation or main branch pushes
- Polls `gh pr checks` or `gh run list` every 30 seconds
- 15-minute timeout
- **On failure: blocks with exit code 2** - forces proper fix

### Behavior

- CI failures **block further work** until properly resolved
- No bypassing, hack fixes, or ignoring issues allowed
- Work is not considered complete until CI passes
- Deployment must succeed after merging to main

### Manual CI Check

If needed, check CI status manually:
```bash
# Check PR checks
gh pr checks <PR_NUMBER>

# Watch workflow run
gh run watch

# View failed logs
gh run view <RUN_ID> --log-failed
```

## Godot Class Loading in CI/Headless Mode

**CRITICAL: Read this before creating ANY new GDScript that extends another custom class!**

### The Problem

Godot registers `class_name` declarations **alphabetically by filename** during headless/CI builds. This means a child class may be registered BEFORE its parent class, causing "Could not resolve class" errors.

**This is NOT a bug you can debug locally** - the Godot editor caches class relationships, hiding the issue. It only manifests in:
- Fresh CI builds (no `.godot` cache)
- Headless Godot execution
- First run after deleting `.godot` directory

### Rule 1: Always Use Path-Based Extends for Custom Classes

```gdscript
# ❌ BAD - class_name reference fails if parent not registered yet
extends MyParentClass

# ✅ GOOD - explicit path forces correct load order
extends "res://scripts/path/to/my_parent_class.gd"
```

**Apply this to EVERY script that extends another custom class (not built-ins like Node2D, Control, etc.)**

### Rule 2: Never Preload Scenes with Inherited Scripts in _ready()

```gdscript
# ❌ BAD - preload runs during parse, before classes fully registered
var my_scene: PackedScene = preload("res://scenes/my_scene.tscn")

# ✅ GOOD - lazy load only when needed
var my_scene: PackedScene

func _some_function_that_needs_scene():
    if not my_scene:
        my_scene = load("res://scenes/my_scene.tscn")
```

**Why?** `preload()` executes during script parsing. If the scene's script has unresolved inheritance, it fails silently and can break game initialization in subtle ways.

### Rule 3: Check the Entire Inheritance Chain

If you have `A extends B extends C extends Node2D`:
- `C` extends `Node2D` (built-in) → OK to use class name
- `B` extends `C` → MUST use path: `extends "res://path/to/c.gd"`
- `A` extends `B` → MUST use path: `extends "res://path/to/b.gd"`

### Debugging CI Failures

1. **Error signature:**
   ```
   SCRIPT ERROR: Parse Error: Could not resolve class "ClassName"
   ```

2. **Find problematic extends:**
   ```bash
   # Find all class_name extends (potential issues)
   grep -rn "^extends [A-Z]" scripts/ --include="*.gd"
   ```

3. **Check CI logs for registration order:**
   Look for `update_scripts_classes` - classes listed alphabetically.

### Checklist for New Scripts

When creating a script that extends a custom class:

- [ ] Use `extends "res://full/path/to/parent.gd"` (not `extends ClassName`)
- [ ] Verify parent class also uses path-based extends (whole chain!)
- [ ] If scene uses this script, use `load()` not `preload()` where loaded
- [ ] CI passes (local tests with cached `.godot` don't catch this!)

### Why This Happens

Godot 4.x processes scripts in this order during `--import`:
1. Scan filesystem
2. Register class_names **alphabetically by path**
3. Parse script contents
4. Resolve inheritance

Step 2 happens before step 4, so `boss_base.gd` (alphabetically first) tries to resolve `EnemyBase` before `enemy_base.gd` has been processed.

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

