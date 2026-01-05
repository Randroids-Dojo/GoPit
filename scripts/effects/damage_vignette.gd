extends ColorRect
## Red vignette flash on player damage

var flash_duration: float = 0.15
var flash_timer: float = 0.0
var max_alpha: float = 0.4


func _ready() -> void:
	color = Color(1, 0, 0, 0)  # Transparent red
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Connect to GameManager damage signal
	GameManager.state_changed.connect(_on_state_changed)


func _on_state_changed(_old: GameManager.GameState, _new: GameManager.GameState) -> void:
	# Reset on game restart
	flash_timer = 0.0
	color.a = 0


func flash() -> void:
	flash_timer = flash_duration


func _process(delta: float) -> void:
	if flash_timer > 0:
		flash_timer -= delta
		color.a = (flash_timer / flash_duration) * max_alpha
	else:
		color.a = 0
