---
title: "implement: Add biome transition effect"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T09:57:35.934733-06:00"
parent: GoPit-5tv
---

# Add Biome Transition Effect

## Description

Add a smooth visual transition effect that plays when the player completes a stage and moves to the next biome. The transition should:
1. Fade out the current biome visuals
2. Show a brief stage name announcement
3. Fade in the new biome visuals

## Context

Currently, `StageManager` emits `biome_changed` signal when transitioning between stages (after defeating the final boss), but nothing listens for visual transitions. The biome simply switches instantly.

The game has 8 biomes:
- The Pit, Frozen Depths, Burning Sands, Final Descent, Toxic Marsh, Storm Spire, Crystal Caverns, The Abyss

## Affected Files

- **NEW**: `scripts/ui/biome_transition.gd` - Transition overlay script
- **NEW**: `scenes/ui/biome_transition.tscn` - Transition overlay scene
- **MODIFY**: `scenes/game.tscn` - Add transition overlay as child
- **MODIFY**: `scripts/autoload/stage_manager.gd` - Ensure proper timing for transition

## Implementation Notes

### BiomeTransition Script
```gdscript
extends CanvasLayer
## Smooth transition overlay between biomes

@onready var color_rect: ColorRect = $ColorRect
@onready var stage_label: Label = $CenterContainer/StageLabel

func _ready():
    visible = false
    StageManager.biome_changed.connect(_on_biome_changed)

func _on_biome_changed(biome: Biome):
    _play_transition(biome.biome_name)

func _play_transition(biome_name: String):
    visible = true
    stage_label.text = biome_name
    stage_label.modulate.a = 0
    color_rect.color.a = 0

    var tween := create_tween()
    # Fade to black
    tween.tween_property(color_rect, "color:a", 1.0, 0.5)
    # Show stage name
    tween.tween_property(stage_label, "modulate:a", 1.0, 0.3)
    tween.tween_interval(1.0)
    # Fade out stage name
    tween.tween_property(stage_label, "modulate:a", 0.0, 0.3)
    # Fade from black
    tween.tween_property(color_rect, "color:a", 0.0, 0.5)
    tween.tween_callback(func(): visible = false)
```

### Scene Structure (biome_transition.tscn)
```
BiomeTransition (CanvasLayer, layer=100)
  ColorRect (covers viewport, color=black, modulate.a=0)
  CenterContainer
    StageLabel (large font, white text with shadow)
```

### Timing Consideration

The transition should play AFTER the stage_complete_overlay is dismissed but BEFORE enemies start spawning in the new biome. StageManager.complete_stage() should be called by stage_complete_overlay when player clicks Continue.

## Verify

- [ ] `./test.sh` passes
- [ ] Complete a stage (defeat boss, click Continue on stage_complete_overlay)
- [ ] Screen fades to black smoothly (0.5s)
- [ ] New biome name appears centered (e.g., "Frozen Depths")
- [ ] Name fades out after ~1 second
- [ ] Screen fades in to new biome (0.5s)
- [ ] Total transition takes ~2.5 seconds
- [ ] Game does not freeze or stutter during transition
- [ ] Works for all 8 biome transitions
