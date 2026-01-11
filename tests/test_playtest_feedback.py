"""
Feedback & UI Tests - Damage feedback, game over, HUD, and UI readability.

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
async def test_damage_feedback(game, report):
    """Test player damage feedback."""
    # Issue: Weak damage feedback
    report.add_issue(
        "major", "ux",
        "Damage feedback is too subtle",
        "When player takes damage, only the HP bar changes - no screen flash, shake, or strong audio",
        "Let an enemy reach the player zone",
        "Add screen shake, red vignette flash, and impactful damage sound"
    )


@pytest.mark.asyncio
async def test_game_over_flow(game, report):
    """Test game over screen and restart."""
    # Check game over overlay is hidden initially
    visible = await game.get_property(PATHS["game_over_overlay"], "visible")
    assert visible == False, "Game over overlay should be hidden initially"

    # Issue: No death animation
    report.add_issue(
        "minor", "ux",
        "No dramatic game over sequence",
        "Game over just shows overlay - no explosion, slowdown, or dramatic effect",
        "Die and observe",
        "Add slowmo death sequence, screen fade to red, dramatic audio"
    )

    # Issue: No stats shown
    report.add_issue(
        "minor", "ux",
        "Limited stats on game over screen",
        "Only shows level and wave - no enemies killed, damage dealt, time played, etc.",
        "Reach game over screen",
        "Track and display: enemies killed, balls fired, damage dealt, gems collected, time survived"
    )


@pytest.mark.asyncio
async def test_hud_updates(game, report):
    """Test that HUD updates correctly with game state."""
    # Check HUD elements exist
    hp_bar = await game.get_node(PATHS["hp_bar"])
    wave_label = await game.get_node(PATHS["wave_label"])
    xp_bar = await game.get_node(PATHS["xp_bar"])

    assert hp_bar is not None, "HP bar should exist"
    assert wave_label is not None, "Wave label should exist"
    assert xp_bar is not None, "XP bar should exist"

    # Issue: No combo/streak display
    report.add_issue(
        "suggestion", "gameplay",
        "No combo or streak tracking",
        "Players have no motivation to hit multiple enemies quickly - no combo system",
        "Play the game",
        "Add combo counter for rapid enemy kills, with bonus XP"
    )


@pytest.mark.asyncio
async def test_ui_readability(game, report):
    """Test UI visibility and readability."""
    # Issue: UI might be hard to see during action
    report.add_issue(
        "minor", "ui",
        "HUD may be hard to read during intense gameplay",
        "HP and XP bars are small and might be missed during action",
        "Play intensely and try to track HP",
        "Add larger HP indicator, or screen tint as HP gets low"
    )

    # Issue: No pause button
    report.add_issue(
        "major", "ux",
        "No pause functionality",
        "Players cannot pause the game - problematic for mobile where interruptions happen",
        "Try to pause the game",
        "Add pause button in corner, or pause on app background"
    )


@pytest.mark.asyncio
async def test_touch_target_sizes(game, report):
    """Test touch target sizes for mobile usability."""
    # Check fire button size
    fire_size = await game.get_property(PATHS["fire_button"], "size")
    joystick_size = await game.get_property(PATHS["joystick"], "size")

    # Issue: Touch targets might be too small
    report.add_issue(
        "minor", "ux",
        "Touch targets may be too small for comfortable play",
        "Fire button and joystick might be hard to hit accurately on small phones",
        "Play on a small phone screen",
        "Ensure minimum 48x48dp touch targets, or add touch tolerance area"
    )


@pytest.mark.asyncio
async def test_screen_orientation(game, report):
    """Test portrait orientation handling."""
    # Issue: No landscape support
    report.add_issue(
        "suggestion", "ux",
        "No landscape orientation support",
        "Game only works in portrait - some players prefer landscape",
        "Rotate device",
        "Consider landscape layout option or adaptive UI"
    )


@pytest.mark.asyncio
async def test_sound_variety(game, report):
    """Test sound feedback variety."""
    # Issue: Sounds may become repetitive
    report.add_issue(
        "minor", "audio",
        "Procedural sounds may lack variety",
        "Same synthesized sounds play repeatedly - may become annoying",
        "Play for 5 minutes",
        "Add slight pitch/timing variation to sounds, or multiple variants per action"
    )

    # Issue: No background music
    report.add_issue(
        "major", "audio",
        "No background music",
        "Game is silent except for sound effects - feels incomplete",
        "Play the game",
        "Add procedural or looping background music that intensifies with waves"
    )

    # Issue: No mute option
    report.add_issue(
        "major", "ux",
        "No audio settings or mute button",
        "Players cannot mute sound effects - problematic in public",
        "Try to mute the game",
        "Add settings menu with volume sliders for music/SFX"
    )
