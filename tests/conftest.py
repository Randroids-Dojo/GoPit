import pytest_asyncio
from pathlib import Path
from playgodot import Godot

GODOT_PROJECT = Path(__file__).parent.parent
GODOT_PATH = "/Applications/Godot.app/Contents/MacOS/Godot"


@pytest_asyncio.fixture
async def game():
    """Launch the game and yield the Godot connection."""
    async with Godot.launch(
        str(GODOT_PROJECT),
        headless=True,
        timeout=15.0,
        godot_path=GODOT_PATH,
    ) as g:
        # Wait for the game scene to be ready
        await g.wait_for_node("/root/Game")
        yield g
