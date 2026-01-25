# PlayGodot Testing Guide

This project uses **PlayGodot** for automated E2E game testing - like Playwright but for Godot games.

**Important:** This project does NOT use GdUnit4. All tests run via PlayGodot from Python.

## Quick Start

```bash
# Run all tests
./test.sh

# Or manually
source .venv/bin/activate
python3 -m pytest tests/ -v --tb=short
```

## Prerequisites

### 1. Python Virtual Environment

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install playgodot pytest pytest-asyncio
```

### 2. Godot Automation Fork

PlayGodot requires a custom Godot build with automation support. The test framework auto-discovers it in this order:

1. `GODOT_PATH` environment variable
2. `.godot-path` file in project root (gitignored)
3. `../godot/bin/godot.*` (sibling directory)
4. Well-known locations (`~/Documents/Dev/Godot/godot/bin/`)

**To configure manually:**

```bash
# Option 1: Local config file (recommended)
echo '/path/to/godot/bin/godot.macos.editor.arm64' > .godot-path

# Option 2: Environment variable
export GODOT_PATH=/path/to/godot/bin/godot.macos.editor.arm64
```

### Building the Godot Fork (if needed)

```bash
git clone https://github.com/Randroids-Dojo/godot.git ../godot
cd ../godot && git checkout automation

# macOS Apple Silicon
scons platform=macos arch=arm64 target=editor -j8

# macOS Intel
scons platform=macos arch=x86_64 target=editor -j8

# Linux
scons platform=linuxbsd target=editor -j8
```

## Running Tests

```bash
# All tests
./test.sh

# Specific file
python3 -m pytest tests/test_fire.py -v

# Single test
python3 -m pytest tests/test_fire.py::test_fire_once -v

# Pattern matching
python3 -m pytest tests/ -k "fire" -v

# Parallel execution (requires pytest-xdist)
pip install pytest-xdist
python3 -m pytest tests/ -n 4 -v
```

## Writing Tests

Tests use pytest with async support:

```python
import asyncio
import pytest

@pytest.mark.asyncio
async def test_example(game):
    """The 'game' fixture provides a connected PlayGodot instance."""

    # Click UI elements
    await game.click("/root/Game/UI/Button")
    await asyncio.sleep(0.2)

    # Call methods on nodes
    result = await game.call("/root/Game/Node", "method_name")

    # Get/set properties
    value = await game.get_property("/root/Game/Node", "property")

    # Assertions
    assert result == expected_value
```

## CRITICAL: Sleep After State Changes

**Always add `await asyncio.sleep(0.1)` after any state-modifying call.**

Godot autoloads connect to signals like `game_started` that can fire during tests. Without sleeps, these signals can race with your test code and reset state unexpectedly.

```python
# ❌ BAD - race condition with game_started signal
await game.call("BallRegistry", "reset")
await game.call("BallRegistry", "level_up_ball", [0])
speed = await game.call("BallRegistry", "get_speed", [0])
# May get L1 speed (800) instead of L2 speed (1200)!

# ✅ GOOD - sleeps prevent race conditions
await game.call("BallRegistry", "reset")
await asyncio.sleep(0.1)  # Let reset complete

await game.call("BallRegistry", "level_up_ball", [0])
await asyncio.sleep(0.1)  # Let level up process

speed = await game.call("BallRegistry", "get_speed", [0])
assert speed == 1200.0  # Correctly gets L2 speed
```

**Calls that need sleeps:**
- `reset()` - Registry/manager resets
- `add_ball()`, `level_up_ball()` - Ball state changes
- `set_property()` - Property changes
- `emit_signal()` - Signal triggers
- Any method that modifies game state

See [AGENTS.md](AGENTS.md) for comprehensive test isolation guidelines.

## Common Node Paths

```python
PATHS = {
    "game": "/root/Game",
    "fire_button": "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton",
    "balls": "/root/Game/GameArea/Balls",
    "enemies": "/root/Game/GameArea/Enemies",
    "gems": "/root/Game/GameArea/Gems",
    "game_over": "/root/Game/UI/GameOverOverlay",
    "level_up": "/root/Game/UI/LevelUpOverlay",
}
```

## Troubleshooting

### "GODOT AUTOMATION FORK NOT FOUND"

The test framework couldn't find the Godot binary. Fix:

```bash
# Create .godot-path with the correct path
echo '/full/path/to/godot/bin/godot.macos.editor.arm64' > .godot-path
```

### Connection timeout / tests hang

Kill any stale Godot processes:

```bash
pkill -9 -f godot
```

### Port conflicts

Tests use dynamic port allocation, but if you see port errors:

```bash
# Check what's using ports
lsof -i :6007

# Force a specific port
PLAYGODOT_PORT=7000 python3 -m pytest tests/ -v
```

## Worktrees

The `.godot-path` configuration works in worktrees. Each worktree can have its own `.godot-path` file, or they can share the same Godot binary via:

1. Environment variable (`export GODOT_PATH=...` in shell profile)
2. Sibling directory (if worktrees are in same parent folder as `godot/`)
