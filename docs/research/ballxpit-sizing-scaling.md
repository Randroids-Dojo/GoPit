# BallxPit First Level Sizing/Scaling Research

## Research Goal
Understand exact sizing proportions in BallxPit's first 5 minutes to replicate the feel in GoPit's Experiment Mode.

## BallxPit Reference (From Gameplay Analysis)

### Screen/Game Area
- **Aspect Ratio**: 9:16 portrait (mobile-first)
- **Typical Resolution**: 1080x1920 or 720x1280
- **Game Area**: Full screen minus minimal HUD at top

### Visual Proportions (Estimated from gameplay)
Based on analysis of gameplay videos and screenshots:

| Element | Approximate Size | % of Screen Width |
|---------|------------------|-------------------|
| Ball | ~2.5-3% of width | ~18-22px at 720w |
| Player paddle | ~10-12% of width | ~72-86px at 720w |
| Basic enemy (skeleton) | ~5-7% of width | ~36-50px at 720w |
| Tank enemy | ~8-10% of width | ~58-72px at 720w |
| Spawn rows | 3-4 rows visible | Top third of screen |

### Key Sizing Observations
1. **Balls are SMALL** - Much smaller than player, feels like projectiles not paddles
2. **Player is visible but not dominant** - About 1/10 of screen width
3. **Enemies fill top third** - Creates visual pressure from above
4. **Spacing between enemies** - Roughly 1.5-2x enemy width apart

## GoPit Current Values

### From Codebase Analysis

| Element | Current Value | At 720px Width |
|---------|---------------|----------------|
| Ball radius | 14.0px | 3.9% of width |
| Player radius | 35.0px | 9.7% of width |
| Slime radius | 20.0px | 5.6% of width |
| Swarm radius | 10.0px | 2.8% of width |
| Gem radius | 14.0px | 3.9% of width |

### Screen Layout (720x1280)

```
┌─────────────────────┐ 0
│      HUD (90px)     │
├─────────────────────┤ 90
│                     │
│    SPAWN AREA       │
│    (0-400px)        │
│                     │
├─────────────────────┤ 400
│                     │
│    PLAY AREA        │
│    (400-1000px)     │
│                     │
├─────────────────────┤ 1000
│    DANGER ZONE      │
├─────────────────────┤ 1110
│    CONTROLS/HUD     │
└─────────────────────┘ 1280
```

### Position Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| Player Y | 900 | Player vertical position |
| Player Zone Y | 1200 | Attack collision zone |
| Danger Zone Y | 1000 | Enemy attack trigger |
| Attack Range Y | 950 | Warning starts |
| Return Y | 1150 | Ball starts returning |

## Gap Analysis

### Current Issues (Why it feels "too chaotic")

1. **Ball may be too large** - 14px radius (28px diameter) is ~4% of width
   - BallxPit balls appear smaller (~2.5-3%)
   - Recommendation: Try 10-12px radius

2. **Player may be correctly sized** - 35px radius (~10%) matches BallxPit

3. **Enemies may be spawning too fast/dense**
   - Need to compare spawn rates
   - Formation spacing may be too tight

4. **Too many balls on screen**
   - Baby balls + main balls + clones = visual chaos
   - BallxPit's first level is relatively simple

5. **Speed feels different**
   - Ball speed 800px/s - need to verify against BallxPit

## Recommendations for Experiment Mode

### Sizing Adjustments to Test

| Element | Current | Try 1 | Try 2 |
|---------|---------|-------|-------|
| Ball radius | 14 | 10 | 12 |
| Player radius | 35 | 35 | 40 |
| Enemy base radius | 20 | 20 | 25 |
| Formation spacing | 40px | 60px | 80px |

### First-Level Simplicity

To match BallxPit's first 5 minutes:
- **1 ball type only** (no evolutions yet)
- **1-2 enemy types** (skeleton/slime only)
- **Simple formations** (LINE, SINGLE - no complex patterns)
- **Slow spawn rate** (3-4 seconds between spawns)
- **No baby balls** (or minimal)

### Experiment Mode Settings

```gdscript
var exp_settings := {
    # Sizing (test these values)
    "ball_radius": 12,
    "player_radius": 35,
    "enemy_base_radius": 22,

    # Simplified first-level feel
    "spawn_interval": 3.5,  # Slow
    "formation_chance": 0.3,  # Mostly singles
    "enemies_per_wave": 5,
    "max_enemy_types": 1,  # Slime only

    # Ball limitations
    "max_balls_on_screen": 3,
    "baby_balls_enabled": false,
}
```

## Sources

- [Ball x Pit Wikipedia](https://en.wikipedia.org/wiki/Ball_x_Pit)
- [Ball x Pit Steam Page](https://store.steampowered.com/app/2062430/BALL_x_PIT/)
- [Ball x Pit Beginner Guide (TheGamer)](https://www.thegamer.com/ball-x-pit-complete-guide/)
- GoPit Codebase Analysis (scripts/entities/*.gd)
- GoPit GDD.md

## Next Steps

1. Implement sizing controls in Experiment Mode debug panel
2. Create side-by-side comparison with BallxPit gameplay video
3. Tune values until "feel" matches
4. Document final values for main game update
