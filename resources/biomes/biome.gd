class_name Biome
extends Resource
## Resource defining a biome/stage theme

@export var biome_name: String = "Unknown"
@export var background_color: Color = Color(0.1, 0.1, 0.18)
@export var wall_color: Color = Color(0.2, 0.2, 0.3)

## Waves in this stage before boss
@export var waves_before_boss: int = 10

## Future: enemy variants, hazards, music
# @export var hazard_scenes: Array[PackedScene]
# @export var enemy_variants: Dictionary
# @export var music_track: AudioStream
