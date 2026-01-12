"""Tests for the difficulty level system (speed levels like BallxPit's Fast+N)."""
import asyncio
import pytest

GAME = "/root/Game"


@pytest.mark.asyncio
async def test_max_difficulty_level_constant(game):
    """GameManager should have MAX_DIFFICULTY_LEVEL = 10."""
    max_level = await game.get_property("GameManager", "MAX_DIFFICULTY_LEVEL")
    assert max_level == 10, f"MAX_DIFFICULTY_LEVEL should be 10, got {max_level}"


@pytest.mark.asyncio
async def test_difficulty_scale_per_level_constant(game):
    """GameManager should have DIFFICULTY_SCALE_PER_LEVEL = 1.5."""
    scale = await game.get_property("GameManager", "DIFFICULTY_SCALE_PER_LEVEL")
    assert scale == 1.5, f"DIFFICULTY_SCALE_PER_LEVEL should be 1.5, got {scale}"


@pytest.mark.asyncio
async def test_default_difficulty_level(game):
    """Default difficulty level should be 1."""
    level = await game.get_property("GameManager", "selected_difficulty_level")
    assert level == 1, f"Default difficulty should be 1, got {level}"


@pytest.mark.asyncio
async def test_set_difficulty_level(game):
    """Should be able to set difficulty level 1-10."""
    # Set to level 5
    await game.call("GameManager", "set_difficulty_level", [5])
    level = await game.get_property("GameManager", "selected_difficulty_level")
    assert level == 5, f"Difficulty should be 5, got {level}"

    # Reset to 1 for other tests
    await game.call("GameManager", "set_difficulty_level", [1])


@pytest.mark.asyncio
async def test_difficulty_level_clamped(game):
    """Difficulty level should be clamped to 1-10."""
    # Try to set below 1
    await game.call("GameManager", "set_difficulty_level", [0])
    level = await game.get_property("GameManager", "selected_difficulty_level")
    assert level == 1, f"Difficulty should be clamped to 1, got {level}"

    # Try to set above 10
    await game.call("GameManager", "set_difficulty_level", [15])
    level = await game.get_property("GameManager", "selected_difficulty_level")
    assert level == 10, f"Difficulty should be clamped to 10, got {level}"

    # Reset
    await game.call("GameManager", "set_difficulty_level", [1])


@pytest.mark.asyncio
async def test_difficulty_enemy_hp_multiplier_level_1(game):
    """Level 1 should have 1.0x HP multiplier."""
    await game.call("GameManager", "set_difficulty_level", [1])
    mult = await game.call("GameManager", "get_difficulty_enemy_hp_multiplier")
    assert mult == 1.0, f"Level 1 HP mult should be 1.0, got {mult}"


@pytest.mark.asyncio
async def test_difficulty_enemy_hp_multiplier_level_2(game):
    """Level 2 should have 1.5x HP multiplier."""
    await game.call("GameManager", "set_difficulty_level", [2])
    mult = await game.call("GameManager", "get_difficulty_enemy_hp_multiplier")
    assert mult == 1.5, f"Level 2 HP mult should be 1.5, got {mult}"

    # Reset
    await game.call("GameManager", "set_difficulty_level", [1])


@pytest.mark.asyncio
async def test_difficulty_enemy_hp_multiplier_level_3(game):
    """Level 3 should have 2.25x HP multiplier (1.5^2)."""
    await game.call("GameManager", "set_difficulty_level", [3])
    mult = await game.call("GameManager", "get_difficulty_enemy_hp_multiplier")
    expected = 1.5 ** 2  # 2.25
    assert abs(mult - expected) < 0.01, f"Level 3 HP mult should be {expected}, got {mult}"

    # Reset
    await game.call("GameManager", "set_difficulty_level", [1])


@pytest.mark.asyncio
async def test_difficulty_xp_multiplier_level_1(game):
    """Level 1 should have 1.0x XP multiplier."""
    await game.call("GameManager", "set_difficulty_level", [1])
    mult = await game.call("GameManager", "get_difficulty_xp_multiplier")
    assert mult == 1.0, f"Level 1 XP mult should be 1.0, got {mult}"


@pytest.mark.asyncio
async def test_difficulty_xp_multiplier_level_5(game):
    """Level 5 should have 1.6x XP multiplier (1.0 + 0.15*4)."""
    await game.call("GameManager", "set_difficulty_level", [5])
    mult = await game.call("GameManager", "get_difficulty_xp_multiplier")
    expected = 1.0 + (0.15 * 4)  # 1.6
    assert abs(mult - expected) < 0.01, f"Level 5 XP mult should be {expected}, got {mult}"

    # Reset
    await game.call("GameManager", "set_difficulty_level", [1])


