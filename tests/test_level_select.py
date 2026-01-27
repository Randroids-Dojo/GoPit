"""Tests for level select UI screen."""
import asyncio
import pytest

LEVEL_SELECT = "/root/Game/UI/LevelSelect"
STAGE_MANAGER = "/root/StageManager"
META_MANAGER = "/root/MetaManager"


@pytest.mark.asyncio
async def test_level_select_exists(game):
    """LevelSelect node should exist in the game."""
    node = await game.get_node(LEVEL_SELECT)
    assert node is not None, "LevelSelect should exist"


@pytest.mark.asyncio
async def test_level_select_initially_hidden(game):
    """LevelSelect should be hidden by default after _ready()."""
    # Wait for node to fully initialize (race condition in CI)
    await asyncio.sleep(0.2)
    visible = await game.get_property(LEVEL_SELECT, "visible")
    assert visible is False, "LevelSelect should be hidden initially"


@pytest.mark.asyncio
async def test_level_select_get_selected_stage(game):
    """LevelSelect should have get_selected_stage method."""
    selected = await game.call(LEVEL_SELECT, "get_selected_stage")
    assert selected is not None, "LevelSelect should return selected stage"
    assert selected >= 0, f"Selected stage should be >= 0, got {selected}"


@pytest.mark.asyncio
async def test_stage_manager_has_stages(game):
    """StageManager should have loaded stages."""
    total_stages = await game.call(STAGE_MANAGER, "get_total_stages")
    assert total_stages == 8, f"Should have 8 stages, got {total_stages}"


@pytest.mark.asyncio
async def test_stage_manager_get_stage_name(game):
    """StageManager should return current stage name."""
    stage_name = await game.call(STAGE_MANAGER, "get_stage_name")
    assert stage_name is not None, "Should have a stage name"


@pytest.mark.asyncio
async def test_meta_manager_stage_tracking(game):
    """MetaManager should track highest stage cleared."""
    highest = await game.call(META_MANAGER, "get_highest_stage_cleared")
    assert highest is not None, "Should return highest stage cleared"
    assert highest >= 0, f"Highest stage should be >= 0, got {highest}"


# ============================================================================
# GEAR UNLOCK SYSTEM TESTS
# ============================================================================


@pytest.mark.asyncio
async def test_gear_system_constants(game):
    """MetaManager should have gear system constants."""
    gears_per_stage = await game.get_property(META_MANAGER, "GEARS_PER_STAGE")
    assert gears_per_stage == 2, "Should require 2 gears per stage"


@pytest.mark.asyncio
async def test_stage_gears_start_at_zero(game):
    """Stage gears should start at 0."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)
    gears = await game.call(META_MANAGER, "get_stage_gears", [0])
    assert gears == 0, "Stage 0 should have 0 gears initially"


@pytest.mark.asyncio
async def test_record_stage_completion_adds_gear(game):
    """Recording stage completion should add a gear."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Record stage 0 completion with Rookie
    result = await game.call(META_MANAGER, "record_stage_completion", [0, "Rookie"])
    assert result is True, "First completion should return true (new gear)"

    gears = await game.call(META_MANAGER, "get_stage_gears", [0])
    assert gears == 1, "Stage 0 should have 1 gear after completion"


@pytest.mark.asyncio
async def test_same_character_no_duplicate_gear(game):
    """Same character completing same stage should not earn duplicate gear."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Record first completion
    await game.call(META_MANAGER, "record_stage_completion", [0, "Rookie"])
    # Record same character again
    result = await game.call(META_MANAGER, "record_stage_completion", [0, "Rookie"])
    assert result is False, "Duplicate completion should return false"

    gears = await game.call(META_MANAGER, "get_stage_gears", [0])
    assert gears == 1, "Still only 1 gear after duplicate"


@pytest.mark.asyncio
async def test_different_characters_earn_gears(game):
    """Different characters should each earn a gear."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Record completions with two characters
    await game.call(META_MANAGER, "record_stage_completion", [0, "Rookie"])
    await game.call(META_MANAGER, "record_stage_completion", [0, "Pyro"])

    gears = await game.call(META_MANAGER, "get_stage_gears", [0])
    assert gears == 2, "Stage 0 should have 2 gears after two characters complete"


