"""Tests for the achievement system."""
import asyncio
import pytest

META_MANAGER = "/root/MetaManager"


@pytest.mark.asyncio
async def test_achievements_constant_exists(game):
    """ACHIEVEMENTS constant should be defined."""
    achievements = await game.get_property(META_MANAGER, "ACHIEVEMENTS")
    assert achievements is not None
    assert len(achievements) > 0, "Should have at least one achievement"


@pytest.mark.asyncio
async def test_unlocked_achievements_starts_empty(game):
    """Unlocked achievements should start empty after reset."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)
    unlocked = await game.get_property(META_MANAGER, "unlocked_achievements")
    assert len(unlocked) == 0, "Should have no unlocked achievements initially"


@pytest.mark.asyncio
async def test_lifetime_stats_start_at_zero(game):
    """Lifetime stats should start at zero after reset."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)
    kills = await game.get_property(META_MANAGER, "lifetime_kills")
    gems = await game.get_property(META_MANAGER, "lifetime_gems")
    damage = await game.get_property(META_MANAGER, "lifetime_damage")
    assert kills == 0, "Lifetime kills should be 0"
    assert gems == 0, "Lifetime gems should be 0"
    assert damage == 0, "Lifetime damage should be 0"


@pytest.mark.asyncio
async def test_is_achievement_unlocked_initially_false(game):
    """is_achievement_unlocked should return false for all achievements initially."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)
    is_unlocked = await game.call(META_MANAGER, "is_achievement_unlocked", ["first_run"])
    assert is_unlocked is False, "first_run should not be unlocked initially"


@pytest.mark.asyncio
async def test_unlock_achievement_manually(game):
    """unlock_achievement should add to unlocked list."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    await game.call(META_MANAGER, "unlock_achievement", ["first_run"])
    is_unlocked = await game.call(META_MANAGER, "is_achievement_unlocked", ["first_run"])
    assert is_unlocked is True, "first_run should be unlocked after manual unlock"


@pytest.mark.asyncio
async def test_unlock_achievement_awards_coins(game):
    """unlock_achievement should award pit coins."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)
    initial_coins = await game.get_property(META_MANAGER, "pit_coins")

    await game.call(META_MANAGER, "unlock_achievement", ["first_run"])
    after_coins = await game.get_property(META_MANAGER, "pit_coins")

    # first_run reward is 50
    assert after_coins == initial_coins + 50, f"Should earn 50 coins, got {after_coins - initial_coins}"


@pytest.mark.asyncio
async def test_check_achievements_unlocks_met_conditions(game):
    """check_achievements should unlock achievements with met conditions."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Record run end to meet first_run condition (1 run)
    await game.call(META_MANAGER, "record_run_end", [5, 1, 10, 5, 100])

    is_unlocked = await game.call(META_MANAGER, "is_achievement_unlocked", ["first_run"])
    assert is_unlocked is True, "first_run should be unlocked after 1 run"


@pytest.mark.asyncio
async def test_record_run_end_accumulates_lifetime_stats(game):
    """record_run_end should accumulate lifetime stats."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Record run with 50 kills, 25 gems, 1000 damage
    await game.call(META_MANAGER, "record_run_end", [10, 2, 50, 25, 1000])

    kills = await game.get_property(META_MANAGER, "lifetime_kills")
    gems = await game.get_property(META_MANAGER, "lifetime_gems")
    damage = await game.get_property(META_MANAGER, "lifetime_damage")

    assert kills == 50, f"Lifetime kills should be 50, got {kills}"
    assert gems == 25, f"Lifetime gems should be 25, got {gems}"
    assert damage == 1000, f"Lifetime damage should be 1000, got {damage}"


@pytest.mark.asyncio
async def test_lifetime_stats_accumulate_across_runs(game):
    """Lifetime stats should accumulate across multiple runs."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Two runs
    await game.call(META_MANAGER, "record_run_end", [5, 1, 30, 10, 500])
    await game.call(META_MANAGER, "record_run_end", [8, 2, 70, 40, 1500])

    kills = await game.get_property(META_MANAGER, "lifetime_kills")
    gems = await game.get_property(META_MANAGER, "lifetime_gems")

    assert kills == 100, f"Lifetime kills should be 100 (30+70), got {kills}"
    assert gems == 50, f"Lifetime gems should be 50 (10+40), got {gems}"


@pytest.mark.asyncio
async def test_kills_achievement_unlocks(game):
    """Kill count achievements should unlock when threshold met."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Record enough kills for kills_100 (100 kills)
    await game.call(META_MANAGER, "record_run_end", [10, 3, 100, 0, 0])

    is_unlocked = await game.call(META_MANAGER, "is_achievement_unlocked", ["kills_100"])
    assert is_unlocked is True, "kills_100 should be unlocked after 100 kills"


@pytest.mark.asyncio
async def test_get_achievement_data(game):
    """get_achievement_data should return achievement definition."""
    data = await game.call(META_MANAGER, "get_achievement_data", ["first_run"])
    assert data is not None
    assert data.get("name") == "Baby Steps"
    assert data.get("reward") == 50


@pytest.mark.asyncio
async def test_get_all_achievements(game):
    """get_all_achievements should return all achievement IDs."""
    all_ids = await game.call(META_MANAGER, "get_all_achievements")
    assert len(all_ids) >= 15, f"Should have at least 15 achievements, got {len(all_ids)}"
    assert "first_run" in all_ids
    assert "first_kill" in all_ids


@pytest.mark.asyncio
async def test_get_achievement_progress(game):
    """get_achievement_progress should return current progress."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    # Record some kills
    await game.call(META_MANAGER, "record_run_end", [5, 1, 50, 0, 0])

    progress = await game.call(META_MANAGER, "get_achievement_progress", ["kills_100"])
    assert progress.get("current") == 50, "Current should be 50 kills"
    assert progress.get("required") == 100, "Required should be 100"
    assert progress.get("is_unlocked") is False, "Should not be unlocked yet"


@pytest.mark.asyncio
async def test_duplicate_unlock_no_extra_coins(game):
    """Unlocking same achievement twice should not award extra coins."""
    await game.call(META_MANAGER, "reset_data")
    await asyncio.sleep(0.1)

    await game.call(META_MANAGER, "unlock_achievement", ["first_run"])
    coins_after_first = await game.get_property(META_MANAGER, "pit_coins")

    await game.call(META_MANAGER, "unlock_achievement", ["first_run"])
    coins_after_second = await game.get_property(META_MANAGER, "pit_coins")

    assert coins_after_second == coins_after_first, "Should not earn extra coins on duplicate unlock"
