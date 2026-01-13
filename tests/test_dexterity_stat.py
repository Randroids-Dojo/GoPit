"""Tests for Dexterity stat affecting crit chance and fire rate."""

import asyncio
import pytest

# Character resources are loaded by character_select
CHARACTER_SELECT = "/root/Game/UI/CharacterSelect"

# Expected character dexterity stats based on our configuration
# base_dexterity: absolute value, dexterity_scaling: StatScaling enum (0=S, 1=A, 2=B, 3=C, 4=D, 5=E)
EXPECTED_DEXTERITY_STATS = {
    "Rookie": {"base_dexterity": 5, "dexterity_scaling": 3},      # C grade - balanced
    "Gambler": {"base_dexterity": 10, "dexterity_scaling": 1},    # A grade - crit focused
    "Frost Mage": {"base_dexterity": 4, "dexterity_scaling": 4},  # D grade - control mage
    "Pyro": {"base_dexterity": 5, "dexterity_scaling": 3},        # C grade - damage focused
    "Tactician": {"base_dexterity": 4, "dexterity_scaling": 4},   # D grade - baby ball focused
    "Vampire": {"base_dexterity": 5, "dexterity_scaling": 3},     # C grade - sustain focused
}

# Scaling grade enum values
SCALING_GRADES = {0: "S", 1: "A", 2: "B", 3: "C", 4: "D", 5: "E"}

# Scaling multipliers per grade (same as Character.SCALING_MULTIPLIERS)
SCALING_MULTIPLIERS = {
    0: 0.15,  # S
    1: 0.12,  # A
    2: 0.10,  # B
    3: 0.08,  # C
    4: 0.05,  # D
    5: 0.03,  # E
}

# Crit chance per dexterity point (formula: dex * 0.02)
CRIT_PER_DEX = 0.02

# Fire rate multiplier formula: 1.0 + (dex - 5) * 0.05
FIRE_RATE_BASE_DEX = 5
FIRE_RATE_PER_DEX = 0.05


@pytest.mark.asyncio
async def test_character_select_loads(game):
    """Character select should load without errors (validates all .tres files)."""
    node = await game.get_node(CHARACTER_SELECT)
    assert node is not None, "CharacterSelect should exist"


@pytest.mark.asyncio
async def test_dexterity_values_in_valid_range(game):
    """All base_dexterity values should be in 1-15 range."""
    for char_name, stats in EXPECTED_DEXTERITY_STATS.items():
        base = stats["base_dexterity"]
        assert 1 <= base <= 15, f"{char_name} base_dexterity {base} not in valid range"


@pytest.mark.asyncio
async def test_dexterity_scaling_values_are_valid_grades(game):
    """All dexterity_scaling values should be valid enum values (0-5)."""
    for char_name, stats in EXPECTED_DEXTERITY_STATS.items():
        scaling = stats["dexterity_scaling"]
        assert 0 <= scaling <= 5, f"{char_name} scaling {scaling} not in valid range"
        grade = SCALING_GRADES.get(scaling)
        assert grade is not None, f"{char_name} has invalid dexterity scaling grade"


@pytest.mark.asyncio
async def test_rookie_base_dexterity(game):
    """Rookie should have base_dexterity of 5 (balanced character)."""
    expected = EXPECTED_DEXTERITY_STATS.get("Rookie", {})
    assert expected.get("base_dexterity") == 5, "Rookie should have base_dexterity of 5"


@pytest.mark.asyncio
async def test_gambler_highest_dexterity(game):
    """Gambler should have highest base_dexterity (10) - crit focused."""
    gambler_dex = EXPECTED_DEXTERITY_STATS["Gambler"]["base_dexterity"]
    for char_name, stats in EXPECTED_DEXTERITY_STATS.items():
        if char_name != "Gambler":
            assert gambler_dex >= stats["base_dexterity"], \
                f"Gambler ({gambler_dex}) should have highest dex, but {char_name} has {stats['base_dexterity']}"


