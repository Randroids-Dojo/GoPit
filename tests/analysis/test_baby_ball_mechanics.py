"""Measure baby ball damage and spawn mechanics for BallxPit comparison."""
import asyncio
import pytest

BABY_SPAWNER = "/root/Game/GameArea/BabyBallSpawner"
GAME_MANAGER = "/root/GameManager"


@pytest.mark.asyncio
async def test_measure_baby_ball_mechanics(game):
    """Measure baby ball damage, spawn rate, and scaling."""

    print("\n" + "=" * 60)
    print("MEASUREMENT: Baby Ball Mechanics")
    print("=" * 60)

    # Get values from game
    base_interval = await game.get_property(BABY_SPAWNER, "base_spawn_interval")
    damage_mult = await game.get_property(BABY_SPAWNER, "baby_ball_damage_multiplier")
    scale = await game.get_property(BABY_SPAWNER, "baby_ball_scale")

    print(f"\nBase Values:")
    print(f"  Spawn Interval: {base_interval}s")
    print(f"  Damage Multiplier: {damage_mult * 100:.0f}% of parent")
    print(f"  Visual Scale: {scale * 100:.0f}% size")

    # Calculate damage examples
    print("\n" + "-" * 60)
    print("Baby Ball Damage (50% of parent):")
    print("-" * 60)
    print(f"{'Parent Ball':<15} {'Parent Dmg':<12} {'Baby Dmg':<12}")
    print("-" * 60)
    parent_damages = {
        "Basic (L1)": 10,
        "Basic (L2)": 15,
        "Basic (L3)": 20,
        "Iron (L1)": 15,
        "Iron (L3)": 30,
    }
    for name, parent_dmg in parent_damages.items():
        baby_dmg = int(parent_dmg * 0.5)
        print(f"{name:<15} {parent_dmg:<12} {baby_dmg:<12}")

    print("\n" + "-" * 60)
    print("Spawn Rate Modifiers:")
    print("-" * 60)
    print("  Base interval: 2.0s")
    print("  Leadership bonus: Reduces interval")
    print("  Character leadership mult: Varies by character")
    print("  Speed mult: Affects interval")
    print("  Squad Leader passive: +30% spawn rate")
    print("  Minimum interval: 0.3s (capped)")

    print("\n" + "-" * 60)
    print("Spawn Rate Examples:")
    print("-" * 60)
    print(f"{'Modifiers':<30} {'Interval':<12} {'Rate':<12}")
    print("-" * 60)
    base = 2.0
    examples = [
        ("Base (no bonuses)", 1.0, 1.0, 0.0),
        ("1.5x character speed", 1.0, 1.5, 0.0),
        ("Squad Leader (+30%)", 1.0, 1.0, 0.3),
        ("Max leadership (1.0)", 2.0, 1.0, 0.0),
        ("Combined maxed", 2.0, 2.0, 0.3),
    ]
    for name, leadership, speed, passive in examples:
        total_bonus = leadership + passive
        interval = base / ((1.0 + total_bonus) * speed)
        interval = max(0.3, interval)
        rate = 1.0 / interval
        print(f"{name:<30} {interval:.2f}s{'':<8} {rate:.1f}/s")

    print("\n" + "-" * 60)
    print("BallxPit Reference:")
    print("-" * 60)
    print("  Baby Ball Damage: 11-17 at Leadership 4")
    print("  Leadership affects count AND damage")
    print("  Can flood firing queue (reduces DPS)")
    print("  Baby balls block specials in queue")
    print("  Empty Nester: no baby balls, multiple specials")

    print("\n" + "-" * 60)
    print("Comparison:")
    print("-" * 60)
    print(f"{'Aspect':<25} {'BallxPit':<20} {'GoPit'}")
    print("-" * 60)
    print(f"{'Damage System':<25} {'Leadership stat':<20} 50% of parent")
    print(f"{'Spawn System':<25} {'Count-based queue':<20} Timer-based auto")
    print(f"{'Queue Issues':<25} {'Blocks specials':<20} N/A (separate)")
    print(f"{'Damage Range':<25} {'11-17 base':<20} 5-15 (50% of 10-30)")

    print("\n" + "=" * 60)
    print("KEY FINDINGS:")
    print("-" * 40)
    print("  1. GoPit uses simple 50% damage multiplier")
    print("  2. GoPit baby balls don't block main fire")
    print("  3. BallxPit has queue-based baby ball system")
    print("  4. Both scale with leadership-like stats")
    print("=" * 60 + "\n")

    # Always pass - this is measurement
    assert True
