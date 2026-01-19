---
title: Add passive abilities integration tests
status: open
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-08T19:57:16.274692-06:00
---

## Description

Add PlayGodot tests to verify passive abilities correctly modify gameplay.

## Context

Each character has a unique passive ability that modifies gameplay. There are 16 passives defined in `GameManager.Passive` enum. Currently no tests verify these work correctly during gameplay.

## Affected Files

- NEW: `tests/test_passives.py` - New test file

## Passive Abilities to Test

### Priority 1 (Core passives - test first)
1. **Quick Learner** - +20% XP from gems (`get_xp_multiplier()`)
2. **Jackpot** - +10% crit chance, +30% XP (`get_bonus_crit_chance()`, `get_xp_multiplier()`)
3. **Lifesteal** - Heal 5% of damage dealt (`get_lifesteal_percent()`)
4. **Squad Leader** - +2 baby balls, +30% baby ball rate (`get_extra_baby_balls()`, `get_baby_ball_rate_bonus()`)
5. **Shatter** - +50% damage vs frozen, +30% freeze duration (`get_damage_vs_frozen()`, `get_freeze_duration_bonus()`)

### Priority 2 (Combat passives)
6. **Inferno** - +20% fire damage, +25% damage vs burning (`get_fire_damage_multiplier()`, `get_damage_vs_burning()`)
7. **Bounce Master** - +3 bounces (`get_bounce_bonus()`)
8. **Executioner** - +100% damage to enemies <30% HP (`get_executioner_multiplier()`)
9. **Berserker** - +50% damage when <50% HP (`get_berserker_damage_mult()`)
10. **Bloodlust** - +5% damage per kill (10 stacks max) (`get_bloodlust_damage_mult()`)

### Priority 3 (Utility passives)
11. **Collector** - Auto-collect gems, +20% gem value (`is_auto_collect_enabled()`, `get_gem_bonus()`)
12. **Empty Nester** - No baby balls, double special fires (`has_no_baby_balls()`, `get_special_fire_count()`)
13. **Swarm Lord** - +50% baby ball damage (`get_baby_ball_damage_mult()`)
14. **Gravity** - Pull enemies toward balls (`has_gravity_pull()`)
15. **Shield Bounce** - Bounce off shield edges (`has_shield_bounce()`)
16. **Pandemic** - +50% status effect spread range (`get_disease_spread_range_mult()`)

## Implementation Notes

```python
@pytest.mark.asyncio
async def test_quick_learner_xp_bonus(game):
    """Verify Quick Learner passive gives +20% XP."""
    # Set Quixley (has Quick Learner passive)
    await game.call(GAME_MANAGER, "set_test_passive", ["QUICK_LEARNER"])

    # Get XP multiplier
    xp_mult = await game.call(GAME_MANAGER, "get_xp_multiplier")
    assert xp_mult >= 1.2, f"Expected 1.2 XP mult with Quick Learner, got {xp_mult}"
```

Note: May need to add `set_test_passive()` method to GameManager for test isolation.

## Verify

- [ ] `./test.sh tests/test_passives.py` passes
- [ ] Tests cover at least Priority 1 passives
- [ ] Tests verify actual gameplay effect where possible (not just return values)
- [ ] No flaky tests
