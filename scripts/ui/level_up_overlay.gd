extends Control
## Level Up overlay with upgrade cards - supports ball types, ball leveling, and passive upgrades
## Passives are now shared with FusionRegistry so fission and level-up use the same tracking.

signal upgrade_selected(upgrade_type: String)

# Upgrade categories for card generation
enum CardType {
	PASSIVE,       # Traditional stat upgrades (uses FusionRegistry.PassiveType)
	NEW_BALL,      # Acquire a new ball type
	LEVEL_UP_BALL, # Level up an owned ball (L1->L2 or L2->L3)
	FISSION,       # Random upgrades (1-3 ball level-ups or new balls)
	HEAL,          # One-time heal (not tracked in stacks)
	TIER_UPGRADE   # Upgrade an evolved ball to next tier (Advanced/Ultimate)
}

# Heal is special - not tracked in FusionRegistry as it's not a stackable passive
const HEAL_DATA := {
	"name": "Heal",
	"description": "Restore 30 HP"
}

const SETTINGS_PATH := "user://settings.save"
const HINT_TEXT := "Choose an upgrade! Tap a card to power up."
const HINT_DURATION := 3.0  # Seconds before auto-dismiss

@onready var panel: Panel = $Panel
@onready var cards_container: HBoxContainer = $Panel/VBoxContainer/CardsContainer
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var hint_label: Label = $Panel/VBoxContainer/HintLabel

# Each card is a Dictionary with: card_type, passive_type (for passive), ball_type (for ball cards)
var _available_cards: Array[Dictionary] = []
var _first_levelup_seen: bool = false
var _hint_tween: Tween = null
var _animation_complete: bool = false


func _ready() -> void:
	visible = false
	_first_levelup_seen = _load_hint_state()
	GameManager.level_up_triggered.connect(_on_level_up)
	_setup_cards()
	_setup_hint_label()


func _setup_cards() -> void:
	for i in range(cards_container.get_child_count()):
		var card: Button = cards_container.get_child(i)
		card.pressed.connect(_on_card_pressed.bind(i))
		card.mouse_entered.connect(_on_card_hover.bind(card, true))
		card.mouse_exited.connect(_on_card_hover.bind(card, false))


func _setup_hint_label() -> void:
	# The hint label will be created dynamically if it doesn't exist in the scene
	if not hint_label:
		hint_label = Label.new()
		hint_label.name = "HintLabel"
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
		hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		hint_label.add_theme_constant_override("outline_size", 3)
		hint_label.add_theme_font_size_override("font_size", 16)
		# Insert after title label
		var vbox := title_label.get_parent()
		vbox.add_child(hint_label)
		vbox.move_child(hint_label, title_label.get_index() + 1)
	hint_label.text = ""
	hint_label.visible = false


func _on_level_up() -> void:
	# Pause game immediately so balls stop firing and everything freezes
	# Skip in headless mode to allow PlayGodot automation to continue
	if DisplayServer.get_name() != "headless":
		get_tree().paused = true
	_randomize_cards()
	_update_cards()
	visible = true
	_animation_complete = false
	_animate_show()
	_show_first_time_hint()


func _animate_show() -> void:
	"""Animate the panel and cards in with staggered entrance."""
	if not panel:
		_animation_complete = true
		return

	# Initial state for panel
	panel.modulate.a = 0
	panel.scale = Vector2(0.9, 0.9)
	panel.pivot_offset = panel.size / 2

	# Hide all cards initially
	for i in range(cards_container.get_child_count()):
		var card: Button = cards_container.get_child(i)
		if card.visible:
			card.modulate.a = 0
			card.scale = Vector2(0.8, 0.8)
			card.pivot_offset = card.size / 2

	var tween := create_tween()

	# Fade in panel with slight bounce
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3)

	# Staggered card entrance
	for i in range(cards_container.get_child_count()):
		var card: Button = cards_container.get_child(i)
		if card.visible:
			tween.tween_property(card, "modulate:a", 1.0, 0.15)
			tween.parallel().tween_property(card, "scale", Vector2(1.0, 1.0), 0.2)

	# Play level up sound
	if SoundManager:
		tween.tween_callback(func(): SoundManager.play(SoundManager.SoundType.LEVEL_UP))

	# Mark animation as complete (tree is already paused from _on_level_up)
	tween.tween_callback(func():
		_animation_complete = true
	)


func _on_card_hover(card: Button, is_hovered: bool) -> void:
	"""Scale card slightly on hover for feedback."""
	if not _animation_complete:
		return

	var target_scale := Vector2(1.05, 1.05) if is_hovered else Vector2(1.0, 1.0)
	var tween := create_tween()
	tween.tween_property(card, "scale", target_scale, 0.1)


