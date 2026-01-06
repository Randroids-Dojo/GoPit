"""Test for fire button position bug - button shifts left on double tap."""
import asyncio
import pytest

FIRE_BUTTON = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"


@pytest.mark.asyncio
async def test_fire_button_position_after_blocked_tap(game):
    """
    Regression test: Fire button should NOT reposition after double-tap.

    Previously, the button would shift left because _original_position was
    captured in _ready() before container layout completed. The fix captures
    position at shake time instead.
    """
    # Wait for layout to settle
    await asyncio.sleep(0.3)

    # Get the button's position after layout
    initial_pos = await game.get_property(FIRE_BUTTON, "position")
    print(f"Initial position after layout: {initial_pos}")

    # Fire once to start cooldown
    await game.click(FIRE_BUTTON)
    await asyncio.sleep(0.1)

    # Verify we're on cooldown
    is_ready = await game.get_property(FIRE_BUTTON, "is_ready")
    assert not is_ready, "Button should be on cooldown after firing"

    # Tap again while on cooldown - this triggers _on_blocked() and _shake_button()
    await game.click(FIRE_BUTTON)

    # Wait for shake animation to complete (0.05 * 4 = 0.2 seconds)
    await asyncio.sleep(0.3)

    # Get position after shake animation
    final_pos = await game.get_property(FIRE_BUTTON, "position")
    print(f"Position after blocked tap + shake: {final_pos}")

    # Button x position should return to initial position after shake
    assert abs(final_pos['x'] - initial_pos['x']) < 1.0, (
        f"Fire button x position shifted! "
        f"Expected ~{initial_pos['x']}, got {final_pos['x']}"
    )


@pytest.mark.asyncio
async def test_fire_button_multiple_blocked_taps(game):
    """
    Test that multiple blocked taps don't cause cumulative position drift.
    """
    # Wait for layout to settle
    await asyncio.sleep(0.3)

    # Get initial position
    initial_pos = await game.get_property(FIRE_BUTTON, "position")
    print(f"Initial position: {initial_pos}")

    # Fire to start cooldown
    await game.click(FIRE_BUTTON)
    await asyncio.sleep(0.1)

    # Tap multiple times while on cooldown
    for i in range(3):
        await game.click(FIRE_BUTTON)
        await asyncio.sleep(0.25)  # Wait for each shake animation

    # Final position check
    final_pos = await game.get_property(FIRE_BUTTON, "position")
    print(f"Position after 3 blocked taps: {final_pos}")

    assert abs(final_pos['x'] - initial_pos['x']) < 1.0, (
        f"Fire button drifted after multiple blocked taps! "
        f"Expected ~{initial_pos['x']}, got {final_pos['x']}"
    )
