"""Integration tests for character passive abilities.

These tests verify that each character's passive ability correctly modifies gameplay.

Passives tested:
- Quick Learner (Rookie): +10% XP gain
- Jackpot (Gambler): 3x crit damage, +15% crit chance
- Lifesteal (Vampire): 5% heal on damage dealt
- Shatter (Frost Mage): +50% damage vs frozen, +30% freeze duration
- Inferno (Pyro): +20% fire damage, +25% vs burning
- Squad Leader (Tactician): +2 starting baby balls, +30% spawn rate
"""
import asyncio
import pytest

# Common paths
GAME = "/root/Game"
GAME_MANAGER = "/root/GameManager"
CHARACTER_SELECT = "/root/Game/UI/CharacterSelect"
CHAR_SELECT_PANEL = f"{CHARACTER_SELECT}/DimBackground/Panel/VBoxContainer"
NAV_NEXT = f"{CHAR_SELECT_PANEL}/NavContainer/NextButton"
NAV_PREV = f"{CHAR_SELECT_PANEL}/NavContainer/PrevButton"
START_BUTTON = f"{CHAR_SELECT_PANEL}/StartButton"
NAME_LABEL = f"{CHAR_SELECT_PANEL}/CharacterPanel/HBoxContainer/InfoContainer/NameLabel"
BABY_SPAWNER = "/root/Game/GameArea/BabyBallSpawner"
BALL_SPAWNER = "/root/Game/GameArea/BallSpawner"


async def select_character_by_name(game, target_name: str, max_clicks: int = 6) -> bool:
    """Navigate to a specific character by name. Returns True if found."""
    await game.call(CHARACTER_SELECT, "show_select", [])
    await asyncio.sleep(0.2)

    for _ in range(max_clicks):
        name = await game.get_property(NAME_LABEL, "text")
        if name.upper() == target_name.upper():
            return True
        # Use direct method call (more reliable in headless mode)
        await game.call(CHARACTER_SELECT, "_on_next_pressed", [])
        await asyncio.sleep(0.1)

    return False


async def select_and_start_with_character(game, target_name: str) -> bool:
    """Select a character and start the game."""
    found = await select_character_by_name(game, target_name)
    if not found:
        return False

    # Use direct method call (more reliable in headless mode)
    await game.call(CHARACTER_SELECT, "_on_start_pressed", [])
    await asyncio.sleep(0.5)
    return True


# ============================================================================
# Quick Learner (Rookie) - +10% XP gain
# ============================================================================

@pytest.mark.asyncio
async def test_quick_learner_xp_multiplier_active(game):
    """Quick Learner passive should give 1.1x XP multiplier."""
    # Select Rookie (index 0 - default)
    success = await select_and_start_with_character(game, "Rookie")
    assert success, "Should be able to select Rookie"

    # Verify the active passive is QUICK_LEARNER (enum value 1)
    active_passive = await game.get_property(GAME_MANAGER, "active_passive")
    assert active_passive == 1, f"Rookie should have QUICK_LEARNER passive (1), got {active_passive}"

    # Call get_xp_multiplier and verify it returns 1.1
    xp_mult = await game.call(GAME_MANAGER, "get_xp_multiplier")
    assert abs(xp_mult - 1.1) < 0.01, f"Quick Learner should give 1.1x XP, got {xp_mult}"


@pytest.mark.asyncio
async def test_default_xp_multiplier_is_one(game):
    """Without Quick Learner, XP multiplier should be 1.0."""
    # Select Pyro (has Inferno, not Quick Learner)
    success = await select_and_start_with_character(game, "Pyro")
    assert success, "Should be able to select Pyro"

    # Verify XP multiplier is 1.0
    xp_mult = await game.call(GAME_MANAGER, "get_xp_multiplier")
    assert abs(xp_mult - 1.0) < 0.01, f"Non-Quick Learner should have 1.0x XP, got {xp_mult}"


