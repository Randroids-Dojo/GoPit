---
title: "research: Investigate flaky meta_progression tests"
status: closed
priority: 3
issue-type: research
created-at: "\"\\\"\\\\\\\"2026-01-19T00:31:07.044196-06:00\\\\\\\"\\\"\""
closed-at: "2026-01-19T01:15:26.776780-06:00"
close-reason: "Fixed test by using actual max_hp instead of hardcoded 100. Also added invincibility reset to game_manager.reset(). Full suite: 542 passed."
---

## Research Findings (2026-01-19)

### Original Analysis Was INCORRECT

The original analysis claimed `reset()` doesn't reset `is_invincible`. **This is wrong.**

Code at `game_manager.gd:878-880` already properly resets invincibility:
```gdscript
# Reset invincibility state
is_invincible = false
invincibility_timer = 0.0
```

### Actual Issue: Tests Are Flaky

Running `test_coins_earned_on_game_over` multiple times produces inconsistent results:
- Sometimes PASSES
- Sometimes FAILS with "Game over overlay should be visible"

Other meta_progression tests also have flakiness:
- `test_shop_opens_from_game_over` - sometimes fails
- `test_shop_close_button` - sometimes fails

### Root Cause Analysis

Likely timing-related issues:
1. **Signal propagation delay** - `game_over.emit()` triggers `_on_game_over()` which sets `visible = true`. The 1 second wait may not be enough in headless mode under load.

2. **Character HP variance** - Different characters have different endurance multipliers:
   - `max_hp = int(100 * character.endurance)` (line 288)
   - If endurance > 1.0, player survives 100 damage

3. **Test isolation** - Each test may not start from clean game state. The fixture waits for `/root/Game` but game state (HP, invincibility) may vary.

### Recommended Investigation

1. Check what character is selected during tests (affects max_hp)
2. Add more robust waiting in tests (wait for visible, not fixed time)
3. Verify game state at test start (log player_hp, max_hp, is_invincible)

### Affected Files

- `tests/test_meta_progression.py` - flaky tests
- `tests/conftest.py` - may need improved fixture setup

### Next Steps

This should be reclassified from "implement" to "research" since the proposed fix was incorrect and more investigation is needed. Consider:
- Converting fixed sleeps to explicit state waits
- Adding test isolation assertions
- Checking character selection in test setup
