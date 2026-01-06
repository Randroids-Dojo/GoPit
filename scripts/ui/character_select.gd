extends CanvasLayer
## Character selection screen - shown before game starts

signal character_selected(character: Resource)

const CHARACTER_PATHS := [
	"res://resources/characters/rookie.tres",
	"res://resources/characters/pyro.tres",
	"res://resources/characters/frost_mage.tres",
	"res://resources/characters/tactician.tres",
	"res://resources/characters/gambler.tres",
	"res://resources/characters/vampire.tres"
]

const BALL_TYPE_NAMES := ["Basic Ball", "Fire Ball", "Ice Ball", "Lightning Ball"]
const PORTRAIT_COLORS := [
	Color(0.3, 0.5, 0.7),  # Rookie - blue
	Color(0.8, 0.3, 0.1),  # Pyro - orange
	Color(0.4, 0.7, 0.9),  # Frost - cyan
	Color(0.5, 0.5, 0.6),  # Tactician - gray
	Color(0.7, 0.5, 0.8),  # Gambler - purple
	Color(0.5, 0.2, 0.2),  # Vampire - dark red
]
const PORTRAIT_EMOJIS := ["R", "P", "F", "T", "G", "V"]

var _characters: Array[Resource] = []
var _current_index: int = 0
var _dots: Array[ColorRect] = []

@onready var name_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/NameLabel
@onready var desc_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/DescLabel
@onready var portrait: ColorRect = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/PortraitContainer/Portrait
@onready var portrait_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/PortraitContainer/Portrait/PortraitLabel
@onready var hp_bar: ProgressBar = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/HPStat/Bar
@onready var dmg_bar: ProgressBar = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/DMGStat/Bar
@onready var spd_bar: ProgressBar = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/SPDStat/Bar
@onready var crit_bar: ProgressBar = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/CRITStat/Bar
@onready var passive_name_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/AbilityPanel/VBoxContainer/PassiveName
@onready var passive_desc_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/AbilityPanel/VBoxContainer/PassiveDesc
@onready var ball_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/AbilityPanel/VBoxContainer/BallLabel
@onready var prev_button: Button = $DimBackground/Panel/VBoxContainer/NavContainer/PrevButton
@onready var next_button: Button = $DimBackground/Panel/VBoxContainer/NavContainer/NextButton
@onready var start_button: Button = $DimBackground/Panel/VBoxContainer/StartButton
@onready var dots_container: HBoxContainer = $DimBackground/Panel/VBoxContainer/NavContainer/DotsContainer
@onready var locked_overlay: ColorRect = $DimBackground/Panel/LockedOverlay
@onready var lock_label: Label = $DimBackground/Panel/LockedOverlay/LockLabel


func _ready() -> void:
	add_to_group("character_select")
	_load_characters()
	_create_dots()
	_connect_signals()
	_update_display()
	visible = false


func _load_characters() -> void:
	for path in CHARACTER_PATHS:
		var character := load(path) as Resource
		if character:
			_characters.append(character)


func _create_dots() -> void:
	for i in range(_characters.size()):
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(12, 12)
		dot.color = Color(0.4, 0.4, 0.4)
		dots_container.add_child(dot)
		_dots.append(dot)


func _connect_signals() -> void:
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	start_button.pressed.connect(_on_start_pressed)


func show_select() -> void:
	visible = true
	get_tree().paused = true
	_update_display()


func hide_select() -> void:
	visible = false
	get_tree().paused = false


func _on_prev_pressed() -> void:
	_current_index = (_current_index - 1 + _characters.size()) % _characters.size()
	SoundManager.play(SoundManager.SoundType.HIT_WALL)  # UI navigation sound
	_update_display()


func _on_next_pressed() -> void:
	_current_index = (_current_index + 1) % _characters.size()
	SoundManager.play(SoundManager.SoundType.HIT_WALL)  # UI navigation sound
	_update_display()


func _on_start_pressed() -> void:
	var character := _characters[_current_index]
	if not character.is_unlocked:
		SoundManager.play(SoundManager.SoundType.BLOCKED)
		return

	SoundManager.play(SoundManager.SoundType.LEVEL_UP)  # Start game sound
	character_selected.emit(character)
	hide_select()


func _update_display() -> void:
	if _characters.is_empty():
		return

	var character := _characters[_current_index]

	# Update portrait
	portrait.color = PORTRAIT_COLORS[_current_index]
	portrait_label.text = PORTRAIT_EMOJIS[_current_index]

	# Update name and description
	name_label.text = character.character_name.to_upper()
	desc_label.text = character.description

	# Update stat bars
	hp_bar.value = character.endurance
	dmg_bar.value = character.strength
	spd_bar.value = character.speed
	crit_bar.value = character.dexterity

	# Update ability info
	passive_name_label.text = "Passive: " + character.passive_name
	passive_desc_label.text = character.passive_description

	var ball_index: int = mini(character.starting_ball, BALL_TYPE_NAMES.size() - 1)
	ball_label.text = "Starting: " + BALL_TYPE_NAMES[ball_index]

	# Update dots
	for i in range(_dots.size()):
		_dots[i].color = Color(1, 0.9, 0.3) if i == _current_index else Color(0.4, 0.4, 0.4)

	# Update locked overlay
	locked_overlay.visible = not character.is_unlocked
	if not character.is_unlocked:
		lock_label.text = "LOCKED\n" + character.unlock_requirement

	# Update start button
	start_button.disabled = not character.is_unlocked


func get_selected_character() -> Resource:
	if _characters.is_empty():
		return null
	return _characters[_current_index]
