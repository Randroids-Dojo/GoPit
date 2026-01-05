#!/usr/bin/env python3
"""
Launch GoPit and fire a ball using PlayGodot with the custom Godot fork.

Usage:
    python tests/launch_and_fire.py
"""
import asyncio
from pathlib import Path
from playgodot import Godot

GODOT_PROJECT = Path(__file__).parent.parent
GODOT_PATH = "/tmp/godot-automation-build/godot.macos.editor.universal"

# Node paths
GAME = "/root/Game"
BALL_SPAWNER = "/root/Game/GameArea/BallSpawner"
BALLS_CONTAINER = "/root/Game/GameArea/Balls"


async def main():
    print(f"Launching GoPit from: {GODOT_PROJECT}")
    print(f"Using Godot fork: {GODOT_PATH}")

    async with Godot.launch(
        str(GODOT_PROJECT),
        headless=True,
        timeout=20.0,
        godot_path=GODOT_PATH,
        verbose=True,
    ) as game:
        print("Game launched, waiting for scene...")

        # Wait for game to be ready
        await game.wait_for_node(GAME)
        print("Game scene ready!")

        # Get initial ball count
        balls_before = await game.call(BALLS_CONTAINER, "get_child_count")
        print(f"Balls before firing: {balls_before}")

        # Fire!
        print("Calling fire() on BallSpawner...")
        await game.call(BALL_SPAWNER, "fire")

        # Wait for ball to spawn
        await asyncio.sleep(0.2)

        # Check ball count after
        balls_after = await game.call(BALLS_CONTAINER, "get_child_count")
        print(f"Balls after firing: {balls_after}")

        if balls_after > balls_before:
            print("\n✅ SUCCESS: Ball was fired!")
        else:
            print("\n❌ FAILED: No ball spawned")

        # Let the game run briefly to see the ball move
        print("Watching ball for 1 second...")
        await asyncio.sleep(1.0)

        print("Done!")


if __name__ == "__main__":
    asyncio.run(main())
