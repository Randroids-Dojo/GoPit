"""Tests for the character selection system."""
import asyncio
import pytest


@pytest.mark.asyncio
async def test_character_select_exists(game):
    """Test that character select UI exists in the scene."""
    char_select = await game.get_node("/root/Game/UI/CharacterSelect")
    assert char_select is not None, "CharacterSelect should exist"


@pytest.mark.asyncio
async def test_character_select_can_show(game):
    """Test that character select can be shown."""
    # Call show_select on the character select
    await game.call("/root/Game/UI/CharacterSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Check it's visible via property
    visible = await game.get_property(
        "/root/Game/UI/CharacterSelect/DimBackground", "visible"
    )
    assert visible, "Character select should be visible after show_select"


@pytest.mark.asyncio
async def test_character_navigation_buttons(game):
    """Test that prev/next buttons exist and can navigate."""
    # Show character select
    await game.call("/root/Game/UI/CharacterSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Get initial character name
    initial_name = await game.get_property(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/NameLabel",
        "text"
    )
    assert initial_name, "Should have a character name displayed"

    # Click next button
    await game.click(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/NavContainer/NextButton"
    )
    await asyncio.sleep(0.2)

    # Get new character name
    new_name = await game.get_property(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/NameLabel",
        "text"
    )
    assert new_name != initial_name, f"Character should change after clicking next (was {initial_name}, now {new_name})"


@pytest.mark.asyncio
async def test_character_stats_display(game):
    """Test that character stats are displayed."""
    # Show character select
    await game.call("/root/Game/UI/CharacterSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Check stat bars exist
    hp_bar = await game.get_node(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/HPStat/Bar"
    )
    assert hp_bar is not None, "HP stat bar should exist"

    dmg_bar = await game.get_node(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/DMGStat/Bar"
    )
    assert dmg_bar is not None, "DMG stat bar should exist"


@pytest.mark.asyncio
async def test_passive_info_display(game):
    """Test that passive ability info is displayed."""
    # Show character select
    await game.call("/root/Game/UI/CharacterSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Check passive name label
    passive_text = await game.get_property(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/AbilityPanel/VBoxContainer/PassiveName",
        "text"
    )
    assert "Passive:" in passive_text, f"Passive name should be shown: {passive_text}"


@pytest.mark.asyncio
async def test_start_button_begins_game(game):
    """Test that clicking start button begins the game."""
    # Show character select
    await game.call("/root/Game/UI/CharacterSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Click start button
    await game.click(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/StartButton"
    )
    await asyncio.sleep(0.3)

    # Check game state is PLAYING (enum value 1)
    state = await game.get_property("/root/GameManager", "current_state")
    assert state == 1, f"Game should be in PLAYING state (1), got {state}"


@pytest.mark.asyncio
async def test_locked_character_overlay(game):
    """Test that locked characters show the locked overlay."""
    # Show character select
    await game.call("/root/Game/UI/CharacterSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Navigate to Vampire (index 5, which is locked)
    for _ in range(5):
        await game.click(
            "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/NavContainer/NextButton"
        )
        await asyncio.sleep(0.15)

    # Check locked overlay is visible
    locked_visible = await game.get_property(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/LockedOverlay",
        "visible"
    )
    assert locked_visible, "Locked overlay should be visible for Vampire"


@pytest.mark.asyncio
async def test_character_stats_affect_gameplay(game):
    """Test that selected character's stats affect the game."""
    # Show character select
    await game.call("/root/Game/UI/CharacterSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Navigate to Pyro (index 1) who has high strength (1.4) and low endurance (0.8)
    await game.click(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/NavContainer/NextButton"
    )
    await asyncio.sleep(0.2)

    # Verify we're on Pyro
    name = await game.get_property(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/NameLabel",
        "text"
    )
    assert name == "PYRO", f"Should be on Pyro character, got {name}"

    # Start game
    await game.click(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/StartButton"
    )
    await asyncio.sleep(0.3)

    # Check that max_hp reflects Pyro's endurance (0.8 * 100 = 80)
    max_hp = await game.get_property("/root/GameManager", "max_hp")
    assert max_hp == 80, f"Pyro should have 80 max HP (0.8 endurance), got {max_hp}"

    # Check damage multiplier
    damage_mult = await game.get_property("/root/GameManager", "character_damage_mult")
    assert abs(damage_mult - 1.4) < 0.01, f"Pyro should have 1.4 damage mult, got {damage_mult}"


@pytest.mark.asyncio
async def test_starting_ball_type(game):
    """Test that character's starting ball type is applied."""
    # Show character select
    await game.call("/root/Game/UI/CharacterSelect", "show_select", [])
    await asyncio.sleep(0.2)

    # Navigate to Pyro (index 1) who starts with Fire ball (type 1)
    await game.click(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/NavContainer/NextButton"
    )
    await asyncio.sleep(0.2)

    # Start game
    await game.click(
        "/root/Game/UI/CharacterSelect/DimBackground/Panel/VBoxContainer/StartButton"
    )
    await asyncio.sleep(0.3)

    # Check ball spawner has fire ball type
    ball_type = await game.get_property("/root/Game/GameArea/BallSpawner", "ball_type")
    assert ball_type == 1, f"Pyro should start with Fire ball (type 1), got {ball_type}"
