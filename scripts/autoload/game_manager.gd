extends Node
## GameManager autoload - handles global game state

enum GameState {
	MENU,
	PLAYING,
	LEVEL_UP,
	PAUSED,
	GAME_OVER
}

signal state_changed(old_state: GameState, new_state: GameState)
signal game_started
signal game_over
signal level_up_triggered
signal level_up_completed
signal player_damaged(amount: int)
signal wave_changed(new_wave: int)

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

# Session stats (reset each run)
var stats := {
	"enemies_killed": 0,
	"balls_fired": 0,
	"damage_dealt": 0,
	"gems_collected": 0,
	"time_survived": 0.0
}


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		stats["time_survived"] += delta


func record_enemy_kill() -> void:
	stats["enemies_killed"] += 1


func record_ball_fired() -> void:
	stats["balls_fired"] += 1


func record_damage_dealt(amount: int) -> void:
	stats["damage_dealt"] += amount


func record_gem_collected() -> void:
	stats["gems_collected"] += 1


func start_game() -> void:
	_reset_stats()
	current_state = GameState.PLAYING
	game_started.emit()


func end_game() -> void:
	current_state = GameState.GAME_OVER
	SoundManager.play(SoundManager.SoundType.GAME_OVER)
	game_over.emit()


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
	current_xp += amount
	if current_xp >= xp_to_next_level:
		trigger_level_up()


func take_damage(amount: int) -> void:
	player_hp = max(0, player_hp - amount)
	SoundManager.play(SoundManager.SoundType.PLAYER_DAMAGE)
	player_damaged.emit(amount)
	# Big screen shake on player damage
	CameraShake.shake(15.0, 3.0)
	if player_hp <= 0:
		end_game()


func heal(amount: int) -> void:
	player_hp = min(max_hp, player_hp + amount)


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