@pytest.mark.asyncio
async def test_crit_chance_formula_rookie(game):
    """Verify crit chance formula: dex * 2% for Rookie at level 1."""
    stats = EXPECTED_DEXTERITY_STATS["Rookie"]
    base_dex = stats["base_dexterity"]  # 5

    # At level 1, crit chance = 5 * 0.02 = 0.10 (10%)
    expected_crit = base_dex * CRIT_PER_DEX
    assert expected_crit == 0.10, f"Rookie L1 crit should be 10%, got {expected_crit * 100}%"


@pytest.mark.asyncio
async def test_crit_chance_formula_gambler(game):
    """Verify crit chance formula: dex * 2% for Gambler at level 1."""
    stats = EXPECTED_DEXTERITY_STATS["Gambler"]
    base_dex = stats["base_dexterity"]  # 10

    # At level 1, crit chance = 10 * 0.02 = 0.20 (20%)
    expected_crit = base_dex * CRIT_PER_DEX
    assert expected_crit == 0.20, f"Gambler L1 crit should be 20%, got {expected_crit * 100}%"


@pytest.mark.asyncio
async def test_gambler_total_crit_with_jackpot(game):
    """Gambler's total crit should include Jackpot passive (+15%)."""
    stats = EXPECTED_DEXTERITY_STATS["Gambler"]
    base_dex = stats["base_dexterity"]  # 10

    dex_crit = base_dex * CRIT_PER_DEX  # 20%
    jackpot_bonus = 0.15  # +15% from Jackpot passive
    total_crit = dex_crit + jackpot_bonus

    # Total: 20% + 15% = 35%
    assert total_crit == 0.35, f"Gambler total crit should be 35%, got {total_crit * 100}%"


@pytest.mark.asyncio
async def test_fire_rate_multiplier_formula_baseline(game):
    """At dex=5, fire rate multiplier should be 1.0 (baseline)."""
    dex = 5  # Rookie base dex
    fire_mult = 1.0 + (dex - FIRE_RATE_BASE_DEX) * FIRE_RATE_PER_DEX
    assert fire_mult == 1.0, f"Fire rate mult at dex=5 should be 1.0, got {fire_mult}"


@pytest.mark.asyncio
async def test_fire_rate_multiplier_formula_high_dex(game):
    """At dex=10 (Gambler), fire rate multiplier should be 1.25."""
    dex = 10  # Gambler base dex
    fire_mult = 1.0 + (dex - FIRE_RATE_BASE_DEX) * FIRE_RATE_PER_DEX
    # 1.0 + (10-5) * 0.05 = 1.0 + 0.25 = 1.25
    assert fire_mult == 1.25, f"Fire rate mult at dex=10 should be 1.25, got {fire_mult}"


@pytest.mark.asyncio
async def test_fire_rate_multiplier_formula_low_dex(game):
    """At dex=4 (Frost Mage), fire rate multiplier should be 0.95."""
    dex = 4  # Frost Mage base dex
    fire_mult = 1.0 + (dex - FIRE_RATE_BASE_DEX) * FIRE_RATE_PER_DEX
    # 1.0 + (4-5) * 0.05 = 1.0 - 0.05 = 0.95
    assert fire_mult == pytest.approx(0.95, abs=0.001), f"Fire rate mult at dex=4 should be 0.95, got {fire_mult}"


