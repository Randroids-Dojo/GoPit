"""Tests for per-biome music system in MusicManager."""

import asyncio
import pytest

# Node paths
MUSIC_MANAGER = "/root/MusicManager"


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
    """Setting a biome should update the root note."""
    # Get initial root note
    initial_root = await game.get_property(MUSIC_MANAGER, "_root_note")

    # Set to Frozen Depths (different root: 82.4)
    await game.call(MUSIC_MANAGER, "set_biome", ["Frozen Depths"])

    new_root = await game.get_property(MUSIC_MANAGER, "_root_note")
    assert abs(new_root - 82.4) < 0.1, f"Root note should be ~82.4 for Frozen Depths, got {new_root}"
    assert new_root != initial_root or initial_root == 82.4, "Root note should have changed"


@pytest.mark.asyncio
async def test_set_biome_updates_tempo(game):
    """Setting a biome should update the tempo."""
    await game.call(MUSIC_MANAGER, "set_biome", ["The Pit"])
    pit_tempo = await game.get_property(MUSIC_MANAGER, "_current_tempo")
    assert pit_tempo == 120, f"The Pit tempo should be 120, got {pit_tempo}"

    await game.call(MUSIC_MANAGER, "set_biome", ["Frozen Depths"])
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
