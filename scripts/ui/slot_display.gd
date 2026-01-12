extends HBoxContainer
## Displays equipped ball slots with colored indicators
## Shows which ball types are currently equipped in the 5 slots

const SLOT_SIZE: Vector2 = Vector2(24, 24)
const EMPTY_COLOR := Color(0.3, 0.3, 0.3, 0.5)
const BORDER_COLOR := Color(0.5, 0.5, 0.5, 0.8)

var _slot_rects: Array[ColorRect] = []


func _ready() -> void:
	# Set up container
	add_theme_constant_override("separation", 4)
	alignment = BoxContainer.ALIGNMENT_CENTER

	# Create 5 slot indicators
	for i in range(BallRegistry.MAX_SLOTS):
		var slot := ColorRect.new()
		slot.custom_minimum_size = SLOT_SIZE
		slot.color = EMPTY_COLOR
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(slot)
		_slot_rects.append(slot)

	# Connect to registry changes
	if BallRegistry:
		BallRegistry.slots_changed.connect(_update_display)
		# Initial update
		_update_display()


func _update_display() -> void:
	"""Update slot colors based on equipped balls"""
	if not BallRegistry:
		return

	var slots := BallRegistry.get_active_slots()
	for i in range(mini(slots.size(), _slot_rects.size())):
		var ball_type: int = slots[i]
		if ball_type == -1:
			_slot_rects[i].color = EMPTY_COLOR
		else:
			_slot_rects[i].color = BallRegistry.get_color(ball_type)


func _draw() -> void:
	# Draw borders around each slot
	for slot in _slot_rects:
		var rect := Rect2(slot.position - Vector2(1, 1), slot.size + Vector2(2, 2))
		draw_rect(rect, BORDER_COLOR, false, 1.0)
