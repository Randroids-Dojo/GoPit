# BallxPit Lazer Ball Mechanics Research

## Overview

In BallxPit, Lazer balls are fundamentally different from other ball types. **They are NOT projectiles.** Instead, they create **instant full-screen lines** that damage all enemies in their path.

## Key Mechanics

### Lazer Types

BallxPit has two distinct Lazer ball types:

1. **Laser Horizontal**: Creates a horizontal line across the entire screen
2. **Laser Vertical**: Creates a vertical line across the entire screen

### Firing Behavior

When the player "fires" a Lazer ball:

1. **No projectile is launched** - unlike other balls
2. **An instant line appears** on screen
3. The line spans the **entire game area** (edge to edge)
4. **Vertical Lazer**: Line runs through the **player's current X position** (top to bottom)
5. **Horizontal Lazer**: Line runs through the **player's current Y position** (left to right)
6. All enemies intersecting the line take damage simultaneously

### Damage Values

| Lazer Type | Damage Range |
|------------|--------------|
| Laser Horizontal | 9-18 damage |
| Laser Vertical | 9-18 damage |
| Holy Laser (evolution) | 24-36 damage |

### Visual Effects

- Brief flash/line effect across screen
- Intensity increases with ball level
- Holy Laser creates a cross pattern (both directions)

### Holy Laser Evolution

When Laser Horizontal and Laser Vertical are merged at L3:

- Creates **Holy Laser** - fires BOTH directions simultaneously
- Forms a **cross pattern** centered on player position
- Considered one of the strongest evolutions
- Can clear 50%+ of enemies with optimal positioning

### Strategic Considerations

- Positioning is critical - player must move to where enemies align in rows/columns
- Most effective in corridors and chokepoints
- Synergizes well with status effects (DoT applied to many enemies at once)

## Our Current Implementation (Incorrect)

Our current LASER ball type:

- Launches as a **projectile** (incorrect)
- Fires beam based on **ball's movement direction** (incorrect)
- Only extends **600px from hit point** (incorrect - should be full screen)
- Single type instead of separate H/V types

## Required Changes

### 1. Split into Two Ball Types

Replace single `LASER` type with:
- `LASER_H` - Horizontal Lazer
- `LASER_V` - Vertical Lazer

### 2. Change Firing Mechanism

Instead of spawning a ball projectile:
- Create instant visual line at player position
- Vertical: Full-height line at player.global_position.x
- Horizontal: Full-width line at player.global_position.y

### 3. Damage Application

- Find all enemies intersecting the line (not corridor detection)
- Apply damage to all intersecting enemies simultaneously
- No travel time - instant effect

### 4. Visual Effect

- Full-screen line flash
- Brief duration (0.15-0.2s)
- Glow effect that fades out
- Color: Bright red (matching current)

### 5. Holy Laser (Future)

When we implement evolutions:
- Merge L3 LASER_H + L3 LASER_V = Holy Laser
- Fires both directions simultaneously
- Cross pattern centered on player

## References

- BallxPit Wiki: Holy Laser Evolution
- BallxPit Wiki: Laser Beam Evolution
- GAM3S.GG: Ball x Pit All Special Balls Guide
- BallxPit Advanced Mechanics Guide