func _randomize_cards() -> void:
	_available_cards.clear()
	var pool: Array[Dictionary] = []

	# 1. Add new ball types (not yet owned)
	if BallRegistry:
		var unowned := BallRegistry.get_unowned_ball_types()
		for ball_type in unowned:
			pool.append({
				"card_type": CardType.NEW_BALL,
				"ball_type": ball_type
			})

		# 2. Add ball level-ups (owned balls below L3)
		var upgradeable := BallRegistry.get_upgradeable_balls()
		for ball_type in upgradeable:
			pool.append({
				"card_type": CardType.LEVEL_UP_BALL,
				"ball_type": ball_type
			})

		# 3. Add Fission card (if there are upgradeable or unowned balls, or available passives)
		var has_upgrades := upgradeable.size() > 0 or unowned.size() > 0
		if FusionRegistry:
			has_upgrades = has_upgrades or FusionRegistry.get_available_passives().size() > 0
		if has_upgrades:
			pool.append({
				"card_type": CardType.FISSION
			})

	# 4. Add passive upgrades from FusionRegistry (shared with fission)
	if FusionRegistry:
		var available_passives := FusionRegistry.get_available_passives()
		for passive_type in available_passives:
			pool.append({
				"card_type": CardType.PASSIVE,
				"passive_type": passive_type
			})

		# 5. Add tier upgrades for evolved balls (Advanced/Ultimate)
		var tier_upgrades := FusionRegistry.get_available_upgrades()
		for upgrade_data in tier_upgrades:
			pool.append({
				"card_type": CardType.TIER_UPGRADE,
				"upgrade_data": upgrade_data
			})

	# 6. Always add heal option (not a stackable passive)
	pool.append({
		"card_type": CardType.HEAL
	})

	pool.shuffle()
	# Take first 3 (or fewer if pool is smaller)
	_available_cards = pool.slice(0, mini(3, pool.size()))


func _update_cards() -> void:
	for i in range(cards_container.get_child_count()):
		var card: Button = cards_container.get_child(i)

		if i < _available_cards.size():
			card.visible = true
			var card_data: Dictionary = _available_cards[i]
			var name_label: Label = card.get_node_or_null("VBoxContainer/NameLabel")
			var desc_label: Label = card.get_node_or_null("VBoxContainer/DescLabel")

			match card_data["card_type"]:
				CardType.PASSIVE:
					var passive_type: FusionRegistry.PassiveType = card_data["passive_type"]
					var stacks: int = FusionRegistry.get_passive_stacks(passive_type) if FusionRegistry else 0
					var passive_name: String = FusionRegistry.get_passive_name(passive_type) if FusionRegistry else "Unknown"
					var passive_desc: String = FusionRegistry.get_passive_description(passive_type) if FusionRegistry else ""

					if name_label:
						if stacks > 0:
							name_label.text = "%s (%d)" % [passive_name, stacks + 1]
						else:
							name_label.text = passive_name
					if desc_label:
						desc_label.text = passive_desc

				CardType.NEW_BALL:
					var ball_type: int = card_data["ball_type"]
					var ball_name: String = BallRegistry.get_ball_name(ball_type) if BallRegistry else "Ball"
					var ball_desc: String = BallRegistry.get_ball_description(ball_type) if BallRegistry else ""

					if name_label:
						name_label.text = "NEW: %s Ball" % ball_name
					if desc_label:
						desc_label.text = ball_desc

				CardType.LEVEL_UP_BALL:
					var ball_type: int = card_data["ball_type"]
					var ball_name: String = BallRegistry.get_ball_name(ball_type) if BallRegistry else "Ball"
					var current_level: int = BallRegistry.get_ball_level(ball_type) if BallRegistry else 1
					var next_level: int = current_level + 1

					if name_label:
						name_label.text = "%s L%d" % [ball_name, next_level]
					if desc_label:
						if next_level == 2:
							desc_label.text = "+50% damage & speed"
						elif next_level == 3:
							desc_label.text = "+100% stats (Fusion ready!)"

				CardType.FISSION:
					if name_label:
						name_label.text = "FISSION"
					if desc_label:
						desc_label.text = "Random 1-5 upgrades!"

				CardType.TIER_UPGRADE:
					var upgrade_data: Dictionary = card_data["upgrade_data"]
					var tier_name: String = upgrade_data.get("name", "Unknown")
					var new_tier: int = upgrade_data.get("new_tier", 2)
					var tier_label: String = FusionRegistry.get_tier_name(new_tier) if FusionRegistry else "Advanced"
					var mult: float = FusionRegistry.get_tier_damage_multiplier(new_tier) if FusionRegistry else 2.5

					if name_label:
						name_label.text = tier_name
					if desc_label:
						desc_label.text = "%s tier: %.1fx damage" % [tier_label, mult]

				CardType.HEAL:
					if name_label:
						name_label.text = HEAL_DATA["name"]
					if desc_label:
						desc_label.text = HEAL_DATA["description"]
		else:
			card.visible = false


func _on_card_pressed(index: int) -> void:
	if index >= _available_cards.size():
		return
	if not _animation_complete:
		return

	# Prevent double-clicks during animation
	_animation_complete = false

	var card: Button = cards_container.get_child(index)
	_animate_selection(card, index)


