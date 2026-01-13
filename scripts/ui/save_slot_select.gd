extends CanvasLayer
## SaveSlotSelect - Main menu for selecting save slots

signal slot_selected(slot: int)

@onready var slot1_panel: Panel = $DimBackground/Panel/VBoxContainer/SlotsContainer/Slot1Panel
@onready var slot2_panel: Panel = $DimBackground/Panel/VBoxContainer/SlotsContainer/Slot2Panel
@onready var slot3_panel: Panel = $DimBackground/Panel/VBoxContainer/SlotsContainer/Slot3Panel
@onready var delete_dialog: CanvasLayer = $DeleteConfirmDialog
@onready var resume_dialog: CanvasLayer = $ResumeRunDialog

var _panels: Array[Panel] = []
var _selected_slot: int = 0
var _pending_session_preview: Dictionary = {}


func _ready() -> void:
	add_to_group("save_slot_select")
	visible = false

	_panels = [slot1_panel, slot2_panel, slot3_panel]

	# Connect panel signals
	for i in range(_panels.size()):
		var panel := _panels[i]
		panel.slot_number = i + 1
		panel.slot_pressed.connect(_on_slot_pressed)
		panel.delete_pressed.connect(_on_delete_pressed)

	# Connect dialog signals
	delete_dialog.confirmed.connect(_on_delete_confirmed)
	delete_dialog.cancelled.connect(_on_delete_cancelled)
	resume_dialog.continue_chosen.connect(_on_continue_chosen)
	resume_dialog.new_game_chosen.connect(_on_new_game_chosen)


func show_select() -> void:
	"""Show the save slot selection screen."""
	visible = true
	get_tree().paused = true
	_refresh_all_slots()


func hide_select() -> void:
	"""Hide the save slot selection screen."""
	visible = false
	get_tree().paused = false


func _refresh_all_slots() -> void:
	"""Refresh preview data for all slots."""
	for i in range(MetaManager.SLOT_COUNT):
		var slot := i + 1
		var preview := MetaManager.get_slot_preview(slot)
		_panels[i].set_slot_data(preview)


func _on_slot_pressed(slot: int) -> void:
	"""Handle slot selection."""
	_selected_slot = slot

	# Check if slot has active session
	var preview := MetaManager.get_slot_preview(slot)
	if preview.get("has_active_session", false):
		_pending_session_preview = preview.get("session", {})
		resume_dialog.show_dialog(_pending_session_preview)
	else:
		# No active session - proceed directly
		_complete_slot_selection(false)


func _on_delete_pressed(slot: int) -> void:
	"""Show delete confirmation for a slot."""
	var preview := MetaManager.get_slot_preview(slot)
	delete_dialog.show_dialog(slot, preview)


func _on_delete_confirmed(slot: int) -> void:
	"""Handle confirmed deletion."""
	MetaManager.delete_slot(slot)
	_refresh_all_slots()


func _on_delete_cancelled() -> void:
	"""Handle cancelled deletion."""
	pass  # Nothing to do


func _on_continue_chosen() -> void:
	"""Handle choosing to continue existing run."""
	_complete_slot_selection(true)


func _on_new_game_chosen() -> void:
	"""Handle choosing to start fresh (discard existing run)."""
	# Clear the session before proceeding
	MetaManager.set_active_slot(_selected_slot)
	MetaManager.clear_session()
	hide_select()
	slot_selected.emit(_selected_slot)


func _complete_slot_selection(has_active_session: bool) -> void:
	"""Complete the slot selection process."""
	MetaManager.set_active_slot(_selected_slot)
	hide_select()

	if has_active_session:
		# Signal with negative slot to indicate session restore
		slot_selected.emit(-_selected_slot)
	else:
		slot_selected.emit(_selected_slot)
