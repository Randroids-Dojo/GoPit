# Level Scrolling Comparison: BallxPit vs GoPit

Research conducted: January 2026

## Executive Summary

BallxPit creates a feeling of "descending into the pit" through **continuous upward world scrolling**, **parallax backgrounds**, and **full-arena player movement**. GoPit currently uses a **static viewport** with enemies descending and gems drifting - a "relative scrolling" approach that lacks visual depth and constrains player movement.

## Key Differences

### 1. World Scrolling

| Aspect | BallxPit | GoPit |
|--------|----------|-------|
| Screen scrolling | Continuous upward ~50-100 px/sec | None (static) |
| Scroll speed scaling | Increases with difficulty tier | N/A |
| In-game speed toggle | 1/2/3 keyboard during gameplay | Not implemented |

**BallxPit**: The screen continuously scrolls upward, creating the sensation of falling deeper into the pit. This is the core visual mechanic.

**GoPit**: No world scrolling. Background is a single static `ColorRect`. The "scrolling feel" comes only from enemies descending and gems drifting up.

### 2. Player Movement Area

| Aspect | BallxPit | GoPit |
|--------|----------|-------|
| Vertical freedom | Entire screen (full arena) | Bottom 60% only (Y: 280-1080) |
| Movement feel | "Freely move up, down, across" | Confined to player zone |
| Strategic depth | Can chase gems, position anywhere | Limited positioning options |

**BallxPit**: Players can move across the **entire vertical field**. This allows chasing gems before they scroll off, positioning tactically, and feeling like part of the scrolling world.

**GoPit**: Player constrained to `bounds_min.y = 280` to `bounds_max.y = 1080` (out of 1280 total). This feels restrictive and disconnected from the action above.

### 3. Background Parallax

| Aspect | BallxPit | GoPit |
|--------|----------|-------|
| Background layers | Multiple parallax layers | Single static color |
| Visual depth | Creates 3D descent feeling | Flat, no depth |
| Biome theming | Rich themed backgrounds | Color change only |

**BallxPit**: Multiple parallax layers scroll at different speeds, creating visual depth and reinforcing the "falling" sensation.

**GoPit**: Background is a `ColorRect` at `/root/Game/Background` that changes color per biome but never moves.

### 4. Enemy Formation Cohesion

| Aspect | BallxPit | GoPit |
|--------|----------|-------|
| Formation movement | Cohesive unit descent | Independent descent |
| Scroll integration | Enemies move WITH scroll | Enemies move independently |
| Visual pattern | Clear organized waves | Somewhat scattered |

**BallxPit**: Enemy formations descend as cohesive units, maintaining relative positions. Combined with scroll, they feel like approaching threats.

**GoPit**: Formations spawn at same Y but descend independently at base speed. No scroll integration.

### 5. Speed/Difficulty Relationship

| Aspect | BallxPit | GoPit |
|--------|----------|-------|
| Scroll speed per tier | Increases significantly | N/A (no scroll) |
| Run duration | 15min (Normal) → 5min (Fast+9) | Fixed timing |
| Enemy speed per tier | Slight increase | Not applied yet |
| Spawn rate per tier | +50% per tier | Constants defined but not applied |

**BallxPit**: Higher difficulty tiers = faster scroll = shorter runs = more pressure. The scroll speed IS the difficulty.

**GoPit**: Difficulty multipliers exist in `GameManager` but are not fully applied to enemy/spawner systems.

## Current GoPit Implementation Details

### Player Movement (`scripts/entities/player.gd`)
```gdscript
var bounds_min: Vector2 = Vector2(30, 280)   # Top of player zone
var bounds_max: Vector2 = Vector2(690, 1080) # Bottom of player zone
var move_speed: float = 300.0
```

### Enemy Descent (`scripts/entities/enemies/enemy_base.gd`)
```gdscript
speed: float = 60.0  # px/sec (reduced from 100 for BallxPit pacing)
# Wave scaling: 5% per wave, capped at 2x
```

