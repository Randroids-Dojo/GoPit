"""Measure crit damage and chance mechanics for BallxPit comparison."""
import asyncio
import pytest

GAME_MANAGER = "/root/GameManager"
BALL_SPAWNER = "/root/Game/GameArea/BallSpawner"


@pytest.mark.asyncio
async def test_measure_crit_mechanics(game):
    """Measure crit damage multiplier and crit chance values."""

    print("\n" + "=" * 60)
    print("MEASUREMENT: Crit Mechanics")
    print("=" * 60)

    # Get current values
    crit_mult = await game.call(GAME_MANAGER, "get_crit_damage_multiplier")
    bonus_crit = await game.call(GAME_MANAGER, "get_bonus_crit_chance")
    base_crit = await game.get_property(BALL_SPAWNER, "crit_chance")
    active_passive = await game.get_property(GAME_MANAGER, "active_passive")

    print(f"\nCurrent State:")
    print(f"  Active Passive: {active_passive}")
    print(f"  Crit Damage Mult: {crit_mult}x")
    print(f"  Bonus Crit Chance: {bonus_crit * 100:.0f}%")
    print(f"  Base Crit Chance: {base_crit * 100:.0f}%")
    print(f"  Total Crit Chance: {(base_crit + bonus_crit) * 100:.0f}%")

    print("\n" + "-" * 60)
    print("Crit Damage Multipliers:")
    print("-" * 60)
    print("  Default:  2.0x")
    print("  Jackpot:  3.0x (Gambler passive)")

    print("\n" + "-" * 60)
    print("Crit Chance Sources:")
    print("-" * 60)
    print("  Base chance: 0%")
    print("  'Critical' upgrade: +10% per level")
    print("  Jackpot passive: +15% bonus")
    print("  Character crit mult: affects base chance")

    print("\n" + "-" * 60)
    print("Crit DPS Impact (vs base damage):")
    print("-" * 60)
    print(f"{'Crit %':<12} {'Default (2x)':<15} {'Jackpot (3x)':<15}")
    print("-" * 60)
    for crit_pct in [0, 10, 15, 25, 30, 50]:
        crit = crit_pct / 100.0
        default_dps = 1.0 * (1 - crit) + 2.0 * crit
        jackpot_dps = 1.0 * (1 - crit) + 3.0 * crit
        print(f"{crit_pct}%{'':<9} {default_dps:.2f}x DPS{'':<7} {jackpot_dps:.2f}x DPS")

    print("\n" + "-" * 60)
    print("BallxPit Reference:")
    print("-" * 60)
    print("  Dexterity stat: affects crit chance")
    print("  +15% crit passive: ~30-40% DPS increase")
    print("  Shade character: 10% base crit + execute")
    print("  AOE can crit, passives may not")
    print("  Dark ball: 3.0x damage (self-destructs)")

    print("\n" + "=" * 60)
    print("GoPit vs BallxPit Crit Comparison:")
    print("-" * 40)
    print("  GoPit default: 2x crit damage")
    print("  GoPit Jackpot: 3x crit (matches Dark ball)")
    print("  Both: 15% bonus crit chance from passive")
    print("=" * 60 + "\n")

    # Always pass - this is measurement
    assert True
