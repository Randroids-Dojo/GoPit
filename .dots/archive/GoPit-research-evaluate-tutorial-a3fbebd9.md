---
title: "research: Evaluate tutorial expansion needs"
status: closed
priority: 2
issue-type: task
created-at: "\"\\\"2026-01-19T03:18:18.411577-06:00\\\"\""
closed-at: "2026-01-19T03:22:06.231389-06:00"
close-reason: "Completed research: documented 5 mechanics not covered by tutorial, recommended 2 minimal hint enhancements. Created GoPit-implement-add-first-bd018b35 for first-time hints on level-up and shop."
---

## Context

The existing tutorial (tutorial_overlay.gd) covers basic controls:
- MOVE - drag left joystick
- AIM - drag right joystick  
- FIRE - tap fire button
- HIT - hit enemies

## Research Questions

1. What additional tutorial steps might help new players?
   - Level-up system? (selecting upgrades)
   - Meta shop? (spending pit coins)
   - Autofire toggle?
   - Ultimate ability? (once implemented)

2. Are there common failure points for new players?
   - Review game over stats/analytics
   - Check player feedback if any

3. Should tutorial be skippable?
   - Currently auto-completes on first enemy hit
   - May be too brief for complex mechanics

## Affected Files
- scripts/ui/tutorial_overlay.gd
- scenes/ui/tutorial_overlay.tscn

## Research Findings

### Mechanics Not Covered by Tutorial

1. **Autofire** (fire_button.gd)
   - ON by default, affects movement speed (slower when shooting)
   - Toggle-able but players may not know how
   - Critical for gameplay pacing understanding

2. **Level-Up System** (level_up_overlay.gd)
   - 6 card types: PASSIVE, NEW_BALL, LEVEL_UP_BALL, FISSION, HEAL, TIER_UPGRADE
   - Players must choose upgrades strategically
   - First level-up is a discovery moment - no guidance provided

3. **XP/Gems Collection**
   - Enemies drop gems that grant XP
   - XP fills bar and triggers level-up
   - No tutorial explains this loop

4. **Meta Shop** (meta_shop.gd + permanent_upgrades.gd)
   - Pit Coins earned on game over (waves * 10 + level * 25)
   - Permanent upgrades: HP, damage, ball_slots, luck, speed_mult
   - Complex economy not explained

5. **Ball Types**
   - Multiple ball types with different effects (fire, ice, etc.)
   - Acquired through level-up NEW_BALL cards
   - Effects not explained

### Recommendation

**Priority: MEDIUM** - The current tutorial covers basic controls well. Complex mechanics are discoverable through play. However, two enhancements would help:

1. **First Level-Up Tooltip** - When the first level-up occurs, show a brief tooltip: "Choose an upgrade! Each card offers different benefits."

2. **Post-Game Shop Hint** - On first game over, highlight the Shop button: "Spend Pit Coins on permanent upgrades!"

These are minimal interventions that don't overwhelm new players but help them understand the core progression loops.

### Not Recommended

- Full tutorials for every mechanic (too much upfront information)
- Mandatory tutorial expansion (current brevity is good for returning players)
- Ultimate ability tutorial (feature not yet implemented)

## Deliverable

Created implementation spec: GoPit-implement-add-first-bd018b35 (Add first-time hints for level-up and shop)
