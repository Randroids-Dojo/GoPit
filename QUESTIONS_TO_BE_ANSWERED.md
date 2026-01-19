# Questions to Be Answered

## Ball Slot System (GoPit-6zk) - RESOLVED (2026-01-19)

**STATUS: IMPLEMENTED** - See `scripts/autoload/ball_registry.gd`

### Implementation Summary

1. **How many slots exactly?** → **5 slots** (`MAX_SLOTS: int = 5` at line 211)

2. **Multi-shot interaction**: Each equipped slot fires independently. Multi-shot would multiply per slot.

3. **Empty slots**: Empty slots (`-1`) are skipped. Only filled slots fire. (`get_filled_slots()` at line 422)

4. **Slot assignment**: When acquiring a new ball type:
   - Automatically fills next empty slot via `_assign_to_empty_slot()` (line 407)
   - Player can rearrange slots via `swap_slots()` (line 459) and `set_slot()` (line 440)

5. **Duplicate balls in slots**: Implementation allows same ball type in multiple slots (no uniqueness check in `set_slot()`)

6. **Baby balls**: Baby balls inherit ball type from their spawner configuration

### Resolved

---

## Ball Return Mechanic (GoPit-ay9) - RESOLVED (2026-01-19)

**STATUS: IMPLEMENTED** - See `scripts/entities/ball.gd`

### Implementation Summary

1. **When does a ball "return"?**
   - Y-position check at `RETURN_Y_THRESHOLD = 1150.0` (line 34)
   - Ball crosses bottom threshold → starts returning
   - Return completes at `RETURN_COMPLETE_Y = 350.0` (line 35)
   - Catch zone: ball is catchable when `y < CATCH_ZONE_Y (600.0)` (line 36)

2. **Fire restriction**: Global ball availability tracking
   - `_balls_available` flag on fire button (checked in `wait_for_fire_ready()`)
   - Fire button waits for balls to be available

3. **Bottom boundary**: Y-position check, not physics wall
   - `is_returning` flag triggers at `y > RETURN_Y_THRESHOLD`
   - Return speed is faster: `RETURN_SPEED_MULT = 1.5` (line 37)

4. **Ball persistence**: `max_bounces` kept as fallback
   - Line 271: "Removed despawn on max_bounces - balls now return at bottom of screen"
   - `max_bounces = 30` still exists as safety limit

5. **Multi-shot + return**: All balls share global availability pool

6. **Baby balls**: Separate tracking via `is_baby_ball` flag (line 52)

### Resolved
