extends CanvasLayer
## Wave transition announcement with animated text

@onready var wave_label: Label = $CenterContainer/WaveLabel


func _ready() -> void:
	visible = false
	GameManager.wave_changed.connect(_on_wave_changed)


func _on_wave_changed(new_wave: int) -> void:
	_show_announcement(new_wave)


func _show_announcement(wave: int) -> void:
	wave_label.text = "WAVE %d" % wave
	visible = true
	wave_label.modulate.a = 0
	wave_label.scale = Vector2(0.5, 0.5)
	wave_label.pivot_offset = wave_label.size / 2

	var tween := create_tween()
	# Fade in and scale up
	tween.tween_property(wave_label, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(wave_label, "scale", Vector2(1.2, 1.2), 0.2)
	# Hold
	tween.tween_interval(0.8)
	# Fade out and scale down
	tween.tween_property(wave_label, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(wave_label, "scale", Vector2(0.8, 0.8), 0.3)
	tween.tween_callback(func(): visible = false)