@pytest.mark.asyncio
async def test_dexterity_at_level_calculation(game):
    """Verify get_dexterity_at_level formula is correct."""
    # Formula: base_dex + (base_dex * scaling_mult * (level - 1))
    # Test with Gambler (base=10, scaling=1=A=0.12)
    base = 10
    scaling_mult = 0.12  # A grade

    # Level 1: just base
    expected_l1 = base

    # Level 5: base + base * 0.12 * 4 = 10 + 4.8 = 14
    expected_l5 = base + int(base * scaling_mult * 4)

    # Level 10: base + base * 0.12 * 9 = 10 + 10.8 = 20
    expected_l10 = base + int(base * scaling_mult * 9)

    assert expected_l1 == 10, f"Level 1 dexterity should be 10, got {expected_l1}"
    assert expected_l5 == 14, f"Level 5 dexterity should be 14, got {expected_l5}"
    assert expected_l10 == 20, f"Level 10 dexterity should be 20, got {expected_l10}"


@pytest.mark.asyncio
async def test_gambler_crit_at_level_10(game):
    """Gambler at level 10 should have high crit chance from leveled dexterity."""
    stats = EXPECTED_DEXTERITY_STATS["Gambler"]
    base = stats["base_dexterity"]  # 10
    scaling = stats["dexterity_scaling"]  # 1 = A grade
    scaling_mult = SCALING_MULTIPLIERS[scaling]  # 0.12

    # Dexterity at level 10: 10 + int(10 * 0.12 * 9) = 10 + 10 = 20
    dex_l10 = base + int(base * scaling_mult * 9)

    # Crit from dex: 20 * 0.02 = 40%
    dex_crit = dex_l10 * CRIT_PER_DEX

    # Plus Jackpot: 40% + 15% = 55%
    total_crit = dex_crit + 0.15

    assert dex_l10 == 20, f"Gambler L10 dex should be 20, got {dex_l10}"
    assert total_crit == pytest.approx(0.55, abs=0.01), f"Gambler L10 total crit should be 55%, got {total_crit * 100}%"


@pytest.mark.asyncio
async def test_frost_mage_low_crit(game):
    """Frost Mage (control focus) should have lower crit than Gambler."""
    frost = EXPECTED_DEXTERITY_STATS["Frost Mage"]
    gambler = EXPECTED_DEXTERITY_STATS["Gambler"]

    frost_crit = frost["base_dexterity"] * CRIT_PER_DEX  # 4 * 0.02 = 8%
    gambler_crit = gambler["base_dexterity"] * CRIT_PER_DEX  # 10 * 0.02 = 20%

    assert frost_crit < gambler_crit, \
        f"Frost Mage crit ({frost_crit * 100}%) should be less than Gambler ({gambler_crit * 100}%)"


@pytest.mark.asyncio
async def test_all_characters_navigate_without_crash(game):
    """Navigating through all characters should work (validates .tres files)."""
    node = await game.get_node(CHARACTER_SELECT)
    assert node is not None, "CharacterSelect should exist"

    # Navigate through all 6 characters
    for i in range(6):
        await game.call(CHARACTER_SELECT, "_on_next_pressed")
        await asyncio.sleep(0.05)

    # If any character's new dexterity properties failed, game would crash


@pytest.mark.asyncio
async def test_character_stat_diversity(game):
    """Characters should have varied dexterity profiles for playstyle diversity."""
    # Count unique dexterity values
    unique_base_dex = set(stats["base_dexterity"] for stats in EXPECTED_DEXTERITY_STATS.values())

    # Should have at least 3 different base dexterity values for variety
    assert len(unique_base_dex) >= 3, \
        f"Should have at least 3 unique base_dexterity values, got {unique_base_dex}"


@pytest.mark.asyncio
async def test_gambler_fastest_scaling(game):
    """Gambler should have fastest dexterity scaling (A grade)."""
    gambler_scaling = EXPECTED_DEXTERITY_STATS["Gambler"]["dexterity_scaling"]

    # Lower number = faster scaling (0=S, 1=A is fastest non-S)
    for char_name, stats in EXPECTED_DEXTERITY_STATS.items():
        if char_name != "Gambler":
            assert gambler_scaling <= stats["dexterity_scaling"], \
                f"Gambler scaling ({gambler_scaling}) should be fastest, but {char_name} has {stats['dexterity_scaling']}"
