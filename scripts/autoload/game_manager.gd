extends Node
## GameManager autoload - handles global game state

enum GameState {
	MENU,
	PLAYING,
	LEVEL_UP,
	PAUSED,
	GAME_OVER,
	VICTORY
}

signal state_changed(old_state: GameState, new_state: GameState)
signal game_started
signal game_over
signal game_victory
signal level_up_triggered
signal level_up_completed
signal player_damaged(amount: int)
signal wave_changed(new_wave: int)
signal hp_changed(current_hp: int, max_hp: int)
signal combo_changed(combo: int, multiplier: float)
signal leadership_changed(new_value: float)
signal ultimate_ready
signal ultimate_used
signal ultimate_charge_changed(current: float, max_val: float)

# Combo system
var combo_count: int = 0
var combo_timer: float = 0.0
var combo_timeout: float = 2.0  # Seconds before combo resets

var current_state: GameState = GameState.MENU:
	set(value):
		if value != current_state:
			var old_state = current_state
			current_state = value
			_on_state_changed(old_state, value)

var player_hp: int = 100
var max_hp: int = 100
var current_wave: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100
var player_level: int = 1
var gem_magnetism_range: float = 0.0
var leadership: float = 0.0  # Affects baby ball spawn rate

# Ultimate ability system
const ULTIMATE_CHARGE_MAX: float = 100.0
const CHARGE_PER_KILL: float = 10.0
const CHARGE_PER_GEM: float = 5.0
var ultimate_charge: float = 0.0

# Character system
var selected_character: Resource = null
var character_damage_mult: float = 1.0
var character_speed_mult: float = 1.0
var character_crit_mult: float = 1.0
var character_leadership_mult: float = 1.0
var character_intelligence_mult: float = 1.0
var character_starting_ball: int = 0  # BallType enum

# Passive ability flags (set based on selected character)
enum Passive { NONE, QUICK_LEARNER, SHATTER, JACKPOT, INFERNO, SQUAD_LEADER, LIFESTEAL }
var active_passive: Passive = Passive.NONE

# High score persistence
var high_score_wave: int = 0
var high_score_level: int = 0
var total_victories: int = 0
var is_endless_mode: bool = false  # True after victory if player continues
const HIGH_SCORE_PATH := "user://high_score.save"

# Session stats (reset each run)
var stats := {
	"enemies_killed": 0,
	"balls_fired": 0,
	"damage_dealt": 0,
	"gems_collected": 0,
	"time_survived": 0.0
}


func _ready() -> void:
	_load_high_scores()


func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		stats["time_survived"] += delta
		# Update combo timer
		if combo_count > 0:
			combo_timer -= delta
			if combo_timer <= 0:
				_reset_combo()


func record_enemy_kill() -> void:
	stats["enemies_killed"] += 1
	_increment_combo()


func _increment_combo() -> void:
	combo_count += 1
	combo_timer = combo_timeout
	combo_changed.emit(combo_count, get_combo_multiplier())


func _reset_combo() -> void:
	if combo_count > 0:
		combo_count = 0
		combo_timer = 0.0
		combo_changed.emit(combo_count, 1.0)


func get_combo_multiplier() -> float:
	# 1x at 1-2 combo, 1.5x at 3-4, 2x at 5+
	if combo_count >= 5:
		return 2.0
	elif combo_count >= 3:
		return 1.5
	return 1.0


func record_ball_fired() -> void:
	stats["balls_fired"] += 1


func record_damage_dealt(amount: int) -> void:
	stats["damage_dealt"] += amount
	# Lifesteal passive: heal 5% of damage dealt
	var lifesteal := get_lifesteal_percent()
	if lifesteal > 0:
		var heal_amount := int(amount * lifesteal)
		if heal_amount > 0:
			heal(heal_amount)


func record_gem_collected() -> void:
	stats["gems_collected"] += 1


func set_character(character: Resource) -> void:
	if character == null:
		_reset_character_stats()
		return

	selected_character = character
	# Apply character stat multipliers
	max_hp = int(100 * character.endurance)
	character_damage_mult = character.strength
	character_speed_mult = character.speed
	character_crit_mult = character.dexterity
	character_leadership_mult = character.leadership
	character_intelligence_mult = character.intelligence
	character_starting_ball = character.starting_ball

	# Set active passive based on character
	_set_passive_from_name(character.passive_name)


