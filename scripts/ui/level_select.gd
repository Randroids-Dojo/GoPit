extends CanvasLayer
## Level/Stage selection screen - shown after character select

signal stage_selected(stage_index: int, difficulty_level: int)

const STAGE_COLORS := [
	Color(0.102, 0.102, 0.18),  # The Pit - dark blue
	Color(0.15, 0.25, 0.35),    # Frozen Depths - icy blue
	Color(0.35, 0.2, 0.1),      # Burning Sands - orange
	Color(0.15, 0.1, 0.2),      # Void Chasm - dark purple
	Color(0.1, 0.2, 0.08),      # Toxic Marsh - sickly green
	Color(0.08, 0.12, 0.25),    # Storm Spire - electric blue
	Color(0.15, 0.12, 0.22),    # Crystal Caverns - purple crystal
	Color(0.03, 0.03, 0.08),    # The Abyss - deepest black
]

const STAGE_ICONS := ["1", "2", "3", "4", "5", "6", "7", "8"]

var _stages: Array[Resource] = []
var _current_index: int = 0
var _dots: Array[ColorRect] = []
var _unlocked_stages: int = 1  # Start with first stage unlocked
var _selected_difficulty: int = 1  # 1-10, selected difficulty for the run
var _difficulty_buttons: Array[Button] = []

@onready var name_label: Label = $DimBackground/Panel/VBoxContainer/StagePanel/InfoContainer/NameLabel
@onready var desc_label: Label = $DimBackground/Panel/VBoxContainer/StagePanel/InfoContainer/DescLabel
@onready var portrait: ColorRect = $DimBackground/Panel/VBoxContainer/StagePanel/PortraitContainer/Portrait
@onready var portrait_label: Label = $DimBackground/Panel/VBoxContainer/StagePanel/PortraitContainer/Portrait/PortraitLabel
@onready var waves_label: Label = $DimBackground/Panel/VBoxContainer/StagePanel/InfoContainer/WavesLabel
@onready var prev_button: Button = $DimBackground/Panel/VBoxContainer/NavContainer/PrevButton
@onready var next_button: Button = $DimBackground/Panel/VBoxContainer/NavContainer/NextButton
@onready var start_button: Button = $DimBackground/Panel/VBoxContainer/StartButton
@onready var dots_container: HBoxContainer = $DimBackground/Panel/VBoxContainer/NavContainer/DotsContainer
@onready var locked_overlay: ColorRect = $DimBackground/Panel/LockedOverlay
@onready var lock_label: Label = $DimBackground/Panel/LockedOverlay/LockLabel
@onready var difficulty_container: HBoxContainer = get_node_or_null("DimBackground/Panel/VBoxContainer/DifficultySection/DifficultyContainer")
@onready var difficulty_label: Label = get_node_or_null("DimBackground/Panel/VBoxContainer/DifficultySection/DifficultyLabel")


func _ready() -> void:
	add_to_group("level_select")
	_load_stages()
	_load_progress()
	_create_dots()
	_create_difficulty_buttons()
	_connect_signals()
	_update_display()
	visible = false


func _load_stages() -> void:
	_stages = [
		preload("res://resources/biomes/the_pit.tres"),
		preload("res://resources/biomes/frozen_depths.tres"),
		preload("res://resources/biomes/burning_sands.tres"),
		preload("res://resources/biomes/final_descent.tres"),
		preload("res://resources/biomes/toxic_marsh.tres"),
		preload("res://resources/biomes/storm_spire.tres"),
		preload("res://resources/biomes/crystal_caverns.tres"),
		preload("res://resources/biomes/the_abyss.tres"),
	]


func _load_progress() -> void:
	# Gear-based unlock system: count unlocked stages based on gear requirements
	if MetaManager:
		_unlocked_stages = 1  # First stage always unlocked
		for i in range(1, _stages.size()):
			if MetaManager.is_stage_unlocked_by_gears(i):
				_unlocked_stages = i + 1
			else:
				break


func _create_dots() -> void:
	for i in range(_stages.size()):
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(12, 12)
		dot.color = Color(0.4, 0.4, 0.4)
		dots_container.add_child(dot)
		_dots.append(dot)


func _create_difficulty_buttons() -> void:
	if not difficulty_container:
		return

	for i in range(GameManager.MAX_DIFFICULTY_LEVEL):
		var level := i + 1
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(42, 42)
		btn.text = str(level)
		btn.pressed.connect(_on_difficulty_selected.bind(level))
		difficulty_container.add_child(btn)
		_difficulty_buttons.append(btn)


func _on_difficulty_selected(level: int) -> void:
	if not GameManager.is_difficulty_unlocked(level, _current_index):
		SoundManager.play(SoundManager.SoundType.BLOCKED)
		return

	_selected_difficulty = level
	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	_update_difficulty_display()


func _connect_signals() -> void:
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	start_button.pressed.connect(_on_start_pressed)


func show_select() -> void:
	visible = true
	_load_progress()  # Refresh in case progress changed
	_selected_difficulty = 1  # Reset to level 1 when opening
	_update_display()


func hide_select() -> void:
	visible = false


func _on_prev_pressed() -> void:
	_current_index = (_current_index - 1 + _stages.size()) % _stages.size()
	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	_update_display()


