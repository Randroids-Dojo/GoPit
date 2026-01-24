extends CanvasLayer
## Character selection screen - shown before game starts
## Supports 2-character mode when Matchmaker building is unlocked

signal character_selected(character: Resource)
signal dual_character_selected(primary: Resource, secondary: Resource)

const CHARACTER_PATHS := [
	"res://resources/characters/rookie.tres",
	"res://resources/characters/pyro.tres",
	"res://resources/characters/frost_mage.tres",
	"res://resources/characters/tactician.tres",
	"res://resources/characters/gambler.tres",
	"res://resources/characters/vampire.tres",
	"res://resources/characters/warrior.tres",
	"res://resources/characters/shade.tres",
	"res://resources/characters/broodmother.tres",
	"res://resources/characters/empty_nester.tres",
	"res://resources/characters/collector.tres",
	"res://resources/characters/repentant.tres",
	"res://resources/characters/physicist.tres",
	"res://resources/characters/shieldbearer.tres",
	"res://resources/characters/plague_doctor.tres",
	"res://resources/characters/berserker.tres"
]

const BALL_TYPE_NAMES := ["Basic Ball", "Fire Ball", "Ice Ball", "Lightning Ball", "Poison Ball", "Bleed Ball", "Iron Ball"]
const PORTRAIT_COLORS := [
	Color(0.3, 0.5, 0.7),  # Rookie - blue
	Color(0.8, 0.3, 0.1),  # Pyro - orange
	Color(0.4, 0.7, 0.9),  # Frost - cyan
	Color(0.5, 0.5, 0.6),  # Tactician - gray
	Color(0.7, 0.5, 0.8),  # Gambler - purple
	Color(0.5, 0.2, 0.2),  # Vampire - dark red
	Color(0.6, 0.3, 0.2),  # Warrior - brown-red
	Color(0.2, 0.1, 0.3),  # Shade - dark purple
	Color(0.3, 0.5, 0.2),  # Broodmother - green
	Color(0.3, 0.3, 0.35), # Empty Nester - charcoal
	Color(0.8, 0.7, 0.2),  # Collector - gold
	Color(0.5, 0.4, 0.3),  # Repentant - brown
	Color(0.2, 0.3, 0.6),  # Physicist - deep blue
	Color(0.6, 0.6, 0.7),  # Shieldbearer - silver
	Color(0.3, 0.5, 0.3),  # Plague Doctor - sickly green
	Color(0.7, 0.2, 0.2),  # Berserker - blood red
]
const PORTRAIT_EMOJIS := ["R", "P", "F", "T", "G", "V", "W", "S", "B", "E", "C", "Re", "Ph", "Sh", "PD", "Be"]

var _characters: Array[Resource] = []
var _current_index: int = 0
var _dots: Array[ColorRect] = []

# Dual character mode (Matchmaker building)
var _selecting_secondary: bool = false
var _primary_character: Resource = null
var _primary_index: int = -1

@onready var name_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/NameLabel
@onready var desc_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/DescLabel
@onready var portrait: ColorRect = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/PortraitContainer/Portrait
@onready var portrait_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/PortraitContainer/Portrait/PortraitLabel
@onready var hp_bar: ProgressBar = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/HPStat/Bar
@onready var str_bar: ProgressBar = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/DMGStat/Bar
@onready var str_grade_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/DMGStat/GradeLabel
@onready var spd_bar: ProgressBar = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/SPDStat/Bar
@onready var crit_bar: ProgressBar = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/CRITStat/Bar
@onready var team_bar: ProgressBar = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/StatsContainer/TEAMStat/Bar
@onready var passive_name_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/AbilityPanel/VBoxContainer/PassiveName
@onready var passive_desc_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/AbilityPanel/VBoxContainer/PassiveDesc
@onready var ball_label: Label = $DimBackground/Panel/VBoxContainer/CharacterPanel/HBoxContainer/InfoContainer/AbilityPanel/VBoxContainer/BallLabel
@onready var prev_button: Button = $DimBackground/Panel/VBoxContainer/NavContainer/PrevButton
@onready var next_button: Button = $DimBackground/Panel/VBoxContainer/NavContainer/NextButton
@onready var start_button: Button = $DimBackground/Panel/VBoxContainer/StartButton
@onready var dots_container: HBoxContainer = $DimBackground/Panel/VBoxContainer/NavContainer/DotsContainer
@onready var locked_overlay: ColorRect = $DimBackground/Panel/LockedOverlay
@onready var lock_label: Label = $DimBackground/Panel/LockedOverlay/LockLabel

# Dual character UI (created dynamically)
var _partner_button: Button = null
var _solo_button: Button = null
var _partner_label: Label = null


func _ready() -> void:
	add_to_group("character_select")
	_load_characters()
	_create_dots()
	_create_dual_character_ui()
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


