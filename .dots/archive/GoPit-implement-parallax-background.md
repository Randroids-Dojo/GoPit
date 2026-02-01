---
title: Implement parallax background scrolling
status: closed
priority: 1
issue-type: implement
created-at: "\"2026-01-27\""
closed-at: "2026-02-01T04:49:16.180831+00:00"
---

## Overview

Add parallax background scrolling to create the "descending into the pit" visual effect that BallxPit uses. Currently GoPit has a static `ColorRect` background.

## Context

BallxPit creates depth through multiple parallax layers scrolling at different speeds. This is the primary visual mechanic for the "falling" sensation. GoPit lacks any visual scrolling.

See: `docs/research/level-scrolling-comparison.md`

## Requirements

### 1. Parallax Layer System

Create a `ParallaxBackground` node with 2-3 layers:

```
ParallaxBackground
├─ ParallaxLayer1 (far - slow scroll, subtle pattern)
├─ ParallaxLayer2 (mid - medium scroll, biome features)
└─ ParallaxLayer3 (near - fast scroll, atmospheric particles)
```

**Layer properties:**
- Far layer: 0.3x scroll speed, dark subtle texture
- Mid layer: 0.6x scroll speed, biome-specific details
- Near layer: 1.0x scroll speed, particles/dust

### 2. Continuous Upward Scroll

Add to `GameManager`:
```gdscript
const BASE_SCROLL_SPEED: float = 50.0  # px/sec

func get_scroll_speed() -> float:
    # Scale with difficulty
    return BASE_SCROLL_SPEED * get_difficulty_scroll_multiplier()

func get_difficulty_scroll_multiplier() -> float:
    if selected_difficulty_level <= 1:
        return 1.0
    return 1.0 + (0.15 * (selected_difficulty_level - 1))
```

### 3. Biome-Specific Backgrounds

Each of 8 biomes needs unique parallax assets:

| Biome | Far Layer | Mid Layer | Near Layer |
|-------|-----------|-----------|------------|
| The Pit | Dark rock | Stone walls | Dust |
| Frozen Depths | Ice crystals | Snow drifts | Snowflakes |
| Burning Sands | Heat haze | Dunes | Sand particles |
| Void Chasm | Stars | Void tendrils | Energy wisps |
| Toxic Marsh | Murky water | Dead trees | Bubbles |
| Storm Spire | Clouds | Lightning | Rain |
| Crystal Caverns | Gem clusters | Crystal pillars | Sparkles |
| The Abyss | Void | Ancient ruins | Shadow wisps |

### 4. Integration with Game Loop

In `game_controller.gd`:
```gdscript
func _process(delta: float) -> void:
    if GameManager.current_state == GameManager.GameState.PLAYING:
        _update_parallax_scroll(delta)

func _update_parallax_scroll(delta: float) -> void:
    var scroll_speed := GameManager.get_scroll_speed()
    parallax_background.scroll_offset.y -= scroll_speed * delta
```

## Implementation Steps

1. Create `scenes/effects/parallax_background.tscn` scene
2. Create `scripts/effects/parallax_background.gd` controller
3. Add placeholder textures (colored rectangles with patterns)
4. Wire into `game_controller.gd`
5. Add scroll speed to `GameManager`
6. Create biome-specific assets (can start with procedural)

## Files to Create/Modify

- **Create:** `scenes/effects/parallax_background.tscn`
- **Create:** `scripts/effects/parallax_background.gd`
- **Modify:** `scripts/game/game_controller.gd` - add parallax reference
- **Modify:** `scripts/autoload/game_manager.gd` - add scroll speed
- **Modify:** `scenes/game.tscn` - replace static Background

## Testing

- Visual verification that background scrolls continuously
- Verify scroll speed increases with difficulty
- Verify biome changes update parallax layers
- Performance test with parallax (mobile)

## Acceptance Criteria

- [ ] Background visually scrolls upward during gameplay
- [ ] Multiple parallax layers create depth effect
- [ ] Scroll speed scales with difficulty tier
- [ ] Each biome has distinct background appearance
- [ ] No performance regression on mobile
