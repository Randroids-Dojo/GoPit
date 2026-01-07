import os
import socket
import pytest_asyncio
from pathlib import Path
from playgodot import Godot

GODOT_PROJECT = Path(__file__).parent.parent
# Use automation fork by default, allow override via environment
GODOT_PATH = os.environ.get(
    "GODOT_PATH",
    "/Users/randroid/Documents/Dev/Godot/godot/bin/godot.macos.editor.arm64"
)


def get_free_port() -> int:
    """Find an available port by binding to port 0."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('127.0.0.1', 0))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return s.getsockname()[1]


def get_playgodot_port() -> int:
    """
    Determine port for PlayGodot connection.

    Priority:
    1. PLAYGODOT_PORT env var (explicit override)
    2. pytest-xdist worker ID (6007 + worker_num)
    3. Dynamic free port (cross-session safety)
    """
    # Priority 1: Explicit environment variable
    env_port = os.environ.get("PLAYGODOT_PORT")
    if env_port:
        return int(env_port)

    # Priority 2: pytest-xdist worker ID
    worker_id = os.environ.get("PYTEST_XDIST_WORKER")
    if worker_id and worker_id != "master":
        worker_num = int(worker_id.replace("gw", ""))
        return 6007 + worker_num + 1

    # Priority 3: Dynamic port allocation
    return get_free_port()


@pytest_asyncio.fixture
async def game():
    """Launch the game and yield the Godot connection."""
    port = get_playgodot_port()

    async with Godot.launch(
        str(GODOT_PROJECT),
        headless=True,
        resolution=(720, 1280),  # Match game's 9:16 portrait aspect ratio
        timeout=15.0,
        godot_path=GODOT_PATH,
        port=port,
    ) as g:
        # Wait for the game scene to be ready
        await g.wait_for_node("/root/Game")
        yield g
