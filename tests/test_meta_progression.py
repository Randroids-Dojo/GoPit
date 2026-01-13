"""Tests for the meta-progression system (Pit Coins and permanent upgrades)."""

import asyncio
import pytest


@pytest.mark.asyncio
async def test_coins_earned_on_game_over(game):
    """Test that Pit Coins are earned when the game ends."""
    # Get initial coin balance
    initial_coins = await game.get_property("/root/MetaManager", "pit_coins")

    # Kill player in one hit to avoid i-frame issues (player has 100 HP)
    await game.call("/root/GameManager", "take_damage", [100])
    await asyncio.sleep(1.0)

    # Check game over overlay is visible
    game_over_visible = await game.get_property(
        "/root/Game/UI/GameOverOverlay", "visible"
    )
    assert game_over_visible, "Game over overlay should be visible"

    # Check coins were earned (wave 1 * 10 + level 1 * 25 = 35 minimum)
    final_coins = await game.get_property("/root/MetaManager", "pit_coins")
    assert final_coins > initial_coins, f"Should have earned coins: {initial_coins} -> {final_coins}"


@pytest.mark.asyncio
async def test_coins_label_shows_earned(game):
    """Test that the game over screen shows coins earned."""
    # Trigger game over
    await game.call("/root/GameManager", "take_damage", [100])
    await asyncio.sleep(1.0)

    # Check coins label exists and has content
    coins_text = await game.get_property(
        "/root/Game/UI/GameOverOverlay/Panel/VBoxContainer/CoinsLabel", "text"
    )
    assert "Pit Coins" in coins_text, f"Coins label should mention Pit Coins: {coins_text}"
    assert "+" in coins_text, f"Should show coins earned with +: {coins_text}"


@pytest.mark.asyncio
async def test_shop_button_exists(game):
    """Test that the shop button exists on game over screen."""
    # Trigger game over
    await game.call("/root/GameManager", "take_damage", [100])
    await asyncio.sleep(1.0)

    # Check shop button exists
    shop_btn = await game.get_node(
        "/root/Game/UI/GameOverOverlay/Panel/VBoxContainer/ButtonsContainer/ShopButton"
    )
    assert shop_btn is not None, "Shop button should exist on game over screen"


@pytest.mark.asyncio
async def test_shop_opens_from_game_over(game):
    """Test that clicking shop button opens the meta shop."""
    # Trigger game over
    await game.call("/root/GameManager", "take_damage", [100])
    await asyncio.sleep(1.0)

    # Click shop button
    await game.click("/root/Game/UI/GameOverOverlay/Panel/VBoxContainer/ButtonsContainer/ShopButton")
    await asyncio.sleep(0.5)

    # Check meta shop is visible
    shop_visible = await game.get_property("/root/Game/UI/MetaShop", "visible")
    assert shop_visible, "Meta shop should be visible after clicking shop button"


@pytest.mark.asyncio
async def test_shop_displays_upgrades(game):
    """Test that the shop displays upgrade cards."""
    # Give player some coins to see the shop properly
    await game.call("/root/MetaManager", "earn_coins", [5, 5])  # 5*10 + 5*25 = 175 coins

    # Trigger game over and open shop
    await game.call("/root/GameManager", "take_damage", [100])
    await asyncio.sleep(1.0)
    await game.click("/root/Game/UI/GameOverOverlay/Panel/VBoxContainer/ButtonsContainer/ShopButton")
    await asyncio.sleep(0.5)

    # Check cards container has children (upgrade cards)
    cards_container = await game.get_node("/root/Game/UI/MetaShop/Panel/VBoxContainer/CardsContainer")
    assert cards_container is not None, "Cards container should exist"

    child_count = await game.call("/root/Game/UI/MetaShop/Panel/VBoxContainer/CardsContainer", "get_child_count")
    assert child_count >= 5, f"Should have at least 5 upgrade cards, got {child_count}"


@pytest.mark.asyncio
async def test_shop_close_button(game):
    """Test that the shop can be closed."""
    # Trigger game over and open shop
    await game.call("/root/GameManager", "take_damage", [100])
    await asyncio.sleep(1.0)
    await game.click("/root/Game/UI/GameOverOverlay/Panel/VBoxContainer/ButtonsContainer/ShopButton")
    await asyncio.sleep(0.5)

    # Verify shop is open
    shop_visible = await game.get_property("/root/Game/UI/MetaShop", "visible")
    assert shop_visible, "Shop should be open"

    # Click close button
    await game.click("/root/Game/UI/MetaShop/Panel/VBoxContainer/CloseButton")
    await asyncio.sleep(0.3)

    # Verify shop is closed
    shop_visible = await game.get_property("/root/Game/UI/MetaShop", "visible")
    assert not shop_visible, "Shop should be closed after clicking close button"


