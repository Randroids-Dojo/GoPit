extends Control
## Level Up overlay with upgrade cards - expanded variety with 10 upgrade types

signal upgrade_selected(upgrade_type: String)

enum UpgradeType {
	DAMAGE,
	FIRE_RATE,
	MAX_HP,
	MULTI_SHOT,
	BALL_SPEED,
	PIERCING,
	RICOCHET,
	CRITICAL,
	MAGNETISM,
	HEAL,
	FIRE_BALL,
	ICE_BALL,
	LIGHTNING_BALL
}

const UPGRADE_DATA := {
	UpgradeType.DAMAGE: {
		"name": "Power Up",
		"description": "+5 Ball Damage",
		"apply": "_apply_damage_upgrade",
		"max_stacks": 10
	},
	UpgradeType.FIRE_RATE: {
		"name": "Quick Fire",
		"description": "-0.1s Cooldown",
		"apply": "_apply_fire_rate_upgrade",
		"max_stacks": 4
	},
	UpgradeType.MAX_HP: {
		"name": "Vitality",
		"description": "+25 Max HP",
		"apply": "_apply_hp_upgrade",
		"max_stacks": 10
	},
	UpgradeType.MULTI_SHOT: {
		"name": "Multi Shot",
		"description": "+1 Ball per shot",
		"apply": "_apply_multi_shot",
		"max_stacks": 3
	},
	UpgradeType.BALL_SPEED: {
		"name": "Velocity",
		"description": "+100 Ball Speed",
		"apply": "_apply_speed_upgrade",
		"max_stacks": 5
	},
	UpgradeType.PIERCING: {
		"name": "Piercing",
		"description": "Pierce +1 enemy",
		"apply": "_apply_piercing",
		"max_stacks": 3
	},
	UpgradeType.RICOCHET: {
		"name": "Ricochet",
		"description": "+5 wall bounces",
		"apply": "_apply_ricochet",
		"max_stacks": 4
	},
	UpgradeType.CRITICAL: {
		"name": "Critical Hit",
		"description": "+10% crit chance",
		"apply": "_apply_critical",
		"max_stacks": 5
	},
	UpgradeType.MAGNETISM: {
		"name": "Magnetism",
		"description": "Gems attracted",
		"apply": "_apply_magnetism",
		"max_stacks": 3
	},
	UpgradeType.HEAL: {
		"name": "Heal",
		"description": "Restore 30 HP",
		"apply": "_apply_heal",
		"max_stacks": 99
	},
	UpgradeType.FIRE_BALL: {
		"name": "Fire Ball",
		"description": "Burn enemies",
		"apply": "_apply_fire_ball",
		"max_stacks": 1
	},
	UpgradeType.ICE_BALL: {
		"name": "Ice Ball",
		"description": "Slow enemies",
		"apply": "_apply_ice_ball",
		"max_stacks": 1
	},
	UpgradeType.LIGHTNING_BALL: {
		"name": "Lightning Ball",
		"description": "Chain damage",
		"apply": "_apply_lightning_ball",
		"max_stacks": 1
	}
}

@onready var cards_container: HBoxContainer = $Panel/VBoxContainer/CardsContainer
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel

var _available_upgrades: Array[UpgradeType] = []
var upgrade_stacks: Dictionary = {}


func _ready() -> void:
	visible = false
	GameManager.level_up_triggered.connect(_on_level_up)
	GameManager.game_started.connect(_reset_stacks)
	_setup_cards()


func _reset_stacks() -> void:
	upgrade_stacks.clear()


func _setup_cards() -> void:
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
	var pool: Array[UpgradeType] = []

	# Add upgrades that haven't hit max stacks
	for upgrade_type in UPGRADE_DATA:
		var data: Dictionary = UPGRADE_DATA[upgrade_type]
		var current_stacks: int = upgrade_stacks.get(upgrade_type, 0)
		if current_stacks < data.get("max_stacks", 99):
			pool.append(upgrade_type)

	pool.shuffle()
	# Take first 3 (or fewer if pool is smaller)
	_available_upgrades = pool.slice(0, mini(3, pool.size()))


func _update_cards() -> void:
	for i in range(cards_container.get_child_count()):
		var card: Button = cards_container.get_child(i)

		if i < _available_upgrades.size():
			card.visible = true
			var upgrade_type: UpgradeType = _available_upgrades[i]
			var data: Dictionary = UPGRADE_DATA[upgrade_type]
			var stacks: int = upgrade_stacks.get(upgrade_type, 0)

			var name_label: Label = card.get_node_or_null("VBoxContainer/NameLabel")
			var desc_label: Label = card.get_node_or_null("VBoxContainer/DescLabel")

			if name_label:
				if stacks > 0:
					name_label.text = "%s (%d)" % [data["name"], stacks + 1]
				else:
					name_label.text = data["name"]
			if desc_label:
				desc_label.text = data["description"]
		else:
			card.visible = false


func _on_card_pressed(index: int) -> void:
	if index >= _available_upgrades.size():
		return

	var upgrade_type: UpgradeType = _available_upgrades[index]
	var data: Dictionary = UPGRADE_DATA[upgrade_type]

	# Track stacks
	upgrade_stacks[upgrade_type] = upgrade_stacks.get(upgrade_type, 0) + 1

	# Apply the upgrade
	call(data["apply"] as String)

	upgrade_selected.emit(data["name"])

	# Resume game
	get_tree().paused = false
	visible = false
	GameManager.complete_level_up()


func _apply_damage_upgrade() -> void:
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("increase_damage"):
		ball_spawner.increase_damage(5)


func _apply_fire_rate_upgrade() -> void:
	var fire_button := get_tree().get_first_node_in_group("fire_button")
	if fire_button and "cooldown_duration" in fire_button:
		fire_button.cooldown_duration = maxf(0.1, fire_button.cooldown_duration - 0.1)


func _apply_hp_upgrade() -> void:
	GameManager.max_hp += 25
	GameManager.heal(25)


func _apply_multi_shot() -> void:
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("add_multi_shot"):
		ball_spawner.add_multi_shot()


func _apply_speed_upgrade() -> void:
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("increase_speed"):
		ball_spawner.increase_speed(100)


func _apply_piercing() -> void:
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("add_piercing"):
		ball_spawner.add_piercing(1)


func _apply_ricochet() -> void:
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("add_ricochet"):
		ball_spawner.add_ricochet(5)


func _apply_critical() -> void:
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("add_crit_chance"):
		ball_spawner.add_crit_chance(0.1)


func _apply_magnetism() -> void:
	GameManager.gem_magnetism_range += 200.0


func _apply_heal() -> void:
	GameManager.heal(30)


func _apply_fire_ball() -> void:
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("set_ball_type"):
		ball_spawner.set_ball_type(1)  # FIRE


func _apply_ice_ball() -> void:
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("set_ball_type"):
		ball_spawner.set_ball_type(2)  # ICE


func _apply_lightning_ball() -> void:
	var ball_spawner := get_tree().get_first_node_in_group("ball_spawner")
	if ball_spawner and ball_spawner.has_method("set_ball_type"):
		ball_spawner.set_ball_type(3)  # LIGHTNING
