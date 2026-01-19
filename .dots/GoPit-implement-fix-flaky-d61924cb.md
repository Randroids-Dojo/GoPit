---
title: "implement: Fix flaky meta_progression tests"
status: active
priority: 2
issue-type: task
created-at: "\"2026-01-19T01:10:38.946236-06:00\""
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

### Step 1: Add New Helper Functions (helpers.py)

Add these helpers to `tests/helpers.py`:

```python
async def wait_for_visible(game, node_path, timeout=WAIT_TIMEOUT):
    """Wait for a node to become visible."""
    async def is_visible():
        return await game.get_property(node_path, "visible")
    return await wait_for_condition(game, is_visible, timeout)

async def wait_for_not_visible(game, node_path, timeout=WAIT_TIMEOUT):
    """Wait for a node to become hidden."""
    async def is_hidden():
        return not await game.get_property(node_path, "visible")
    return await wait_for_condition(game, is_hidden, timeout)

async def wait_for_game_over(game, timeout=WAIT_TIMEOUT):
    """Wait for game over overlay to become visible."""
    return await wait_for_visible(game, PATHS["game_over_overlay"], timeout)

async def wait_for_meta_shop(game, timeout=WAIT_TIMEOUT):
    """Wait for meta shop to become visible."""
    return await wait_for_visible(game, "/root/Game/UI/MetaShop", timeout)

async def wait_for_meta_shop_closed(game, timeout=WAIT_TIMEOUT):
    """Wait for meta shop to close."""
    return await wait_for_not_visible(game, "/root/Game/UI/MetaShop", timeout)
```

### Step 2: Move trigger_game_over to helpers.py

Move `trigger_game_over` from `test_meta_progression.py` to `helpers.py` so it can use the wait helpers:

```python
async def trigger_game_over(game, timeout=WAIT_TIMEOUT):
    """Trigger game over by dealing exact max HP damage and wait for overlay."""
    max_hp = await game.get_property(PATHS["game_manager"], "max_hp")
    await game.call(PATHS["game_manager"], "take_damage", [max_hp])
    success = await wait_for_game_over(game, timeout)
    assert success, "Game over should trigger within timeout"
```

### Step 3: Update test_meta_progression.py imports

At the top of `test_meta_progression.py`, add:
```python
from helpers import (
    trigger_game_over,
    wait_for_meta_shop,
    wait_for_meta_shop_closed,
)
```

Remove the local `trigger_game_over` definition from the file (lines 8-12).

### Step 4: Sleep Replacement Map

Replace fixed sleeps with wait helpers:

| Line | Current Sleep | Test | Replacement |
|------|--------------|------|-------------|
| 12 | `asyncio.sleep(1.0)` | `trigger_game_over` | (moved to helpers, uses `wait_for_game_over`) |
| 70 | `asyncio.sleep(0.5)` | `test_shop_opens_from_game_over` | `await wait_for_meta_shop(game)` |
| 86 | `asyncio.sleep(0.5)` | `test_shop_displays_upgrades` | `await wait_for_meta_shop(game)` |
| 102 | `asyncio.sleep(0.5)` | `test_shop_close_button` (open) | `await wait_for_meta_shop(game)` |
| 110 | `asyncio.sleep(0.3)` | `test_shop_close_button` (close) | `await wait_for_meta_shop_closed(game)` |
| 126 | `asyncio.sleep(0.5)` | `test_coin_balance_display` | `await wait_for_meta_shop(game)` |

### Step 5: Persistence Test Sleeps (Leave as-is)

The sleeps in `test_meta_manager_persistence_functions` (lines 151, 155, 159, 167, 176, 180) are for file I/O timing, not UI state. These are harder to replace with state waits since we can't easily detect when file operations complete. Leave these as-is for now; they're already conditional (skipped in parallel mode).

### Step 6: test_upgrade_purchase Sleep (Leave as-is)

Line 195 (`asyncio.sleep(0.1)`) after `reset_data` is a minimal delay that's generally safe. Can be replaced with a wait if flaky.

### Character HP Variance Note

The `trigger_game_over` helper already handles character HP variance by reading `max_hp` from GameManager (which accounts for endurance multiplier).

## Verify

- [ ] `./test.sh` passes
- [ ] Run `pytest tests/test_meta_progression.py -v --count=5` - all 5 runs pass
- [ ] Run `pytest tests/test_meta_progression.py -v -n 4` - parallel tests pass
- [ ] No more flaky failures in CI for these tests
