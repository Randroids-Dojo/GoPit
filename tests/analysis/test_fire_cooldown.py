"""Measure fire cooldown / rate for BallxPit comparison."""
import asyncio
import pytest

FIRE_BUTTON = "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton"
GAME_MANAGER = "/root/GameManager"


@pytest.mark.asyncio
async def test_measure_fire_cooldown(game):
    """Measure fire cooldown and rate values."""

    print("\n" + "=" * 60)
    print("MEASUREMENT: Fire Cooldown / Rate")
    print("=" * 60)

    # Get base cooldown from fire button
    base_cooldown = await game.get_property(FIRE_BUTTON, "cooldown_duration")
    print(f"\nBase Cooldown: {base_cooldown}s")
    print(f"Base Fire Rate: {1.0 / base_cooldown:.1f} balls/second")

    # Get character speed multiplier (affects cooldown)
    char_speed = await game.get_property(GAME_MANAGER, "character_speed_mult")
    print(f"\nCharacter Speed Mult: {char_speed}x")

    effective_cooldown = base_cooldown / char_speed
    print(f"Effective Cooldown: {effective_cooldown:.2f}s")
    print(f"Effective Fire Rate: {1.0 / effective_cooldown:.1f} balls/second")

    # Check autofire state
    autofire_enabled = await game.get_property(FIRE_BUTTON, "autofire_enabled")
    print(f"\nAutofire Available: Yes (toggle button)")
    print(f"Autofire Enabled: {autofire_enabled}")

    print("\n" + "-" * 60)
    print("Fire Rate by Character Speed Modifier:")
    print("-" * 60)
    print(f"{'Speed Mult':<15} {'Cooldown':<15} {'Fire Rate':<15}")
    print("-" * 60)
    for mult in [1.0, 1.25, 1.5, 2.0]:
        cd = base_cooldown / mult
        rate = 1.0 / cd
        print(f"{mult}x{'':<13} {cd:.2f}s{'':<11} {rate:.1f} balls/s")

    print("\n" + "-" * 60)
    print("Permanent Upgrade: Rapid Fire")
    print("-" * 60)
    print("  Each level: -0.1s cooldown")
    print("  Max levels: 5")
    print("  Base cost: 200 Pit Coins (doubles per level)")
    for level in range(6):
        reduced_cd = max(0.1, base_cooldown - (level * 0.1))
        rate = 1.0 / reduced_cd
        print(f"  Level {level}: {reduced_cd:.1f}s cooldown ({rate:.1f} balls/s)")

    print("\n" + "=" * 60)
    print("Design Notes:")
    print("-" * 40)
    print("  - All equipped balls fire simultaneously")
    print("  - Cooldown shared across all ball slots")
    print("  - Autofire automatically fires when ready")
    print("  - Character passives can modify speed mult")
    print("=" * 60 + "\n")

    # Always pass - this is measurement
    assert True
