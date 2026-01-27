---
title: Expand player movement area
status: open
priority: 1
issue-type: implement
created-at: "2026-01-27"
---

## Overview

Expand the player's vertical movement area to allow reaching higher parts of the screen. Currently confined to Y: 280-1080, should allow Y: 100-1080.

## Context

BallxPit allows players to "freely move up, down, and across most of the lane." GoPit restricts players to the bottom ~60% of the screen, limiting tactical options and gem collection.

See: `docs/research/level-scrolling-comparison.md`

## Current Implementation

In `scripts/entities/player.gd`:
```gdscript
var bounds_min: Vector2 = Vector2(30, 280)   # Top restricted to 280
var bounds_max: Vector2 = Vector2(690, 1080) # Bottom at 1080
```

Player vertical range: 800 pixels (280 to 1080)
Screen height: 1280 pixels
**Current coverage: 62.5%**

## Proposed Change

```gdscript
var bounds_min: Vector2 = Vector2(30, 100)   # Allow much higher movement
var bounds_max: Vector2 = Vector2(690, 1080) # Keep bottom the same
```

Player vertical range: 980 pixels (100 to 1080)
**New coverage: 76.5%**

## Benefits

1. **Gem chasing** - Players can move up to collect gems before they drift off-screen
2. **Tactical positioning** - Position to intercept enemy formations earlier
3. **Risk/reward** - Moving up puts player closer to incoming enemies
4. **BallxPit feel** - Matches the "full arena" movement freedom

## Considerations

### HUD/UI Overlap
- Top bar (HP, XP, wave info) ends around Y: 100-120
- New bounds should not overlap with HUD
- Y: 100 provides some buffer below top bar

### Enemy Spawn Position
- Enemies spawn at Y: -50 (above screen)
- Player at Y: 100 still has 150 pixels safety margin
- No collision risk with spawning enemies

### Gem Visibility
- Gems currently spawn at enemy death position
- With wider player range, gems above Y: 280 become reachable
- Magnetism range may need adjustment

### Balance Impact
- Players can intercept threats earlier (easier)
- Players may overextend and take more damage (harder)
- Overall neutral; adds skill expression

## Implementation Steps

1. Change `bounds_min.y` from 280 to 100 in `player.gd`
2. Verify no HUD overlap issues
3. Test enemy/player interactions in upper area
4. Adjust gem magnetism if needed
5. Update any hardcoded Y assumptions elsewhere

## Files to Modify

- `scripts/entities/player.gd` - bounds_min change

## Testing

```python
async def test_player_can_move_to_upper_area(game):
    # Move player up
    await game.set_property(PLAYER, "position", {"x": 360, "y": 150})
    await asyncio.sleep(0.1)

    pos = await game.get_property(PLAYER, "position")
    # Should be clamped to new minimum (100), not old (280)
    assert pos["y"] >= 100
    assert pos["y"] <= 150
```

## Acceptance Criteria

- [ ] Player can move up to Y: 100 (was 280)
- [ ] No visual overlap with HUD elements
- [ ] Gem collection works in upper area
- [ ] Enemy interactions work correctly in upper area
- [ ] Feels more like BallxPit's free movement
