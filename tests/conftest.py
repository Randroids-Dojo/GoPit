import os
import pytest_asyncio
from pathlib import Path
from playgodot import Godot

GODOT_PROJECT = Path(__file__).parent.parent
# Use automation fork by default, allow override via environment
GODOT_PATH = os.environ.get(
    "GODOT_PATH",
    "/Users/randroid/Documents/Dev/Godot/godot/bin/godot.macos.editor.arm64"
)


@pytest_asyncio.fixture
async def game():
    """Launch the game and yield the Godot connection."""
    async with Godot.launch(
        str(GODOT_PROJECT),
        headless=True,
        resolution=(1280, 1280),  # Match game's expected resolution for UI input
        timeout=15.0,
        godot_path=GODOT_PATH,
    ) as g:
        # Wait for the game scene to be ready
        await g.wait_for_node("/root/Game")
        yield g
