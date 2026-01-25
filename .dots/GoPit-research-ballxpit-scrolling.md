---
title: Research BallxPit scrolling and gem mechanics
status: closed
priority: 1
issue-type: research
created-at: "2026-01-25"
closed-at: "2026-01-25"
---

## Research Questions

Clarify exactly how BallxPit's core mechanics work to ensure accurate comparison with GoPit.

### Confirmed (from web research)

1. **Screen scrolls upward** - "the screen continuously scrolls upward"
2. **Stages scroll at set pace** - auto-scrolling, not player-controlled
3. **Player at bottom of screen** - "little dude at the bottom of your screen"
4. **Enemies descend** - "waves of enemies coming down towards you"
5. **Gems don't auto-collect** - "XP crystals don't auto-collect, so you need to actively pick them up"
6. **Every enemy drops a gem** - "every enemy leaves a gem which gives you experience"
7. **Enemies attack at bottom** - "When enemies reach the bottom, they launch an attack and then die"

### Verified (January 2026 Research)

- [x] **Q1: Do gems scroll with the world or stay screen-relative?**
  - **Likely world-relative** - gems scroll off-screen if not collected
  - Steam discussions confirm higher speeds make drops "harder to collect"
  - Players report "move speed too great at higher levels" affecting drop collection

- [x] **Q2: Is there a gem despawn timer?**
  - **No evidence of despawn timer** - pressure comes entirely from scrolling
  - Gems scroll off the bottom of the screen if not collected
  - No mentions of blinking/fading before disappearing

- [x] **Q3: How fast does the screen scroll?**
  - Base run: **15 minutes**
  - Fast difficulty: **12 minutes**
  - Fast+: **10 minutes**
  - Up to **Fast+9**: ~5 minutes (maximum difficulty)
  - **In-game speed toggle**: 3 speed settings player can adjust during run
  - Yes, scroll speed increases significantly with Fast+N difficulties

- [x] **Q4: What is the base gem pickup radius?**
  - **Tile-based system** - player must be touching or adjacent to gem
  - Base pickup radius: effectively **0-1 tiles** (requires physical contact)
  - Magnet passive: **+1 tile per level** (up to +3 tiles at L3)
  - Special characters (Shieldbearer, Tactician): hidden **screen-wide magnet**
  - Boss fights: **auto-magnet enabled** for all characters

- [x] **Q5: Player vertical movement range?**
  - Player **can move freely about entire vertical field**
  - "Your character can freely move up, down, and across most of the lane"
  - **Grid-based movement** system
  - No confinement to lower portion - full vertical freedom

### Additional Findings

**Hidden Mechanics:**
- Shieldbearer and Tactician characters have undocumented screen-wide magnet effects
- Boss fights enable auto-collection for all characters (hidden passive)
- Baby balls from Slingshot passive (25% chance when picking up gems)

**Speed Scaling Trade-offs:**
- Higher speeds make precise movement harder
- "Even the slightest adjustments become over corrections" at high speeds
- Collection difficulty increases with speed scaling

### Sources

- [Steam Store](https://store.steampowered.com/app/2062430/BALL_x_PIT/)
- [TheGamer Complete Guide](https://www.thegamer.com/ball-x-pit-complete-guide/)
- [GAM3S.GG Beginner Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-ultimate-beginners-guide/)
- [GameRant Passives List](https://gamerant.com/ball-x-pit-all-passives-list/)
- [Steam Community - Speed Scaling Discussion](https://steamcommunity.com/app/2062430/discussions/0/624436409752945056/)
- [Steam Community - Fast Levels Discussion](https://steamcommunity.com/app/2062430/discussions/0/595163560549933673/)
- [Steam Community - Magnet Mechanics](https://steamcommunity.com/app/2062430/discussions/0/595163560549659306/)

## Resolution

All research questions have been answered through web research and Steam community discussions. Findings have been documented in `docs/research/gem-collection-comparison.md`.
