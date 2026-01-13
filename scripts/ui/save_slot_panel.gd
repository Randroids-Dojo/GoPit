extends Panel
## SaveSlotPanel - Displays a single save slot with preview info and actions

signal slot_pressed(slot: int)
signal delete_pressed(slot: int)

@export var slot_number: int = 1

@onready var slot_label: Label = $VBoxContainer/SlotLabel
@onready var empty_label: Label = $VBoxContainer/EmptyLabel
@onready var preview_container: VBoxContainer = $VBoxContainer/PreviewContainer
@onready var coins_label: Label = $VBoxContainer/PreviewContainer/CoinsLabel
@onready var playtime_label: Label = $VBoxContainer/PreviewContainer/PlaytimeLabel
@onready var best_wave_label: Label = $VBoxContainer/PreviewContainer/BestWaveLabel
@onready var last_played_label: Label = $VBoxContainer/PreviewContainer/LastPlayedLabel
@onready var active_run_indicator: ColorRect = $VBoxContainer/PreviewContainer/ActiveRunIndicator
@onready var active_run_label: Label = $VBoxContainer/PreviewContainer/ActiveRunIndicator/ActiveRunLabel
@onready var delete_button: Button = $VBoxContainer/DeleteButton
@onready var select_button: Button = $VBoxContainer/SelectButton

var _is_empty: bool = true
var _has_active_session: bool = false
var _preview_data: Dictionary = {}


func _ready() -> void:
	delete_button.pressed.connect(_on_delete_pressed)
	select_button.pressed.connect(_on_select_pressed)
	slot_label.text = "SLOT %d" % slot_number
	_update_display()


func set_slot_data(preview: Dictionary) -> void:
	"""Update the panel with slot preview data."""
	_preview_data = preview
	_is_empty = preview.is_empty()
	_has_active_session = preview.get("has_active_session", false)
	_update_display()


func _update_display() -> void:
	if _is_empty:
		empty_label.visible = true
		preview_container.visible = false
		delete_button.visible = false
		select_button.text = "NEW GAME"
	else:
		empty_label.visible = false
		preview_container.visible = true
		delete_button.visible = true
		select_button.text = "SELECT" if not _has_active_session else "CONTINUE"

		# Update preview labels
		var coins: int = _preview_data.get("coins", 0)
		coins_label.text = "Coins: %s" % _format_number(coins)

		var playtime: float = _preview_data.get("total_playtime", 0.0)
		playtime_label.text = "Playtime: %s" % MetaManager.format_playtime(playtime)

		var best_wave: int = _preview_data.get("best_wave", 0)
		best_wave_label.text = "Best Wave: %d" % best_wave

		var last_played: String = _preview_data.get("last_played", "")
		last_played_label.text = "Last: %s" % MetaManager.format_relative_time(last_played)

		# Active run indicator
		active_run_indicator.visible = _has_active_session
		if _has_active_session:
			var session: Dictionary = _preview_data.get("session", {})
			var wave: int = session.get("current_wave", 1)
			var hp: int = session.get("player_hp", 100)
			var max_hp: int = session.get("max_hp", 100)
			active_run_label.text = "Wave %d - HP %d/%d" % [wave, hp, max_hp]


func _format_number(num: int) -> String:
	"""Format number with commas for thousands."""
	var str_num := str(num)
	var result := ""
	var count := 0
	for i in range(str_num.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = str_num[i] + result
		count += 1
	return result


func _on_delete_pressed() -> void:
	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	delete_pressed.emit(slot_number)


func _on_select_pressed() -> void:
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	slot_pressed.emit(slot_number)
