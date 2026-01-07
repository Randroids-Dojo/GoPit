extends Control
## Boss HP Bar - displays boss name, HP bar with phase markers

signal boss_bar_hidden

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var hp_bar: ProgressBar = $VBoxContainer/HPBarContainer/HPBar
@onready var hp_label: Label = $VBoxContainer/HPBarContainer/HPBar/HPLabel
@onready var phase_container: HBoxContainer = $VBoxContainer/PhaseContainer

var _boss: Node = null
var _phase_markers: Array[TextureRect] = []
var _is_showing: bool = false


func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if _boss and is_instance_valid(_boss) and _is_showing:
		_update_hp()


func show_boss(boss: Node) -> void:
	if not boss:
		return

	_boss = boss
	_is_showing = true

	# Set boss name
	if name_label and boss.has_method("get") and boss.get("boss_name"):
		name_label.text = boss.boss_name
	elif name_label:
		name_label.text = "BOSS"

	# Setup phase markers
	_setup_phase_markers()

	# Connect to boss signals
	if boss.has_signal("phase_changed"):
		if not boss.phase_changed.is_connected(_on_phase_changed):
			boss.phase_changed.connect(_on_phase_changed)
	if boss.has_signal("boss_defeated"):
		if not boss.boss_defeated.is_connected(_on_boss_defeated):
			boss.boss_defeated.connect(_on_boss_defeated)

	# Initial HP update
	_update_hp()

	# Animate in
	visible = true
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)


func hide_boss() -> void:
	_is_showing = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		visible = false
		_boss = null
		boss_bar_hidden.emit()
	)


func _update_hp() -> void:
	if not _boss or not is_instance_valid(_boss):
		return

	var current_hp: int = _boss.hp if _boss.get("hp") != null else 0
	var max_hp_val: int = _boss.max_hp if _boss.get("max_hp") != null else 100

	if hp_bar:
		hp_bar.max_value = max_hp_val
		hp_bar.value = current_hp

	if hp_label:
		hp_label.text = "%d/%d" % [current_hp, max_hp_val]


func _setup_phase_markers() -> void:
	if not phase_container:
		return

	# Clear existing markers
	for marker in _phase_markers:
		marker.queue_free()
	_phase_markers.clear()

	if not _boss:
		return

	var phase_count: int = 3  # Default
	if _boss.has_method("get_phase_count"):
		phase_count = _boss.get_phase_count()

	# Create phase indicator circles
	for i in phase_count:
		var marker := TextureRect.new()
		marker.custom_minimum_size = Vector2(20, 20)
		marker.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		# Create a simple colored rect as placeholder
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.3, 0.3, 0.3)
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_left = 10
		style.corner_radius_bottom_right = 10

		# Use a Panel for the circle visual
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(20, 20)
		panel.add_theme_stylebox_override("panel", style)
		panel.name = "PhaseMarker_%d" % i

		phase_container.add_child(panel)
		# Store reference for updating
		_phase_markers.append(marker)

	_update_phase_markers()


func _update_phase_markers() -> void:
	if not _boss or not phase_container:
		return

	var current_phase_idx: int = -1
	if _boss.has_method("get_current_phase_index"):
		current_phase_idx = _boss.get_current_phase_index()

	for i in phase_container.get_child_count():
		var panel := phase_container.get_child(i) as Panel
		if not panel:
			continue

		var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
		if not style:
			continue

		# Color based on phase state
		if i < current_phase_idx:
			# Completed phase - dim
			style.bg_color = Color(0.2, 0.2, 0.2)
		elif i == current_phase_idx:
			# Current phase - bright red
			style.bg_color = Color(0.9, 0.2, 0.2)
		else:
			# Future phase - yellow
			style.bg_color = Color(0.8, 0.7, 0.2)


func _on_phase_changed(_new_phase) -> void:
	_update_phase_markers()

	# Flash effect on phase change
	var tween := create_tween()
	tween.tween_property(hp_bar, "modulate", Color(2.0, 2.0, 2.0), 0.1)
	tween.tween_property(hp_bar, "modulate", Color.WHITE, 0.2)


func _on_boss_defeated() -> void:
	# Flash green then hide
	if hp_bar:
		hp_bar.modulate = Color(0.3, 1.0, 0.3)

	await get_tree().create_timer(1.0).timeout
	hide_boss()
