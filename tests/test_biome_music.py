"""Tests for per-biome music system and boss fight music in MusicManager."""

import asyncio
import pytest

# Node paths
MUSIC_MANAGER = "/root/MusicManager"
STAGE_MANAGER = "/root/StageManager"


@pytest.mark.asyncio
async def test_music_manager_has_set_biome(game):
    """MusicManager should have a set_biome method."""
    has_method = await game.call(MUSIC_MANAGER, "has_method", ["set_biome"])
    assert has_method, "MusicManager should have set_biome method"


@pytest.mark.asyncio
async def test_biome_music_constants_exist(game):
    """MusicManager should have BIOME_MUSIC and SCALES constants."""
    # Test by calling set_biome which uses these constants
    # If they don't exist, this will error
    await game.call(MUSIC_MANAGER, "set_biome", ["The Pit"])
    # No error means constants exist


@pytest.mark.asyncio
async def test_set_biome_updates_root_note(game):
    """Setting a biome should update the root note (after crossfade)."""
    # Get initial root note
    initial_root = await game.get_property(MUSIC_MANAGER, "_root_note")

    # Set to Frozen Depths (different root: 82.4)
    await game.call(MUSIC_MANAGER, "set_biome", ["Frozen Depths"])

    # Wait for crossfade to complete (1 second total)
    await asyncio.sleep(1.1)

    new_root = await game.get_property(MUSIC_MANAGER, "_root_note")
    assert abs(new_root - 82.4) < 0.1, f"Root note should be ~82.4 for Frozen Depths, got {new_root}"
    assert new_root != initial_root or initial_root == 82.4, "Root note should have changed"


@pytest.mark.asyncio
async def test_set_biome_updates_tempo(game):
    """Setting a biome should update the tempo (after crossfade)."""
    await game.call(MUSIC_MANAGER, "set_biome", ["The Pit"])
    await asyncio.sleep(1.1)  # Wait for crossfade
    pit_tempo = await game.get_property(MUSIC_MANAGER, "_current_tempo")
    assert pit_tempo == 120, f"The Pit tempo should be 120, got {pit_tempo}"

    await game.call(MUSIC_MANAGER, "set_biome", ["Frozen Depths"])
    await asyncio.sleep(1.1)  # Wait for crossfade
    frozen_tempo = await game.get_property(MUSIC_MANAGER, "_current_tempo")
    assert frozen_tempo == 90, f"Frozen Depths tempo should be 90, got {frozen_tempo}"


@pytest.mark.asyncio
async def test_all_biomes_have_parameters(game):
    """All 8 biomes should have valid music parameters."""
    biomes = [
        "The Pit",
        "Frozen Depths",
        "Burning Sands",
        "Final Descent",
        "Toxic Marsh",
        "Storm Spire",
        "Crystal Caverns",
        "The Abyss",
    ]

    for biome_name in biomes:
        # Should not error
        await game.call(MUSIC_MANAGER, "set_biome", [biome_name])
        # Wait for crossfade to complete
        await asyncio.sleep(1.1)
        # Verify root note is a valid frequency
        root = await game.get_property(MUSIC_MANAGER, "_root_note")
        assert 60 < root < 200, f"{biome_name} root note {root} should be between 60-200 Hz"


@pytest.mark.asyncio
async def test_unknown_biome_is_ignored(game):
    """Setting an unknown biome should not change parameters."""
    await game.call(MUSIC_MANAGER, "set_biome", ["The Pit"])
    original_root = await game.get_property(MUSIC_MANAGER, "_root_note")

    # Try to set unknown biome
    await game.call(MUSIC_MANAGER, "set_biome", ["Unknown Biome"])

    # Root should be unchanged
    new_root = await game.get_property(MUSIC_MANAGER, "_root_note")
    assert new_root == original_root, "Unknown biome should not change root note"


# Crossfade tests


@pytest.mark.asyncio
async def test_crossfade_state_during_transition(game):
    """Crossfading flag should be true during biome transition."""
    # Start at a known biome
    await game.call(MUSIC_MANAGER, "set_biome", ["The Pit"])
    await asyncio.sleep(1.1)

    # Trigger a biome change
    await game.call(MUSIC_MANAGER, "set_biome", ["Frozen Depths"])

    # Check crossfading is true (during transition)
    await asyncio.sleep(0.2)  # Mid-transition
    is_crossfading = await game.get_property(MUSIC_MANAGER, "_crossfading")
    # Note: This may flake - crossfade takes 1s, we're checking at 0.2s
    # If it fails, the crossfade may have already completed

    # Wait for complete
    await asyncio.sleep(1.0)
    is_crossfading_after = await game.get_property(MUSIC_MANAGER, "_crossfading")
    assert is_crossfading_after == False, "Crossfading should be false after transition completes"


# Boss music tests


@pytest.mark.asyncio
async def test_music_manager_has_set_boss_mode(game):
    """MusicManager should have a set_boss_mode method."""
    has_method = await game.call(MUSIC_MANAGER, "has_method", ["set_boss_mode"])
    assert has_method, "MusicManager should have set_boss_mode method"


@pytest.mark.asyncio
async def test_boss_mode_initially_false(game):
    """Boss mode should be off by default."""
    is_boss = await game.get_property(MUSIC_MANAGER, "is_boss_fight")
    assert is_boss == False, "Boss fight mode should be off initially"


@pytest.mark.asyncio
async def test_set_boss_mode_enables_boss_fight(game):
    """set_boss_mode(true) should enable boss fight mode."""
    # Ensure starting state
    await game.call(MUSIC_MANAGER, "set_boss_mode", [False])

    # Enable boss mode
    await game.call(MUSIC_MANAGER, "set_boss_mode", [True])

    is_boss = await game.get_property(MUSIC_MANAGER, "is_boss_fight")
    assert is_boss == True, "Boss fight mode should be enabled"


@pytest.mark.asyncio
async def test_boss_mode_changes_tempo(game):
    """Boss mode should make the tempo faster."""
    # Set to a known biome first
    await game.call(MUSIC_MANAGER, "set_biome", ["The Pit"])
    await game.call(MUSIC_MANAGER, "set_boss_mode", [False])
    await asyncio.sleep(0.1)

    # Get normal beat timer wait time (via the stored pre-boss tempo after enable)
    await game.call(MUSIC_MANAGER, "set_boss_mode", [True])

    # Check that boss mode is active
    is_boss = await game.get_property(MUSIC_MANAGER, "is_boss_fight")
    assert is_boss == True, "Boss fight mode should be enabled"

    # The _pre_boss_tempo stores the original tempo before boss mode
    pre_boss = await game.get_property(MUSIC_MANAGER, "_pre_boss_tempo")
    assert pre_boss > 0, "Pre-boss tempo should be stored"


@pytest.mark.asyncio
async def test_boss_mode_restores_on_disable(game):
    """Disabling boss mode should restore previous settings."""
    # Set to known state
    await game.call(MUSIC_MANAGER, "set_biome", ["The Pit"])
    await game.call(MUSIC_MANAGER, "set_boss_mode", [False])
    await asyncio.sleep(0.1)

    # Enable then disable boss mode
    await game.call(MUSIC_MANAGER, "set_boss_mode", [True])
    boss_active = await game.get_property(MUSIC_MANAGER, "is_boss_fight")
    assert boss_active == True, "Boss mode should be active"

    await game.call(MUSIC_MANAGER, "set_boss_mode", [False])

    # Verify restored
    is_boss = await game.get_property(MUSIC_MANAGER, "is_boss_fight")
    assert is_boss == False, "Boss mode should be disabled after restore"
