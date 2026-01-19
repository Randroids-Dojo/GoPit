---
title: "implement: Add first-time hints for level-up and shop"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T03:21:56.321488-06:00"
---

## Description

Add minimal contextual hints that appear on first occurrence of key events to help new players understand progression systems.

## Context

Research (GoPit-research-evaluate-tutorial-a3fbebd9) found that while basic controls are tutorialized, the progression systems (level-up upgrades, meta shop) have no guidance. Rather than adding extensive tutorials, we'll use lightweight first-time hints.

## Affected Files

### Modify
- `scripts/ui/level_up_overlay.gd` - Add first-time hint logic
- `scripts/ui/game_over_overlay.gd` - Add first-time shop hint
- `scripts/ui/tutorial_overlay.gd` - Add hint state tracking to settings

### Potentially New
- Scene modifications for hint UI (could use existing Label + animation)

## Implementation Notes

### First Level-Up Hint
When level_up_overlay becomes visible AND player hasn't seen hint before:
1. Show a brief tooltip/label near cards: "Choose an upgrade! Tap a card to power up."
2. Save `first_levelup_seen: true` to settings file
3. Hint auto-dismisses after 3s or on card selection

### First Game Over Shop Hint
When game_over_overlay becomes visible AND player hasn't used shop before:
1. Add pulsing glow/arrow pointing to Shop button
2. Show label: "Spend Pit Coins on permanent upgrades!"
3. Save `shop_hint_seen: true` after clicking Shop button
4. Hint persists until Shop is clicked

### Settings Storage
Use same file as tutorial (`user://settings.save`):
```json
{
  "tutorial_complete": true,
  "first_levelup_seen": true,
  "shop_hint_seen": true
}
```

## Verify

- [ ] `./test.sh` passes
- [ ] First level-up shows hint text near cards
- [ ] Hint dismisses on card selection or after timeout
- [ ] Hint doesn't appear on second level-up
- [ ] First game over shows shop hint with visual indicator
- [ ] Shop hint disappears after clicking Shop button
- [ ] Hints don't appear after settings are saved
- [ ] Fresh install shows all hints
- [ ] Returning player (with settings) sees no hints
