---
title: Implement floating damage numbers
status: closed
priority: 1
issue-type: implement
created-at: 2026-01-27T12:00:00Z
closed-at: 2026-01-27T12:30:00Z
---

## Overview

Add BallxPit-style floating damage numbers that appear above enemies when they take damage.

**Resolution:** Already implemented in `scripts/effects/damage_number.gd` with:
- Rising animation (60px over 0.6s)
- Fade out effect
- Object pooling for performance
- Color customization per damage type
- Random offset to prevent stacking

## Reference

From BallxPit screenshot analysis:
- Damage numbers appear briefly above enemies when hit
- Numbers float upward and fade out
- Provides immediate visual feedback for player actions

## Requirements

### 1. Create DamageNumber Scene
**File:** `scenes/effects/damage_number.tscn` + `scripts/effects/damage_number.gd`

- Label node with dynamic text
- Float upward animation (50-80px over 0.5-0.8s)
- Fade out during animation
- Auto-queue_free after animation completes
- Support for different colors (white default, yellow for crits)

### 2. Spawn on Enemy Damage
**File:** `scripts/entities/enemies/enemy_base.gd`

In `take_damage()` function:
- Instantiate damage number at enemy position
- Set damage value as text
- Add to game layer (not enemy, so it persists if enemy dies)

### 3. Visual Style (Portrait-Friendly)

- Font size: 16-20px (readable but not overwhelming)
- Bold/outline for visibility against backgrounds
- Slight random X offset to prevent stacking
- Optional: Scale pulse on spawn (1.2x → 1.0x)

## Acceptance Criteria

- [ ] Damage numbers appear when enemies take damage
- [ ] Numbers float upward and fade out
- [ ] Numbers are readable in portrait mode
- [ ] Performance: Object pooling or lightweight spawning
- [ ] Crit damage shows different color (yellow)
- [ ] Tests pass