# ============================================================================
# Jackpot (Gambler) - 3x crit damage, +15% crit chance
# ============================================================================

@pytest.mark.asyncio
async def test_jackpot_crit_damage_multiplier(game):
    """Jackpot passive should give 3x crit damage instead of 2x."""
    success = await select_and_start_with_character(game, "Gambler")
    assert success, "Should be able to select Gambler"

    # Verify the active passive is JACKPOT (enum value 3)
    active_passive = await game.get_property(GAME_MANAGER, "active_passive")
    assert active_passive == 3, f"Gambler should have JACKPOT passive (3), got {active_passive}"

    # Check crit damage multiplier
    crit_mult = await game.call(GAME_MANAGER, "get_crit_damage_multiplier")
    assert abs(crit_mult - 3.0) < 0.01, f"Jackpot should give 3x crit damage, got {crit_mult}"


@pytest.mark.asyncio
async def test_jackpot_bonus_crit_chance(game):
    """Jackpot passive should give +15% bonus crit chance."""
    success = await select_and_start_with_character(game, "Gambler")
    assert success, "Should be able to select Gambler"

    bonus_crit = await game.call(GAME_MANAGER, "get_bonus_crit_chance")
    assert abs(bonus_crit - 0.15) < 0.01, f"Jackpot should give +15% crit chance, got {bonus_crit}"


@pytest.mark.asyncio
async def test_default_crit_damage_is_two(game):
    """Without Jackpot, crit damage multiplier should be 2x."""
    success = await select_and_start_with_character(game, "Rookie")
    assert success, "Should be able to select Rookie"

    crit_mult = await game.call(GAME_MANAGER, "get_crit_damage_multiplier")
    assert abs(crit_mult - 2.0) < 0.01, f"Default crit damage should be 2x, got {crit_mult}"


# ============================================================================
# Lifesteal (Vampire) - 5% heal on damage, 20% health gem chance
# ============================================================================

@pytest.mark.asyncio
async def test_lifesteal_percent_active(game):
    """Lifesteal passive should return 5% heal rate."""
    # Vampire may be locked, so we set the passive directly for testing
    await game.call(CHARACTER_SELECT, "show_select", [])
    await asyncio.sleep(0.2)

    # Navigate to find Vampire (might be locked but we can still test the passive)
    # Instead, let's test by directly setting the passive
    await game.click(START_BUTTON)  # Start with default character
    await asyncio.sleep(0.3)

    # Manually set the passive for testing purposes
    await game.set_property(GAME_MANAGER, "active_passive", 6)  # LIFESTEAL = 6

    lifesteal = await game.call(GAME_MANAGER, "get_lifesteal_percent")
    assert abs(lifesteal - 0.05) < 0.001, f"Lifesteal should be 5%, got {lifesteal}"


@pytest.mark.asyncio
async def test_lifesteal_health_gem_chance(game):
    """Lifesteal passive should give 20% health gem chance on kill."""
    # Start game and set passive
    await game.call(CHARACTER_SELECT, "show_select", [])
    await asyncio.sleep(0.2)
    await game.click(START_BUTTON)
    await asyncio.sleep(0.3)

    # Set LIFESTEAL passive
    await game.set_property(GAME_MANAGER, "active_passive", 6)

    gem_chance = await game.call(GAME_MANAGER, "get_health_gem_chance")
    assert abs(gem_chance - 0.2) < 0.01, f"Health gem chance should be 20%, got {gem_chance}"


@pytest.mark.asyncio
async def test_default_lifesteal_is_zero(game):
    """Without Lifesteal passive, heal percent should be 0."""
    success = await select_and_start_with_character(game, "Rookie")
    assert success, "Should be able to select Rookie"

    lifesteal = await game.call(GAME_MANAGER, "get_lifesteal_percent")
    assert lifesteal == 0, f"Default lifesteal should be 0, got {lifesteal}"


