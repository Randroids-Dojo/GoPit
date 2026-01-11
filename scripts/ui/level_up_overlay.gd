extends Control
## Level Up overlay with upgrade cards - supports ball types, ball leveling, and passive upgrades
## Passives are now shared with FusionRegistry so fission and level-up use the same tracking.

signal upgrade_selected(upgrade_type: String)

# Upgrade categories for card generation
enum CardType {
	PASSIVE,      # Traditional stat upgrades (uses FusionRegistry.PassiveType)
	NEW_BALL,     # Acquire a new ball type
	LEVEL_UP_BALL, # Level up an owned ball (L1->L2 or L2->L3)
	FISSION,      # Random upgrades (1-3 ball level-ups or new balls)
	HEAL          # One-time heal (not tracked in stacks)
}

# Heal is special - not tracked in FusionRegistry as it's not a stackable passive
const HEAL_DATA := {
	"name": "Heal",
	"description": "Restore 30 HP"
}

@onready var cards_container: HBoxContainer = $Panel/VBoxContainer/CardsContainer
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel

# Each card is a Dictionary with: card_type, passive_type (for passive), ball_type (for ball cards)
var _available_cards: Array[Dictionary] = []


func _ready() -> void:
	visible = false
	GameManager.level_up_triggered.connect(_on_level_up)
	_setup_cards()


func _setup_cards() -> void:
	for i in range(cards_container.get_child_count()):
		var card: Button = cards_container.get_child(i)
		card.pressed.connect(_on_card_pressed.bind(i))


func _on_level_up() -> void:
	_randomize_cards()
	_update_cards()
	visible = true
	get_tree().paused = true


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

	# 5. Always add heal option (not a stackable passive)
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

		CardType.HEAL:
			GameManager.heal(30)
			selected_name = "Heal"

	upgrade_selected.emit(selected_name)

	# Resume game
	get_tree().paused = false
	visible = false
	GameManager.complete_level_up()


