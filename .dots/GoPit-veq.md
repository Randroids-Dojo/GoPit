---
title: Character Resource & Selection UI
status: done
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:41:00.103959-06:00
---

# Character Resource & Selection UI

## Parent Epic
GoPit-ivv (Phase 4 - Character System)

## Overview
Create character data resource type and selection screen shown before game start.

## Requirements
1. Character resource defining stats, starting ball, passive
2. Character selection screen with 6 characters
3. Character preview showing stats and ability
4. Selected character affects gameplay
5. Character unlock system (future)

## Character Data
```gdscript
# resources/characters/character.gd
class_name Character
extends Resource

@export var character_name: String
@export var portrait: Texture2D
@export var description: String

# Stats (relative to 1.0 baseline)
@export var endurance: float = 1.0  # HP multiplier
@export var strength: float = 1.0   # Damage multiplier
@export var leadership: float = 1.0 # Baby ball rate
@export var speed: float = 1.0      # Movement speed
@export var dexterity: float = 1.0  # Crit chance
@export var intelligence: float = 1.0  # Effect duration

@export var starting_ball: int  # BallRegistry.BallType
@export var passive_name: String
@export var passive_description: String

@export var is_unlocked: bool = true
@export var unlock_requirement: String
```

## Character Roster
| Name | Ball | Passive | Focus |
|------|------|---------|-------|
| Rookie | Basic | None | Balanced |
| Pyro | Burn | +20% fire dmg | Strength |
| Frost Mage | Freeze | Frozen +50% dmg | Intelligence |
| Tactician | Iron | +2 baby balls | Leadership |
| Gambler | Random | 3x crit dmg | Dexterity |
| Vampire | Bleed | Lifesteal | Endurance |

## Selection UI Layout
```
┌─────────────────────────────────────┐
│         SELECT CHARACTER            │
├─────────────────────────────────────┤
│  [Portrait]     ROOKIE              │
│                 "Jack of all trades"│
│  ────────────────────────────────   │
│  HP: ████████░░                     │
│  DMG: ████████░░                    │
│  SPD: ████████░░                    │
│  ────────────────────────────────   │
│  Starting: Basic Ball               │
│  Passive: None                      │
├─────────────────────────────────────┤
│ [<]  ●○○○○○  [>]                   │
│           [START]                   │
└─────────────────────────────────────┘
```

## Files to Create
- NEW: resources/characters/character.gd
- NEW: resources/characters/*.tres (6 characters)
- NEW: scenes/ui/character_select.tscn
- NEW: scripts/ui/character_select.gd
- MODIFY: Main menu flow to include selection

## Acceptance Criteria
- [ ] Character resource type created
- [ ] 6 character resources defined
- [ ] Selection UI shows all characters
- [ ] Can browse and select character
- [ ] Selected character stats applied to game
- [ ] Starting ball matches character