func _on_next_pressed() -> void:
	_current_index = (_current_index + 1) % _stages.size()
	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	_update_display()


func _on_start_pressed() -> void:
	if not _is_stage_unlocked(_current_index):
		SoundManager.play(SoundManager.SoundType.BLOCKED)
		return

	# Set the selected difficulty in GameManager before starting
	GameManager.set_difficulty_level(_selected_difficulty)

	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	stage_selected.emit(_current_index, _selected_difficulty)
	hide_select()


func _is_stage_unlocked(index: int) -> bool:
	return index < _unlocked_stages


func _update_display() -> void:
	if _stages.is_empty():
		return

	var stage: Biome = _stages[_current_index]
	var is_unlocked := _is_stage_unlocked(_current_index)

	# Update portrait
	portrait.color = STAGE_COLORS[_current_index]
	portrait_label.text = STAGE_ICONS[_current_index]

	# Update name and description
	name_label.text = stage.biome_name.to_upper()
	desc_label.text = _get_stage_description(_current_index)

	# Update waves info
	waves_label.text = "Waves: " + str(stage.waves_before_boss) + " + Boss"

	# Update dots
	for i in range(_dots.size()):
		if i == _current_index:
			_dots[i].color = Color(1, 0.9, 0.3)  # Selected
		elif i < _unlocked_stages:
			_dots[i].color = Color(0.6, 0.6, 0.6)  # Unlocked
		else:
			_dots[i].color = Color(0.3, 0.3, 0.3)  # Locked

	# Update locked overlay with gear info
	locked_overlay.visible = not is_unlocked
	if not is_unlocked:
		var prev_gears := MetaManager.get_stage_gears(_current_index - 1) if MetaManager else 0
		var needed := MetaManager.GEARS_PER_STAGE if MetaManager else 2
		lock_label.text = "LOCKED\nGears: %d/%d\nBeat %s with %d characters" % [
			prev_gears, needed,
			_stages[_current_index - 1].biome_name,
			needed - prev_gears
		]

	# Update start button
	start_button.disabled = not is_unlocked

	# Update difficulty selection (reset to highest unlocked when switching stages)
	_selected_difficulty = _get_smart_default_difficulty()
	_update_difficulty_display()


func _get_smart_default_difficulty() -> int:
	# Default to highest unlocked difficulty for this stage, capped at 1 above beaten
	var highest_beaten := MetaManager.get_highest_difficulty_for_stage(_current_index) if MetaManager else 0
	# Start at the next challenge level (or 1 if never beaten)
	return mini(highest_beaten + 1, GameManager.MAX_DIFFICULTY_LEVEL)


func _update_difficulty_display() -> void:
	if _difficulty_buttons.is_empty():
		return

	var highest_unlocked := _get_highest_unlocked_difficulty()

	# Update each difficulty button
	for i in range(_difficulty_buttons.size()):
		var level := i + 1
		var btn := _difficulty_buttons[i]
		var is_unlocked := level <= highest_unlocked

		btn.disabled = not is_unlocked

		# Style: selected, unlocked, or locked
		if level == _selected_difficulty:
			btn.modulate = Color(1, 0.9, 0.3)  # Gold for selected
		elif is_unlocked:
			btn.modulate = Color(1, 1, 1)  # Normal for unlocked
		else:
			btn.modulate = Color(0.4, 0.4, 0.4)  # Gray for locked

	# Update difficulty info label
	if difficulty_label:
		var diff_name: String = GameManager.DIFFICULTY_NAMES.get(_selected_difficulty, "Unknown")
		var hp_mult := _get_difficulty_hp_multiplier(_selected_difficulty)
		var xp_mult := _get_difficulty_xp_multiplier(_selected_difficulty)
		difficulty_label.text = "%s  (HP x%.1f, XP x%.1f)" % [diff_name, hp_mult, xp_mult]


func _get_highest_unlocked_difficulty() -> int:
	# Difficulty N is unlocked if we've beaten N-1 on this stage
	var highest_beaten := MetaManager.get_highest_difficulty_for_stage(_current_index) if MetaManager else 0
	return mini(highest_beaten + 1, GameManager.MAX_DIFFICULTY_LEVEL)


func _get_difficulty_hp_multiplier(level: int) -> float:
	if level <= 1:
		return 1.0
	return pow(GameManager.DIFFICULTY_SCALE_PER_LEVEL, level - 1)


func _get_difficulty_xp_multiplier(level: int) -> float:
	if level <= 1:
		return 1.0
	return 1.0 + (GameManager.DIFFICULTY_XP_BONUS_PER_LEVEL * (level - 1))


func _get_stage_description(index: int) -> String:
	match index:
		0: return "Where it all begins. Basic enemies and learning the ropes."
		1: return "Chilling depths with frozen foes. Ice hazards await."
		2: return "Scorching desert with fire enemies. Stay cool."
		3: return "Darkness consumes all. Void zones drain your will."
		4: return "Poisonous swamps breed deadly swarms. Watch your step."
		5: return "Lightning strikes from above. Speed is survival."
		6: return "Ancient crystals hide stone guardians. Shatter or be shattered."
		7: return "The deepest abyss. Only the strongest survive."
		_: return "Unknown territory."


func get_selected_stage() -> int:
	return _current_index


func get_selected_difficulty() -> int:
	return _selected_difficulty
