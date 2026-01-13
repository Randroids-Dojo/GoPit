class_name Biome
extends Resource
## Resource defining a biome/stage theme

@export var biome_name: String = "Unknown"
@export var background_color: Color = Color(0.1, 0.1, 0.18)
@export var wall_color: Color = Color(0.2, 0.2, 0.3)

## Waves in this stage before boss
@export var waves_before_boss: int = 10

## Enemy types that spawn in this biome (paths to scenes)
## If empty, spawner uses default all-enemy logic
@export var enemy_scenes: Array[PackedScene] = []

## Environmental hazard scene for this biome (optional)
@export var hazard_scene: PackedScene

## How many hazards to spawn in this biome
@export var hazard_count: int = 0

## Future: music
# @export var music_track: AudioStream
