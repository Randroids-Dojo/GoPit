---
title: "implement: Fix flaky meta_progression tests"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T01:10:38.946236-06:00"
---

## Description

Fix flaky tests in `tests/test_meta_progression.py` by replacing fixed `asyncio.sleep()` calls with proper state-waiting using the existing `wait_for_condition()` helper.

## Context

Research (GoPit-implement-fix-test-92bfaf01) identified that these tests are flaky due to timing issues:
- `test_coins_earned_on_game_over` - sometimes fails with "Game over overlay should be visible"
- `test_shop_opens_from_game_over` - sometimes fails
- `test_shop_close_button` - sometimes fails

Root cause: Tests use fixed sleeps (e.g., `asyncio.sleep(1.0)`) instead of waiting for actual state changes. This is unreliable in headless/CI environments under load.

## Affected Files

- `tests/test_meta_progression.py` - Update tests to use wait helpers
- `tests/helpers.py` - Add new wait helpers if needed

## Implementation Notes

### Add New Helper Functions (helpers.py)

```python
async def wait_for_visible(game, node_path, timeout=WAIT_TIMEOUT):
    """Wait for a node to become visible."""
    async def is_visible():
        return await game.get_property(node_path, "visible")
    return await wait_for_condition(game, is_visible, timeout)

async def wait_for_game_over(game, timeout=WAIT_TIMEOUT):
    """Wait for game over overlay to become visible."""
    return await wait_for_visible(game, PATHS["game_over_overlay"], timeout)
```

### Update trigger_game_over Helper

Replace:
```python
async def trigger_game_over(game):
    """Helper to trigger game over by dealing exactly max HP damage."""
    max_hp = await game.get_property("/root/GameManager", "max_hp")
    await game.call("/root/GameManager", "take_damage", [max_hp])
    await asyncio.sleep(1.0)
```

With:
```python
async def trigger_game_over(game):
    """Helper to trigger game over by dealing exactly max HP damage."""
    max_hp = await game.get_property("/root/GameManager", "max_hp")
    await game.call("/root/GameManager", "take_damage", [max_hp])
    # Wait for actual state change instead of fixed sleep
    from helpers import wait_for_game_over
    success = await wait_for_game_over(game)
    assert success, "Game over should trigger within timeout"
```

### Update Tests Using Fixed Sleeps

- `test_shop_opens_from_game_over`: Wait for shop visibility, not fixed sleep
- `test_shop_close_button`: Wait for shop to close, not fixed sleep
- Similar pattern for other flaky tests

### Character HP Variance

Consider logging which character is selected in tests, as different characters have different HP:
```python
max_hp = int(100 * character.endurance)
```

If a character has endurance > 1.0, they may survive 100 damage. The fix of using `max_hp` from GameManager should handle this.

## Verify

- [ ] `./test.sh` passes
- [ ] Run `pytest tests/test_meta_progression.py -v --count=5` - all 5 runs pass
- [ ] Run `pytest tests/test_meta_progression.py -v -n 4` - parallel tests pass
- [ ] No more flaky failures in CI for these tests
