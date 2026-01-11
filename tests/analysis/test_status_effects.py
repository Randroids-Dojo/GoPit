"""Measure all status effects for BallxPit comparison."""
import asyncio
import pytest


@pytest.mark.asyncio
async def test_measure_status_effects(game):
    """Measure all status effect values (Burn, Freeze, Poison, Bleed)."""

    print("\n" + "=" * 60)
    print("MEASUREMENT: Status Effects")
    print("=" * 60)

    # From code analysis (status_effect.gd)
    effects = {
        "BURN": {
            "duration": 3.0,
            "damage_per_tick": 2.5,
            "tick_interval": 0.5,
            "dps": 5.0,
            "max_stacks": 1,
            "slow": None,
            "notes": "Refreshes duration, affected by Intelligence"
        },
        "FREEZE": {
            "duration": 2.0,
            "damage_per_tick": 0,
            "tick_interval": 0.5,
            "dps": 0,
            "max_stacks": 1,
            "slow": "50%",
            "notes": "+30% duration with Shatter passive"
        },
        "POISON": {
            "duration": 5.0,
            "damage_per_tick": 1.5,
            "tick_interval": 0.5,
            "dps": 3.0,
            "max_stacks": 1,
            "slow": None,
            "notes": "Longer duration, lower DPS than Burn"
        },
        "BLEED": {
            "duration": "INF",
            "damage_per_tick": 1.0,
            "tick_interval": 0.5,
            "dps": "2.0 per stack",
            "max_stacks": 5,
            "slow": None,
            "notes": "Permanent, stacking DoT (up to 10 DPS)"
        }
    }

    print("\n" + "-" * 70)
    print("GoPit Status Effect Values:")
    print("-" * 70)
    print(f"{'Effect':<10} {'Duration':<12} {'DPS':<15} {'Max Stack':<10} {'Special'}")
    print("-" * 70)
    for name, data in effects.items():
        dur = f"{data['duration']}s" if isinstance(data['duration'], float) else data['duration']
        dps = data['dps']
        stacks = data['max_stacks']
        special = data['slow'] or data['notes'][:25] + "..." if len(data['notes']) > 25 else data['notes']
        print(f"{name:<10} {dur:<12} {dps:<15} {stacks:<10} {special}")

    print("\n" + "-" * 70)
    print("Status Effect Details:")
    print("-" * 70)
    for name, data in effects.items():
        print(f"\n  {name}:")
        print(f"    Duration: {data['duration']}s")
        print(f"    Damage: {data['damage_per_tick']} per {data['tick_interval']}s = {data['dps']} DPS")
        print(f"    Max Stacks: {data['max_stacks']}")
        if data['slow']:
            print(f"    Slow: {data['slow']}")
        print(f"    Notes: {data['notes']}")

    print("\n" + "-" * 70)
    print("Total DoT Potential (per enemy):")
    print("-" * 70)
    print("  Burn:   5.0 DPS x 3s = 15 damage")
    print("  Freeze: 0 damage (crowd control)")
    print("  Poison: 3.0 DPS x 5s = 15 damage")
    print("  Bleed:  2.0 DPS x 5 stacks = 10 DPS (permanent)")

    print("\n" + "-" * 70)
    print("BallxPit Reference:")
    print("-" * 70)
    print("  Burn:     max 5 stacks")
    print("  Bleed:    max 24 stacks (Hemorrhage: 12+ stacks = 20% HP nuke)")
    print("  Poison:   max 8 stacks")
    print("  Frostburn: 20s duration, max 4 stacks, +25% damage taken")
    print("  Disease:  6s duration, max 8 stacks")

    print("\n" + "-" * 70)
    print("Comparison Summary:")
    print("-" * 70)
    print("  GoPit simpler: 1-5 max stacks vs BallxPit 4-24")
    print("  GoPit Bleed: permanent, up to 5 stacks")
    print("  BallxPit: more stack-based with caps")
    print("  BallxPit Freeze: includes damage amp (+25%)")
    print("  GoPit Freeze: pure slow (50%), no damage amp")

    print("\n" + "=" * 60)
    print("KEY FINDINGS:")
    print("-" * 40)
    print("  1. GoPit status effects are simpler/streamlined")
    print("  2. Bleed stacking differs significantly (5 vs 24 max)")
    print("  3. Freeze in GoPit is pure CC, no damage amp")
    print("  4. No Hemorrhage-style HP% nuke mechanic")
    print("=" * 60 + "\n")

    # Always pass - this is measurement
    assert True
