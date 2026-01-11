"""Measure XP mechanics for BallxPit comparison."""
import asyncio
import pytest

GAME_MANAGER = "/root/GameManager"


@pytest.mark.asyncio
async def test_measure_xp_mechanics(game):
    """Measure XP per gem and level-up curve."""

    print("\n" + "=" * 60)
    print("MEASUREMENT: XP Mechanics")
    print("=" * 60)

    # Get current XP values
    current_xp = await game.get_property(GAME_MANAGER, "current_xp")
    xp_to_next = await game.get_property(GAME_MANAGER, "xp_to_next_level")
    player_level = await game.get_property(GAME_MANAGER, "player_level")

    print(f"\nCurrent State:")
    print(f"  Player Level: {player_level}")
    print(f"  Current XP: {current_xp}")
    print(f"  XP to Next: {xp_to_next}")

    # From code analysis:
    # _calculate_xp_requirement(level) = 100 + (level - 1) * 50
    # xp_value default = 10 per enemy (scales +5% per wave)

    print("\n" + "-" * 60)
    print("XP Per Gem (from code analysis):")
    print("-" * 60)
    print(f"{'Enemy':<12} {'Base XP':<10} {'Wave 5':<10} {'Wave 10':<10}")
    print("-" * 60)
    enemies = {
        "Slime": 10,
        "Bat": 12,  # 10 * 1.2
        "Crab": 13,  # 10 * 1.3
        "Slime King": 100,
    }
    for name, base_xp in enemies.items():
        wave5 = int(base_xp * (1.0 + 4 * 0.05)) if "King" not in name else base_xp
        wave10 = int(base_xp * (1.0 + 9 * 0.05)) if "King" not in name else base_xp
        print(f"{name:<12} {base_xp:<10} {wave5:<10} {wave10:<10}")

    print("\n" + "-" * 60)
    print("XP to Level Up Curve:")
    print("-" * 60)
    print("Formula: 100 + (level - 1) * 50")
    print("")
    print(f"{'Level':<8} {'XP Required':<15} {'Cumulative':<15} {'Gems to Level (base 10)':<20}")
    print("-" * 60)
    cumulative = 0
    for level in range(1, 11):
        xp_req = 100 + (level - 1) * 50
        cumulative += xp_req
        gems = (xp_req + 9) // 10  # Round up
        print(f"{level:<8} {xp_req:<15} {cumulative:<15} {gems:<20}")

    print("\n" + "-" * 60)
    print("XP Modifiers:")
    print("-" * 60)
    print("  Quick Learner (Rookie): +10% XP gain")
    print("  Combo multiplier: Scales with consecutive hits")
    print("  Wave scaling: +5% XP per wave")

    print("\n" + "-" * 60)
    print("BallxPit Reference:")
    print("-" * 60)
    print("  1 XP = 1 Kill (base)")
    print("  Veteran's Hut: +25% bonus XP")
    print("  Abbey: +5% XP on level 1")
    print("  Each level = new ball or upgrade choice")

    print("\n" + "=" * 60)
    print("Level Progression Speed (rough estimate):")
    print("-" * 40)
    print("  L1->L2: 10 enemies (100 XP)")
    print("  L2->L3: 15 enemies (150 XP)")
    print("  L3->L4: 20 enemies (200 XP)")
    print("  First 5 levels: ~60 enemies total")
    print("=" * 60 + "\n")

    # Always pass - this is measurement
    assert True
