"""Measure enemy base HP for BallxPit comparison."""
import asyncio
import pytest

ENEMY_SPAWNER = "/root/Game/GameArea/EnemySpawner"
GAME_MANAGER = "/root/GameManager"


@pytest.mark.asyncio
async def test_measure_enemy_hp(game):
    """Measure enemy base HP and scaling values."""

    print("\n" + "=" * 60)
    print("MEASUREMENT: Enemy Base HP")
    print("=" * 60)

    # From code analysis (can't easily spawn enemies in test)
    # enemy_base.gd: @export var max_hp: int = 10
    # _scale_with_wave(): max_hp = int(max_hp * (1.0 + (wave - 1) * 0.1))

    print("\n" + "-" * 60)
    print("Base HP by Enemy Type (from code analysis):")
    print("-" * 60)

    enemies = {
        "Slime": {"base_hp": 10, "speed_mult": 1.0, "xp_mult": 1.0, "notes": "Default stats"},
        "Bat": {"base_hp": 10, "speed_mult": 1.3, "xp_mult": 1.2, "notes": "Fast, zigzag movement"},
        "Crab": {"base_hp": 15, "speed_mult": 0.6, "xp_mult": 1.3, "notes": "Tanky (1.5x HP), slow, sideways"},
    }

    print(f"{'Enemy':<10} {'Base HP':<10} {'Speed':<10} {'XP':<10} {'Notes'}")
    print("-" * 60)
    for name, data in enemies.items():
        print(f"{name:<10} {data['base_hp']:<10} {data['speed_mult']:.1f}x{'':<6} {data['xp_mult']:.1f}x{'':<6} {data['notes']}")

    print("\n" + "-" * 60)
    print("HP Scaling Per Wave (+10% per wave):")
    print("-" * 60)
    print(f"{'Wave':<8} {'Slime':<10} {'Bat':<10} {'Crab':<10}")
    print("-" * 60)
    for wave in [1, 2, 3, 5, 10, 20]:
        scale = 1.0 + (wave - 1) * 0.1
        slime_hp = int(10 * scale)
        bat_hp = int(10 * scale)
        crab_hp = int(15 * scale)
        print(f"{wave:<8} {slime_hp:<10} {bat_hp:<10} {crab_hp:<10}")

    print("\n" + "-" * 60)
    print("Hits to Kill (with 10 damage Basic Ball):")
    print("-" * 60)
    print(f"{'Wave':<8} {'Slime':<10} {'Bat':<10} {'Crab':<10}")
    print("-" * 60)
    for wave in [1, 2, 3, 5, 10]:
        scale = 1.0 + (wave - 1) * 0.1
        import math
        slime_hits = math.ceil(10 * scale / 10)
        bat_hits = math.ceil(10 * scale / 10)
        crab_hits = math.ceil(15 * scale / 10)
        print(f"{wave:<8} {slime_hits:<10} {bat_hits:<10} {crab_hits:<10}")

    print("\n" + "=" * 60)
    print("Design Notes:")
    print("-" * 40)
    print("  - Base HP values are simple (10-15)")
    print("  - Wave scaling linear (+10% per wave)")
    print("  - Enemy variety through HP/speed tradeoffs")
    print("  - Crab is tankier, slower - requires more hits")
    print("=" * 60 + "\n")

    # Always pass - this is measurement
    assert True
