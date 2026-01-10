"""Tests for audio settings system."""
import asyncio
import pytest

GAME = "/root/Game"
SOUND_MANAGER = "/root/SoundManager"
HUD = "/root/Game/UI/HUD"
MUTE_BUTTON = "/root/Game/UI/HUD/TopBar/MuteButton"


@pytest.mark.asyncio
async def test_sound_manager_exists(game):
    """SoundManager autoload should be accessible."""
    node = await game.get_node(SOUND_MANAGER)
    assert node is not None, "SoundManager autoload should exist"


@pytest.mark.asyncio
async def test_sound_manager_has_volume_properties(game):
    """SoundManager should have master, sfx, and music volume properties."""
    # Check master_volume
    master = await game.get_property(SOUND_MANAGER, "master_volume")
    assert 0.0 <= master <= 1.0, f"master_volume should be 0-1, got {master}"

    # Check sfx_volume
    sfx = await game.get_property(SOUND_MANAGER, "sfx_volume")
    assert 0.0 <= sfx <= 1.0, f"sfx_volume should be 0-1, got {sfx}"

    # Check music_volume
    music = await game.get_property(SOUND_MANAGER, "music_volume")
    assert 0.0 <= music <= 1.0, f"music_volume should be 0-1, got {music}"


@pytest.mark.asyncio
async def test_sound_manager_has_mute_property(game):
    """SoundManager should have is_muted property."""
    is_muted = await game.get_property(SOUND_MANAGER, "is_muted")
    assert isinstance(is_muted, bool), f"is_muted should be bool, got {type(is_muted)}"


@pytest.mark.asyncio
async def test_toggle_mute_changes_state(game):
    """toggle_mute should toggle is_muted state."""
    initial_muted = await game.get_property(SOUND_MANAGER, "is_muted")

    await game.call(SOUND_MANAGER, "toggle_mute")
    await asyncio.sleep(0.1)

    new_muted = await game.get_property(SOUND_MANAGER, "is_muted")
    assert new_muted != initial_muted, "toggle_mute should change is_muted state"

    # Toggle back to original state
    await game.call(SOUND_MANAGER, "toggle_mute")


@pytest.mark.asyncio
async def test_mute_button_exists_in_hud(game):
    """HUD should have a mute button."""
    button = await game.get_node(MUTE_BUTTON)
    assert button is not None, "Mute button should exist in HUD TopBar"


@pytest.mark.asyncio
async def test_mute_button_click_toggles_mute(game):
    """Clicking mute button should toggle mute state."""
    initial_muted = await game.get_property(SOUND_MANAGER, "is_muted")

    # Click mute button
    await game.click(MUTE_BUTTON)
    await asyncio.sleep(0.15)

    new_muted = await game.get_property(SOUND_MANAGER, "is_muted")
    assert new_muted != initial_muted, "Clicking mute button should toggle mute state"

    # Click again to restore
    await game.click(MUTE_BUTTON)
    await asyncio.sleep(0.15)

    restored_muted = await game.get_property(SOUND_MANAGER, "is_muted")
    assert restored_muted == initial_muted, "Second click should restore original state"


@pytest.mark.asyncio
async def test_set_volume_methods_exist(game):
    """SoundManager should have set volume methods."""
    # Test set_master_volume
    await game.call(SOUND_MANAGER, "set_master_volume", [0.8])
    master = await game.get_property(SOUND_MANAGER, "master_volume")
    assert abs(master - 0.8) < 0.01, f"set_master_volume should work, got {master}"

    # Restore
    await game.call(SOUND_MANAGER, "set_master_volume", [1.0])


@pytest.mark.asyncio
async def test_volume_clamped_to_valid_range(game):
    """Volume values should be clamped to 0-1 range."""
    # Try setting volume > 1
    await game.call(SOUND_MANAGER, "set_master_volume", [2.0])
    master = await game.get_property(SOUND_MANAGER, "master_volume")
    assert master == 1.0, f"Volume > 1 should clamp to 1.0, got {master}"

    # Try setting volume < 0
    await game.call(SOUND_MANAGER, "set_master_volume", [-0.5])
    master = await game.get_property(SOUND_MANAGER, "master_volume")
    assert master == 0.0, f"Volume < 0 should clamp to 0.0, got {master}"

    # Restore
    await game.call(SOUND_MANAGER, "set_master_volume", [1.0])


@pytest.mark.asyncio
async def test_ball_type_sound_method_exists(game):
    """SoundManager should have play_ball_type_sound method."""
    # Call for fire ball (type 1) - shouldn't error
    await game.call(SOUND_MANAGER, "play_ball_type_sound", [1])
    await asyncio.sleep(0.1)
    # If we get here without error, the method exists and works


@pytest.mark.asyncio
async def test_status_effect_sound_method_exists(game):
    """SoundManager should have play_status_effect_sound method."""
    # Call for burn effect (type 0) - shouldn't error
    await game.call(SOUND_MANAGER, "play_status_effect_sound", [0])
    await asyncio.sleep(0.1)
    # If we get here without error, the method exists and works