### Gem Drift (`scripts/entities/gem.gd`)
```gdscript
GemMovementMode.DRIFT_UP  # Default mode - gems drift upward
base_speed: float = 150.0  # px/sec
```

### Background (`scripts/game/game_controller.gd`)
```gdscript
@onready var background: ColorRect = $Background  # Static, no scrolling
```

### Camera (`scripts/effects/camera_shake.gd`)
- Only provides screen shake via offset
- No position movement or scrolling functionality

## Recommendations

### High Priority (Core Feel)

1. **Add Background Parallax Scrolling**
   - Create 2-3 parallax layers per biome
   - Continuous upward scroll at varying speeds
   - Creates visual depth and "falling" sensation

2. **Implement World Scroll Speed System**
   - Base scroll: ~50 px/sec
   - Scale with difficulty tier
   - Affects enemy effective descent rate

3. **Expand Player Movement Area**
   - Allow movement to Y: 100-1080 (from 280-1080)
   - Players can chase gems, position tactically
   - Feels more like BallxPit's free movement

4. **Add In-Game Speed Toggle**
   - Keys 1/2/3 or button to adjust game speed
   - Speed 1: 0.5x (slow-mo for bosses)
   - Speed 2: 1.0x (normal)
   - Speed 3: 2.0x (fast-forward for farming)

### Medium Priority (Polish)

5. **Apply Difficulty Multipliers**
   - Wire `get_difficulty_spawn_rate_multiplier()` to spawner
   - Wire `get_difficulty_enemy_hp_multiplier()` to enemies
   - Makes difficulty selection meaningful

6. **Formation Cohesion Movement**
   - Formation enemies maintain relative positions during descent
   - Move as a unit rather than individuals

7. **Scroll-Integrated Gem Despawn**
   - Gems scroll with world (not just drift independently)
   - Creates authentic "collect before it scrolls away" pressure

### Lower Priority (Enhancement)

8. **Per-Character Completion Display** (Stage Select UI)
   - Show which characters beat each stage/difficulty

9. **Smooth Stage Transition Animations** (Stage Select UI)
   - Tween effects when scrolling between stages

10. **Difficulty Completion Badges** (Stage Select UI)
    - Visual indicators of completion status on difficulty buttons

## Implementation Approach

### Phase 1: Visual Scrolling Foundation
1. Create `ParallaxBackground` with 2-3 layers per biome
2. Add scroll speed to `GameManager` (configurable per difficulty)
3. Update background system to scroll layers

### Phase 2: Player Freedom
1. Expand `bounds_min.y` from 280 to 100
2. Ensure gems are reachable in upper area
3. Adjust enemy spawn positions if needed

### Phase 3: Speed System
1. Add in-game speed toggle (Engine.time_scale)
2. Create HUD indicator for current speed
3. Add keybindings (1/2/3 or UI button)

### Phase 4: Difficulty Integration
1. Apply spawn rate multiplier to EnemySpawner
2. Apply HP/damage multipliers to enemies on spawn
3. Scale scroll speed with difficulty tier

## File Locations

| Component | File |
|-----------|------|
| Player bounds | `scripts/entities/player.gd:24-25` |
| Enemy speed | `scripts/entities/enemies/enemy_base.gd:57` |
| Gem movement | `scripts/entities/gem.gd:117-128` |
| Background | `scripts/game/game_controller.gd:24` |
| Camera shake | `scripts/effects/camera_shake.gd` |
| Difficulty constants | `scripts/autoload/game_manager.gd:50-67` |
| Enemy spawner | `scripts/entities/enemies/enemy_spawner.gd` |

## Sources

- BallxPit gameplay analysis
- [Steam Community discussions](https://steamcommunity.com/app/2062430/)
- [Ball x Pit guides](https://ballxpit.org/guides/)
- GoPit codebase analysis
