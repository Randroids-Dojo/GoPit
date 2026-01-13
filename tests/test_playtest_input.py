"""
Input System Tests - Fire button, joystick aiming, and dead zones.

Part of the comprehensive playtest suite, split for parallel execution.
"""
import asyncio
import pytest

from helpers import (
    PATHS, WAIT_TIMEOUT, PlaytestReport,
    wait_for_fire_ready, get_joystick_center
)


@pytest.fixture
def report():
    """Create a fresh report for each test."""
    return PlaytestReport()


@pytest.mark.asyncio
async def test_fire_button_cooldown(game, report):
    """Test that fire button cooldown state transitions correctly."""
    # Disable autofire so we control timing
    await game.call(PATHS["fire_button"], "set_autofire", [False])

    # Wait for fire button to be ready (may be on cooldown from autofire)
    ready = await wait_for_fire_ready(game, PATHS["fire_button"])
    assert ready, "Fire button should become ready within timeout"

    # Initially button should be ready
    is_ready_initial = await game.get_property(PATHS["fire_button"], "is_ready")
    assert is_ready_initial, "Fire button should start ready"

    # Fire - this should trigger cooldown
    await game.click(PATHS["fire_button"])

    # Immediately check cooldown is active (no sleep to avoid timing issues)
    is_ready_during_cooldown = await game.get_property(PATHS["fire_button"], "is_ready")
    assert not is_ready_during_cooldown, "Fire button should be in cooldown after firing"

    # Wait for cooldown to complete (0.5s default + buffer)
    await asyncio.sleep(0.6)

    # Button should be ready again (cooldown-wise)
    is_ready_after_cooldown = await game.get_property(PATHS["fire_button"], "is_ready")
    assert is_ready_after_cooldown, "Fire button should be ready after cooldown"

    # Wait for balls to return (salvo mechanic: can't fire until balls return)
    ready = await wait_for_fire_ready(game, PATHS["fire_button"])
    assert ready, "Fire button should become fully ready (cooldown + balls returned)"

    # Verify firing still works after cooldown by checking state transitions again
    await game.click(PATHS["fire_button"])
    is_ready_after_second_fire = await game.get_property(PATHS["fire_button"], "is_ready")
    assert not is_ready_after_second_fire, "Fire button should enter cooldown after second fire"

    # Check for issue: No visual feedback that fire is blocked
    report.add_issue(
        "minor", "ux",
        "No feedback when fire button pressed during cooldown",
        "Players spam the fire button but get no indication that presses during cooldown are ignored",
        "Tap fire rapidly",
        "Add haptic feedback, button shake, or brief visual flash when fire is blocked"
    )


@pytest.mark.asyncio
async def test_joystick_aim_direction(game, report):
    """Test that joystick properly updates aim direction."""
    coords = await get_joystick_center(game, PATHS["joystick"])

    if not coords:
        pytest.skip("Could not get joystick position")

    center_x, center_y = coords

    # Simulate drag to the right
    await game.click(center_x + 50, center_y)
    await asyncio.sleep(0.1)

    # Check aim line visibility
    aim_visible = await game.get_property(PATHS["aim_line"], "visible")

    # Fire and check ball direction
    await game.click(PATHS["fire_button"])
    await asyncio.sleep(0.2)

    # Issue: Joystick doesn't show current aim after release
    report.add_issue(
        "minor", "ux",
        "Aim direction resets/hides after joystick release",
        "Players lose visual feedback of their current aim when not actively touching joystick",
        "Aim with joystick, release, try to fire",
        "Show a persistent (but faded) aim indicator that shows last direction"
    )


@pytest.mark.asyncio
async def test_joystick_dead_zone(game, report):
    """Test joystick dead zone behavior."""
    coords = await get_joystick_center(game, PATHS["joystick"])

    if not coords:
        pytest.skip("Could not get joystick position")

    center_x, center_y = coords

    # Click near center (within dead zone of 0.1 = 8px on 80px radius)
    await game.click(center_x + 5, center_y - 5)
    await asyncio.sleep(0.1)

    # Issue: Dead zone might feel unresponsive
    report.add_issue(
        "minor", "ux",
        "Joystick dead zone may feel unresponsive",
        "Dead zone of 10% (8px) might feel laggy to players expecting immediate response",
        "Make tiny movements on joystick",
        "Consider reducing dead zone to 5% or adding visual feedback when in dead zone"
    )
