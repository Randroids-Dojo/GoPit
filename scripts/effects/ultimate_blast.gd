extends Node2D
## Screen-clearing ultimate blast effect
## Creates flash, kills all enemies, shakes camera, plays sound

signal blast_completed


func execute() -> void:
	## Execute the ultimate blast - call this after adding to scene tree
	_play_sound()
	_create_flash()
	_shake_camera()
	_kill_all_enemies()

	# Clean up after effects complete
	await get_tree().create_timer(0.6).timeout
	blast_completed.emit()
	queue_free()


func _play_sound() -> void:
	SoundManager.play(SoundManager.SoundType.ULTIMATE)


func _create_flash() -> void:
	# Create a white flash overlay
	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0.8)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Add to UI layer for proper z-ordering
	var ui := get_tree().current_scene.get_node_or_null("UI")
	if ui:
		ui.add_child(flash)
	else:
		get_tree().current_scene.add_child(flash)

	# Fade out the flash
	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_callback(flash.queue_free)


func _shake_camera() -> void:
	# Big screen shake
	CameraShake.shake(25.0, 4.0)


func _kill_all_enemies() -> void:
	# Find all enemies and deal massive damage
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			# Deal 9999 damage to instantly kill
			enemy.take_damage(9999)
