# GoPit - Game Design Document

> **Version**: 0.1.0 (MVP)
> **Last Updated**: January 2026
> **Platform**: Mobile (iOS/Android), Web
> **Engine**: Godot 4.x (automation branch)

---

## 1. Game Overview

### Concept
**GoPit** is a mobile-first endless survival roguelike where players fire balls upward into a pit of descending enemies. Defeat enemies to collect gems, level up, and evolve your ball arsenal.

### Tagline
*"Bounce. Evolve. Survive the Pit."*

### Genre
- Roguelike / Roguelite
- Action / Arcade
- Ball Physics

### Inspiration
Inspired by [Ball x Pit](https://www.ballxpit.com/) by Kenny Sun, combining Arkanoid-style ball mechanics with Vampire Survivors-style progression.

### Core Loop
```
Fire Balls → Defeat Enemies → Collect Gems → Level Up → Choose Upgrades → Repeat
                                    ↓
                            Enemies Reach Bottom
                                    ↓
                            Take Damage → Game Over
```

---

## 2. Core Mechanics

### 2.1 Ball Physics
- Balls bounce off walls and enemies
- Trajectory determined by virtual joystick angle
- Multiple balls can be active simultaneously
- Each ball type has unique bounce/damage properties

### 2.2 Controls (Virtual Joystick)
| Input | Action |
|-------|--------|
| Left stick drag | Aim trajectory (shows preview line) |
| Fire button tap | Launch ball in aimed direction |
| Fire button hold | Rapid fire (if unlocked) |

### 2.3 Enemy Behavior
- Spawn above the viewport
- Descend at varying speeds based on type/wave
- Each enemy has a health pool
- When reaching bottom:
  1. **Vibrate** for ~1 second (warning)
  2. **Fling** at player position (deal damage)
  3. Despawn after attack

### 2.4 Health System
- Player starts with **100 HP**
- Damage scales with enemy type
- No natural regeneration (heal via power-ups only)
- **Game Over** when HP reaches 0

### 2.5 Gem & XP System
- Enemies drop **gems** on death
- Gems are auto-collected (magnetic pull)
- Gems fill the **XP bar**
- Full XP bar triggers **Level Up**

---

## 3. Ball System

### 3.1 Starter Balls (MVP)

| Ball | Damage | Speed | Special |
|------|--------|-------|---------|
| **Basic Ball** | 10 | Normal | None |
| **Heavy Ball** | 20 | Slow | Knockback |
| **Swift Ball** | 5 | Fast | Pierces 1 enemy |
| **Splitter Ball** | 8 | Normal | Splits into 2 on wall hit |

### 3.2 Upgrade Tiers
Each ball can be upgraded through 3 levels:

| Level | Effect |
|-------|--------|
| **Level 1** | Base stats |
| **Level 2** | +50% damage, slight visual change |
| **Level 3** | +100% damage, can be fused |

### 3.3 Ball Fusion
When you have two **Level 3** balls of compatible types and find a **Fusion Reactor** drop:
- Combine them into an **Evolved Ball**
- Evolved balls have combined properties + bonus effect

**Example Fusions:**
| Ball A | Ball B | Result |
|--------|--------|--------|
| Heavy L3 | Swift L3 | **Meteor Ball** - Fast + High damage + Burn DoT |
| Splitter L3 | Basic L3 | **Chain Ball** - Splits and each piece bounces more |

### 3.4 Evolution Paths (Future)
```
Basic Ball
    ├─→ Fire Ball (+ burn damage)
    └─→ Ice Ball (+ slow effect)
         └─→ [Fusion with Fire] → Void Ball
```

---

## 4. Progression System

### 4.1 Per-Run Progression
On **Level Up**, player chooses 1 of 3 options:
- **New Ball** - Add a new ball type to your loadout
- **Upgrade Ball** - Level up an existing ball
- **Passive Item** - Gain a passive bonus

**Passive Items (MVP Examples):**
| Item | Effect |
|------|--------|
| Magnet | Increased gem pickup range |
| Bounce+ | Balls bounce one extra time |
| Damage Up | +10% all ball damage |
| Fire Rate | -15% fire cooldown |

### 4.2 Meta Progression (MVP - Ball Upgrades Only)
After each run, earn **Pit Coins** based on:
- Enemies defeated
- Time survived
- Level reached

Spend Pit Coins on:
- **Unlock new starter balls**
- **Permanent stat bonuses** (+5% base HP, etc.)
- **New passive items** in the level-up pool

---

## 5. Enemy Types (MVP)

| Enemy | HP | Speed | Damage | Behavior |
|-------|-----|-------|--------|----------|
| **Slime** | 20 | Slow | 5 | Basic, moves straight down |
| **Bat** | 15 | Fast | 10 | Zigzag movement |
| **Golem** | 50 | Very Slow | 20 | Tank, takes hits |
| **Swarm** | 5 | Normal | 3 | Spawns in groups of 5 |

### Wave Scaling
| Wave | Enemy Count | Speed Modifier | HP Modifier |
|------|-------------|----------------|-------------|
| 1-5 | 3-5 | 1.0x | 1.0x |
| 6-10 | 5-8 | 1.2x | 1.3x |
| 11-20 | 8-12 | 1.4x | 1.6x |
| 21+ | 12+ | 1.5x | 2.0x+ |

---

## 6. Technical Specifications

### 6.1 Engine & Tools
| Component | Technology |
|-----------|------------|
| Engine | Godot 4.x (automation branch) |
| Unit Tests | GdUnit4 |
| E2E Tests | PlayGodot (Python) |
| Skills | Godot-Claude-Skills |

### 6.2 Display
- **Orientation**: Portrait (mobile-first)
- **Base Resolution**: 720 x 1280
- **Aspect Ratios**: Support 16:9 to 19.5:9
- **Target FPS**: 60fps on mid-range devices

### 6.3 Rendering
- Use `gl_compatibility` for broad mobile support
- Minimize draw calls with batching
- Simple particle effects (not GPU particles)

### 6.4 Input
- Touch input with virtual joystick
- Keyboard/mouse fallback for desktop/web
- Gamepad support (future)

---

## 7. Art Direction

### 7.1 Style: Minimalist Geometric
- Clean shapes (circles, rectangles, hexagons)
- Bold outlines
- Limited color palette per enemy type
- High contrast for mobile visibility

### 7.2 Color Palette
| Element | Color |
|---------|-------|
| Background | Dark blue/purple (#1a1a2e) |
| Player Zone | Warm accent (#e94560) |
| Balls | Bright, distinct per type |
| Enemies | Contrasting to background |
| UI | White/light with dark outlines |

### 7.3 Visual Feedback
- Screen shake on damage taken
- Ball trail effects
- Enemy hit flash
- Gem sparkle and magnetism lines
- Level-up fanfare overlay

---

## 8. UI/UX

### 8.1 HUD Layout (Portrait)
```
┌─────────────────────┐
│ Wave: 5    HP: ████ │  <- Top bar
│                     │
│                     │
│    [GAME AREA]      │  <- Pit / enemies
│                     │
│                     │
│  ┌───────────────┐  │
│  │ XP: ████████░ │  │  <- XP bar
│  └───────────────┘  │
│                     │
│  (⊙)          [🔥]  │  <- Joystick + Fire
└─────────────────────┘
```

### 8.2 Level-Up Screen
- Pause gameplay
- Display 3 card-style options
- Tap to select
- Brief animation, resume

### 8.3 Game Over Screen
- Stats summary (time, kills, level)
- Pit Coins earned
- Retry / Main Menu buttons

---

## 9. Future Features (Post-MVP)

### 9.1 Base Building
- **New Ballbylon** - Village adjacent to the pit
- Build structures with resources
- Unlock characters, abilities, cosmetics
- Based on Ball x Pit's meta-game

### 9.2 Multiple Characters
- Each character has unique starting ball
- Special abilities (active/passive)
- Unlock via base building or achievements

### 9.3 Boss Battles
- Mini-bosses every 10 waves
- Final boss at wave 50 (optional win condition)
- Unique attack patterns per boss

### 9.4 Daily Challenges
- Pre-seeded runs
- Global leaderboards
- Bonus rewards

### 9.5 Additional Features
- Achievements system
- Ball collection / codex
- Endless mode variants (modifiers)
- Multiplayer co-op (stretch goal)

---

## 10. File Structure

```
GoPit/
├── GDD.md                      # This document
├── project.godot               # Godot project config
├── icon.svg                    # App icon
├── export_presets.cfg          # Mobile export settings
│
├── scenes/
│   ├── main_menu.tscn          # Main menu scene
│   ├── game.tscn               # Core gameplay scene
│   ├── game_over.tscn          # Game over screen
│   ├── level_up.tscn           # Level-up selection
│   └── ui/
│       ├── hud.tscn            # In-game HUD
│       └── virtual_joystick.tscn
│
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd     # Global game state
│   │   └── audio_manager.gd    # Sound management
│   ├── ball/
│   │   ├── ball.gd             # Base ball class
│   │   ├── ball_types.gd       # Ball type definitions
│   │   └── ball_spawner.gd     # Ball firing logic
│   ├── enemy/
│   │   ├── enemy.gd            # Base enemy class
│   │   ├── enemy_spawner.gd    # Wave spawning logic
│   │   └── enemy_types/        # Individual enemy scripts
│   ├── player/
│   │   └── player.gd           # Player health, position
│   ├── progression/
│   │   ├── xp_system.gd        # Gem/XP logic
│   │   ├── level_up.gd         # Level-up choices
│   │   └── meta_progression.gd # Pit coins, unlocks
│   └── ui/
│       ├── virtual_joystick.gd # Touch joystick input
│       └── hud.gd              # HUD updates
│
├── resources/
│   ├── balls/                  # Ball type resources
│   ├── enemies/                # Enemy type resources
│   └── themes/                 # UI themes
│
├── assets/
│   ├── sprites/                # Game sprites
│   ├── audio/                  # Sound effects, music
│   └── fonts/                  # UI fonts
│
├── tests/                      # GdUnit4 unit tests
│   ├── test_ball.gd
│   ├── test_enemy.gd
│   └── test_progression.gd
│
└── playgodot_tests/            # PlayGodot E2E tests
    ├── conftest.py
    ├── test_gameplay.py
    └── test_ui.py
```

---

## 11. Development Milestones

### Milestone 1: Core Loop
- [ ] Virtual joystick + fire button
- [ ] Ball physics (bounce, trajectory)
- [ ] Basic enemy spawning
- [ ] Collision detection
- [ ] Enemy reaches bottom → damage player

### Milestone 2: Progression
- [ ] Gem drops + collection
- [ ] XP bar + level up trigger
- [ ] Level-up UI with 3 choices
- [ ] Ball upgrades (Level 1-3)
- [ ] Game over screen

### Milestone 3: Content
- [ ] 4 starter ball types
- [ ] 4 enemy types
- [ ] Wave difficulty scaling
- [ ] 5+ passive items
- [ ] Ball fusion system

### Milestone 4: Polish
- [ ] Sound effects + music
- [ ] Visual juice (particles, shake)
- [ ] Mobile optimization
- [ ] PlayGodot test coverage

### Milestone 5: Release
- [ ] Meta progression (Pit Coins)
- [ ] Ball unlock system
- [ ] Export to iOS/Android/Web
- [ ] Beta testing

---

## Appendix A: References

- [Ball x Pit (Steam)](https://store.steampowered.com/app/2062430/BALL_x_PIT/)
- [Ball x Pit (Official Site)](https://www.ballxpit.com/)
- [Ball x Pit Review - MonsterVine](https://monstervine.com/2025/10/ball-x-pit-review/)
- [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/) - Progression inspiration

---

*This document will be updated as development progresses.*
