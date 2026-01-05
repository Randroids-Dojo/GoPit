# GoPit Playtest Report

Generated: 2026-01-05

## Executive Summary

This report documents potential issues and proposed improvements discovered through comprehensive code analysis and PlayGodot automated testing of GoPit, a mobile-first arcade roguelike.

**Overall Assessment:** The core gameplay loop is functional but lacks polish and feedback. Players will find the mechanics work, but the experience feels incomplete due to missing feedback systems, limited variety, and no meta-progression.

---

## Test Coverage

- **Input Systems** - Joystick aiming, fire button cooldown, aim line visibility
- **Ball Physics** - Wall bouncing, enemy collisions, damage dealing, despawning
- **Enemy System** - Spawn timing, wave scaling, player zone damage
- **Gem & XP System** - Collection mechanics, level-up triggers, XP requirements
- **Level-Up System** - Overlay display, upgrade application, game pause/resume
- **Damage & Game Over** - HP tracking, death detection, restart flow
- **UI/HUD** - HP bar, wave counter, XP progress, level display
- **Audio** - Procedural sound effects (8 types)
- **Mobile UX** - Touch targets, orientation, controls

---

## CRITICAL Issues (1)

### [gameplay] Game lacks core progression hook

**Description:** No meta-progression system exists. Each run starts completely fresh with no permanent upgrades, unlocks, or currency. Players have no reason to replay after initial curiosity wears off.

**Reproduction:** Complete a run, restart - everything is reset, nothing was earned.

**Proposed Fix:**
- Add "Pit Coins" currency earned per run (based on score/waves)
- Permanent upgrade shop: starting HP, starting damage, unlock ball types
- Achievement system with rewards
- Daily challenges for bonus coins

**Impact:** This is the #1 retention killer. Without progression, the game has no stickiness.

---

## MAJOR Issues (11)

### [ux] No tutorial or onboarding

**Description:** New players have no guidance. The joystick and fire button controls must be discovered through experimentation. Game objectives are unclear.

**Reproduction:** Start game as a new player - no instructions appear.

**Proposed Fix:** First-time tutorial overlay:
1. "Drag to aim" with highlight on joystick
2. "Tap to fire" with highlight on fire button
3. "Hit enemies before they reach you!"
4. Dismiss after first successful hit

---

### [ux] No pause functionality

**Description:** Players cannot pause the game. On mobile, interruptions are constant (notifications, calls, switching apps). No pause means lost progress.

**Reproduction:** Try to pause during gameplay - impossible.

**Proposed Fix:**
- Pause button in top corner
- Auto-pause when app backgrounds
- Pause menu with: Resume, Settings, Quit

---

### [audio] No background music

**Description:** Game is silent except for sound effects. The procedural sounds work but the lack of music makes the game feel empty and less engaging.

**Reproduction:** Play the game - notice absence of music.

**Proposed Fix:** Add procedural or looping background music:
- Calm ambient for early waves
- Intensify tempo/layers as waves progress
- Dramatic shift at boss waves (if added)

---

### [ux] No audio settings or mute button

**Description:** Players cannot mute or adjust volume. Problematic when playing in public, at night, or when using other audio (calls, music).

**Reproduction:** Try to mute game sounds - impossible.

**Proposed Fix:** Settings menu with:
- Master volume slider
- Music volume slider
- SFX volume slider
- Quick mute toggle accessible from HUD

---

### [ux] Weak feedback on hit/damage

**Description:** When balls hit enemies, there's only a brief 0.1s red flash. When player takes damage, only the HP bar decreases. Neither feels impactful.

**Reproduction:** Fire at enemies, observe minimal feedback. Let enemy reach player zone, notice subtle HP decrease.

**Proposed Fix:**
- **Enemy hit:** Larger flash, hit particles, floating damage number, brief camera shake
- **Player damage:** Screen shake, red vignette flash, impactful sound, HP bar pulse/shake
- **Low HP warning:** Persistent red vignette, heartbeat sound when below 25%

---

### [ux] No wave transition announcement

**Description:** Wave counter silently increments. Players don't notice progression or feel accomplishment from clearing waves.

**Reproduction:** Kill 5 enemies, observe wave counter changes without fanfare.

**Proposed Fix:**
- "WAVE X" text appears center screen (fades in/out)
- Brief 0.5s slowmo during transition
- Wave completion sound effect
- Optional: Brief enemy spawn pause during announcement

