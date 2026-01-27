---
title: Implement boss/wave progress bar
status: closed
priority: 2
issue-type: implement
created-at: 2026-01-27T12:00:00Z
closed-at: 2026-01-27T12:30:00Z
---

## Overview

Add a compact horizontal progress bar showing progress toward the next boss wave, similar to BallxPit's vertical boss meter.

**Resolution:** Implemented in:
- `scenes/game.tscn` - Added BossProgressContainer with ProgressBar and "BOSS" label
- `scripts/ui/hud.gd` - Added `_update_boss_progress()` function
- Bar fills as waves progress, label turns orange/red when near boss

## Reference

From BallxPit screenshot analysis:
- Vertical bar on right side showing progress to boss
- Boss name displayed ("Twisted Serpent")
- Visual indicator of how close player is to boss fight

## Requirements

### 1. Portrait-Mode Adaptation

Since GoPit is portrait, use a **thin horizontal bar** at top of screen:
- Position: Below wave counter, above game area
- Width: 80% of screen width
- Height: 8-12px (thin but visible)

### 2. Progress Calculation

**File:** `scripts/autoload/game_manager.gd` or `scripts/autoload/stage_manager.gd`

- Track waves until boss (e.g., boss every 10 waves)
- Calculate progress: `(current_wave % boss_interval) / boss_interval`
- Signal when boss wave reached

### 3. UI Implementation

**File:** `scripts/ui/hud.gd` + scene

- ProgressBar or TextureProgressBar node
- Smooth tween animation when progress changes
- Optional: Boss icon at end of bar
- Optional: "BOSS" text appears when bar fills

### 4. Visual Style

- Bar color: Orange/red gradient (danger feeling)
- Background: Dark/muted
- Glow or pulse effect when near boss (>80%)
- Flash when boss wave starts

## Acceptance Criteria

- [ ] Progress bar visible at top of screen
- [ ] Bar fills as waves progress toward boss
- [ ] Bar resets after boss defeated
- [ ] Visual feedback when boss wave imminent
- [ ] Works in portrait mode without blocking gameplay
- [ ] Tests pass
