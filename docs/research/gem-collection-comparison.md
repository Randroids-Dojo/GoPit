# Gem Collection Comparison: BallxPit vs GoPit

## Research Summary

This document compares gem collection mechanics between BallxPit (the reference game) and GoPit to identify why gems might feel harder to collect in BallxPit.

---

## Fundamental Design Difference

| Aspect | BallxPit | GoPit |
|--------|----------|-------|
| **World structure** | Scrolling level (upward) | Static arena |
| **Player position** | Bottom of screen | Bottom of screen |
| **Enemy behavior** | Descend toward player | Descend toward player |
| **Camera behavior** | Auto-scrolls upward at set pace | Fixed viewport |
| **Gem behavior** | Stay where dropped, NO auto-collect | Fall toward player |

**Key similarity:** Both games have player at bottom with enemies descending.
**Key difference:** BallxPit scrolls through a level; GoPit has fixed arena with spawning waves.

---

## BallxPit Gem Collection Mechanics

### Scrolling World Model (Confirmed)
- Screen continuously scrolls upward through the "pit"
- Stages scroll at a **set pace** (auto-scroll, not player-controlled)
- Player stays at bottom, enemies descend from above
- When enemies die, gems drop at that position
- **"XP crystals don't auto-collect, so you need to actively pick them up"**

### Natural Collection Pressure
The scrolling creates organic urgency:
- Gems likely scroll off-screen if not collected (needs verification)
- Player must actively navigate to collect
- Trade-off: chase gems vs. stay safe vs. keep progressing

### Unverified Details (Needs Gameplay Testing)
- Do gems scroll with the world or stay screen-relative?
- Is there also a despawn timer?
- What is the base pickup radius without Magnet?
- How fast does the screen scroll?

### Default Behavior
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
| **World model** | Scrolling level | Static arena |
| **Gem behavior** | Stationary (scroll off-screen) | Fall toward player |
| **Collection pressure** | Viewport movement | 10s despawn timer |
| **Default pickup** | Must walk over gems | 40px collection radius |
| **Magnetism start** | None (requires passive) | None (0px range) |
| **Magnet upgrade** | +1 tile per level | +200px per level |
| **Boss auto-collect** | Screen-wide | 2000px range |

---

## Why BallxPit Feels Harder

### 1. No Auto-Collection
**Confirmed:** "XP crystals don't auto-collect, so you need to actively pick them up."
- Gems don't fall toward player
- Gems don't have attraction behavior by default
- Player must physically move to each gem

### 2. Scrolling Creates Pressure (Likely)
The screen auto-scrolls upward at a set pace:
- Gems (probably) scroll off the bottom if not collected
- Creates time pressure without explicit despawn timer
- Player must balance collecting vs. staying safe

### 3. Movement Trade-offs
Moving up to collect gems means:
- Moving toward incoming enemies
- Less reaction time for new threats
- Potentially getting hit while collecting
- Missing shot opportunities

### 4. No Distance-Based Attraction
BallxPit's Magnet passive is a simple **radius increase** (+1 tile per level):
- Gems still don't fly toward you
- Must still move into range to collect
- Just expands the "touch to collect" radius

### 5. GoPit's Passive Collection (Much Easier)
In contrast, GoPit gems:
- **Fall toward the player** at 150px/sec
- Get **attracted** at up to 400px/sec with magnetism
- Have a generous **40px pickup radius**
- Come to you rather than you going to them

---

## Potential GoPit Adjustments

GoPit uses a static arena model, so we can't directly replicate scrolling. But we can create similar collection pressure:

### Option A: Stationary Gems (No Falling)
- Gems spawn where enemies die and stay fixed
- Player must move up into the arena to collect
- Creates risk/reward: venture into danger for XP
- **Most faithful to BallxPit feel**

### Option B: Faster Despawn
- Reduce `despawn_time` from 10s to 3-5s
- Creates urgency similar to scrolling pressure
- Visual warning (blinking) before despawn

### Option C: Reduce Passive Collection
- Decrease `COLLECTION_RADIUS` from 40px to 20-25px
- Disable gem falling (or make it very slow)
- Player must be more intentional about collection

### Option D: Weaker Magnetism
- Reduce `MAGNETISM_SPEED` from 400 to 150-200px/sec
- Reduce per-upgrade bonus from +200px to +100px
- Magnetism helps but doesn't trivialize collection

### Option E: Upward Gem Drift
- Instead of falling, gems slowly drift upward (opposite of player)
- Simulates "scrolling away" in a static arena
- Creates natural pressure to collect before they leave

### Option F: Collection Zones
- Gems only collectible in upper portion of arena
- Player must venture into enemy territory
- Mirrors BallxPit's "backtrack to collect" dynamic

---

## Recommendations

**To match BallxPit's feel:**

1. **Stationary gems** (Option A) + **shorter despawn** (Option B) - gems don't come to you, and you have limited time
2. **Upward drift** (Option E) - elegant simulation of scrolling in a static arena
3. **Smaller collection radius** (Option C) - simple tuning change

**Key insight:** BallxPit's difficulty comes from the scrolling world model, not just gem physics. In a static arena, we need artificial pressure to replicate that tension.

---

## Design Considerations

### What Makes BallxPit Collection Feel Good
- Clear visual feedback when gems drop
- Auto-collect during boss fights (QoL when it matters)
- Magnet passive is meaningful because default is hard
- Risk/reward for backtracking

### What GoPit Should Preserve
- Boss fight auto-magnet (already implemented)
- Magnetism passive as a real upgrade choice
- Visual clarity on gem positions

### What GoPit Could Change
- Gem movement direction (up instead of down, or stationary)
- Despawn timing and visual warnings
- Collection radius tuning

---

*Last updated: 2026-01-25*