@pytest.mark.asyncio
async def test_difficulty_spawn_rate_multiplier(game):
    """Level 5 should have 1.8x spawn rate (1.0 + 0.2*4)."""
    await game.call("GameManager", "set_difficulty_level", [5])
    mult = await game.call("GameManager", "get_difficulty_spawn_rate_multiplier")
    expected = 1.0 + (0.2 * 4)  # 1.8
    assert abs(mult - expected) < 0.01, f"Level 5 spawn mult should be {expected}, got {mult}"

    # Reset
    await game.call("GameManager", "set_difficulty_level", [1])


@pytest.mark.asyncio
async def test_difficulty_name_normal(game):
    """Level 1 should be named 'Normal'."""
    await game.call("GameManager", "set_difficulty_level", [1])
    name = await game.call("GameManager", "get_difficulty_name")
    assert name == "Normal", f"Level 1 name should be 'Normal', got '{name}'"


@pytest.mark.asyncio
async def test_difficulty_name_fast_plus_3(game):
    """Level 5 should be named 'Fast+3'."""
    await game.call("GameManager", "set_difficulty_level", [5])
    name = await game.call("GameManager", "get_difficulty_name")
    assert name == "Fast+3", f"Level 5 name should be 'Fast+3', got '{name}'"

    # Reset
    await game.call("GameManager", "set_difficulty_level", [1])


# === MetaManager Difficulty Tracking Tests ===

@pytest.mark.asyncio
async def test_meta_record_difficulty_completion(game):
    """Should be able to record difficulty completions."""
    # Reset meta data first
    await game.call("MetaManager", "reset_data")

    # Record a completion
    is_new = await game.call("MetaManager", "record_difficulty_completion", ["TestChar", 0, 3])
    assert is_new == True, "First completion should return True"

    # Check it was recorded
    highest = await game.call("MetaManager", "get_highest_difficulty_beaten", ["TestChar", 0])
    assert highest == 3, f"Highest should be 3, got {highest}"


@pytest.mark.asyncio
async def test_meta_cascading_completion(game):
    """Beating level N should count as beating 1..N."""
    await game.call("MetaManager", "reset_data")

    # Beat level 5
    await game.call("MetaManager", "record_difficulty_completion", ["CascadeChar", 0, 5])

    # Should count as having beaten 1-5
    has_beaten_3 = await game.call("MetaManager", "has_beaten_difficulty", [0, 3])
    assert has_beaten_3 == True, "Beating level 5 should count as beating level 3"

    has_beaten_5 = await game.call("MetaManager", "has_beaten_difficulty", [0, 5])
    assert has_beaten_5 == True, "Should have beaten level 5"

    has_beaten_6 = await game.call("MetaManager", "has_beaten_difficulty", [0, 6])
    assert has_beaten_6 == False, "Should NOT have beaten level 6"


@pytest.mark.asyncio
async def test_meta_no_duplicate_record(game):
    """Recording same or lower difficulty should return False."""
    await game.call("MetaManager", "reset_data")

    # Beat level 5
    await game.call("MetaManager", "record_difficulty_completion", ["DupeChar", 0, 5])

    # Try to record level 3 (lower)
    is_new = await game.call("MetaManager", "record_difficulty_completion", ["DupeChar", 0, 3])
    assert is_new == False, "Recording lower difficulty should return False"

    # Try to record level 5 again
    is_new = await game.call("MetaManager", "record_difficulty_completion", ["DupeChar", 0, 5])
    assert is_new == False, "Recording same difficulty should return False"


@pytest.mark.asyncio
async def test_meta_highest_for_stage(game):
    """get_highest_difficulty_for_stage should return max across all characters."""
    await game.call("MetaManager", "reset_data")

    # Different characters beat different levels
    await game.call("MetaManager", "record_difficulty_completion", ["CharA", 0, 3])
    await game.call("MetaManager", "record_difficulty_completion", ["CharB", 0, 7])
    await game.call("MetaManager", "record_difficulty_completion", ["CharC", 0, 5])

    highest = await game.call("MetaManager", "get_highest_difficulty_for_stage", [0])
    assert highest == 7, f"Highest for stage should be 7, got {highest}"