---

### [ux] No warning when enemy approaches player zone

**Description:** Players are caught off-guard when enemies reach the bottom and deal damage. No early warning system exists.

**Reproduction:** Let an enemy descend - no warning until damage is dealt.

**Proposed Fix:**
- Warning indicator when enemy is within 200px of player zone
- Screen edge pulse/flash in enemy's column
- Audio danger cue (low frequency pulse)
- Consider: enemy sprites turn red when near player zone

---

### [gameplay] Limited upgrade variety

**Description:** Only 3 upgrade types exist (Damage +5, Fire Rate -0.1s, HP +25). All 3 are shown every level-up. No interesting choices or build diversity.

**Reproduction:** Level up multiple times - always same 3 options, just shuffled.

**Proposed Fix:** Expand to 8+ upgrade types, show random 3:
- **Power Up:** +5 ball damage
- **Quick Fire:** -0.1s cooldown
- **Vitality:** +25 max HP
- **Multi-Shot:** Fire 2 balls (spread)
- **Velocity:** +100 ball speed
- **Heavy Ball:** +50% damage, -20% speed
- **Piercing:** Ball goes through first enemy
- **Ricochet:** +1 bounce before despawn
- **Critical:** 10% chance for 2x damage
- **Magnetism:** Gems attracted to player

---

### [balance] Early game pacing too slow

**Description:** Initial 0.5s fire cooldown feels sluggish. Combined with 2s enemy spawn rate and slow gem fall, the opening minute is boring.

**Reproduction:** Play first 30 seconds - fire rate feels restrictive.

**Proposed Fix:**
- Start with 0.3s cooldown (upgrade to 0.2s min)
- OR implement "hold to rapid fire" mechanic from GDD
- Faster initial enemy spawn (1.5s)
- Consider starting with 2 balls available

---

### [ux] No feedback when fire blocked by cooldown

**Description:** Tapping fire button during cooldown is silently ignored. Players spam-tap without knowing their presses register.

**Reproduction:** Rapidly tap fire button during cooldown period.

**Proposed Fix:**
- Haptic feedback (vibration) on blocked tap
- Button shake/wobble animation
- Brief red tint on fire button
- Audio "click" that indicates blocked (different from fire sound)

---

### [ux] XP gain not clearly communicated

**Description:** When collecting gems, XP bar fills silently. No indication of amount gained or acknowledgment of collection.

**Reproduction:** Collect a gem - no floating text, no bar flash.

**Proposed Fix:**
- Floating "+10 XP" text at gem collection point
- XP bar pulse/flash on gain
- Satisfying collection sound (already exists, may need enhancement)
- Consider gem collection animation (sparkle trail to XP bar)

---

## MINOR Issues (10)

### [ux] Aim direction hidden after joystick release

**Description:** Aim line disappears when joystick is released. Players lose visual feedback of current aim direction.

**Reproduction:** Aim with joystick, release, observe aim line disappears.

**Proposed Fix:** Show faded/ghosted aim indicator after release showing last direction. Clear only when new direction is set.

---

### [gameplay] Gems have no magnetism

**Description:** Gems fall straight down at 150 units/sec. No attraction toward player zone. Players passively wait for collection.

**Reproduction:** Kill enemy at top of screen, watch gem fall slowly down.

**Proposed Fix:** Add attraction when gems are within 300px of player zone. Increases collection feel and reduces "missed gem" frustration.

---

### [gameplay] Enemy spawn pattern is predictable

**Description:** Enemies spawn at fixed intervals (2s initially). Creates mechanical, predictable rhythm.

**Reproduction:** Play 30 seconds, notice clockwork spawn timing.

**Proposed Fix:** Add ±0.5s randomness to spawn interval. Consider occasional "burst" spawns (2-3 enemies at once).

---

### [audio] Sounds may become repetitive

**Description:** Same procedural sounds play each time. With high fire rate, sounds repeat constantly.

**Reproduction:** Play for 5 minutes, notice sound repetition.

**Proposed Fix:** Add slight pitch variation (±5%) per play. Or generate 2-3 variants per sound type that randomly alternate.

---

### [ui] Game over stats are limited

**Description:** Game over shows only level and wave. Missing stats that add replay motivation.

**Reproduction:** Reach game over screen.

**Proposed Fix:** Display: enemies killed, balls fired, damage dealt, gems collected, time survived, highest combo.