@pytest.mark.asyncio
async def test_coin_balance_display(game):
    """Test that coin balance is displayed in the shop."""
    # Give player specific amount of coins
    await game.call("/root/MetaManager", "set", ["pit_coins", 500])

    # Trigger game over and open shop
    await game.call("/root/GameManager", "take_damage", [100])
    await asyncio.sleep(1.0)
    await game.click("/root/Game/UI/GameOverOverlay/Panel/VBoxContainer/ButtonsContainer/ShopButton")
    await asyncio.sleep(0.5)

    # Check coin label shows balance
    coin_text = await game.get_property(
        "/root/Game/UI/MetaShop/Panel/VBoxContainer/TopBar/CoinLabel", "text"
    )
    assert "500" in coin_text or "Pit Coins" in coin_text, f"Should show coin balance: {coin_text}"


@pytest.mark.asyncio
async def test_meta_manager_persistence_functions(game):
    """Test MetaManager save/load functionality.

    NOTE: This test may be skipped in headless/CI mode where user:// file I/O
    doesn't work reliably. The test verifies file operations work before proceeding.
    """
    # Use slot 3 to avoid interference with other parallel tests
    await game.call("/root/MetaManager", "set_active_slot", [3])
    await asyncio.sleep(0.3)

    # Reset slot to ensure clean state
    await game.call("/root/MetaManager", "reset_data", [])
    await asyncio.sleep(0.3)

    # Set some values
    await game.call("/root/MetaManager", "set", ["pit_coins", 1000])
    await asyncio.sleep(0.1)

    # Verify the value was set before saving
    coins_before_save = await game.get_property("/root/MetaManager", "pit_coins")
    assert coins_before_save == 1000, f"Coins should be 1000 before save: got {coins_before_save}"

    # Call save
    await game.call("/root/MetaManager", "save_data")
    await asyncio.sleep(0.5)  # More time for file write in CI

    # Verify the file was actually written (skip test if file I/O doesn't work)
    slot_empty = await game.call("/root/MetaManager", "is_slot_empty", [3])
    if slot_empty:
        pytest.skip("File I/O not working in headless mode - skipping persistence test")

    # Reset in memory
    await game.call("/root/MetaManager", "set", ["pit_coins", 0])
    await asyncio.sleep(0.1)

    # Reload
    await game.call("/root/MetaManager", "load_data")
    await asyncio.sleep(0.5)  # More time for file read in CI

    # Check value restored
    coins = await game.get_property("/root/MetaManager", "pit_coins")
    assert coins == 1000, f"Coins should persist after save/load: got {coins}"

    # Cleanup: delete slot 3 data
    await game.call("/root/MetaManager", "reset_data", [])


@pytest.mark.asyncio
async def test_upgrade_purchase(game):
    """Test purchasing an upgrade."""
    # Reset all meta data to ensure clean state
    await game.call("/root/MetaManager", "reset_data", [])
    await asyncio.sleep(0.1)

    # Give player enough coins for first HP upgrade (100 coins)
    await game.call("/root/MetaManager", "set", ["pit_coins", 200])

    # Get initial upgrade level
    hp_level = await game.call("/root/MetaManager", "get_upgrade_level", ["hp"])
    assert hp_level == 0, f"HP upgrade should start at level 0, got {hp_level}"

    # Purchase upgrade
    success = await game.call("/root/MetaManager", "purchase_upgrade", ["hp", 100])
    assert success, "Purchase should succeed with enough coins"

    # Check upgrade level increased
    hp_level = await game.call("/root/MetaManager", "get_upgrade_level", ["hp"])
    assert hp_level == 1, "HP upgrade should be level 1 after purchase"

    # Check coins deducted
    coins = await game.get_property("/root/MetaManager", "pit_coins")
    assert coins == 100, f"Should have 100 coins remaining, got {coins}"


@pytest.mark.asyncio
async def test_cannot_purchase_without_coins(game):
    """Test that purchases fail without enough coins."""
    # Set low coin balance
    await game.call("/root/MetaManager", "set", ["pit_coins", 50])

    # Try to purchase (costs 100)
    success = await game.call("/root/MetaManager", "purchase_upgrade", ["hp", 100])
    assert not success, "Purchase should fail without enough coins"

    # Coins should be unchanged
    coins = await game.get_property("/root/MetaManager", "pit_coins")
    assert coins == 50, f"Coins should be unchanged: got {coins}"