func _animate_selection(card: Button, index: int) -> void:
	"""Animate the selected card with highlight, fade others, then apply selection."""
	var tween := create_tween()

	# Scale up and highlight selected card
	tween.tween_property(card, "scale", Vector2(1.15, 1.15), 0.1)
	tween.parallel().tween_property(card, "modulate", Color(1.3, 1.3, 1.0, 1.0), 0.1)

	# Fade out other cards
	for i in range(cards_container.get_child_count()):
		if i != index:
			var other_card: Button = cards_container.get_child(i)
			if other_card.visible:
				tween.parallel().tween_property(other_card, "modulate:a", 0.3, 0.2)

	# Brief pause then apply selection
	tween.tween_interval(0.2)
	tween.tween_callback(func(): _apply_selection(index))


func _apply_selection(index: int) -> void:
	"""Apply the card selection and close the overlay."""
	var card_data: Dictionary = _available_cards[index]
	var selected_name: String = ""

	match card_data["card_type"]:
		CardType.PASSIVE:
			var passive_type: FusionRegistry.PassiveType = card_data["passive_type"]
			if FusionRegistry:
				FusionRegistry.apply_passive(passive_type)
				selected_name = FusionRegistry.get_passive_name(passive_type)

		CardType.NEW_BALL:
			var ball_type: int = card_data["ball_type"]
			if BallRegistry:
				BallRegistry.add_ball(ball_type)
				selected_name = "NEW: %s Ball" % BallRegistry.get_ball_name(ball_type)

		CardType.LEVEL_UP_BALL:
			var ball_type: int = card_data["ball_type"]
			if BallRegistry:
				var new_level: int = BallRegistry.get_ball_level(ball_type) + 1
				BallRegistry.level_up_ball(ball_type)
				selected_name = "%s L%d" % [BallRegistry.get_ball_name(ball_type), new_level]

		CardType.FISSION:
			if FusionRegistry:
				var result: Dictionary = FusionRegistry.apply_fission()
				var upgrade_count: int = result.get("upgrades", []).size()
				if upgrade_count > 0:
					selected_name = "FISSION x%d" % upgrade_count
				elif result.get("pit_coins", 0) > 0:
					selected_name = "FISSION (+%d Coins)" % result["pit_coins"]
				else:
					selected_name = "FISSION"
				SoundManager.play(SoundManager.SoundType.FISSION)

		CardType.TIER_UPGRADE:
			if FusionRegistry:
				var upgrade_data: Dictionary = card_data["upgrade_data"]
				var evolved_type: FusionRegistry.EvolvedBallType = upgrade_data["evolved_type"]
				var sacrifice_options: Array = upgrade_data.get("sacrifice_options", [])
				if not sacrifice_options.is_empty():
					# Use first available L3 ball as sacrifice
					var sacrifice_ball: int = sacrifice_options[0]
					if FusionRegistry.upgrade_evolution(evolved_type, sacrifice_ball):
						selected_name = upgrade_data.get("name", "Upgraded")
						SoundManager.play(SoundManager.SoundType.LEVEL_UP)

		CardType.HEAL:
			GameManager.heal(30)
			selected_name = "Heal"

	upgrade_selected.emit(selected_name)

	# Hide hint on card selection
	_dismiss_hint()

	# Resume game
	get_tree().paused = false
	visible = false
	GameManager.complete_level_up()


# =============================================================================
# FIRST-TIME HINT SYSTEM
# =============================================================================

func _show_first_time_hint() -> void:
	"""Show hint text on first level-up."""
	if _first_levelup_seen:
		return

	if hint_label:
		hint_label.text = HINT_TEXT
		hint_label.visible = true
		hint_label.modulate.a = 0.0

		# Fade in animation
		_hint_tween = create_tween()
		_hint_tween.tween_property(hint_label, "modulate:a", 1.0, 0.3)

		# Auto-dismiss after duration (but save state immediately)
		_hint_tween.tween_interval(HINT_DURATION)
		_hint_tween.tween_callback(_fade_out_hint)

	# Mark as seen and save immediately
	_first_levelup_seen = true
	_save_hint_state()


func _dismiss_hint() -> void:
	"""Dismiss hint immediately (on card selection)."""
	if _hint_tween and _hint_tween.is_running():
		_hint_tween.kill()
	if hint_label:
		hint_label.visible = false


func _fade_out_hint() -> void:
	"""Fade out the hint label."""
	if hint_label and hint_label.visible:
		var tween := create_tween()
		tween.tween_property(hint_label, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): hint_label.visible = false)


func _load_hint_state() -> bool:
	"""Load first_levelup_seen state from settings."""
	if not FileAccess.file_exists(SETTINGS_PATH):
		return false

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return false

	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if data and data.has("first_levelup_seen"):
		return data["first_levelup_seen"]
	return false


func _save_hint_state() -> void:
	"""Save first_levelup_seen state to settings."""
	var data := {}

	# Load existing settings first
	if FileAccess.file_exists(SETTINGS_PATH):
		var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var existing = JSON.parse_string(file.get_as_text())
			file.close()
			if existing:
				data = existing

	data["first_levelup_seen"] = true

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
