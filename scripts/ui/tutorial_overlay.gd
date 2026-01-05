extends CanvasLayer
## First-time tutorial overlay with step-by-step hints

enum TutorialStep { AIM, FIRE, HIT, COMPLETE }

var current_step: TutorialStep = TutorialStep.AIM
var has_completed_tutorial: bool = false

@onready var dim_background: ColorRect = $DimBackground
@onready var hint_label: Label = $DimBackground/HintLabel
@onready var highlight_ring: Control = $DimBackground/HighlightRing

const SETTINGS_PATH := "user://settings.save"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	has_completed_tutorial = _load_tutorial_state()

	if has_completed_tutorial:
		visible = false
		queue_free()
		return

	visible = true
	_show_step(TutorialStep.AIM)


func _show_step(step: TutorialStep) -> void:
	current_step = step

	match step:
		TutorialStep.AIM:
			hint_label.text = "Drag the JOYSTICK to aim"
			_show_highlight_at("VirtualJoystick")
		TutorialStep.FIRE:
			hint_label.text = "Tap FIRE to shoot!"
			_show_highlight_at("FireButton")
		TutorialStep.HIT:
			hint_label.text = "Hit enemies before they reach you!"
			_hide_highlight()
		TutorialStep.COMPLETE:
			_save_tutorial_complete()
			_fade_out()


func _show_highlight_at(node_name: String) -> void:
	# Find the control in the HUD
	var hud := get_tree().current_scene.get_node_or_null("UI/HUD")
	if not hud:
		return

	var target: Control = hud.find_child(node_name, true, false)
	if not target or not highlight_ring:
		return

	# Position the highlight ring over the target
	var target_center := target.global_position + target.size / 2
	highlight_ring.global_position = target_center - highlight_ring.size / 2
	highlight_ring.visible = true

	# Pulse animation
	var tween := create_tween().set_loops()
	tween.tween_property(highlight_ring, "modulate:a", 0.5, 0.5)
	tween.tween_property(highlight_ring, "modulate:a", 1.0, 0.5)


func _hide_highlight() -> void:
	if highlight_ring:
		highlight_ring.visible = false


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(dim_background, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)


func on_joystick_used() -> void:
	if current_step == TutorialStep.AIM:
		_show_step(TutorialStep.FIRE)


func on_ball_fired() -> void:
	if current_step == TutorialStep.FIRE:
		_show_step(TutorialStep.HIT)


func on_enemy_hit() -> void:
	if current_step == TutorialStep.HIT:
		_show_step(TutorialStep.COMPLETE)


func _load_tutorial_state() -> bool:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return false

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return false

	var data = JSON.parse_string(file.get_as_text())
	if data and data.has("tutorial_complete"):
		return data["tutorial_complete"]
	return false


func _save_tutorial_complete() -> void:
	var data := {}

	# Load existing settings first
	if FileAccess.file_exists(SETTINGS_PATH):
		var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var existing = JSON.parse_string(file.get_as_text())
			if existing:
				data = existing

	data["tutorial_complete"] = true

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
