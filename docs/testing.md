# Testing GoPit with PlayGodot

This document explains how to run automated tests for GoPit using [PlayGodot](https://github.com/Randroids-Dojo/PlayGodot).

## Overview

PlayGodot enables external testing of Godot games via Python. It connects to a custom Godot fork that includes automation protocol support, allowing you to:

- Launch games headlessly
- Query the scene tree
- Call methods on nodes
- Simulate input
- Verify game state

## Prerequisites

### 1. Install PlayGodot Python Library

```bash
pip3 install /path/to/PlayGodot/python
# Or if PlayGodot is in the parent directory:
pip3 install ../PlayGodot/python
```

### 2. Get the Godot Automation Fork

The tests require a custom Godot build with automation protocol support. Download from GitHub Actions:

```bash
# List recent automation builds
gh run list -R Randroids-Dojo/godot --branch automation -w "Build Godot Automation" --limit 5

# Download macOS binary (replace RUN_ID with actual ID)
gh run download RUN_ID -R Randroids-Dojo/godot -n macos-editor -D /tmp/godot-automation-build
```

The binary will be at `/tmp/godot-automation-build/godot.macos.editor.universal`.

## Running Tests

### Quick Start

```bash
python3 tests/launch_and_fire.py
```

### Expected Output

```
Launching GoPit from: /path/to/GoPit
Using Godot fork: /tmp/godot-automation-build/godot.macos.editor.universal
[PlayGodot] Starting Godot with remote debugging on port 6007
...
Game scene ready!
Balls before firing: 0
Calling fire() on BallSpawner...
Balls after firing: 1

✅ SUCCESS: Ball was fired!
```

## Test Structure

```
tests/
├── launch_and_fire.py   # Standalone test script
├── conftest.py          # Pytest fixtures
└── test_fire.py         # Pytest test cases (future)
```

## Writing Tests

### Standalone Script

```python
import asyncio
from pathlib import Path
from playgodot import Godot

GODOT_PATH = "/tmp/godot-automation-build/godot.macos.editor.universal"
PROJECT_PATH = Path(__file__).parent.parent

async def main():
    async with Godot.launch(
        str(PROJECT_PATH),
        headless=True,
        timeout=20.0,
        godot_path=GODOT_PATH,
    ) as game:
        # Wait for scene
        await game.wait_for_node("/root/Game")

        # Call methods
        result = await game.call("/root/Game/GameArea/Balls", "get_child_count")
        print(f"Ball count: {result}")

        # Fire a ball
        await game.call("/root/Game/GameArea/BallSpawner", "fire")

if __name__ == "__main__":
    asyncio.run(main())
```

### Pytest Style

```python
import pytest

@pytest.mark.asyncio
async def test_fire_creates_ball(game):
    balls_before = await game.call("/root/Game/GameArea/Balls", "get_child_count")
    await game.call("/root/Game/GameArea/BallSpawner", "fire")
    balls_after = await game.call("/root/Game/GameArea/Balls", "get_child_count")

    assert balls_after > balls_before
```

## PlayGodot API Reference

### Launching

```python
async with Godot.launch(project_path, headless=True, godot_path=path) as game:
    ...
```

### Querying Nodes

```python
# Wait for a node to exist
node = await game.wait_for_node("/root/Game")

# Get node info (includes full subtree)
info = await game.get_node("/root/Game")
```

### Calling Methods

```python
# Call a method on a node
result = await game.call("/root/Node", "method_name", arg1, arg2)

# Examples
count = await game.call("/root/Game/Balls", "get_child_count")
await game.call("/root/Game/BallSpawner", "fire")
await game.call("/root/Game/BallSpawner", "set_aim_direction", {"x": 1.0, "y": -1.0})
```

### Properties

```python
# Get property
value = await game.get("/root/Node", "property_name")

# Set property
await game.set("/root/Node", "property_name", new_value)
```

## Troubleshooting

### "Node not found" timeout

- Ensure you're using the Godot automation fork, not standard Godot
- Check that the game scene loads without errors
- Verify the node path is correct

### Connection refused

- Make sure no other Godot instance is using port 6007
- Check that the Godot binary has execute permissions

### Binary not found

Re-download from GitHub Actions:

```bash
gh run download -R Randroids-Dojo/godot -n macos-editor -D /tmp/godot-automation-build
```

## Resources

- [PlayGodot Repository](https://github.com/Randroids-Dojo/PlayGodot)
- [Godot Automation Fork](https://github.com/Randroids-Dojo/godot/tree/automation)
