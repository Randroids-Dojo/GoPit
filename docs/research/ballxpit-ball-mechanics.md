# BallxPit First Level Ball Mechanics Research

## Research Goal
Understand ball mechanics in BallxPit's first 5 minutes to match the feel in Experiment Mode.

## BallxPit Ball Mechanics (From Research)

### Ball Speed
- **Base speed**: Not documented numerically, but "feels responsive"
- **Radiant Feather passive**: +20% ball launch speed (suggests base is tunable)
- **Rubber Headband passive**: -30% initial speed, +20% per bounce (max 200%)
- **Key observation**: Balls in BallxPit feel FAST - quick screen traversal

### Fire Rate System
- Fire rate determines how quickly balls **drain from queue**
- Not all balls fire at once - they fire in sequence
- Default fire rate: ~3 balls/second (estimated)
- **Itchy Finger character**: 2x fire rate (rapid-fire playstyle)
- **Shortbow passive**: +15% fire rate

### Bounce Physics
- Balls bounce off walls and return to player
- **Diagonal shot strategy**: 20-30 bounces = high damage
- **Repentant character**: +5% damage per bounce
- Balls hitting back wall return faster to player
- BallxPit encourages bouncing balls behind enemies

### Return Behavior
- Balls return after hitting back wall (top of screen)
- Return speed may be faster than outgoing
- Player can catch returning balls for bonus
- Queue drains while balls are in flight

### Aim Sensitivity
- Player can aim precisely
- Can hold and aim before firing
- Aim line shows trajectory preview
- Bounce prediction visible in aim line

## GoPit Current Implementation

### Ball Speed
```gdscript
# ball.gd
@export var speed: float = 800.0  # Base speed (800 px/sec)

# Type modifiers:
# Lightning: 1.125x = 900 px/sec
# Iron: 0.75x = 600 px/sec
# Standard: 1.0x = 800 px/sec
```

### Fire Rate
```gdscript
# ball_spawner.gd
var fire_rate: float = 3.0  # balls/second
var max_queue_size: int = 30

# Fire interval = 1.0 / fire_rate = 0.33 seconds between shots
```

### Fire Button Cooldown
```gdscript
# fire_button.gd
@export var cooldown_duration: float = 0.5  # 500ms between fire presses
var autofire_enabled: bool = true  # Default ON
```

### Ball Return Constants
```gdscript
# ball.gd
const RETURN_Y_THRESHOLD: float = 1150.0  # Start returning at Y > 1150
const RETURN_COMPLETE_Y: float = 350.0    # Return complete at Y < 350
const RETURN_SPEED_MULT: float = 1.5      # 50% faster return
const CATCH_MAGNETISM_RADIUS: float = 80.0  # Auto-catch radius
```

### Bounce Prediction
```gdscript
# aim_line.gd
@export var max_bounces: int = 3  # Show 3 bounce predictions
@export var max_length: float = 400.0
```

## Gap Analysis

### Speed Comparison
| Aspect | BallxPit (estimated) | GoPit | Notes |
|--------|---------------------|-------|-------|
| Base speed | ~1000-1200 px/sec | 800 px/sec | GoPit may be slower |
| Return speed | 1.5-2x | 1.5x | Similar |
| Bounce decay | None (constant) | None | Match |

### Fire Rate Comparison
| Aspect | BallxPit | GoPit | Notes |
|--------|----------|-------|-------|
| Queue drain | ~3/sec | 3/sec | Match |
| Fire cooldown | Instant | 0.5s | GoPit has delay |
| Autofire | Yes | Yes (default ON) | Match |

### First 5 Minutes Specifics
In BallxPit's first level:
- **1 ball only** - No baby balls yet
- **Simple trajectory** - Straight up or slight angle
- **Few bounces** - Enemies near top, quick hits
- **Slow fire rate** - Learning the mechanic

## Recommendations for Experiment Mode

### Ball Speed Adjustments
```gdscript
var exp_settings := {
    "ball_speed": 900.0,           # Slightly faster
    "ball_speed_on_return": 1.5,   # Current is good
}
```

### Simplified Firing
```gdscript
var exp_settings := {
    "fire_rate": 2.0,              # Slower - 1 ball every 0.5s
    "fire_cooldown": 0.3,          # Shorter cooldown
    "max_balls_on_screen": 3,      # Limit chaos
    "baby_balls_enabled": false,   # No babies in first 5 min
}
```

### Aim Line Adjustments
```gdscript
var exp_settings := {
    "aim_line_max_length": 600.0,  # Longer preview
    "bounce_preview": 2,           # Show 2 bounces only
}
```

### First-Level Ball Behavior
1. **Single ball type** - NORMAL only
2. **No pierce** - Balls hit and return
3. **Max 3 balls in flight** - Visual clarity
4. **Slower queue drain** - Feel each shot
5. **Longer catch window** - Learn mechanic

## Testing Metrics

To validate ball mechanics match BallxPit:
1. **Screen traversal time**: Ball should cross screen in ~1.5s
2. **Bounce responsiveness**: No delay on wall contact
3. **Return feel**: Player should feel rewarded catching balls
4. **Fire rhythm**: Natural 2-beat firing pattern

## Sources

- [Steam: Fire Rate Discussion](https://steamcommunity.com/app/2062430/discussions/0/624436409752895957/)
- [Steam: Attack Speed Discussion](https://steamcommunity.com/app/2062430/discussions/0/624436409752955709/)
- [GameFAQs: Passives Guide](https://gamefaqs.gamespot.com/pc/539487-ball-x-pit/faqs/82316)
- [Ball x Pit Combos & Synergies Guide](https://ballxpit.org/guides/combos-synergies/)
- GoPit Codebase Analysis (scripts/entities/ball*.gd, scripts/input/*.gd)