# ============================================================================
# Shatter (Frost Mage) - +50% vs frozen, +30% freeze duration
# ============================================================================

@pytest.mark.asyncio
async def test_shatter_damage_vs_frozen(game):
    """Shatter passive should give +50% damage vs frozen enemies."""
    success = await select_and_start_with_character(game, "Frost Mage")
    assert success, "Should be able to select Frost Mage"

    # Verify the active passive is SHATTER (enum value 2)
    active_passive = await game.get_property(GAME_MANAGER, "active_passive")
    assert active_passive == 2, f"Frost Mage should have SHATTER passive (2), got {active_passive}"

    frozen_mult = await game.call(GAME_MANAGER, "get_damage_vs_frozen")
    assert abs(frozen_mult - 1.5) < 0.01, f"Shatter should give 1.5x vs frozen, got {frozen_mult}"


@pytest.mark.asyncio
async def test_shatter_freeze_duration_bonus(game):
    """Shatter passive should give +30% freeze duration."""
    success = await select_and_start_with_character(game, "Frost Mage")
    assert success, "Should be able to select Frost Mage"

    freeze_bonus = await game.call(GAME_MANAGER, "get_freeze_duration_bonus")
    assert abs(freeze_bonus - 1.3) < 0.01, f"Shatter should give 1.3x freeze duration, got {freeze_bonus}"


@pytest.mark.asyncio
async def test_default_damage_vs_frozen_is_baseline(game):
    """Without Shatter, damage vs frozen should be 1.25x (baseline frozen bonus)."""
    success = await select_and_start_with_character(game, "Pyro")
    assert success, "Should be able to select Pyro"

    frozen_mult = await game.call(GAME_MANAGER, "get_damage_vs_frozen")
    # Baseline: frozen enemies take +25% damage (1.25x)
    # With Shatter passive: +50% (1.5x)
    assert abs(frozen_mult - 1.25) < 0.01, f"Baseline damage vs frozen should be 1.25x, got {frozen_mult}"


# ============================================================================
# Inferno (Pyro) - +20% fire damage, +25% vs burning
# ============================================================================

@pytest.mark.asyncio
async def test_inferno_fire_damage_multiplier(game):
    """Inferno passive should give +20% fire damage."""
    success = await select_and_start_with_character(game, "Pyro")
    assert success, "Should be able to select Pyro"

    # Verify the active passive is INFERNO (enum value 4)
    active_passive = await game.get_property(GAME_MANAGER, "active_passive")
    assert active_passive == 4, f"Pyro should have INFERNO passive (4), got {active_passive}"

    fire_mult = await game.call(GAME_MANAGER, "get_fire_damage_multiplier")
    assert abs(fire_mult - 1.2) < 0.01, f"Inferno should give 1.2x fire damage, got {fire_mult}"


@pytest.mark.asyncio
async def test_inferno_damage_vs_burning(game):
    """Inferno passive should give +25% damage vs burning enemies."""
    success = await select_and_start_with_character(game, "Pyro")
    assert success, "Should be able to select Pyro"

    burning_mult = await game.call(GAME_MANAGER, "get_damage_vs_burning")
    assert abs(burning_mult - 1.25) < 0.01, f"Inferno should give 1.25x vs burning, got {burning_mult}"


@pytest.mark.asyncio
async def test_default_fire_damage_is_one(game):
    """Without Inferno, fire damage multiplier should be 1.0x."""
    success = await select_and_start_with_character(game, "Rookie")
    assert success, "Should be able to select Rookie"

    fire_mult = await game.call(GAME_MANAGER, "get_fire_damage_multiplier")
    assert abs(fire_mult - 1.0) < 0.01, f"Default fire damage should be 1x, got {fire_mult}"


# ============================================================================
# Squad Leader (Tactician) - +2 baby balls, +30% spawn rate
# ============================================================================

