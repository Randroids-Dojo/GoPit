extends CanvasLayer
## DeleteConfirmDialog - Confirmation popup for deleting a save slot

signal confirmed(slot: int)
signal cancelled

@onready var warning_label: Label = $DimBackground/Panel/VBoxContainer/WarningLabel
@onready var details_label: Label = $DimBackground/Panel/VBoxContainer/DetailsLabel
@onready var cancel_button: Button = $DimBackground/Panel/VBoxContainer/ButtonsContainer/CancelButton
@onready var confirm_button: Button = $DimBackground/Panel/VBoxContainer/ButtonsContainer/ConfirmButton

var _slot_to_delete: int = 0


func _ready() -> void:
	visible = false
	cancel_button.pressed.connect(_on_cancel_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)


func show_dialog(slot: int, preview: Dictionary) -> void:
	"""Show the delete confirmation dialog for a slot."""
	_slot_to_delete = slot
	warning_label.text = "Delete Slot %d?" % slot

	# Build details text
	var details := "This will permanently delete:"
	if not preview.is_empty():
		var coins: int = preview.get("coins", 0)
		var runs: int = preview.get("runs", 0)
		details += "\n- %s Pit Coins" % _format_number(coins)
		details += "\n- %d completed runs" % runs
		details += "\n- All progress and unlocks"
		if preview.get("has_active_session", false):
			details += "\n- Active run in progress"
	else:
		details += "\n- This save slot is empty"

	details_label.text = details
	visible = true
	get_tree().paused = true


func hide_dialog() -> void:
	visible = false
	get_tree().paused = false


func _format_number(num: int) -> String:
	var str_num := str(num)
	var result := ""
	var count := 0
	for i in range(str_num.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = str_num[i] + result
		count += 1
	return result


func _on_cancel_pressed() -> void:
	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	hide_dialog()
	cancelled.emit()


func _on_confirm_pressed() -> void:
	SoundManager.play(SoundManager.SoundType.BLOCKED)
	hide_dialog()
	confirmed.emit(_slot_to_delete)
