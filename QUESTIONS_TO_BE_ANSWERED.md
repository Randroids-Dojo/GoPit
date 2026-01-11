# Questions to Be Answered

## Ball Slot System (GoPit-6zk)

### Key Questions

1. **How many slots exactly?** The task says "4-5 ball types". Is it 4 or 5? BallxPit might have a specific number.

2. **Multi-shot interaction**: When there are 4 slots and multi-shot is 3:
   - Does each slot fire 3 balls (total 12)?
   - Or do all 4 slots share the 3-ball spread?

3. **Empty slots**: What happens if player only has 2 ball types but 4 slots?
   - Fire nothing from empty slots?
   - Fill remaining slots with Basic ball?

4. **Slot assignment**: When acquiring a new ball type:
   - Automatically fills next empty slot?
   - Player can rearrange slots?

5. **Duplicate balls in slots**: Can the same ball type be in multiple slots for more of that type?

6. **Baby balls**: How do baby balls interact with slots? Do they inherit from parent slot's ball type?

### Need to Verify in BallxPit

- [ ] Count exact number of ball slots
- [ ] Test multi-shot with multiple ball types
- [ ] Observe what happens when acquiring new balls
- [ ] Check if slots can be rearranged

---

## Ball Return Mechanic (GoPit-ay9)

### Key Questions

1. **When does a ball "return"?**
   - When hitting bottom of screen only?
   - When player "catches" it manually?
   - Both? (bottom = auto-return, catch = bonus DPS)

2. **Fire restriction**: With multi-slot system, how does "cannot fire until balls return" work?
   - All balls must return before ANY can fire?
   - Each slot tracks its own balls independently?
   - Pool of available balls across all slots?

3. **Bottom boundary**: Is there a physical bottom wall, or Y-position check?
   - Current GoPit has no bottom wall (balls just bounce off sides)
   - Should add a bottom collision or check Y > threshold?

4. **Ball persistence**: With return mechanic, what replaces max_bounces?
   - Remove max_bounces entirely?
   - Keep as fallback safety?
   - Different mechanic (time-based despawn)?

5. **Multi-shot + return**: If multi-shot=3 and 4 slots = 12 balls per fire:
   - Must ALL 12 return before firing again?
   - Does this make the game feel slow?

6. **Baby balls**: Do baby balls count in the "balls out" system?
   - They auto-spawn, would they block player firing?

### Design Decision Needed

The ball return mechanic fundamentally changes gameplay from:
- **Current**: Cooldown-based firing, balls despawn after bounces
- **BallxPit**: Balls persist, must return before firing again

This is a MAJOR change. Proceeding with implementation:
- Add bottom-screen detection for ball return
- Track "balls in flight" per slot
- Fire button only active when balls are available
- Consider keeping autofire but adjusting for return timing
