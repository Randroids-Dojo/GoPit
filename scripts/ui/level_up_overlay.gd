extends Control
## Level Up overlay with upgrade cards

signal upgrade_selected(upgrade_type: String)

enum UpgradeType {
	DAMAGE,
	FIRE_RATE,
	MAX_HP
}

const UPGRADE_DATA := {
	UpgradeType.DAMAGE: {
		"name": "Power Up",
		"description": "+5 Ball Damage",
		"apply": "_apply_damage_upgrade"
	},
	UpgradeType.FIRE_RATE: {
		"name": "Quick Fire",
		"description": "-0.1s Cooldown",
		"apply": "_apply_fire_rate_upgrade"
	},
	UpgradeType.MAX_HP: {
		"name": "Vitality",
		"description": "+25 Max HP",
		"apply": "_apply_hp_upgrade"
	}
}

@onready var cards_container: HBoxContainer = $Panel/VBoxContainer/CardsContainer
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel

var _available_upgrades: Array[UpgradeType] = []


func _ready() -> void:
	visible = false
	GameManager.level_up_triggered.connect(_on_level_up)
	_setup_cards()


func _setup_cards() -> void:
	# Get the three card buttons
	for i in range(cards_container.get_child_count()):
		var card: Button = cards_container.get_child(i)
		card.pressed.connect(_on_card_pressed.bind(i))


func _on_level_up() -> void:
	_randomize_upgrades()
	_update_cards()
	visible = true
	get_tree().paused = true


func _randomize_upgrades() -> void:
	_available_upgrades.clear()
	var all_upgrades: Array[UpgradeType] = [
		UpgradeType.DAMAGE,
		UpgradeType.FIRE_RATE,
		UpgradeType.MAX_HP
	]
	all_upgrades.shuffle()
	_available_upgrades = all_upgrades


func _update_cards() -> void:
	for i in range(min(cards_container.get_child_count(), _available_upgrades.size())):
		var card: Button = cards_container.get_child(i)
		var upgrade_type: UpgradeType = _available_upgrades[i]
		var data: Dictionary = UPGRADE_DATA[upgrade_type]

		var name_label: Label = card.get_node_or_null("VBoxContainer/NameLabel")
		var desc_label: Label = card.get_node_or_null("VBoxContainer/DescLabel")

		if name_label:
			name_label.text = data["name"]
		if desc_label:
			desc_label.text = data["description"]


func _on_card_pressed(index: int) -> void:
	if index >= _available_upgrades.size():
		return

	var upgrade_type: UpgradeType = _available_upgrades[index]
	var data: Dictionary = UPGRADE_DATA[upgrade_type]

	# Apply the upgrade
	call(data["apply"] as String)

	upgrade_selected.emit(data["name"])

	# Resume game
	get_tree().paused = false
	visible = false
	GameManager.complete_level_up()


func _apply_damage_upgrade() -> void:
	# Increase ball damage - stored in GameManager or applied globally
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("increase_damage"):
		ball_spawner.increase_damage(5)


func _apply_fire_rate_upgrade() -> void:
	# Decrease fire button cooldown
	var fire_button := get_tree().get_first_node_in_group("fire_button")
	if fire_button and "cooldown_duration" in fire_button:
		fire_button.cooldown_duration = max(0.1, fire_button.cooldown_duration - 0.1)


func _apply_hp_upgrade() -> void:
	GameManager.max_hp += 25
	GameManager.heal(25)
