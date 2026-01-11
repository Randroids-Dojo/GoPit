"""Measure magnetism range per upgrade level for BallxPit comparison."""
import asyncio
import pytest

GAME_MANAGER = "/root/GameManager"


@pytest.mark.asyncio
async def test_measure_magnetism(game):
    """Measure magnetism range values at each upgrade level."""

    print("\n" + "=" * 60)
    print("MEASUREMENT: Magnetism Range")
    print("=" * 60)

    # Get current magnetism range from GameManager
    base_range = await game.get_property(GAME_MANAGER, "gem_magnetism_range")

    print(f"\nBase Values:")
    print(f"  Default Range: {base_range} pixels (0 = disabled)")
    print(f"  Upgrade Increment: 200 pixels per level")
    print(f"  Max Stacks: 3")

    print("\n" + "-" * 60)
    print("Magnetism Range per Upgrade Level:")
    print("-" * 60)
    print(f"{'Level':<10} {'Range (px)':<15} {'Notes'}")
    print("-" * 60)

    # Calculate ranges based on code analysis (level_up_overlay.gd)
    # Each upgrade adds 200.0 to gem_magnetism_range
    upgrade_increment = 200.0
    max_stacks = 3

    for level in range(max_stacks + 1):
        range_val = level * upgrade_increment
        if level == 0:
            notes = "No magnet (default)"
        elif level == 1:
            notes = "Basic attraction"
        elif level == 2:
            notes = "Medium range"
        else:
            notes = "Max range"
        print(f"{level:<10} {range_val:<15.0f} {notes}")

    print("\n" + "-" * 60)
    print("Magnetism Pull Speed:")
    print("-" * 60)
    print("  Base Speed: lerp from fall_speed to 500 px/s")
    print("  Pull Strength: increases as gem gets closer")
    print("  Formula: speed = lerp(fall_speed, 500, 1 - distance/range)")

    print("\n" + "-" * 60)
    print("Special Cases:")
    print("-" * 60)
    print("  Gems: Use full magnetism_range")
    print("  Fusion Reactors: Use 1.5x magnetism_range")

    print("\n" + "-" * 60)
    print("BallxPit Reference:")
    print("-" * 60)
    print("  Magnet passive: +1 tile per level (up to L3)")
    print("  Shieldbearer/Tactician: Hidden level-wide magnet")
    print("  Boss fights: Auto-enable magnet for all characters")
    print("  Source: GameFAQs Passives Guide")

    print("\n" + "-" * 60)
    print("Comparison:")
    print("-" * 60)
    print(f"{'Aspect':<25} {'BallxPit':<20} {'GoPit'}")
    print("-" * 60)
    print(f"{'Default Range':<25} {'0 (no magnet)':<20} 0 (no magnet)")
    print(f"{'Max Upgrades':<25} {'3 levels':<20} 3 stacks")
    print(f"{'Per-Level Increase':<25} {'+1 tile':<20} +200 pixels")
    print(f"{'Boss Auto-Magnet':<25} {'Yes':<20} No")
    print(f"{'Character Magnet':<25} {'2 have hidden':<20} None")

    print("\n" + "=" * 60)
    print("KEY FINDINGS:")
    print("-" * 40)
    print("  1. GoPit uses pixel-based range (200px increments)")
    print("  2. BallxPit uses tile-based range (+1 tile/level)")
    print("  3. Both have same max upgrade level (3)")
    print("  4. Missing: Boss fight auto-magnet feature")
    print("  5. Missing: Character-specific hidden magnet")
    print("=" * 60 + "\n")

    # Always pass - this is measurement
    assert True
