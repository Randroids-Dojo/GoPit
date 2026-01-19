---
title: Add meta-progression system (Pit Coins)
status: done
priority: 0
issue-type: feature
assignee: randroid
created-at: 2026-01-05T02:02:56.728446-06:00
---

## Problem
No meta-progression system exists. Each run starts fresh with no permanent upgrades, unlocks, or currency. Players have no reason to replay after initial curiosity wears off. This is the #1 retention killer.

## Implementation Plan

### Phase 1: Currency System
**File: `scripts/autoload/meta_manager.gd`** (new autoload)

```gdscript
extends Node
# Persisted data
var pit_coins: int = 0
var total_runs: int = 0
var unlocked_upgrades: Array[String] = []

func _ready():
    load_data()

func earn_coins(wave: int, level: int) -> int:
    var earned = wave * 10 + level * 25
    pit_coins += earned
    save_data()
    return earned

func spend_coins(amount: int) -> bool:
    if pit_coins >= amount:
        pit_coins -= amount
        save_data()
        return true
    return false

func save_data():
    var data = {"coins": pit_coins, "runs": total_runs, "unlocks": unlocked_upgrades}
    var file = FileAccess.open("user://meta.save", FileAccess.WRITE)
    file.store_string(JSON.stringify(data))

func load_data():
    if FileAccess.file_exists("user://meta.save"):
        var file = FileAccess.open("user://meta.save", FileAccess.READ)
        var data = JSON.parse_string(file.get_as_text())
        pit_coins = data.get("coins", 0)
        total_runs = data.get("runs", 0)
        unlocked_upgrades = data.get("unlocks", [])
```

### Phase 2: Permanent Upgrades
**File: `scripts/data/permanent_upgrades.gd`**

Define permanent upgrades purchasable with Pit Coins:
- Starting HP +10 (cost: 100, 200, 400, 800...)
- Starting Damage +2 (cost: 150, 300, 600...)
- Starting Fire Rate -0.05s (cost: 200, 400, 800...)
- Unlock ball types (cost: 500 each)

### Phase 3: UI Integration
**File: `scenes/ui/meta_shop.tscn`** (new scene)

- Main menu with "SHOP" button
- Grid of upgrade cards showing:
  - Upgrade name and current level
  - Cost for next level
  - Buy button (disabled if insufficient coins)
- Coin balance display in corner

### Phase 4: Game Over Integration
**Modify: `scripts/ui/game_over_overlay.gd`**

- Show coins earned this run
- Show total coin balance
- Add "SHOP" button to go to upgrade menu

### Files to Create/Modify
1. NEW: `scripts/autoload/meta_manager.gd`
2. NEW: `scripts/data/permanent_upgrades.gd`
3. NEW: `scenes/ui/meta_shop.tscn`
4. NEW: `scripts/ui/meta_shop.gd`
5. MODIFY: `scripts/ui/game_over_overlay.gd`
6. MODIFY: `project.godot` (add MetaManager autoload)
7. NEW: `scenes/main_menu.tscn` (optional - for shop access)

### Testing
- Verify coins save/load correctly
- Verify upgrades apply on game start
- Verify coins accumulate across runs
- Test purchase flow and insufficient funds
