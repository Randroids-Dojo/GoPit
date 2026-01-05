extends ColorRect
## Red vignette flash on player damage + low HP warning

var flash_duration: float = 0.15
var flash_timer: float = 0.0
var max_alpha: float = 0.4

# Low HP warning state
var low_hp_threshold: float = 0.3  # 30% HP
var low_hp_pulse_speed: float = 3.0
var low_hp_min_alpha: float = 0.1
var low_hp_max_alpha: float = 0.3
var _pulse_time: float = 0.0
var _is_low_hp: bool = false


func _ready() -> void:
	color = Color(1, 0, 0, 0)  # Transparent red
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Connect to GameManager signals
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.hp_changed.connect(_on_hp_changed)


func _on_state_changed(_old: GameManager.GameState, _new: GameManager.GameState) -> void:
	# Reset on game restart
	flash_timer = 0.0
	_is_low_hp = false
	color.a = 0


func _on_hp_changed(current_hp: int, max_hp: int) -> void:
	var hp_ratio: float = float(current_hp) / float(max_hp)
	_is_low_hp = hp_ratio <= low_hp_threshold and current_hp > 0


func flash() -> void:
	flash_timer = flash_duration


func _process(delta: float) -> void:
	# Damage flash takes priority
	if flash_timer > 0:
		flash_timer -= delta
		color.a = (flash_timer / flash_duration) * max_alpha
	elif _is_low_hp:
		# Pulsing low HP warning
		_pulse_time += delta * low_hp_pulse_speed
		var pulse: float = (sin(_pulse_time * TAU) + 1.0) * 0.5
		color.a = lerpf(low_hp_min_alpha, low_hp_max_alpha, pulse)
	else:
		color.a = 0
