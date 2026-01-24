# Slot System Comparison: BallxPit vs GoPit

Research conducted: January 2026

## BallxPit Slot System

### Ball Slots

| Aspect | Details |
|--------|---------|
| **Starting slots** | 3 ball slots |
| **Maximum slots** | 5 ball slots |
| **Progression** | 3 → 4 → 5 via building unlocks |
| **4th slot unlock** | Bag Maker building (HEAVENLYxGATES) |
| **5th slot unlock** | 5th slot building (blueprint drops from Heaven/Void endgame) |
| **Firing behavior** | All equipped balls fire simultaneously (salvo mechanic) |
| **Ball levels** | L1 → L2 → L3, then can be fused/evolved at L3 |
| **UI display** | Visible in HUD (top area near health bar) |

#### Bag Maker Building
- **Effect:** Add 1 ball slot (3rd → 4th slot)
- **Location:** HEAVENLYxGATES
- **Cost:** 5,000 Gold, 100 Wheat, 30 Stone, 120 build points
- **Upgradeable:** No, single-level building
- **Priority:** Most impactful early building - always build first

#### 5th Ball Slot Building
- **Effect:** Add 1 ball slot (4th → 5th slot)
- **Location:** Blueprint drops from Heaven or Void (endgame stages)
- **Requirements:** Complete late-game content to obtain blueprint
- **Priority:** Endgame upgrade

### Passive Slots

| Aspect | Details |
|--------|---------|
| **Starting slots** | 3 passive slots |
| **Maximum slots** | 5 passive slots |
| **Progression** | 3 → 4 → 5 via building unlocks |
| **4th slot unlock** | Carpenter building (HEAVENLYxGATES) |
| **5th slot unlock** | 5th slot building (blueprint drops from Heaven/Void endgame) |
| **Passive levels** | L1 → L2 → L3 per passive |
| **Replacement** | Cannot replace passives once chosen during a run |
| **Evolution** | L3 passives can be evolved using Fusion Reactor |
| **UI display** | Visible in HUD |

#### Carpenter Building
- **Effect:** Add 1 passive slot (3rd → 4th slot)
- **Location:** HEAVENLYxGATES
- **Requirements:** Collect blueprint (RNG drop), then build
- **Priority:** High - enables more passive combinations

#### 5th Passive Slot Building
- **Effect:** Add 1 passive slot (4th → 5th slot)
- **Location:** Blueprint drops from Heaven or Void (endgame stages)
- **Requirements:** Complete late-game content to obtain blueprint
- **Priority:** Endgame upgrade

### Slot Philosophy

BallxPit uses slot progression as a **core meta-progression mechanic**:
- Players start constrained (3 ball, 3 passive slots)
- Building unlocks provide meaningful power spikes
- Endgame content rewards unlock maximum potential
- Forces strategic choices early (which 3 balls? which 3 passives?)
- Creates "aha moment" when gaining 4th/5th slots

---

## GoPit Current Implementation

### Ball Slots

| Aspect | GoPit Status | File Location |
|--------|--------------|---------------|
| **Default slots** | 5 (fixed) | `scripts/autoload/ball_registry.gd:208` |
| **Maximum slots** | 5 (fixed) | `scripts/autoload/ball_registry.gd:208` |
| **Progression** | None - all 5 slots available from start | N/A |
| **Firing behavior** | ✅ All filled slots fire (salvo) | `scripts/entities/ball_spawner.gd:123` |
| **Ball levels** | ✅ L1 → L2 → L3 | Various |
| **UI display** | ❌ No visual representation | Missing |

#### Implementation Details
```gdscript
# scripts/autoload/ball_registry.gd:208
const MAX_SLOTS: int = 5
var active_ball_slots: Array[int] = [-1, -1, -1, -1, -1]

# Auto-fills first empty slot when ball acquired
func add_ball(ball_type: BallType) -> void:
    _assign_to_empty_slot(ball_type)
```

#### Test Coverage
- File: `tests/test_ball_slots.py`
- Tests: Auto-assignment, multi-slot firing, manual management
- Status: ✅ Backend functionality complete

### Passive Slots

| Aspect | GoPit Status | File Location |
|--------|--------------|---------------|
| **Default slots** | 4 (fixed) | `scripts/autoload/fusion_registry.gd:720` |
| **Maximum slots** | 4 (fixed) | `scripts/autoload/fusion_registry.gd:720` |
| **Progression** | None - all 4 slots available from start | N/A |
| **Passive levels** | ✅ L1 → L2 → L3 | `scripts/autoload/fusion_registry.gd:720` |
| **Replacement** | N/A - no replacement UI | N/A |
| **Evolution** | ✅ Via Fusion Reactor | `scripts/autoload/fusion_registry.gd` |
| **UI display** | ✅ PassiveSlotsDisplay exists | `scripts/ui/passive_slots_display.gd` |

