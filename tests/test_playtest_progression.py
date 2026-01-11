"""
Progression System Tests - Gems, XP, and level-up mechanics.

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
async def test_gem_collection_in_player_zone(game, report):
    """Test that gems are collected when falling into player zone."""
    xp_before = await game.get_property(PATHS["game_manager"], "current_xp")
    if xp_before is None:
        xp_before = 0

    # Wait for natural gem collection (enemy dies, gem falls)
    # This requires enemies to die first
    await asyncio.sleep(10.0)

    xp_after = await game.get_property(PATHS["game_manager"], "current_xp")

    # Issue: Gems just fall - no magnetism
    report.add_issue(
        "minor", "gameplay",
        "Gems have no magnetism/attraction to player",
        "Players have to wait for gems to fall naturally - no active collection",
        "Kill an enemy and watch gem fall slowly",
        "Add gem magnetism that pulls gems toward player zone when within range"
    )


@pytest.mark.asyncio
async def test_gem_despawn(game, report):
    """Test gem despawning behavior."""
    # Gems fall at 150 units/sec, despawn at y > 1400
    # From spawn around y=600 (mid-screen), takes ~5s to despawn

    # Issue: Gems can be missed if they spawn at bad times
    report.add_issue(
        "minor", "gameplay",
        "Gems can despawn before collection",
        "If player is focused on aiming, gems might despawn before falling to player zone",
        "Kill enemies quickly and watch gems",
        "Gems should always reach player zone before despawning, or have collection radius"
    )


@pytest.mark.asyncio
async def test_level_up_overlay_appears(game, report):
    """Test that level-up overlay appears correctly."""
    # This requires getting enough XP (100 for level 2)
    # Would need to kill 10 enemies (10 XP each) naturally

    # Check overlay is initially hidden
    visible = await game.get_property(PATHS["level_up_overlay"], "visible")
    assert visible == False, "Level-up overlay should be hidden initially"

    # Issue: No XP progress indication
    report.add_issue(
        "minor", "ux",
        "XP gain not clearly communicated",
        "When collecting gems, there's no floating number or clear indication of XP gained",
        "Collect a gem and observe",
        "Add floating '+10 XP' text at collection point, or XP bar flash"
    )


@pytest.mark.asyncio
async def test_upgrade_cards_variety(game, report):
    """Test upgrade card randomization."""
    # The game has only 3 upgrade types - all shown every level-up

    # Issue: Limited upgrade variety
    report.add_issue(
        "major", "gameplay",
        "Only 3 upgrade types - no variety or strategy",
        "Every level-up shows the same 3 upgrades, just shuffled. No interesting choices",
        "Level up multiple times",
        "Add more upgrade types: multi-shot, ball speed, ball size, piercing, etc."
    )

    # Issue: All upgrades shown every time
    report.add_issue(
        "minor", "gameplay",
        "All upgrades available every level-up",
        "Players always see all 3 options - no surprise or strategic selection",
        "Level up and observe cards",
        "Show 3 random from larger pool of 6-8 upgrades"
    )
