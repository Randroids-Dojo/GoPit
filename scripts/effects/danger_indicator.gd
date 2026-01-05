extends Control
## Shows pulsing red indicator at bottom of screen when enemies are near

var danger_count: int = 0
var pulse_tween: Tween

@onready var indicator: ColorRect = $Indicator


func _ready() -> void:
	indicator.color = Color(1, 0, 0, 0)


func add_danger() -> void:
	danger_count += 1
	if danger_count == 1:
		_start_pulsing()


func remove_danger() -> void:
	danger_count = maxi(0, danger_count - 1)
	if danger_count == 0:
		_stop_pulsing()


func reset() -> void:
	danger_count = 0
	_stop_pulsing()


func _start_pulsing() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(indicator, "color:a", 0.5, 0.3)
	pulse_tween.tween_property(indicator, "color:a", 0.2, 0.3)


func _stop_pulsing() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	var fade := create_tween()
	fade.tween_property(indicator, "color:a", 0.0, 0.2)