#### Implementation Details
```gdscript
# scripts/autoload/fusion_registry.gd:720
const MAX_PASSIVE_SLOTS: int = 4
const MAX_PASSIVE_LEVEL: int = 3
var passive_slots: Array[Dictionary] = []  # {"type": PassiveType, "level": 0-3}
```

#### UI Component
- **File:** `scripts/ui/passive_slots_display.gd`
- **Display:** HBoxContainer with 4 slots (60×60px each)
- **Features:** Icon, level indicator (L1/L2/L3), color-coded borders
- **Location:** Bottom center of screen, above XP bar
- **Refresh:** Auto-updates on `FusionRegistry.passive_slots_changed` signal

#### Test Coverage
- File: `tests/test_passive_slots.py`
- Tests: Display exists, 4 slots, leveling L1→L2→L3, max limit
- Status: ✅ UI and backend complete

---

## Gap Analysis

### Ball Slots Gaps

| Feature | BallxPit | GoPit | Status |
|---------|----------|-------|--------|
| **Starting count** | 3 | 5 | ❌ Too many (no scarcity) |
| **Maximum count** | 5 | 5 | ✅ Correct |
| **Progression** | 3→4→5 via buildings | None | ❌ Missing mechanic |
| **UI display** | Visible HUD | None | ❌ Critical missing feature |
| **Backend logic** | Salvo firing | Salvo firing | ✅ Correct |

**Critical Issues:**
1. **No visual feedback** - Players can't see which balls they have equipped
2. **No progression** - Starting with 5 slots removes strategic constraint
3. **No "aha moment"** - Missing meta-progression power spike

### Passive Slots Gaps

| Feature | BallxPit | GoPit | Status |
|---------|----------|-------|--------|
| **Starting count** | 3 | 4 | ❌ Too many (no scarcity) |
| **Maximum count** | 5 | 4 | ❌ Too few (limits builds) |
| **Progression** | 3→4→5 via buildings | None | ❌ Missing mechanic |
| **UI display** | Visible HUD | ✅ Exists | ✅ Correct |
| **Backend logic** | L1→L2→L3 leveling | L1→L2→L3 leveling | ✅ Correct |

**Critical Issues:**
1. **Wrong starting count** - Should be 3, not 4
2. **Wrong max count** - Should be 5, not 4
3. **No progression** - Starting with 4 slots removes strategic constraint

---

## Recommendations

### Phase 1: Ball Slots UI (Critical)

**Priority: HIGH** - Players have no visual feedback for equipped balls

1. Create `BallSlotsDisplay` component (mirror `PassiveSlotsDisplay` structure)
   - File: `scripts/ui/ball_slots_display.gd`
   - HBoxContainer with slot panels
   - Show ball icon, level, empty slots
   - Position: Top-center or top-right of HUD

2. Connect to `BallRegistry.slots_changed` signal for auto-refresh

3. Test coverage: `tests/test_ball_slots_ui.py`

### Phase 2: Slot Progression System (High)

**Priority: HIGH** - Core meta-progression mechanic

1. **Ball Slots:**
   - Change starting from 5 → 3
   - Add unlock system for 4th slot (early/mid game)
   - Add unlock system for 5th slot (late game)
   - Update tests to reflect new progression

2. **Passive Slots:**
   - Change starting from 4 → 3
   - Change max from 4 → 5
   - Add unlock system for 4th slot (early/mid game)
   - Add unlock system for 5th slot (late game)
   - Update PassiveSlotsDisplay to handle 5 slots
   - Update tests to reflect new progression

