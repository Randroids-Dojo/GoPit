# Experiment Mode Iteration Guide

## Goal
Replicate BallxPit's first 5 minutes exactly in GoPit's Experiment Mode.

## How to Use Experiment Mode

### Launching
1. Start GoPit
2. On the Save Slot Select screen, click "EXPERIMENT MODE"
3. Game loads with simplified settings

### Tuning Controls (Keyboard)
| Key | Action |
|-----|--------|
| 1/2 | Decrease/Increase Ball Speed |
| 3/4 | Decrease/Increase Spawn Interval |
| 5/6 | Decrease/Increase Ball Size |
| 7/8 | Decrease/Increase Formation Chance |
| 9/0 | Decrease/Increase Enemy Speed |
| R | Reset settings to defaults |
| Backspace | Instant restart (clear all, reset stats) |
| P | Pause/Unpause |
| M | Save metrics to file |
| ESC | Return to menu |

### Metrics Tracking
Press M to save a metrics report including:
- Time to first kill
- Average time per kill
- Accuracy (hit rate)
- Max balls/enemies on screen
- Kills per minute breakdown
- Current settings values

### XP and Level-Up System
Experiment mode includes a simplified level-up system matching BallxPit's first level:
- **XP from kills**: Each enemy kill grants XP (displayed in debug panel)
- **Level-up overlay**: Shows when you reach enough XP
- **Simplified upgrades**: Only Power Up, Vitality, Magnetism, and Heal
- No ball evolutions or complex options (matches early BallxPit)

### Quick Iteration with Restart
Press **Backspace** for instant restart:
- Clears all enemies, balls, and gems
- Resets player position, XP, level, and health
- **Keeps your current tuning settings** (ball speed, spawn interval, etc.)
- Perfect for rapid A/B testing of parameter changes

Typical workflow:
1. Adjust a setting (e.g., press 2 to increase ball speed)
2. Play for 30 seconds to feel the change
3. Press Backspace to restart with same settings
4. Compare against previous feel

## Research-Based Starting Settings

Based on the research documents in docs/research/:

### Ball Settings
```
Ball Speed: 900 (slightly faster than default 800)
Ball Radius: 12 (smaller than default 14)
Max Balls: 3 (limit visual chaos)
```

### Enemy Settings
```
Spawn Interval: 3.5s (slower for learning)
Formation Chance: 30% (mostly singles)
Max Enemies: 8 (cap for clarity)
Enemy Speed: 50 (slower descent for first level)
Enemy Type: Slime only (single type)
```

### Target Metrics (BallxPit First Level)
| Metric | Target | Why |
|--------|--------|-----|
| First kill time | 5-8s | Quick feedback |
| Avg time per kill | 2-4s | Steady pace |
| Max enemies | 6-8 | Manageable pressure |
| Max balls | 2-3 | Visual clarity |
| Kills per minute | 15-20 | Engaging but not overwhelming |

## Iteration Process

### Step 1: Visual Clarity Check
1. Start experiment mode
2. Let enemies spawn for 30 seconds
3. Can you track every ball? Every enemy?
4. If not, reduce spawn rate or max counts

### Step 2: Timing Check
1. Play for 2 minutes
2. Check metrics (press M)
3. Compare time-to-first-kill and avg-time-per-kill
4. Adjust ball speed if kills feel too slow/fast

### Step 3: Pressure Check
1. Play for 3 minutes without firing
2. How long until overwhelmed?
3. Should be ~45-60 seconds of passive play
4. Adjust spawn interval if too easy/hard

### Step 4: Feel Check (Subjective)
Answer these questions:
- Does each shot feel impactful?
- Is there "breathing room" between threats?
- Can you plan your shots?
- Does leveling up feel rewarding?

If any answer is "no", adjust settings accordingly.

## Common Adjustments

### "Too chaotic"
- Increase spawn_interval to 4.0+
- Reduce formation_chance to 20%
- Reduce ball_speed to 800

### "Too slow/boring"
- Decrease spawn_interval to 2.5
- Increase formation_chance to 50%
- Increase ball_speed to 1000

### "Can't track balls"
- Reduce ball_speed to 700
- Increase ball_radius to 14
- Limit to 2 balls on screen

### "Enemies too easy"
- Decrease spawn_interval
- Increase formation_chance
- Increase enemy_speed to 80+
- Add more enemy types (future work)

### "Enemies too threatening"
- Decrease enemy_speed to 30-40
- Increase spawn_interval
- Reduce formation_chance

## Recording Comparison Data

### BallxPit Reference Session
1. Play BallxPit first level for 5 minutes
2. Note: time to first kill, kills at 1/2/3/4/5 min marks
3. Observe: max enemies on screen, typical enemy spacing
4. Feel: rhythm of gameplay, moments of intensity vs calm

### GoPit Experiment Session
1. Play Experiment Mode for 5 minutes
2. Press M to save metrics
3. Compare against BallxPit notes
4. Adjust settings and repeat

## Success Criteria

The experiment is "done" when:
1. **Timing matches**: First kill ~5-8s, avg kill ~3s
2. **Complexity matches**: Max 6-8 enemies, max 2-3 balls
3. **Feel matches**: Same rhythm of action and calm
4. **Clarity achieved**: Every object trackable
5. **Satisfaction loop**: Kills feel rewarding, not chaotic

## Next Steps After Match

Once Experiment Mode feels right:
1. Document final settings in this file
2. Apply settings to main game's first level
3. Create difficulty ramp from Level 1 settings
4. Add complexity gradually per wave