## Valid passive names mapped to enum values
const VALID_PASSIVES := {
	"Quick Learner": Passive.QUICK_LEARNER,
	"Shatter": Passive.SHATTER,
	"Jackpot": Passive.JACKPOT,
	"Inferno": Passive.INFERNO,
	"Squad Leader": Passive.SQUAD_LEADER,
	"Lifesteal": Passive.LIFESTEAL
}


func _set_passive_from_name(passive_name: String) -> void:
	if passive_name.is_empty():
		active_passive = Passive.NONE
		return

	if passive_name in VALID_PASSIVES:
		active_passive = VALID_PASSIVES[passive_name]
	else:
		# Log warning for unrecognized passive name (likely a typo in Character resource)
		push_warning("GameManager: Unrecognized passive name '%s'. Check Character resource for typos. Valid passives: %s" % [passive_name, VALID_PASSIVES.keys()])
		active_passive = Passive.NONE


func _reset_character_stats() -> void:
	selected_character = null
	max_hp = 100
	character_damage_mult = 1.0
	character_speed_mult = 1.0
	character_crit_mult = 1.0
	character_leadership_mult = 1.0
	character_intelligence_mult = 1.0
	character_starting_ball = 0
	active_passive = Passive.NONE


func start_game() -> void:
	_reset_stats()
	current_state = GameState.PLAYING
	game_started.emit()


func end_game() -> void:
	current_state = GameState.GAME_OVER
	SoundManager.play(SoundManager.SoundType.GAME_OVER)
	_check_high_scores()
	game_over.emit()


func trigger_victory() -> void:
	current_state = GameState.VICTORY
	total_victories += 1
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)  # Victory sound
	_check_high_scores()
	_save_high_scores()
	game_victory.emit()


func enable_endless_mode() -> void:
	## Called when player chooses to continue after victory
	is_endless_mode = true
	current_state = GameState.PLAYING


func trigger_level_up() -> void:
	current_state = GameState.LEVEL_UP
	SoundManager.play(SoundManager.SoundType.LEVEL_UP)
	level_up_triggered.emit()


func complete_level_up() -> void:
	player_level += 1
	current_xp = 0
	xp_to_next_level = _calculate_xp_requirement(player_level)
	current_state = GameState.PLAYING
	level_up_completed.emit()


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		get_tree().paused = false
		current_state = GameState.PLAYING


func return_to_menu() -> void:
	get_tree().paused = false
	current_state = GameState.MENU


func add_xp(amount: int) -> void:
	var final_xp: int = int(amount * get_combo_multiplier() * get_xp_multiplier())
	current_xp += final_xp
	if current_xp >= xp_to_next_level:
		trigger_level_up()


func take_damage(amount: int) -> void:
	player_hp = max(0, player_hp - amount)
	SoundManager.play(SoundManager.SoundType.PLAYER_DAMAGE)
	player_damaged.emit(amount)
	hp_changed.emit(player_hp, max_hp)
	# Reset combo on damage
	_reset_combo()
	# Big screen shake on player damage
	CameraShake.shake(15.0, 3.0)
	if player_hp <= 0:
		end_game()


func heal(amount: int) -> void:
	player_hp = min(max_hp, player_hp + amount)
	hp_changed.emit(player_hp, max_hp)


func add_leadership(amount: float) -> void:
	leadership += amount
	leadership_changed.emit(leadership)


# === Ultimate ability methods ===

func add_ultimate_charge(amount: float) -> void:
	## Add charge to the ultimate meter. Emits ultimate_ready when full.
	if ultimate_charge >= ULTIMATE_CHARGE_MAX:
		return  # Already full

	var was_ready := ultimate_charge >= ULTIMATE_CHARGE_MAX
	ultimate_charge = minf(ULTIMATE_CHARGE_MAX, ultimate_charge + amount)
	ultimate_charge_changed.emit(ultimate_charge, ULTIMATE_CHARGE_MAX)

	if not was_ready and ultimate_charge >= ULTIMATE_CHARGE_MAX:
		ultimate_ready.emit()


func use_ultimate() -> bool:
	## Attempt to use the ultimate ability. Returns true if successful.
	if ultimate_charge >= ULTIMATE_CHARGE_MAX:
		ultimate_charge = 0.0
		ultimate_used.emit()
		ultimate_charge_changed.emit(0.0, ULTIMATE_CHARGE_MAX)
		return true
	return false


