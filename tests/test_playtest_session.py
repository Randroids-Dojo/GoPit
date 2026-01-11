"""
Full Gameplay Session Test - Extended simulation and performance tests.

Part of the comprehensive playtest suite, split for parallel execution.

NOTE: This file contains the longest-running tests (~60-80 seconds total).
"""
import asyncio
import pytest
import time

from helpers import PATHS, WAIT_TIMEOUT, PlaytestReport, get_joystick_center


@pytest.fixture
def report():
    """Create a fresh report for each test."""
    return PlaytestReport()


@pytest.mark.asyncio
async def test_full_gameplay_session(game, report):
    """Simulate a full gameplay session and collect metrics."""
    metrics = {
        "balls_fired": 0,
        "session_duration": 0,
        "max_wave_reached": 1,
        "final_level": 1,
    }

    start_time = time.time()

    # Play for 60 seconds
    for tick in range(120):  # 120 half-second ticks = 60 seconds
        # Fire every 0.6 seconds (respecting cooldown)
        if tick % 2 == 0:  # Every second
            await game.click(PATHS["fire_button"])
            metrics["balls_fired"] += 1

        # Occasionally aim in different directions
        if tick % 10 == 0:
            coords = await get_joystick_center(game, PATHS["joystick"])
            if coords:
                import random
                offset_x = random.randint(-60, 60)
                offset_y = random.randint(-60, 0)  # Mostly aim upward
                center_x, center_y = coords
                await game.click(center_x + offset_x, center_y + offset_y)

        await asyncio.sleep(0.5)

        # Check game state
        state = await game.get_property(PATHS["game_manager"], "current_state")
        if state == 4:  # GAME_OVER = 4
            break

        # Update metrics
        wave = await game.get_property(PATHS["game_manager"], "current_wave")
        level = await game.get_property(PATHS["game_manager"], "player_level")
        if wave and wave > metrics["max_wave_reached"]:
            metrics["max_wave_reached"] = wave
        if level and level > metrics["final_level"]:
            metrics["final_level"] = level

    metrics["session_duration"] = time.time() - start_time
    report.metrics = metrics

    # Gameplay balance issues
    report.add_issue(
        "major", "balance",
        "Early game may be too slow",
        f"Fired {metrics['balls_fired']} balls in {metrics['session_duration']:.0f}s with 0.5s cooldown - pacing feels slow",
        "Play the first minute",
        "Consider faster initial fire rate, or give player 2 balls at start"
    )

    if metrics["max_wave_reached"] <= 2:
        report.add_issue(
            "major", "balance",
            "Wave progression may be too slow",
            f"Only reached wave {metrics['max_wave_reached']} in {metrics['session_duration']:.0f}s",
            "Play a full session",
            "Consider fewer enemies per wave (3 instead of 5) or faster enemy movement"
        )


@pytest.mark.asyncio
async def test_many_balls(game, report):
    """Test performance with many balls on screen."""
    # Rapidly fire many balls
    for _ in range(20):
        await game.call(PATHS["ball_spawner"], "fire")
        await asyncio.sleep(0.1)

    balls_count = await game.call(PATHS["balls"], "get_child_count")

    # Issue: No ball limit
    report.add_issue(
        "minor", "performance",
        "No limit on simultaneous balls",
        f"Created {balls_count} balls - could cause performance issues on low-end devices",
        "Fire rapidly with upgrades",
        "Consider limiting max balls to 20-30, or implement object pooling"
    )


@pytest.mark.asyncio
async def test_many_enemies(game, report):
    """Test performance with many enemies."""
    # Wait for enemies to accumulate
    await asyncio.sleep(20.0)

    enemies_count = await game.call(PATHS["enemies"], "get_child_count")

    if enemies_count > 15:
        report.add_issue(
            "minor", "performance",
            "Enemies can accumulate significantly",
            f"Found {enemies_count} enemies on screen - could cause performance issues",
            "Don't kill enemies for 30 seconds",
            "Consider enemy despawn if off bottom of screen, or spawn rate adjustment"
        )
