extends Node
## Meta-progression manager - handles Pit Coins, permanent upgrades, and cross-run persistence

signal coins_changed(new_amount: int)
signal upgrade_purchased(upgrade_id: String, new_level: int)

const SAVE_PATH := "user://meta.save"

# Persistent data
var pit_coins: int = 0
var total_runs: int = 0
var best_wave: int = 0
var unlocked_upgrades: Dictionary = {}  # upgrade_id -> level

# Permanent upgrade bonuses (applied at run start)
var bonus_hp: int = 0
var bonus_damage: float = 0.0
var bonus_fire_rate: float = 0.0


func _ready() -> void:
	load_data()
	_calculate_bonuses()


func earn_coins(wave: int, level: int) -> int:
	var earned := wave * 10 + level * 25
	pit_coins += earned
	coins_changed.emit(pit_coins)
	save_data()
	return earned


func spend_coins(amount: int) -> bool:
	if pit_coins >= amount:
		pit_coins -= amount
		coins_changed.emit(pit_coins)
		save_data()
		return true
	return false


func can_afford(amount: int) -> bool:
	return pit_coins >= amount


func record_run_end(wave: int, _level: int) -> void:
	total_runs += 1
	if wave > best_wave:
		best_wave = wave
	save_data()


func get_upgrade_level(upgrade_id: String) -> int:
	return unlocked_upgrades.get(upgrade_id, 0)


func purchase_upgrade(upgrade_id: String, cost: int) -> bool:
	if not spend_coins(cost):
		return false

	var current_level := get_upgrade_level(upgrade_id)
	unlocked_upgrades[upgrade_id] = current_level + 1
	_calculate_bonuses()
	upgrade_purchased.emit(upgrade_id, current_level + 1)
	save_data()
	return true


func _calculate_bonuses() -> void:
	# HP bonus: +10 per level
	bonus_hp = get_upgrade_level("hp") * 10

	# Damage bonus: +2 per level
	bonus_damage = get_upgrade_level("damage") * 2.0

	# Fire rate bonus: -0.05s per level (faster firing)
	bonus_fire_rate = get_upgrade_level("fire_rate") * 0.05


func get_starting_hp() -> int:
	# Base HP from GameManager + bonus
	return bonus_hp


func get_damage_bonus() -> float:
	return bonus_damage


func get_fire_rate_bonus() -> float:
	return bonus_fire_rate


func save_data() -> void:
	var data := {
		"coins": pit_coins,
		"runs": total_runs,
		"best_wave": best_wave,
		"upgrades": unlocked_upgrades
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var json_string := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)
	if data is Dictionary:
		pit_coins = data.get("coins", 0)
		total_runs = data.get("runs", 0)
		best_wave = data.get("best_wave", 0)
		unlocked_upgrades = data.get("upgrades", {})
		coins_changed.emit(pit_coins)


func reset_data() -> void:
	pit_coins = 0
	total_runs = 0
	best_wave = 0
	unlocked_upgrades = {}
	bonus_hp = 0
	bonus_damage = 0.0
	bonus_fire_rate = 0.0

	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	coins_changed.emit(pit_coins)
