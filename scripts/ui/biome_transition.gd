extends CanvasLayer
## Smooth transition overlay between biomes with stage name announcement

@onready var color_rect: ColorRect = $ColorRect
@onready var stage_label: Label = $CenterContainer/StageLabel


func _ready() -> void:
	visible = false
	StageManager.biome_changed.connect(_on_biome_changed)


func _on_biome_changed(biome: Biome) -> void:
	# Only play transition for biomes after the first one (stage > 0)
	if StageManager.current_stage > 0:
		_play_transition(biome.biome_name)


func _play_transition(biome_name: String) -> void:
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