@pytest.mark.asyncio
async def test_squad_leader_extra_baby_balls(game):
    """Squad Leader passive should give +2 starting baby balls."""
    success = await select_and_start_with_character(game, "Tactician")
    assert success, "Should be able to select Tactician"

    # Verify the active passive is SQUAD_LEADER (enum value 5)
    active_passive = await game.get_property(GAME_MANAGER, "active_passive")
    assert active_passive == 5, f"Tactician should have SQUAD_LEADER passive (5), got {active_passive}"

    extra_balls = await game.call(GAME_MANAGER, "get_extra_baby_balls")
    assert extra_balls == 2, f"Squad Leader should give +2 baby balls, got {extra_balls}"


@pytest.mark.asyncio
async def test_squad_leader_baby_ball_rate_bonus(game):
    """Squad Leader passive should give +30% baby ball spawn rate."""
    success = await select_and_start_with_character(game, "Tactician")
    assert success, "Should be able to select Tactician"

    rate_bonus = await game.call(GAME_MANAGER, "get_baby_ball_rate_bonus")
    assert abs(rate_bonus - 0.3) < 0.01, f"Squad Leader should give +30% spawn rate, got {rate_bonus}"


@pytest.mark.asyncio
async def test_default_extra_baby_balls_is_zero(game):
    """Without Squad Leader, extra baby balls should be 0."""
    success = await select_and_start_with_character(game, "Rookie")
    assert success, "Should be able to select Rookie"

    extra_balls = await game.call(GAME_MANAGER, "get_extra_baby_balls")
    assert extra_balls == 0, f"Default extra baby balls should be 0, got {extra_balls}"


# ============================================================================
# Integration: Passive affects baby ball spawner timing
# ============================================================================

@pytest.mark.asyncio
async def test_squad_leader_affects_baby_spawner(game):
    """Squad Leader's +2 extra baby balls should affect baby ball spawner (queue-based)."""
    success = await select_and_start_with_character(game, "Tactician")
    assert success, "Should be able to select Tactician"

    # Queue-based system: Squad Leader adds +2 extra baby balls
    # Verify get_max_baby_balls method exists and returns expected value
    has_method = await game.call(BABY_SPAWNER, "has_method", ["get_max_baby_balls"])
    assert has_method, "BabyBallSpawner should have get_max_baby_balls method"

    # With Tactician (Squad Leader passive), should have base (1) + extra (2) = 3 baby balls
    max_babies = await game.call(BABY_SPAWNER, "get_max_baby_balls")
    assert max_babies >= 3, f"Tactician should have at least 3 baby balls, got {max_babies}"


# ============================================================================
# Verify passive enum values match expected
# ============================================================================

@pytest.mark.asyncio
async def test_passive_enum_values(game):
    """Verify passive enum values are correct."""
    # Start game
    await game.call(CHARACTER_SELECT, "show_select", [])
    await asyncio.sleep(0.2)
    await game.click(START_BUTTON)
    await asyncio.sleep(0.3)

    # Test each passive by setting it and verifying the corresponding function works
    test_cases = [
        (0, "NONE", "get_xp_multiplier", 1.0),  # No passive = default XP
        (1, "QUICK_LEARNER", "get_xp_multiplier", 1.1),
        (2, "SHATTER", "get_damage_vs_frozen", 1.5),
        (3, "JACKPOT", "get_crit_damage_multiplier", 3.0),
        (4, "INFERNO", "get_fire_damage_multiplier", 1.2),
        (5, "SQUAD_LEADER", "get_extra_baby_balls", 2),
        (6, "LIFESTEAL", "get_lifesteal_percent", 0.05),
    ]

    for enum_val, name, method, expected in test_cases:
        await game.set_property(GAME_MANAGER, "active_passive", enum_val)
        result = await game.call(GAME_MANAGER, method)
        assert abs(result - expected) < 0.01, f"Passive {name} ({enum_val}): {method} should return {expected}, got {result}"
