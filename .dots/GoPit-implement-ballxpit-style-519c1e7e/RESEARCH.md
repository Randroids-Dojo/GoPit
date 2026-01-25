# Ball Merging Research: BallxPit vs GoPit

## Executive Summary

GoPit already has a solid ball merging foundation that closely mirrors BallxPit's core mechanics. However, there are several key differences in trigger timing, multi-evolution depth, and evolved ball progression that need to be addressed.

## BallxPit Mechanics (Source: Web Research)

### Core Merging System

1. **Ball Leveling**: Each ball type gains XP through combat. L1 → L2 → L3 (fusion-ready)

2. **Rainbow Orb Trigger**: Appears as **XP level-up reward** when player has 2+ L3 balls
   - Not a random enemy drop
   - Tied to player progression/leveling
   - Creates meaningful decision points at level-ups

3. **Two Merge Types**:
   - **Evolution**: Specific recipes create unique evolved balls (Bomb, Blizzard, etc.)
   - **Fusion**: Any 2 L3 balls without recipe → combined ball with both effects

4. **Multi-Evolution System** (key differentiator):
   - Evolved balls can **level to L3** and be used in further evolutions
   - Creates "evolution trees":
     - `Burn + Iron = Bomb`
     - `Bomb + Poison = Nuclear Bomb` (two-step)
     - `Sun + Dark = Black Hole` (two-step)
   - Ultimate three-way fusions: `Vampire Lord + Mosquito King + Spider Queen = Nosferatu`

5. **Damage Multipliers**: 1.5x → 2.5x → 4.0x for evolved tiers

### Known BallxPit Recipes (from guides)

| Input A | Input B | Result | Notes |
|---------|---------|--------|-------|
| Burn | Iron | Bomb | S-tier, AoE explosion |
| Freeze | Lightning | Blizzard | S-tier, AoE freeze |
| Burn | Earthquake | Magma | Ground pools |
| Earthquake | Wind | Sandstorm | |
| Bomb | Poison | Nuclear Bomb | Multi-evolution |
| Sun | Dark | Black Hole | Multi-evolution |

---

## GoPit Current Implementation

### What's Already Implemented

| Feature | Implementation | File Location |
|---------|---------------|---------------|
| Ball levels (L1-L3) | `owned_balls: Dictionary` with level tracking | `ball_registry.gd:203` |
| 18 ball types | Full enum with BALL_DATA | `ball_registry.gd:16-200` |
| 10 evolution recipes | EVOLUTION_RECIPES dictionary | `fusion_registry.gd:49-62` |
| Evolution tiers | TIER_1 (1.5x), TIER_2 (2.5x), TIER_3 (4.0x) | `fusion_registry.gd:12-23` |
| Generic fusion | Any 2 L3 balls → combined effects | `fusion_registry.gd:380-440` |
| Fission system | Random upgrades alternative | `fusion_registry.gd:515-586` |
| Fusion Reactor trigger | Purple atom drop from enemies | `fusion_reactor.gd` |
| Fusion UI overlay | 3-tab UI (Fission/Fusion/Evolution) | `fusion_overlay.gd` |
| Evolved ball effects | Unique mechanics per evolved type | `ball.gd:986-1348` |
| Ball slots (5 max) | Multi-shot with equipped balls | `ball_registry.gd:406-498` |
| Passive upgrades (20 types) | Slot-based L1-L3 passives | `fusion_registry.gd:589-944` |

### Current GoPit Evolution Recipes

| Ball A | Ball B | Result | Effect |
|--------|--------|--------|--------|
| Burn | Iron | Bomb | AoE explosion (100px) |
| Freeze | Lightning | Blizzard | AoE freeze + chain |
| Poison | Bleed | Virus | Spreading DoT + lifesteal |
| Burn | Poison | Magma | Ground pools (3s, 5 dps) |
| Burn | Freeze | Void | Alternating burn/freeze |
| Freeze | Iron | Glacier | Pierce (3) + slow |
| Lightning | Poison | Storm | Chain poison (4 enemies) |
| Lightning | Bleed | Plasma | Chain bleed (3 enemies) |
| Bleed | Iron | Cleaver | Heavy bleed + knockback |
| Bleed | Freeze | Frostbite | Freeze → bleed on thaw |

### Current Trigger Mechanism (TO BE REMOVED)

```gdscript
# GoPit current trigger (game_controller.gd:723-728)
# THIS SHOULD BE REMOVED - not BallxPit style
func _maybe_spawn_fusion_reactor(pos: Vector2) -> void:
    var chance := 0.02 + GameManager.current_wave * 0.001
    if randf() < chance:
        _spawn_fusion_reactor(pos)
```

---

## Gap Analysis

### Gap 1: Level-Up Triggered Merging

**Current**: Random drops on enemy death
**BallxPit**: Guaranteed at level-up when conditions met

**Implementation**:
1. Add check in level-up logic: `if BallRegistry.get_fusion_ready_balls().size() >= 2`
2. Auto-spawn Fusion Reactor at player position on level-up
3. Remove random drop logic entirely