3. **Unlock Mechanics (choose one approach):**
   - **Option A:** XP level milestones (e.g., reach Level 5 for 4th slot, Level 15 for 5th)
   - **Option B:** Currency purchase in shop (e.g., spend 1000 gems for 4th slot)
   - **Option C:** Achievement-based (e.g., "Defeat 100 enemies" for 4th slot)
   - **Option D:** Building system (future - mimic BallxPit's base building)

### Phase 3: Visual Polish (Medium)

1. Add slot unlock animation/notification
2. Visual indication when slots are locked vs unlocked
3. Tooltips explaining slot system
4. Tutorial messaging for new players

---

## Implementation Plan

### Task 1: Create Ball Slots UI
- **Files to create:** `scripts/ui/ball_slots_display.gd`
- **Files to modify:** `scenes/ui/hud.tscn` (add BallSlotsDisplay node)
- **Tests to write:** `tests/test_ball_slots_ui.py`
- **Estimated complexity:** Medium (copy PassiveSlotsDisplay pattern)

### Task 2: Implement Slot Progression - Ball Slots
- **Files to modify:** `scripts/autoload/ball_registry.gd`
- **Changes:**
  - Add `unlocked_slots: int = 3` variable
  - Replace `MAX_SLOTS` references with `unlocked_slots` where appropriate
  - Add `unlock_slot()` method
  - Add `get_unlocked_slots()` method
  - Update `active_ball_slots` initialization to respect unlocked count
- **Tests to update:** `tests/test_ball_slots.py`
- **Estimated complexity:** Medium

### Task 3: Implement Slot Progression - Passive Slots
- **Files to modify:**
  - `scripts/autoload/fusion_registry.gd`
  - `scripts/ui/passive_slots_display.gd`
- **Changes:**
  - Add `unlocked_passive_slots: int = 3` variable
  - Change `MAX_PASSIVE_SLOTS` from 4 → 5
  - Update slot management to respect unlocked count
  - Update UI to display 5 slots (with locked state)
  - Add `unlock_passive_slot()` method
- **Tests to update:** `tests/test_passive_slots.py`
- **Estimated complexity:** Medium

### Task 4: Add Unlock System
- **Approach:** Start simple with XP level milestones
- **Files to modify:**
  - `scripts/autoload/game_manager.gd` (level-up hook)
  - `scripts/autoload/ball_registry.gd` (unlock logic)
  - `scripts/autoload/fusion_registry.gd` (unlock logic)
- **Unlock thresholds:**
  - 4th ball slot: Level 5
  - 5th ball slot: Level 15
  - 4th passive slot: Level 5
  - 5th passive slot: Level 15
- **Tests to write:** `tests/test_slot_unlocks.py`
- **Estimated complexity:** Low

### Task 5: Visual Feedback
- **Files to modify:**
  - `scripts/ui/ball_slots_display.gd`
  - `scripts/ui/passive_slots_display.gd`
- **Changes:**
  - Add locked/unlocked visual states
  - Add unlock notification/animation
  - Add tooltips
- **Estimated complexity:** Low

---

## Design Rationale

### Why Match BallxPit's Slot System?

1. **Proven Design:** BallxPit's slot progression is a successful meta-progression mechanic
2. **Strategic Depth:** Starting with 3 slots forces meaningful choices
3. **Power Curve:** Unlocking slots provides satisfying power spikes
4. **Retention:** Meta-progression gives players goals to work toward
5. **Balance:** Constrains early game power, enables late game builds

### Why Start with 3 Slots?

- **Early game scarcity:** Forces players to choose "best 3" balls/passives
- **Learning curve:** Fewer slots = simpler decision space for new players
- **Upgrade value:** Unlocking 4th/5th slots feels impactful
- **Strategic trade-offs:** "Do I keep basic ball or replace with new one?"

### Why 5 Maximum Slots?

- **Build diversity:** 5 slots enables complex ball/passive combos
- **Late game power:** Matches player mastery and enemy scaling
- **Aspiration:** Players have long-term goal to unlock all slots

---

## Open Questions

1. **Unlock timing:** Should 4th slot come at Level 5 or earlier (Level 3)?
2. **Separate unlocks:** Should ball slots and passive slots unlock independently or together?
3. **Unlock cost:** XP levels only, or also require currency/resources?
4. **Persistence:** Do unlocks persist across runs (meta) or per-run only?
5. **Visual placement:** Where should BallSlotsDisplay go in HUD? (top-left, top-center, top-right?)

**Recommendation:** Start simple (XP milestones, meta-persistent, top-right placement) and iterate based on playtesting.

---

## Sources

- [what is the requirement for 5th row inventory :: BALL x PIT General Discussions](https://steamcommunity.com/app/2062430/discussions/0/595163936630956894/)
- [Ball x Pit Buildings Guide: Construction, Strategy & Tier List (2025)](https://ballxpit.org/guides/buildings-guide/)
- [Bag Maker (Building) - BALL x PIT Wiki](https://ballxpit.wiki.gg/wiki/Bag_Maker_(Building))
- [Buildings - BALL x PIT Wiki](https://ballxpit.wiki.gg/wiki/Buildings)
- [Carpenter (Building) - BALL x PIT Wiki](https://ballxpit.wiki.gg/wiki/Carpenter_(Building))
- [Ball x Pit Trophy Guide & Roadmap](https://daynglsgameguides.com/2025/10/15/ball-x-pit-trophy-guide-roadmap/)
