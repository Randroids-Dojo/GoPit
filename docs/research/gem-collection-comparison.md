# Gem Collection Comparison: BallxPit vs GoPit

## Research Summary

This document compares gem collection mechanics between BallxPit (the reference game) and GoPit to identify why gems might feel harder to collect in BallxPit.

---

## BallxPit Gem Collection Mechanics

### Default Behavior
- Gems drop from defeated enemies
- Player must physically move over gems to collect them
- **No built-in magnetism** by default - gems require manual pickup

### Magnet Passive
| Level | Effect |
|-------|--------|
| L1 | +1 tile pickup range |
| L2 | +1 tile (total +2) |
| L3 | +1 tile (total +3) |

- The Magnet passive **increases pickup radius by 1 tile per level**
- This is a *tile-based* system, not pixel-based
- BallxPit tile size appears to be ~32-64px based on visual analysis

### Special Cases
- **Boss fights**: Auto-collect enabled (screen-wide magnet)
- **Shieldbearer character**: Hidden auto-collect passive
- **Tactician character**: Hidden auto-collect passive
- **Full board clear**: Triggers auto-collect

### Related Passives
- **Slingshot**: 25% chance to launch baby ball when picking up a gem
- **Gemspring**: Spawns every 7-11 rows, drops XP gems when damaged

### Sources
- [BallxPit Passives Wiki](https://ballpit.fandom.com/wiki/Passives)
- [Steam Community Discussions](https://steamcommunity.com/app/2062430/discussions/0/624436764983013226/)
- [BallxPit Guide - Items](https://www.ballxpitguide.com/items)

---

## GoPit Current Implementation

### Constants (gem.gd)
| Parameter | Value | Description |
|-----------|-------|-------------|
| `COLLECTION_RADIUS` | 40px | Distance to auto-collect |
| `MAGNETISM_SPEED` | 400px/sec | Speed when attracted |
| `fall_speed` | 150px/sec | Default descent speed |
| `despawn_time` | 10 seconds | Lifetime before despawn |
| `radius` | 14px | Visual gem size |

### Magnetism System (game_manager.gd)
| Parameter | Value | Description |
|-----------|-------|-------------|
| `gem_magnetism_range` | 0px (default) | Starts at zero |
| `BOSS_MAGNET_RANGE` | 2000px | Auto-magnet during bosses |
| Per upgrade | +200px | From MAGNETISM passive |

### How Collection Works
1. **Direct contact**: If player within 40px → instant collection
2. **Magnetism active**: If gem within `magnetism_range`:
   - Direction calculated toward player
   - Speed interpolated based on distance (`lerpf`)
   - Closer gems move faster (up to 400px/sec)
3. **No magnetism**: Gems fall at 150px/sec, must touch to collect

### Magnetism Speed Formula
```gdscript
var pull_strength := 1.0 - (distance_to_player / magnetism_range)
var current_speed := lerpf(fall_speed, MAGNETISM_SPEED, pull_strength)
```

---

## Key Differences

| Aspect | BallxPit | GoPit |
|--------|----------|-------|
| **Default pickup** | Must walk over gems | 40px collection radius |
| **Magnetism start** | None (requires passive) | None (0px range) |
| **Magnet upgrade** | +1 tile per level | +200px per level |
| **Gem movement** | Stationary? | Falls at 150px/sec |
| **Boss auto-collect** | Screen-wide | 2000px range |
| **Unit system** | Tile-based | Pixel-based |

---

## Why BallxPit Feels Harder

### 1. No Falling Gems
In BallxPit, gems likely **stay where enemies die** rather than falling. The player must actively navigate to collect them, creating a strategic choice between:
- Collecting gems (gaining XP, triggering passives like Slingshot)
- Avoiding enemy contact (survival)

### 2. Smaller Default Pickup Radius
BallxPit likely has a **smaller base pickup hitbox** without the Magnet passive. In GoPit, the 40px `COLLECTION_RADIUS` is quite generous (nearly 3x the gem's visual radius).

### 3. No Distance-Based Attraction
BallxPit's Magnet passive appears to be a simple **radius increase**, not an attraction force. You still must move into range - gems don't actively chase you.

### 4. Movement Trade-offs
In BallxPit, moving to collect gems means:
- Taking your eyes off enemy patterns
- Potentially entering danger zones
- Missing shot opportunities

GoPit's magnetism system may make this too automatic.

---

## Potential GoPit Adjustments

To match BallxPit's feel of "gems are harder to collect":

### Option A: Reduce Passive Collection
- Decrease `COLLECTION_RADIUS` from 40px to 20-25px
- Requires more precise positioning

### Option B: Remove Gem Falling
- Gems spawn where enemies die and stay stationary
- Player must actively collect them
- Adds strategic depth

### Option C: Weaker Magnetism
- Reduce `MAGNETISM_SPEED` from 400 to 200-250px/sec
- Reduce per-upgrade bonus from +200px to +100px
- Makes Magnetism upgrades feel more impactful

### Option D: Collection Delay
- Add a brief "spawn delay" before gems can be collected
- Prevents instant collection during combat

### Option E: True Tile-Based Magnetism
- Convert to tile-based system (if using grid)
- +1 tile = ~48px pickup radius increase
- More granular control

---

## Recommendations

1. **Stationary gems** (Option B) would be the biggest change toward BallxPit parity
2. **Smaller collection radius** (Option A) is the simplest fix
3. **Weaker magnetism** (Option C) makes the upgrade more meaningful

The current GoPit implementation prioritizes QoL (convenience) over strategic depth. BallxPit makes gem collection an active decision, not passive.

---

## Test Methodology

To validate these findings:
1. Play BallxPit without Magnet passive, observe gem behavior
2. Measure approximate pickup radius in BallxPit tiles
3. Compare player movement patterns for gem collection

---

*Last updated: 2026-01-25*
