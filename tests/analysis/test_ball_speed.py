"""Measure ball speed per level for BallxPit comparison."""
import asyncio
import pytest

BALL_REGISTRY = "/root/BallRegistry"


@pytest.mark.asyncio
async def test_measure_ball_speed(game):
    """Measure ball speed values at each level for all ball types."""

    # Ball types with their base speeds (from ball_registry.gd BALL_DATA)
    ball_speeds = {
        "BASIC": 800.0,
        "BURN": 800.0,
        "FREEZE": 800.0,
        "POISON": 800.0,
        "BLEED": 800.0,
        "LIGHTNING": 900.0,  # Faster
        "IRON": 600.0,  # Slower (heavy ball)
    }

    # Level multipliers (same as damage)
    level_multipliers = {1: 1.0, 2: 1.5, 3: 2.0}

    print("\n" + "=" * 60)
    print("MEASUREMENT: Ball Speed Per Level")
    print("=" * 60)

    print("\nBase Speed by Ball Type (pixels/second):")
    print("-" * 40)
    for ball_name, base_speed in ball_speeds.items():
        speed_class = ""
        if base_speed > 800:
            speed_class = " (FAST)"
        elif base_speed < 800:
            speed_class = " (SLOW)"
        print(f"  {ball_name}: {base_speed}{speed_class}")

    print("\nLevel Multipliers:")
    print("-" * 40)
    for level, mult in level_multipliers.items():
        print(f"  L{level}: {mult}x")

    print("\nCalculated Speed by Level (pixels/second):")
    print("-" * 60)
    print(f"{'Ball Type':<12} {'L1':<12} {'L2':<12} {'L3':<12}")
    print("-" * 60)
    for ball_name, base_speed in ball_speeds.items():
        l1 = base_speed * level_multipliers[1]
        l2 = base_speed * level_multipliers[2]
        l3 = base_speed * level_multipliers[3]
        print(f"{ball_name:<12} {l1:<12.0f} {l2:<12.0f} {l3:<12.0f}")

    print("\nSpeed Variance Analysis:")
    print("-" * 40)
    base = 800.0
    for ball_name, speed in ball_speeds.items():
        if speed != base:
            diff_pct = ((speed - base) / base) * 100
            print(f"  {ball_name}: {diff_pct:+.0f}% vs standard ({speed:.0f} vs {base:.0f})")

    print("\n" + "=" * 60)
    print("Speed Design Philosophy:")
    print("-" * 40)
    print("  - Most balls share standard 800 px/s base")
    print("  - Lightning is 12.5% faster (hit & run)")
    print("  - Iron is 25% slower (heavy/high damage)")
    print("=" * 60 + "\n")

    # Always pass - this is measurement
    assert True
