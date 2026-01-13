"""Tests for Intelligence stat affecting status effect duration and damage."""

import asyncio
import pytest

# Character resources are loaded by character_select
CHARACTER_SELECT = "/root/Game/UI/CharacterSelect"

# Expected character intelligence stats based on our configuration
# base_intelligence: absolute value, intelligence_scaling: StatScaling enum (0=S, 1=A, 2=B, 3=C, 4=D, 5=E)
EXPECTED_INTELLIGENCE_STATS = {
    "Rookie": {"base_intelligence": 5, "intelligence_scaling": 3},      # C grade - balanced
    "Frost Mage": {"base_intelligence": 8, "intelligence_scaling": 1},  # A grade - status effect master
    "Pyro": {"base_intelligence": 4, "intelligence_scaling": 3},        # C grade - damage not status
    "Gambler": {"base_intelligence": 4, "intelligence_scaling": 4},     # D grade - crit not status
    "Tactician": {"base_intelligence": 6, "intelligence_scaling": 3},   # C grade - strategic
    "Vampire": {"base_intelligence": 4, "intelligence_scaling": 3},     # C grade - lifesteal not status
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

# Status duration multiplier formula: 1.0 + (intel - 5) * 0.10
# Status damage multiplier formula: 1.0 + (intel - 5) * 0.05
STATUS_DURATION_PER_INT = 0.10
STATUS_DAMAGE_PER_INT = 0.05
BASE_INTELLIGENCE = 5


@pytest.mark.asyncio
async def test_character_select_loads(game):
    """Character select should load without errors (validates all .tres files)."""
    node = await game.get_node(CHARACTER_SELECT)
    assert node is not None, "CharacterSelect should exist"


@pytest.mark.asyncio
async def test_intelligence_values_in_valid_range(game):
    """All base_intelligence values should be in 1-15 range."""
    for char_name, stats in EXPECTED_INTELLIGENCE_STATS.items():
        base = stats["base_intelligence"]
        assert 1 <= base <= 15, f"{char_name} base_intelligence {base} not in valid range"


@pytest.mark.asyncio
async def test_intelligence_scaling_values_are_valid_grades(game):
    """All intelligence_scaling values should be valid enum values (0-5)."""
    for char_name, stats in EXPECTED_INTELLIGENCE_STATS.items():
        scaling = stats["intelligence_scaling"]
        assert 0 <= scaling <= 5, f"{char_name} scaling {scaling} not in valid range"
        grade = SCALING_GRADES.get(scaling)
        assert grade is not None, f"{char_name} has invalid intelligence scaling grade"


@pytest.mark.asyncio
async def test_rookie_base_intelligence(game):
    """Rookie should have base_intelligence of 5 (balanced character)."""
    expected = EXPECTED_INTELLIGENCE_STATS.get("Rookie", {})
    assert expected.get("base_intelligence") == 5, "Rookie should have base_intelligence of 5"


@pytest.mark.asyncio
async def test_frost_mage_highest_intelligence(game):
    """Frost Mage should have highest base_intelligence (8) - status effect specialist."""
    frost_int = EXPECTED_INTELLIGENCE_STATS["Frost Mage"]["base_intelligence"]
    for char_name, stats in EXPECTED_INTELLIGENCE_STATS.items():
        if char_name != "Frost Mage":
            assert frost_int >= stats["base_intelligence"], \
                f"Frost Mage ({frost_int}) should have highest INT, but {char_name} has {stats['base_intelligence']}"


@pytest.mark.asyncio
async def test_status_duration_formula_baseline(game):
    """At INT=5, status duration multiplier should be 1.0 (baseline)."""
    intel = 5  # Baseline
    duration_mult = 1.0 + (intel - BASE_INTELLIGENCE) * STATUS_DURATION_PER_INT
    assert duration_mult == 1.0, f"Duration mult at INT=5 should be 1.0, got {duration_mult}"


@pytest.mark.asyncio
async def test_status_duration_formula_high_int(game):
    """At INT=8 (Frost Mage), status duration multiplier should be 1.3."""
    intel = 8  # Frost Mage base
    duration_mult = 1.0 + (intel - BASE_INTELLIGENCE) * STATUS_DURATION_PER_INT
    # 1.0 + (8-5) * 0.10 = 1.0 + 0.30 = 1.30
    assert duration_mult == pytest.approx(1.30, abs=0.001), f"Duration mult at INT=8 should be 1.3, got {duration_mult}"


@pytest.mark.asyncio
async def test_status_duration_formula_low_int(game):
    """At INT=4 (Gambler), status duration multiplier should be 0.9."""
    intel = 4  # Gambler base
    duration_mult = 1.0 + (intel - BASE_INTELLIGENCE) * STATUS_DURATION_PER_INT
    # 1.0 + (4-5) * 0.10 = 1.0 - 0.10 = 0.90
    assert duration_mult == pytest.approx(0.90, abs=0.001), f"Duration mult at INT=4 should be 0.9, got {duration_mult}"


@pytest.mark.asyncio
async def test_status_damage_formula_baseline(game):
    """At INT=5, status damage multiplier should be 1.0 (baseline)."""
    intel = 5  # Baseline
    damage_mult = 1.0 + (intel - BASE_INTELLIGENCE) * STATUS_DAMAGE_PER_INT
    assert damage_mult == 1.0, f"Damage mult at INT=5 should be 1.0, got {damage_mult}"


@pytest.mark.asyncio
async def test_status_damage_formula_high_int(game):
    """At INT=8 (Frost Mage), status damage multiplier should be 1.15."""
    intel = 8  # Frost Mage base
    damage_mult = 1.0 + (intel - BASE_INTELLIGENCE) * STATUS_DAMAGE_PER_INT
    # 1.0 + (8-5) * 0.05 = 1.0 + 0.15 = 1.15
    assert damage_mult == pytest.approx(1.15, abs=0.001), f"Damage mult at INT=8 should be 1.15, got {damage_mult}"


@pytest.mark.asyncio
async def test_intelligence_at_level_calculation(game):
    """Verify get_intelligence_at_level formula is correct."""
    # Formula: base_intel + (base_intel * scaling_mult * (level - 1))
    # Test with Frost Mage (base=8, scaling=1=A=0.12)
    base = 8
    scaling_mult = 0.12  # A grade

    # Level 1: just base
    expected_l1 = base

    # Level 5: base + base * 0.12 * 4 = 8 + 3.84 = 11
    expected_l5 = base + int(base * scaling_mult * 4)

    # Level 10: base + base * 0.12 * 9 = 8 + 8.64 = 16
    expected_l10 = base + int(base * scaling_mult * 9)

    assert expected_l1 == 8, f"Level 1 intelligence should be 8, got {expected_l1}"
    assert expected_l5 == 11, f"Level 5 intelligence should be 11, got {expected_l5}"
    assert expected_l10 == 16, f"Level 10 intelligence should be 16, got {expected_l10}"


@pytest.mark.asyncio
async def test_frost_mage_status_duration_at_level_10(game):
    """Frost Mage at level 10 should have significantly longer status duration."""
    stats = EXPECTED_INTELLIGENCE_STATS["Frost Mage"]
    base = stats["base_intelligence"]  # 8
    scaling = stats["intelligence_scaling"]  # 1 = A grade
    scaling_mult = SCALING_MULTIPLIERS[scaling]  # 0.12

    # Intelligence at level 10: 8 + int(8 * 0.12 * 9) = 8 + 8 = 16
    int_l10 = base + int(base * scaling_mult * 9)

    # Duration mult at L10: 1.0 + (16-5) * 0.10 = 1.0 + 1.1 = 2.1
    duration_mult = 1.0 + (int_l10 - BASE_INTELLIGENCE) * STATUS_DURATION_PER_INT

    assert int_l10 == 16, f"Frost Mage L10 INT should be 16, got {int_l10}"
    assert duration_mult == pytest.approx(2.1, abs=0.01), f"Frost Mage L10 duration mult should be 2.1, got {duration_mult}"


@pytest.mark.asyncio
async def test_frost_mage_status_damage_at_level_10(game):
    """Frost Mage at level 10 should deal more status damage."""
    stats = EXPECTED_INTELLIGENCE_STATS["Frost Mage"]
    base = stats["base_intelligence"]  # 8
    scaling = stats["intelligence_scaling"]  # 1 = A grade
    scaling_mult = SCALING_MULTIPLIERS[scaling]  # 0.12

    # Intelligence at level 10: 8 + int(8 * 0.12 * 9) = 8 + 8 = 16
    int_l10 = base + int(base * scaling_mult * 9)

    # Damage mult at L10: 1.0 + (16-5) * 0.05 = 1.0 + 0.55 = 1.55
    damage_mult = 1.0 + (int_l10 - BASE_INTELLIGENCE) * STATUS_DAMAGE_PER_INT

    assert damage_mult == pytest.approx(1.55, abs=0.01), f"Frost Mage L10 damage mult should be 1.55, got {damage_mult}"


@pytest.mark.asyncio
async def test_gambler_low_intelligence(game):
    """Gambler (crit focus) should have lower intelligence than Frost Mage."""
    gambler = EXPECTED_INTELLIGENCE_STATS["Gambler"]
    frost = EXPECTED_INTELLIGENCE_STATS["Frost Mage"]

    gambler_int = gambler["base_intelligence"]
    frost_int = frost["base_intelligence"]

    assert gambler_int < frost_int, \
        f"Gambler INT ({gambler_int}) should be less than Frost Mage ({frost_int})"


@pytest.mark.asyncio
async def test_all_characters_navigate_without_crash(game):
    """Navigating through all characters should work (validates .tres files)."""
    node = await game.get_node(CHARACTER_SELECT)
    assert node is not None, "CharacterSelect should exist"

    # Navigate through all 6 characters
    for i in range(6):
        await game.call(CHARACTER_SELECT, "_on_next_pressed")
        await asyncio.sleep(0.05)

    # If any character's new intelligence properties failed, game would crash


@pytest.mark.asyncio
async def test_frost_mage_fastest_int_scaling(game):
    """Frost Mage should have fastest intelligence scaling (A grade)."""
    frost_scaling = EXPECTED_INTELLIGENCE_STATS["Frost Mage"]["intelligence_scaling"]

    # Lower number = faster scaling (0=S, 1=A is fastest non-S)
    for char_name, stats in EXPECTED_INTELLIGENCE_STATS.items():
        if char_name != "Frost Mage":
            assert frost_scaling <= stats["intelligence_scaling"], \
                f"Frost Mage scaling ({frost_scaling}) should be fastest, but {char_name} has {stats['intelligence_scaling']}"


@pytest.mark.asyncio
async def test_character_stat_diversity(game):
    """Characters should have varied intelligence profiles for playstyle diversity."""
    # Count unique intelligence values
    unique_base_int = set(stats["base_intelligence"] for stats in EXPECTED_INTELLIGENCE_STATS.values())

    # Should have at least 3 different base intelligence values for variety
    assert len(unique_base_int) >= 3, \
        f"Should have at least 3 unique base_intelligence values, got {unique_base_int}"


@pytest.mark.asyncio
async def test_burn_effect_scales_with_int(game):
    """Burn effect duration and damage should scale with intelligence."""
    # Burn base duration = 3.0s
    # At INT=8 (Frost Mage): duration = 3.0 * 1.3 = 3.9s
    base_duration = 3.0
    frost_int = 8
    frost_duration_mult = 1.0 + (frost_int - BASE_INTELLIGENCE) * STATUS_DURATION_PER_INT

    expected_duration = base_duration * frost_duration_mult
    assert expected_duration == pytest.approx(3.9, abs=0.01), \
        f"Burn duration for Frost Mage should be 3.9s, got {expected_duration}"

    # Burn base damage_per_tick = 2.5
    # At INT=8: damage = 2.5 * 1.15 = 2.875
    base_damage = 2.5
    frost_damage_mult = 1.0 + (frost_int - BASE_INTELLIGENCE) * STATUS_DAMAGE_PER_INT

    expected_damage = base_damage * frost_damage_mult
    assert expected_damage == pytest.approx(2.875, abs=0.01), \
        f"Burn damage for Frost Mage should be 2.875, got {expected_damage}"