func _create_dual_character_ui() -> void:
	# Guard against missing start button (required for positioning)
	if not start_button:
		return

	# Create partner selection label (shows selected primary character)
	_partner_label = Label.new()
	_partner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_partner_label.add_theme_font_size_override("font_size", 16)
	_partner_label.visible = false

	# Create "Add Partner" button
	_partner_button = Button.new()
	_partner_button.text = "+ ADD PARTNER"
	_partner_button.custom_minimum_size = Vector2(200, 50)
	_partner_button.visible = false
	_partner_button.pressed.connect(_on_partner_button_pressed)

	# Create "Play Solo" button (for when selecting secondary)
	_solo_button = Button.new()
	_solo_button.text = "PLAY SOLO"
	_solo_button.custom_minimum_size = Vector2(200, 50)
	_solo_button.visible = false
	_solo_button.pressed.connect(_on_solo_button_pressed)

	# Add to container (above start button)
	var vbox := start_button.get_parent()
	var start_idx := start_button.get_index()
	vbox.add_child(_partner_label)
	vbox.move_child(_partner_label, start_idx)
	vbox.add_child(_partner_button)
	vbox.move_child(_partner_button, start_idx + 1)
	vbox.add_child(_solo_button)
	vbox.move_child(_solo_button, start_idx + 2)


func _connect_signals() -> void:
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	start_button.pressed.connect(_on_start_pressed)


func show_select() -> void:
	visible = true
	get_tree().paused = true
	# Reset dual character state
	_selecting_secondary = false
	_primary_character = null
	_primary_index = -1
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
	if not MetaManager.is_character_unlocked(character.character_name):
		SoundManager.play(SoundManager.SoundType.BLOCKED)
		return

	SoundManager.play(SoundManager.SoundType.LEVEL_UP)  # Start game sound

	if _selecting_secondary:
		# Selected second character - start dual character run
		dual_character_selected.emit(_primary_character, character)
	else:
		# Single character run
		character_selected.emit(character)
	hide_select()


func _on_partner_button_pressed() -> void:
	"""Switch to secondary character selection mode."""
	var character := _characters[_current_index]
	if not MetaManager.is_character_unlocked(character.character_name):
		SoundManager.play(SoundManager.SoundType.BLOCKED)
		return

	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	_primary_character = character
	_primary_index = _current_index
	_selecting_secondary = true
	# Move to a different character by default
	_current_index = (_current_index + 1) % _characters.size()
	_update_display()


func _on_solo_button_pressed() -> void:
	"""Cancel partner selection and go back to primary selection."""
	SoundManager.play(SoundManager.SoundType.HIT_WALL)
	_selecting_secondary = false
	_current_index = _primary_index if _primary_index >= 0 else 0
	_primary_character = null
	_primary_index = -1
	_update_display()


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
	str_bar.value = character.base_strength  # Show actual Strength value (5-15)
	str_grade_label.text = character.get_strength_scaling_grade()  # Show scaling grade (S/A/B/C/D/E)
	spd_bar.value = character.speed
	crit_bar.value = character.dexterity
	team_bar.value = character.leadership

	# Update ability info
	passive_name_label.text = "Passive: " + character.passive_name
	passive_desc_label.text = character.passive_description

	var ball_index: int = mini(character.starting_ball, BALL_TYPE_NAMES.size() - 1)
	ball_label.text = "Starting: " + BALL_TYPE_NAMES[ball_index]

	# Update dots
	for i in range(_dots.size()):
		_dots[i].color = Color(1, 0.9, 0.3) if i == _current_index else Color(0.4, 0.4, 0.4)

	# Update locked overlay - use MetaManager for dynamic unlock tracking
	var is_unlocked := MetaManager.is_character_unlocked(character.character_name)
	locked_overlay.visible = not is_unlocked
	if not is_unlocked:
		var progress := MetaManager.get_unlock_progress(character.character_name)
		if progress.is_empty():
			lock_label.text = "LOCKED\n" + character.unlock_requirement
		else:
			# Show progress toward unlock (e.g., "Wave 15/20")
			var progress_text := ""
			match progress["type"]:
				"wave":
					progress_text = "Wave %d/%d" % [progress["current"], progress["required"]]
				"stage":
					progress_text = "Stage %d/%d" % [progress["current"], progress["required"]]
				"runs":
					progress_text = "Runs %d/%d" % [progress["current"], progress["required"]]
			lock_label.text = "LOCKED\n" + character.unlock_requirement + "\n(" + progress_text + ")"

	# Update start button
	start_button.disabled = not is_unlocked

	# Update dual character UI
	_update_dual_character_ui(character, is_unlocked)


func _update_dual_character_ui(character: Resource, is_unlocked: bool) -> void:
	"""Update visibility and state of dual character UI elements."""
	# Guard against missing dynamic UI elements
	if not _partner_label or not _partner_button or not _solo_button:
		return

	var matchmaker_available := MetaManager.is_matchmaker_unlocked()

	if _selecting_secondary:
		# Selecting partner - show partner info and different buttons
		_partner_label.visible = true
		_partner_label.text = "Primary: %s" % _primary_character.character_name
		_partner_button.visible = false
		_solo_button.visible = true

		# Can't select same character as partner
		var is_same := _current_index == _primary_index
		start_button.text = "START DUO"
		start_button.disabled = not is_unlocked or is_same
		if is_same:
			lock_label.text = "Cannot select same character"
			locked_overlay.visible = true
	else:
		# Normal selection - show partner button if matchmaker unlocked
		_partner_label.visible = false
		_partner_button.visible = matchmaker_available and is_unlocked
		_solo_button.visible = false
		start_button.text = "START"


func get_selected_character() -> Resource:
	if _characters.is_empty():
		return null
	return _characters[_current_index]
