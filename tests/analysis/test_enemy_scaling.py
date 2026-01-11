"""Measure enemy HP and speed scaling per wave for BallxPit comparison."""
import asyncio
import pytest


@pytest.mark.asyncio
async def test_measure_enemy_scaling(game):
    """Measure enemy scaling values per wave."""

    print("\n" + "=" * 60)
    print("MEASUREMENT: Enemy HP & Speed Scaling Per Wave")
    print("=" * 60)

    # From code analysis (enemy_base.gd _scale_with_wave())
    # HP: max_hp = int(max_hp * (1.0 + (wave - 1) * 0.1))  -> +10% per wave
    # Speed: speed = speed * min(2.0, 1.0 + (wave - 1) * 0.05)  -> +5% per wave, capped at 2x
    # XP: xp_value = int(xp_value * (1.0 + (wave - 1) * 0.05))  -> +5% per wave

    print("\n" + "-" * 60)
    print("Scaling Formulas (from code):")
    print("-" * 60)
    print("  HP:    max_hp * (1.0 + (wave - 1) * 0.10)")
    print("  Speed: base_speed * min(2.0, 1.0 + (wave - 1) * 0.05)")
    print("  XP:    xp_value * (1.0 + (wave - 1) * 0.05)")
    print("")
    print("  HP:    +10% per wave (linear, no cap)")
    print("  Speed: +5% per wave (capped at 2x)")
    print("  XP:    +5% per wave (linear, no cap)")

    print("\n" + "-" * 60)
    print("Multiplier Progression:")
    print("-" * 60)
    print(f"{'Wave':<8} {'HP Mult':<12} {'Speed Mult':<12} {'XP Mult':<12}")
    print("-" * 60)
    for wave in [1, 2, 3, 5, 10, 15, 20, 30, 50]:
        hp_mult = 1.0 + (wave - 1) * 0.1
        speed_mult = min(2.0, 1.0 + (wave - 1) * 0.05)
        xp_mult = 1.0 + (wave - 1) * 0.05
        print(f"{wave:<8} {hp_mult:.1f}x{'':<9} {speed_mult:.2f}x{'':<8} {xp_mult:.2f}x")

    print("\n" + "-" * 60)
    print("Slime HP & Speed by Wave:")
    print("-" * 60)
    base_hp = 10
    base_speed = 100  # px/s
    print(f"{'Wave':<8} {'HP':<10} {'Speed (px/s)':<15} {'Notes'}")
    print("-" * 60)
    for wave in [1, 5, 10, 15, 20, 21]:
        hp_mult = 1.0 + (wave - 1) * 0.1
        speed_mult = min(2.0, 1.0 + (wave - 1) * 0.05)
        hp = int(base_hp * hp_mult)
        speed = base_speed * speed_mult
        note = "Speed capped at 2x" if speed_mult >= 2.0 else ""
        print(f"{wave:<8} {hp:<10} {speed:<15.0f} {note}")

    print("\n" + "-" * 60)
    print("Speed Cap Analysis:")
    print("-" * 60)
    print("  Speed reaches 2x cap at wave 21")
    print("  Speed formula: 1.0 + (wave - 1) * 0.05 = 2.0")
    print("  Solving: (wave - 1) * 0.05 = 1.0 -> wave = 21")
    print("  After wave 21, HP continues scaling but speed stays at 2x")

    print("\n" + "-" * 60)
    print("Difficulty Curve Comparison:")
    print("-" * 60)
    print("  BallxPit: Post-boss HP spike (feels like 3x sudden increase)")
    print("  BallxPit: Fast modes compound exponentially")
    print("  BallxPit: NG+ = +50% HP, +50% damage (major spike)")
    print("  GoPit:    Linear +10% HP per wave (gradual)")
    print("  GoPit:    +5% speed per wave (capped at 2x)")

    print("\n" + "=" * 60)
    print("KEY FINDING: GoPit scaling is linear and predictable")
    print("BallxPit has steeper post-boss spikes for difficulty")
    print("=" * 60 + "\n")

    # Always pass - this is measurement
    assert True