---

### [ux] Joystick dead zone may feel unresponsive

**Description:** 10% dead zone (8px on 80px radius) might feel laggy.

**Reproduction:** Make tiny joystick movements.

**Proposed Fix:** Reduce to 5%, or add visual feedback when in dead zone.

---

### [physics] Potential ball clipping at extreme angles

**Description:** At 800 units/sec, balls might clip through walls on extreme angle shots due to frame timing.

**Reproduction:** Fire at extreme angles toward walls.

**Proposed Fix:** Use continuous collision detection or verify physics tick rate is sufficient.

---

### [performance] No limit on simultaneous balls

**Description:** With fire rate upgrades, many balls can exist simultaneously.

**Reproduction:** Upgrade fire rate, spam fire.

**Proposed Fix:** Limit max balls to 20-30, or implement object pooling.

---

### [ux] Touch targets may be too small

**Description:** Fire button/joystick might be hard to hit on small phones.

**Reproduction:** Play on 4-5" screen.

**Proposed Fix:** Ensure 48x48dp minimum, add touch tolerance area.

---

### [ui] HUD may be hard to read during gameplay

**Description:** HP/XP bars are small, might be missed during action.

**Reproduction:** Play intensely, try to track HP.

**Proposed Fix:** Screen tint as HP gets low. Consider larger HP display or HP number overlay.

---

## SUGGESTIONS (6)

### [gameplay] Add combo system

**Description:** No reward for rapid kills. Kill 5 enemies in 5 seconds = same as 5 enemies over 30 seconds.

**Proposed Fix:** Combo counter for kills within 2s window. XP multiplier: 1.5x at 5 combo, 2x at 10.

---

### [gameplay] Add more enemy types

**Description:** Only slimes exist. GDD mentions bat, crab, ghost.

**Proposed Fix:**
- **Bat:** Zigzag movement, faster
- **Crab:** Side-to-side movement, tankier
- **Ghost:** Phases through walls, immune to bounced balls

---

### [gameplay] Add ball types

**Description:** Only basic blue ball exists.

**Proposed Fix:**
- **Fire Ball:** Damage over time
- **Ice Ball:** Slows enemies
- **Multi Ball:** Splits on enemy hit
- **Heavy Ball:** More damage, slower

---

### [ux] Add high score tracking

**Description:** No persistence between sessions.

**Proposed Fix:** Save: high score, highest wave, highest level, longest survival, total enemies killed.

---

### [ux] Consider landscape support

**Description:** Portrait only.

**Proposed Fix:** Landscape layout with joystick left, fire right, wider playfield.

---

### [gameplay] Add special ability

**Description:** No power moment. Just steady fire.

**Proposed Fix:** Charge meter fills with kills. When full, unleash screen-clearing blast or 10-ball barrage.

---

## Priority Implementation Order

1. **Pause menu + mute** - Essential mobile UX
2. **Screen shake + damage feedback** - Core game feel
3. **Wave announcement** - Progression satisfaction
4. **Enemy approach warning** - Fairness
5. **More upgrade types** - Variety
6. **Background music** - Atmosphere
7. **Tutorial** - Onboarding
8. **XP floating text** - Feedback
9. **Aim persistence** - UX polish
10. **Meta-progression** - Long-term retention

---

## Key Files Reference

| Component | Path |
|-----------|------|
| Game Controller | `scripts/game/game_controller.gd` |
| Game Manager | `scripts/autoload/game_manager.gd` |
| Sound Manager | `scripts/autoload/sound_manager.gd` |
| Ball | `scripts/entities/ball.gd` |
| Ball Spawner | `scripts/entities/ball_spawner.gd` |
| Enemy Base | `scripts/entities/enemies/enemy_base.gd` |
| Slime | `scripts/entities/enemies/slime.gd` |
| Enemy Spawner | `scripts/entities/enemies/enemy_spawner.gd` |
| Gem | `scripts/entities/gem.gd` |
| Joystick | `scripts/input/virtual_joystick.gd` |
| Fire Button | `scripts/input/fire_button.gd` |
| Aim Line | `scripts/input/aim_line.gd` |
| HUD | `scripts/ui/hud.gd` |
| Level Up | `scripts/ui/level_up_overlay.gd` |
| Game Over | `scripts/ui/game_over_overlay.gd` |

---

*Report generated via PlayGodot comprehensive playtest automation*
