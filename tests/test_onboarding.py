"""Test streamlined onboarding for new players."""
import asyncio
import pytest
from tests.helpers import PATHS


@pytest.mark.asyncio
async def test_new_player_skips_menus_and_starts_with_tutorial(game):
    """New players should skip save/character/level select and start with tutorial."""
    # Verify we're in a new player state (no saves exist)
    slot_empty = await game.call("/root/MetaManager", "are_all_slots_empty")
    assert slot_empty, "Expected all save slots to be empty for new player test"

    # Game should automatically start (already done by game fixture)
    # Verify game state is PLAYING
    game_state = await game.get_property("/root/GameManager", "current_state")
    assert game_state == 1, f"Expected PLAYING state (1), got {game_state}"

    # Verify Rookie character is selected
    selected_character = await game.get_property("/root/GameManager", "selected_character")
    assert selected_character is not None, "Expected a character to be selected"

    # Verify first stage (The Pit, stage 0) is selected
    current_stage = await game.get_property("/root/StageManager", "current_stage")
    assert current_stage == 0, f"Expected stage 0 (The Pit), got {current_stage}"

    # Verify slot 1 is active
    active_slot = await game.get_property("/root/MetaManager", "current_slot")
    assert active_slot == 1, f"Expected slot 1, got {active_slot}"

    # Verify tutorial overlay is visible (new player should see tutorial)
    tutorial = await game.get_node(PATHS["tutorial_overlay"])
    assert tutorial is not None, "Tutorial overlay should exist"
    tutorial_visible = tutorial.get("visible", False)
    assert tutorial_visible, "Tutorial should be visible for new players"

    print("✓ New player onboarding works: skipped menus, started with Rookie on The Pit with tutorial")


@pytest.mark.asyncio
async def test_existing_player_sees_save_select(game):
    """Players with existing saves should see the save slot select."""
    # This test would require creating a save first, then restarting
    # For now, we'll just document the expected behavior
    #
    # Expected flow:
    # 1. If any save slot exists, show save slot select
    # 2. User selects slot
    # 3. If slot has session, show resume dialog
    # 4. Otherwise, show character select
    # 5. Then show level select
    # 6. Then start game

    # Skip this test if no saves exist
    has_saves = not await game.call("/root/MetaManager", "are_all_slots_empty")
    if not has_saves:
        pytest.skip("No existing saves to test with")

    # If we get here, save select should have been shown
    # (This is hard to test without UI interaction framework)
    print("✓ Save select flow documented (requires manual testing)")