func is_ultimate_ready() -> bool:
	return ultimate_charge >= ULTIMATE_CHARGE_MAX


# === Passive ability helpers ===

func get_xp_multiplier() -> float:
	## Returns XP multiplier (Quick Learner: +10%)
	if active_passive == Passive.QUICK_LEARNER:
		return 1.1
	return 1.0


func get_crit_damage_multiplier() -> float:
	## Returns crit damage multiplier (Jackpot: 3x instead of 2x)
	if active_passive == Passive.JACKPOT:
		return 3.0
	return 2.0


func get_bonus_crit_chance() -> float:
	## Returns bonus crit chance (Jackpot: +15%)
	if active_passive == Passive.JACKPOT:
		return 0.15
	return 0.0


func get_fire_damage_multiplier() -> float:
	## Returns fire damage multiplier (Inferno: +20%)
	if active_passive == Passive.INFERNO:
		return 1.2
	return 1.0


func get_damage_vs_burning() -> float:
	## Returns damage multiplier vs burning enemies (Inferno: +25%)
	if active_passive == Passive.INFERNO:
		return 1.25
	return 1.0


func get_damage_vs_bleeding() -> float:
	## Returns damage multiplier vs bleeding enemies (base +15%)
	return 1.15


func get_damage_vs_frozen() -> float:
	## Returns damage multiplier vs frozen enemies (base +25%, Shatter: +50%)
	if active_passive == Passive.SHATTER:
		return 1.5
	return 1.25  # Frozen enemies always take +25% more damage


func get_freeze_duration_bonus() -> float:
	## Returns freeze duration bonus multiplier (Shatter: +30%)
	if active_passive == Passive.SHATTER:
		return 1.3
	return 1.0


func get_lifesteal_percent() -> float:
	## Returns lifesteal percentage (Lifesteal: 5%)
	if active_passive == Passive.LIFESTEAL:
		return 0.05
	return 0.0


func get_health_gem_chance() -> float:
	## Returns chance for health gem on kill (Lifesteal: 20%)
	if active_passive == Passive.LIFESTEAL:
		return 0.2
	return 0.0


func get_extra_baby_balls() -> int:
	## Returns starting baby ball count bonus (Squad Leader: +2)
	if active_passive == Passive.SQUAD_LEADER:
		return 2
	return 0


func get_baby_ball_rate_bonus() -> float:
	## Returns baby ball spawn rate bonus (Squad Leader: +30%)
	if active_passive == Passive.SQUAD_LEADER:
		return 0.3
	return 0.0


func advance_wave() -> void:
	current_wave += 1
	wave_changed.emit(current_wave)


func _reset_stats() -> void:
	player_hp = max_hp
	current_wave = 1
	current_xp = 0
	player_level = 1
	xp_to_next_level = _calculate_xp_requirement(player_level)
	gem_magnetism_range = 0.0
	leadership = 0.0
	is_endless_mode = false
	ultimate_charge = 0.0
	# Reset session stats
	stats["enemies_killed"] = 0
	stats["balls_fired"] = 0
	stats["damage_dealt"] = 0
	stats["gems_collected"] = 0
	stats["time_survived"] = 0.0


func _calculate_xp_requirement(level: int) -> int:
	return 100 + (level - 1) * 50


func _on_state_changed(old_state: GameState, new_state: GameState) -> void:
	state_changed.emit(old_state, new_state)


func _load_high_scores() -> void:
	if not FileAccess.file_exists(HIGH_SCORE_PATH):
		return

	var file := FileAccess.open(HIGH_SCORE_PATH, FileAccess.READ)
	if not file:
		return

	var data = JSON.parse_string(file.get_as_text())
	if data:
		high_score_wave = data.get("wave", 0)
		high_score_level = data.get("level", 0)
		total_victories = data.get("victories", 0)


func _check_high_scores() -> void:
	var is_new_high_score := false

	if current_wave > high_score_wave:
		high_score_wave = current_wave
		is_new_high_score = true

	if player_level > high_score_level:
		high_score_level = player_level
		is_new_high_score = true

	if is_new_high_score:
		_save_high_scores()


func _save_high_scores() -> void:
	var data := {
		"wave": high_score_wave,
		"level": high_score_level,
		"victories": total_victories
	}

	var file := FileAccess.open(HIGH_SCORE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