@pytest.mark.asyncio
async def test_first_stage_always_unlocked(game):
    """Stage 0 should always be unlocked."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    is_unlocked = await game.call(META_MANAGER, "is_stage_unlocked_by_gears", [0])
    assert is_unlocked is True, "Stage 0 should always be unlocked"


@pytest.mark.asyncio
async def test_stage_unlock_requires_gears(game):
    """Stage 1 should require 2 gears from stage 0."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Stage 1 should be locked initially
    is_unlocked = await game.call(META_MANAGER, "is_stage_unlocked_by_gears", [1])
    assert is_unlocked is False, "Stage 1 should be locked with 0 gears"

    # Add 1 gear
    await game.call(META_MANAGER, "record_stage_completion", [0, "Rookie"])
    is_unlocked = await game.call(META_MANAGER, "is_stage_unlocked_by_gears", [1])
    assert is_unlocked is False, "Stage 1 should still be locked with 1 gear"

    # Add 2nd gear
    await game.call(META_MANAGER, "record_stage_completion", [0, "Pyro"])
    is_unlocked = await game.call(META_MANAGER, "is_stage_unlocked_by_gears", [1])
    assert is_unlocked is True, "Stage 1 should be unlocked with 2 gears"


@pytest.mark.asyncio
async def test_get_total_gears(game):
    """get_total_gears should sum gears across all stages."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Add gears to multiple stages
    await game.call(META_MANAGER, "record_stage_completion", [0, "Rookie"])
    await game.call(META_MANAGER, "record_stage_completion", [0, "Pyro"])
    await game.call(META_MANAGER, "record_stage_completion", [1, "Frost Mage"])

    total = await game.call(META_MANAGER, "get_total_gears")
    assert total == 3, f"Total gears should be 3, got {total}"


@pytest.mark.asyncio
async def test_get_characters_who_cleared_stage(game):
    """Should return list of characters who cleared a stage."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    await game.call(META_MANAGER, "record_stage_completion", [0, "Rookie"])
    await game.call(META_MANAGER, "record_stage_completion", [0, "Pyro"])

    characters = await game.call(META_MANAGER, "get_characters_who_cleared_stage", [0])
    assert len(characters) == 2, "Should have 2 characters"
    assert "Rookie" in characters, "Rookie should be in list"
    assert "Pyro" in characters, "Pyro should be in list"


# ============================================================================
# DIFFICULTY/SPEED LEVEL SELECTION TESTS
# ============================================================================

GAME_MANAGER = "/root/GameManager"


@pytest.mark.asyncio
async def test_level_select_get_selected_difficulty(game):
    """LevelSelect should have get_selected_difficulty method."""
    selected = await game.call(LEVEL_SELECT, "get_selected_difficulty")
    assert selected is not None, "Should return selected difficulty"
    assert 1 <= selected <= 10, f"Difficulty should be 1-10, got {selected}"


@pytest.mark.asyncio
async def test_difficulty_defaults_to_one(game):
    """GameManager difficulty should default to 1."""
    await game.call(GAME_MANAGER, "set_difficulty_level", [1])
    await asyncio.sleep(0.1)

    level = await game.call(GAME_MANAGER, "get_difficulty_level")
    assert level == 1, f"Default difficulty should be 1, got {level}"


@pytest.mark.asyncio
async def test_set_difficulty_level(game):
    """GameManager should allow setting difficulty level 1-10."""
    await game.call(GAME_MANAGER, "set_difficulty_level", [5])
    await asyncio.sleep(0.1)

    level = await game.call(GAME_MANAGER, "get_difficulty_level")
    assert level == 5, f"Difficulty should be 5, got {level}"

    # Reset for other tests
    await game.call(GAME_MANAGER, "set_difficulty_level", [1])


@pytest.mark.asyncio
async def test_difficulty_clamped_to_valid_range(game):
    """Difficulty should be clamped to 1-10."""
    # Try setting above max
    await game.call(GAME_MANAGER, "set_difficulty_level", [15])
    await asyncio.sleep(0.1)
    level = await game.call(GAME_MANAGER, "get_difficulty_level")
    assert level == 10, f"Difficulty should cap at 10, got {level}"

    # Try setting below min
    await game.call(GAME_MANAGER, "set_difficulty_level", [0])
    await asyncio.sleep(0.1)
    level = await game.call(GAME_MANAGER, "get_difficulty_level")
    assert level == 1, f"Difficulty should floor at 1, got {level}"


