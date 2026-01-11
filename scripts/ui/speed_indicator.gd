extends Label
## Speed indicator - shows current game speed tier in HUD


func _ready() -> void:
	# Connect to speed tier changes
	GameManager.speed_tier_changed.connect(_on_speed_tier_changed)
	# Set initial state
	_update_display()


func _on_speed_tier_changed(_tier: int, _multiplier: float, _loot_bonus: float) -> void:
	_update_display()


func _update_display() -> void:
	var tier_name := GameManager.get_speed_tier_name()
	var loot_mult := GameManager.get_loot_multiplier()

	if GameManager.current_speed_tier == GameManager.SpeedTier.NORMAL:
		text = "1x"
		modulate = Color.WHITE
	else:
		# Show speed with loot bonus
		var loot_bonus := int((loot_mult - 1.0) * 100)
		text = "%s (+%d%%)" % [tier_name, loot_bonus]
		# Color based on tier
		match GameManager.current_speed_tier:
			GameManager.SpeedTier.FAST:
				modulate = Color(0.5, 1.0, 0.5)  # Light green
			GameManager.SpeedTier.FAST_2:
				modulate = Color(1.0, 1.0, 0.3)  # Yellow
			GameManager.SpeedTier.FAST_3:
				modulate = Color(1.0, 0.5, 0.3)  # Orange
