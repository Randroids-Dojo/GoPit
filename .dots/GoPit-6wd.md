---
title: Biome System Architecture
status: done
priority: 2
issue-type: task
assignee: randroid
created-at: 2026-01-05T23:37:53.360749-06:00
---

# Biome System Architecture

## Parent Epic
GoPit-6p4 (Phase 3 - Boss & Stages)

## Overview
Create the biome/stage system that allows different themed environments with unique visuals, hazards, and enemy variants.

## Requirements
1. Biome resource type defining theme properties
2. Dynamic background/tileset swapping
3. Biome-specific hazard system
4. Enemy variant support per biome
5. Stage progression logic (Pit → Ice → Desert → etc)
6. Wave-based boss triggers per stage

## Biome Structure
```gdscript
# resources/biomes/biome.gd
class_name Biome
extends Resource

@export var biome_name: String
@export var background_texture: Texture2D
@export var wall_color: Color
@export var ambient_color: Color
@export var music_track: AudioStream

@export var hazard_scenes: Array[PackedScene]
@export var hazard_spawn_rate: float

@export var enemy_variants: Dictionary  # base_type -> variant_scene
@export var boss_scene: PackedScene

@export var waves_in_stage: int = 30
@export var boss_wave: int = 10
```

## Stage Progression
```
The Pit (waves 1-30) → Frozen Depths (31-60) → Burning Sands (61-90) → Final Descent (91-100)
         ↓                    ↓                      ↓                      ↓
    Slime King           Frost Wyrm            Sand Golem              Final Boss
```

## Implementation
```gdscript
# scripts/autoload/stage_manager.gd
extends Node

var current_biome: Biome
var current_stage: int = 0
var stages: Array[Biome] = []

func _ready() -> void:
    _load_stages()
    GameManager.wave_changed.connect(_on_wave_changed)

func _load_stages() -> void:
    stages = [
        preload("res://resources/biomes/the_pit.tres"),
        preload("res://resources/biomes/frozen_depths.tres"),
        preload("res://resources/biomes/burning_sands.tres"),
        preload("res://resources/biomes/final_descent.tres"),
    ]
    
func advance_stage() -> void:
    current_stage += 1
    if current_stage < stages.size():
        _apply_biome(stages[current_stage])
    else:
        _trigger_game_victory()

func _apply_biome(biome: Biome) -> void:
    current_biome = biome
    _update_visuals()
    _start_hazards()
    MusicManager.play_track(biome.music_track)
```

## Files to Create
- NEW: scripts/autoload/stage_manager.gd
- NEW: resources/biomes/biome.gd
- NEW: resources/biomes/the_pit.tres
- NEW: resources/biomes/frozen_depths.tres
- NEW: resources/biomes/burning_sands.tres
- NEW: resources/biomes/final_descent.tres

## Acceptance Criteria
- [ ] Biome resource type created
- [ ] Stage manager handles progression
- [ ] Backgrounds change per biome
- [ ] Hazards spawn per biome rules
- [ ] Boss triggers at correct wave
- [ ] Stage complete after boss defeat