@pytest.mark.asyncio
async def test_difficulty_hp_multiplier_scaling(game):
    """Higher difficulty should increase enemy HP multiplier."""
    # Level 1 = 1.0x
    await game.call(GAME_MANAGER, "set_difficulty_level", [1])
    await asyncio.sleep(0.1)
    mult1 = await game.call(GAME_MANAGER, "get_difficulty_enemy_hp_multiplier")
    assert mult1 == 1.0, f"Level 1 HP mult should be 1.0, got {mult1}"

    # Level 2 = 1.5x
    await game.call(GAME_MANAGER, "set_difficulty_level", [2])
    await asyncio.sleep(0.1)
    mult2 = await game.call(GAME_MANAGER, "get_difficulty_enemy_hp_multiplier")
    assert mult2 == 1.5, f"Level 2 HP mult should be 1.5, got {mult2}"

    # Level 3 = 2.25x (1.5^2)
    await game.call(GAME_MANAGER, "set_difficulty_level", [3])
    await asyncio.sleep(0.1)
    mult3 = await game.call(GAME_MANAGER, "get_difficulty_enemy_hp_multiplier")
    assert abs(mult3 - 2.25) < 0.01, f"Level 3 HP mult should be 2.25, got {mult3}"

    # Reset
    await game.call(GAME_MANAGER, "set_difficulty_level", [1])


@pytest.mark.asyncio
async def test_difficulty_xp_multiplier_scaling(game):
    """Higher difficulty should increase XP multiplier."""
    # Level 1 = 1.0x
    await game.call(GAME_MANAGER, "set_difficulty_level", [1])
    await asyncio.sleep(0.1)
    mult1 = await game.call(GAME_MANAGER, "get_difficulty_xp_multiplier")
    assert mult1 == 1.0, f"Level 1 XP mult should be 1.0, got {mult1}"

    # Level 2 = 1.15x (+15% per level above 1)
    await game.call(GAME_MANAGER, "set_difficulty_level", [2])
    await asyncio.sleep(0.1)
    mult2 = await game.call(GAME_MANAGER, "get_difficulty_xp_multiplier")
    assert abs(mult2 - 1.15) < 0.01, f"Level 2 XP mult should be 1.15, got {mult2}"

    # Reset
    await game.call(GAME_MANAGER, "set_difficulty_level", [1])


@pytest.mark.asyncio
async def test_difficulty_one_always_unlocked(game):
    """Difficulty 1 should always be unlocked."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    is_unlocked = await game.call(GAME_MANAGER, "is_difficulty_unlocked", [1, 0])
    assert is_unlocked is True, "Difficulty 1 should always be unlocked"


@pytest.mark.asyncio
async def test_difficulty_two_locked_initially(game):
    """Difficulty 2 should be locked until difficulty 1 is beaten."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    is_unlocked = await game.call(GAME_MANAGER, "is_difficulty_unlocked", [2, 0])
    assert is_unlocked is False, "Difficulty 2 should be locked initially"


@pytest.mark.asyncio
async def test_difficulty_unlocks_after_completion(game):
    """Beating difficulty N should unlock difficulty N+1."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Difficulty 2 should be locked
    is_unlocked = await game.call(GAME_MANAGER, "is_difficulty_unlocked", [2, 0])
    assert is_unlocked is False, "Difficulty 2 should be locked"

    # Record completion at difficulty 1
    await game.call(META_MANAGER, "record_difficulty_completion", ["Rookie", 0, 1])
    await asyncio.sleep(0.1)

    # Now difficulty 2 should be unlocked
    is_unlocked = await game.call(GAME_MANAGER, "is_difficulty_unlocked", [2, 0])
    assert is_unlocked is True, "Difficulty 2 should be unlocked after beating difficulty 1"


@pytest.mark.asyncio
async def test_difficulty_completion_cascading(game):
    """Beating difficulty 3 should also count as beating 1 and 2."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Record completion at difficulty 3 (cascading should unlock 1-4)
    await game.call(META_MANAGER, "record_difficulty_completion", ["Rookie", 0, 3])
    await asyncio.sleep(0.1)

    # Difficulty 4 should now be unlocked
    is_unlocked = await game.call(GAME_MANAGER, "is_difficulty_unlocked", [4, 0])
    assert is_unlocked is True, "Difficulty 4 should be unlocked after beating difficulty 3"


@pytest.mark.asyncio
async def test_get_highest_difficulty_for_stage(game):
    """Should return highest difficulty beaten by any character."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Initially 0
    highest = await game.call(META_MANAGER, "get_highest_difficulty_for_stage", [0])
    assert highest == 0, "Highest should be 0 initially"

    # Beat level 2 with Rookie
    await game.call(META_MANAGER, "record_difficulty_completion", ["Rookie", 0, 2])
    await asyncio.sleep(0.1)

    highest = await game.call(META_MANAGER, "get_highest_difficulty_for_stage", [0])
    assert highest == 2, f"Highest should be 2, got {highest}"

    # Beat level 5 with Pyro
    await game.call(META_MANAGER, "record_difficulty_completion", ["Pyro", 0, 5])
    await asyncio.sleep(0.1)

    highest = await game.call(META_MANAGER, "get_highest_difficulty_for_stage", [0])
    assert highest == 5, f"Highest should be 5 now, got {highest}"
