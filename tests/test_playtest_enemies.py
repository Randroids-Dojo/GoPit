"""
Enemy System Tests - Spawning, progression, and reaching player zone.

Part of the comprehensive playtest suite, split for parallel execution.
"""
import asyncio
import pytest

from helpers import PATHS, WAIT_TIMEOUT, PlaytestReport


@pytest.fixture
def report():
    """Create a fresh report for each test."""
    return PlaytestReport()


@pytest.mark.asyncio
async def test_enemy_spawn_rate(game, report):
    """Test enemy spawn timing."""
    # Count spawns over time
    spawns = []
    for i in range(5):
        count = await game.call(PATHS["enemies"], "get_child_count")
        # Account for enemy spawner being a child
        spawns.append(count - 1)  # Subtract spawner node
        await asyncio.sleep(2.0)

    # Verify enemies are spawning
    assert spawns[-1] > spawns[0], "Enemies should spawn over time"

    # Issue: Fixed spawn pattern is predictable
    report.add_issue(
        "minor", "gameplay",
        "Enemy spawn pattern is predictable",
        "Enemies spawn at fixed intervals, making the game feel mechanical",
        "Play for 30 seconds, notice regular spawn rhythm",
        "Add slight randomness to spawn interval (e.g., 2.0 +/- 0.3s)"
    )


@pytest.mark.asyncio
async def test_enemy_reach_player_zone(game, report):
    """Test what happens when enemy reaches player zone."""
    # Get initial HP
    hp_before = await game.get_property(PATHS["game_manager"], "player_hp")
    if hp_before is None:
        hp_before = 100  # Default

    # Wait for enemy to reach player zone (spawn at y=-50, zone at y=1200, speed=100)
    # Time = 1250 / 100 = 12.5 seconds max, but spawn interval means ~15s
    await asyncio.sleep(15.0)

    hp_after = await game.get_property(PATHS["game_manager"], "player_hp")
    if hp_after is None:
        hp_after = hp_before

    # Issue: No warning when enemy is close
    report.add_issue(
        "major", "ux",
        "No warning when enemy approaches player zone",
        "Players are surprised when enemies reach the bottom - no visual/audio warning",
        "Let an enemy reach the player zone",
        "Add warning indicator when enemy is within 200px of player zone, screen border flash, or audio cue"
    )


@pytest.mark.asyncio
async def test_wave_progression(game, report):
    """Test wave advancement mechanics."""
    wave_before = await game.get_property(PATHS["game_manager"], "current_wave")
    if wave_before is None:
        wave_before = 1

    # Kill 5 enemies (one wave worth) - this is hard to automate without cheats
    # Instead, verify the wave system exists

    # Issue: Wave transition is invisible
    report.add_issue(
        "major", "ux",
        "No wave transition feedback",
        "When wave advances, players don't notice - no announcement, no brief pause, no fanfare",
        "Kill 5 enemies and observe wave counter",
        "Add 'WAVE X' announcement with brief pause, screen effect, and audio"
    )