**Files to modify**:
- `scripts/game/game_controller.gd` - Remove `_maybe_spawn_fusion_reactor`, add level-up hook
- `scripts/autoload/game_manager.gd` - Emit signal when fusion conditions met

### Gap 2: Multi-Evolution System (Evolved + Evolved/L3)

**Current**: Tier upgrades consume any L3 ball, but evolved balls don't level up
**BallxPit**: Evolved balls gain XP, reach L3, and unlock advanced recipes

**Implementation**:
1. Add `evolved_ball_levels: Dictionary` in FusionRegistry (EvolvedBallType → level)
2. Evolved balls in slots earn XP like regular balls
3. Add "Multi-Evolution" recipes:

| Input A | Input B | Result | Requirement |
|---------|---------|--------|-------------|
| Bomb (L3) | Poison (L3) | Nuclear Bomb | Evolved + base |
| Blizzard (L3) | Dark (L3) | Black Hole | Evolved + base |
| Virus (L3) | Radiation (L3) | Plague | Evolved + base |
| Magma (L3) | Glacier (L3) | Volcano | Evolved + evolved |

**Files to modify**:
- `scripts/autoload/fusion_registry.gd` - Add MULTI_EVOLUTION_RECIPES, evolved ball leveling
- `scripts/entities/ball.gd` - Add XP earning for evolved balls
- `scripts/ui/fusion_overlay.gd` - Show multi-evolution tab/section

### Gap 3: Evolved Ball in Ball Slots

**Current**: Evolved balls exist but aren't directly slottable
**BallxPit**: Evolved balls can be equipped and used like regular balls

**Implementation**:
1. Add `active_evolved_slots: Array[int]` in BallRegistry (parallel to ball slots)
2. Modify `get_filled_slots()` to include evolved ball slot info
3. Update BallSpawner to spawn evolved ball instances

**Files to modify**:
- `scripts/autoload/ball_registry.gd` - Evolved slot support
- `scripts/entities/ball_spawner.gd` - Evolved ball instantiation

### Gap 4: Three-Way Fusions (Ultimate Evolutions)

**Current**: Only 2-ball combinations
**BallxPit**: 3 evolved balls → ultimate ball (rare, endgame)

**Implementation**:
1. Add ULTIMATE_RECIPES in FusionRegistry:
```gdscript
const ULTIMATE_RECIPES := {
    [EvolvedBallType.BOMB, EvolvedBallType.VIRUS, EvolvedBallType.STORM]: "APOCALYPSE",
    [EvolvedBallType.BLIZZARD, EvolvedBallType.GLACIER, EvolvedBallType.FROSTBITE]: "ABSOLUTE_ZERO",
}
```
2. Add TIER_4 (6.0x damage) for ultimate balls
3. Update fusion UI to show ultimate options when 3+ evolved balls owned

**Files to modify**:
- `scripts/autoload/fusion_registry.gd`
- `scripts/ui/fusion_overlay.gd`

---

## Implementation Priority

### Phase 1: Core Trigger Change
1. **Level-up fusion trigger** - Replace random drops with level-up spawns
2. **Fusion Ready indicator** - HUD shows when 2+ L3 balls owned

### Phase 2: Evolved Ball Progression
3. **Evolved ball leveling** - Let evolved balls earn XP and reach L3
4. **Evolved ball slots** - Make evolved balls directly usable in slots

### Phase 3: Multi-Evolution
5. **Multi-evolution recipes** - Add 4-6 two-step recipes
6. **Update fusion overlay** - Support multi-evolution UI

### Phase 4: Ultimate Tier
7. **Three-way fusions** - Add ultimate evolution tier
8. **Evolution tree UI** - Show unlock paths and requirements

### Phase 5: Polish
9. **Recipe discovery** - Unknown recipes shown as "???"
10. **Session persistence** - Save evolved ball progress
11. **PlayGodot tests** - Comprehensive test coverage

---

## Technical Notes

### Ball Type Mapping

Currently there are TWO ball type enums that need to stay in sync:
- `BallRegistry.BallType` (18 types) - Used for ownership tracking
- `Ball.BallType` (18 types) - Used for entity behavior

Evolved balls use `FusionRegistry.EvolvedBallType` (11 types including NONE).

### Session State

Both registries support session save/restore:
- `BallRegistry.get_session_state()` / `restore_session_state()`
- `FusionRegistry.get_session_state()` / `restore_session_state()`

Any new evolved ball leveling system needs similar persistence.

### Testing Requirements

Per AGENTS.md, all code changes need PlayGodot tests. Key test files:
- `tests/test_fusion_system.py` - Existing fusion tests
- New tests needed for multi-evolution mechanics

---

## Sources

- [Evolution & Fusion Basics - Complete Mechanics Guide | Ball x Pit](https://ballxpit.org/guides/evolution-guide/)
- [Ball x Pit Evolutions and Guide - SteelSeries](https://steelseries.com/blog/ball-x-pit-evolutions-and-guide)
- [Master Ball x Pit Evolution Combos: Complete Fusion Guide | GAM3S.GG](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-evolution-combos/)
- [Ball x Pit Beginner's Guide - NeonLightsMedia](https://www.neonlightsmedia.com/blog/ball-x-pit-beginners-guide)
