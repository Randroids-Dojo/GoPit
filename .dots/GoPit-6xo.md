---
title: Add character stats integration tests
status: open
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-08T19:57:16.049635-06:00
---

## Description

Add PlayGodot tests to verify character stat multipliers correctly affect gameplay mechanics.

## Context

Characters have 5 stats that modify gameplay: strength (damage), speed, dexterity (crit), leadership (baby balls), and intelligence (status effects). These are stored as multipliers in `GameManager` and applied throughout the codebase, but no tests verify the integration works correctly.

## Affected Files

- NEW: `tests/test_character_stats.py` - New test file

## Stats to Test

1. **Strength** (`character_damage_mult`)
   - Verify ball damage scales with strength stat
   - Location: `game_manager.gd:215` affects base damage

2. **Speed** (`character_speed_mult`)
   - Verify player movement speed changes
   - Verify ball speed changes
   - Verify fire cooldown changes
   - Locations: `player.gd:44`, `ball_spawner.gd:337-353`, `fire_button.gd:131`

3. **Dexterity** (`character_crit_mult`)
   - Verify crit chance scales
   - Location: `game_manager.gd:543`

4. **Intelligence** (`character_intelligence_mult`)
   - Verify status effect duration scales
   - Verify status effect damage scales
   - Location: `status_effect.gd:29-31`

5. **Leadership** (`character_leadership_mult`)
   - Verify baby ball count changes
   - Location: `baby_ball_spawner.gd:56-59`

## Implementation Notes

```python
# Example test structure
@pytest.mark.asyncio
async def test_strength_affects_damage(game):
    """Verify high strength character deals more damage."""
    # Set character with high strength
    await game.call("/root/Game", "set_test_character_stat", ["strength", 2.0])

    # Spawn enemy, record HP
    await game.call(ENEMY_SPAWNER, "spawn_enemy")
    enemy_path = await game.call(ENEMY_SPAWNER, "get_last_enemy_path")
    initial_hp = await game.get_property(enemy_path, "current_health")

    # Fire ball at enemy
    await game.click(FIRE_BUTTON)
    await asyncio.sleep(0.5)

    # Verify damage scaled
    final_hp = await game.get_property(enemy_path, "current_health")
    damage_dealt = initial_hp - final_hp
    # With 2x strength, expect ~2x base damage (10 * 2 = 20)
    assert damage_dealt >= 18, f"Expected ~20 damage, got {damage_dealt}"
```

Note: May need to add `set_test_character_stat()` method to GameManager for test isolation.

## Verify

- [ ] `./test.sh tests/test_character_stats.py` passes
- [ ] Tests cover all 5 stat types
- [ ] Tests verify actual gameplay effect (not just variable values)
- [ ] No flaky tests (timing-dependent failures)
