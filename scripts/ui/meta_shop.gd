extends Control
## Meta shop UI for purchasing permanent upgrades with Pit Coins

signal closed

const Upgrades := preload("res://scripts/data/permanent_upgrades.gd")

@onready var coin_label: Label = $Panel/VBoxContainer/TopBar/CoinLabel
@onready var cards_container: GridContainer = $Panel/VBoxContainer/CardsContainer
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

var _upgrade_cards: Dictionary = {}  # upgrade_id -> card node


func _ready() -> void:
	visible = false
	add_to_group("meta_shop")

	if close_button:
		close_button.pressed.connect(_on_close_pressed)

	if MetaManager:
		MetaManager.coins_changed.connect(_update_coin_display)
		MetaManager.upgrade_purchased.connect(_on_upgrade_purchased)

	_create_upgrade_cards()
	_update_coin_display(MetaManager.pit_coins if MetaManager else 0)


func show_shop() -> void:
	_refresh_all_cards()
	_update_coin_display(MetaManager.pit_coins if MetaManager else 0)
	visible = true
	get_tree().paused = true


func hide_shop() -> void:
	visible = false
	get_tree().paused = false
	closed.emit()


func _create_upgrade_cards() -> void:
	if not cards_container:
		return

	# Clear existing cards
	for child in cards_container.get_children():
		child.queue_free()

	# Create card for each upgrade
	for upgrade_id in Upgrades.get_upgrade_ids():
		var data := Upgrades.get_upgrade(upgrade_id)
		if not data:
			continue

		var card := _create_card(data)
		cards_container.add_child(card)
		_upgrade_cards[upgrade_id] = card


func _create_card(data: Upgrades.UpgradeData) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 180)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.add_child(vbox)

	# Icon and Name
	var header := HBoxContainer.new()
	var icon_label := Label.new()
	icon_label.text = data.icon
	icon_label.add_theme_font_size_override("font_size", 32)
	header.add_child(icon_label)

	var name_label := Label.new()
	name_label.text = data.name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_label)
	vbox.add_child(header)

	# Description
	var desc_label := Label.new()
	desc_label.text = data.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	# Level display
	var level_label := Label.new()
	level_label.name = "LevelLabel"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(level_label)

	# Cost display
	var cost_label := Label.new()
	cost_label.name = "CostLabel"
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	vbox.add_child(cost_label)

	# Buy button
	var buy_btn := Button.new()
	buy_btn.name = "BuyButton"
	buy_btn.text = "Buy"
	buy_btn.pressed.connect(_on_buy_pressed.bind(data.id))
	vbox.add_child(buy_btn)

	card.add_child(margin)
	card.set_meta("upgrade_id", data.id)

	return card


func _refresh_card(upgrade_id: String) -> void:
	var card: PanelContainer = _upgrade_cards.get(upgrade_id)
	if not card:
		return

	var data := Upgrades.get_upgrade(upgrade_id)
	if not data:
		return

	var current_level := MetaManager.get_upgrade_level(upgrade_id) if MetaManager else 0
	var cost := data.get_cost(current_level)
	var is_maxed := cost < 0
	var can_afford := MetaManager.can_afford(cost) if MetaManager and not is_maxed else false

	# Update level label
	var level_label: Label = card.find_child("LevelLabel", true, false)
	if level_label:
		if is_maxed:
			level_label.text = "Level %d/%d (MAX)" % [current_level, data.max_level]
		else:
			level_label.text = "Level %d/%d" % [current_level, data.max_level]

	# Update cost label
	var cost_label: Label = card.find_child("CostLabel", true, false)
	if cost_label:
		if is_maxed:
			cost_label.text = "MAXED"
			cost_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
		else:
			cost_label.text = "%d coins" % cost
			if can_afford:
				cost_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
			else:
				cost_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))

	# Update buy button
	var buy_btn: Button = card.find_child("BuyButton", true, false)
	if buy_btn:
		buy_btn.disabled = is_maxed or not can_afford
		if is_maxed:
			buy_btn.text = "MAXED"
		elif can_afford:
			buy_btn.text = "Buy"
		else:
			buy_btn.text = "Not enough"


func _refresh_all_cards() -> void:
	for upgrade_id in _upgrade_cards.keys():
		_refresh_card(upgrade_id)


func _update_coin_display(amount: int) -> void:
	if coin_label:
		coin_label.text = "Pit Coins: %d" % amount
	_refresh_all_cards()


func _on_buy_pressed(upgrade_id: String) -> void:
	var data := Upgrades.get_upgrade(upgrade_id)
	if not data:
		return

	var current_level := MetaManager.get_upgrade_level(upgrade_id) if MetaManager else 0
	var cost := data.get_cost(current_level)

	if cost > 0 and MetaManager:
		if MetaManager.purchase_upgrade(upgrade_id, cost):
			SoundManager.play(SoundManager.SoundType.LEVEL_UP)
		else:
			SoundManager.play(SoundManager.SoundType.BLOCKED)


func _on_upgrade_purchased(upgrade_id: String, _new_level: int) -> void:
	_refresh_card(upgrade_id)


func _on_close_pressed() -> void:
	hide_shop()
