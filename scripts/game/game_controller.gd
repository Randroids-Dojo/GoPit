extends Node2D
## Main game controller - wires together input, spawner, and aim line

@onready var ball_spawner: Node2D = $GameArea/BallSpawner
@onready var balls_container: Node2D = $GameArea/Balls
@onready var enemies_container: Node2D = $GameArea/Enemies
@onready var gems_container: Node2D = $GameArea/Gems
@onready var hazards_container: Node2D = $GameArea/Hazards
@onready var enemy_spawner: EnemySpawner = $GameArea/Enemies/EnemySpawner
@onready var player_zone: Area2D = $GameArea/PlayerZone
@onready var player: CharacterBody2D = $GameArea/Player
@onready var move_joystick: Control = $UI/HUD/InputContainer/HBoxContainer/MoveJoystickContainer/VirtualJoystick
@onready var aim_joystick: Control = $UI/HUD/InputContainer/HBoxContainer/AimJoystickContainer/VirtualJoystick
@onready var fire_button: Control = $UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton
@onready var auto_toggle: Button = $UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/AutoToggle
@onready var aim_line: Line2D = $GameArea/AimLine
@onready var baby_ball_spawner: Node2D = $GameArea/BabyBallSpawner
@onready var pause_overlay: CanvasLayer = $UI/PauseOverlay
@onready var damage_vignette: ColorRect = $UI/DamageVignette
@onready var tutorial_overlay: CanvasLayer = $UI/TutorialOverlay
@onready var danger_indicator: Control = $UI/DangerIndicator
@onready var character_select: CanvasLayer = $UI/CharacterSelect
@onready var level_select: CanvasLayer = $UI/LevelSelect
@onready var background: ColorRect = $Background
@onready var left_wall: StaticBody2D = $GameArea/Walls/LeftWall
@onready var right_wall: StaticBody2D = $GameArea/Walls/RightWall
@onready var stage_complete_overlay: CanvasLayer = $UI/StageCompleteOverlay
@onready var fusion_overlay: Control = $UI/FusionOverlay
@onready var boss_hp_bar: Control = $UI/BossHPBar
@onready var ultimate_button: Control = $UI/HUD/InputContainer/HBoxContainer/UltimateButtonContainer/UltimateButton
@onready var save_slot_select: CanvasLayer = $UI/SaveSlotSelect

var gem_scene: PackedScene = preload("res://scenes/entities/gem.tscn")
# NOTE: Boss scenes use load() not preload() to avoid class resolution issues during import
# See boss_base.gd for detailed explanation of Godot's class loading order problem
var slime_king_scene: PackedScene
var frost_wyrm_scene: PackedScene
var sand_golem_scene: PackedScene
var void_lord_scene: PackedScene

# Boss tracking
var _current_boss: Node = null
var player_scene: PackedScene = preload("res://scenes/entities/player.tscn")
var fusion_reactor_scene: PackedScene = preload("res://scenes/entities/fusion_reactor.tscn")

# Viewport bounds for ball cleanup
var viewport_height: float = 1280.0

# Wave tracking
var enemies_killed_this_wave: int = 0
var enemies_per_wave: int = 5

# Keyboard input tracking
var _keyboard_aim_direction: Vector2 = Vector2.ZERO
var _last_keyboard_aim: Vector2 = Vector2.UP  # Default aim upward

# Catch zone for touch input (tap above this Y to try catching)
const CATCH_TAP_ZONE_MAX_Y: float = 900.0  # Don't trigger on HUD area


func _ready() -> void:
	viewport_height = get_viewport_rect().size.y

	# Wire up move joystick (left) - controls player movement
	if move_joystick:
		move_joystick.direction_changed.connect(_on_move_joystick_direction_changed)
		move_joystick.released.connect(_on_move_joystick_released)

	# Wire up aim joystick (right) - controls aim direction
	if aim_joystick:
		aim_joystick.direction_changed.connect(_on_aim_joystick_direction_changed)
		aim_joystick.released.connect(_on_aim_joystick_released)

	# Wire up fire button
	if fire_button:
		fire_button.fired.connect(_on_fire_pressed)

	# Wire up ball spawner catch signal
	if ball_spawner:
		ball_spawner.ball_caught.connect(_on_ball_caught)

	# Wire up autofire toggle
	if auto_toggle and fire_button:
		auto_toggle.toggled.connect(_on_auto_toggle_pressed)
		fire_button.autofire_toggled.connect(_on_autofire_state_changed)

	# Wire up ultimate button
	if ultimate_button:
		ultimate_button.ultimate_activated.connect(_on_ultimate_activated)

	# Set up ball spawner
	if ball_spawner:
		ball_spawner.balls_container = balls_container

	# Set up player
	if player:
		# Player starts at bottom center
		player.position = Vector2(360, 1000)
		# Connect player to ball spawner so balls spawn from player position
		player.moved.connect(_on_player_moved)

	# Connect player zone to detect enemies and gems (legacy, still used for gem magnet)
	if player_zone:
		player_zone.body_entered.connect(_on_player_zone_body_entered)
		player_zone.area_entered.connect(_on_player_zone_area_entered)

	# Connect to game state for enemy spawning
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over.connect(_on_game_over)
	GameManager.player_damaged.connect(_on_player_damaged)
	GameManager.leadership_changed.connect(_on_leadership_changed)

	# Connect to stage manager for biome changes
	StageManager.biome_changed.connect(_on_biome_changed)
	StageManager.boss_wave_reached.connect(_on_boss_wave_reached)
	StageManager.stage_completed.connect(_on_stage_completed)
	StageManager.game_won.connect(_on_game_won)

	# Connect enemy spawner to spawn gems on death
	if enemy_spawner:
		enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)

	# Connect character select
	if character_select:
		character_select.character_selected.connect(_on_character_selected)

	# Connect level select
	if level_select:
		level_select.stage_selected.connect(_on_stage_selected)

	# Connect save slot select
	if save_slot_select:
		save_slot_select.slot_selected.connect(_on_slot_selected)

	# Connect wave changes for auto-save
	GameManager.wave_changed.connect(_on_wave_changed_for_autosave)

	# Start game flow
	# Skip save slot/character/level select in headless mode (for testing)
	if DisplayServer.get_name() == "headless":
		GameManager.start_game()
	elif save_slot_select:
		# Show save slot select first for normal gameplay
		save_slot_select.show_select()
	elif character_select:
		# Fallback: show character select if no save slot select
		character_select.show_select()
	else:
		# Fallback: auto-start if no character select
		GameManager.start_game()


func _on_character_selected(character: Resource) -> void:
	# Apply character to GameManager
	GameManager.set_character(character)

	# Apply character stats to ball spawner
	if ball_spawner:
		# Apply Strength-based damage (all balls use character Strength)
		ball_spawner.ball_damage = GameManager.get_character_strength()
		# Apply crit multiplier
		ball_spawner.crit_chance = 0.0 + (GameManager.character_crit_mult - 1.0) * 0.15
		# Set starting ball type
		ball_spawner.set_ball_type(GameManager.character_starting_ball)

	# Show level select (or start game if no level select)
	if level_select:
		level_select.show_select()
	else:
		GameManager.start_game()


func _on_stage_selected(stage_index: int) -> void:
	# Set starting stage in StageManager
	if StageManager:
		StageManager.current_stage = stage_index
		StageManager._apply_biome()

	# Start the game
	GameManager.start_game()


func _on_slot_selected(slot: int) -> void:
	"""Handle save slot selection. Negative slot means restore session."""
	if slot < 0:
		# Restore session from saved data
		_restore_session()
	else:
		# Normal flow - show character select
		if character_select:
			character_select.show_select()
		else:
			GameManager.start_game()


func _restore_session() -> void:
	"""Restore a saved mid-run session."""
	var session_data := MetaManager.load_session()
	if session_data.is_empty():
		# No session to restore - fall back to normal flow
		if character_select:
			character_select.show_select()
		return

	# Restore GameManager state
	GameManager.restore_session_state(session_data)

	# Restore BallRegistry state
	var ball_state: Dictionary = session_data.get("ball_registry", {})
	if not ball_state.is_empty():
		BallRegistry.restore_session_state(ball_state)

	# Restore FusionRegistry state
	var fusion_state: Dictionary = session_data.get("fusion_registry", {})
	if not fusion_state.is_empty():
		FusionRegistry.restore_session_state(fusion_state)

	# Restore StageManager state
	var stage: int = session_data.get("current_stage", 0)
	if StageManager:
		StageManager.current_stage = stage
		StageManager._apply_biome()

	# Apply character stats to ball spawner
	if ball_spawner and GameManager.selected_character:
		ball_spawner.ball_damage = GameManager.get_character_strength()
		ball_spawner.crit_chance = 0.0 + (GameManager.character_crit_mult - 1.0) * 0.15
		ball_spawner.set_ball_type(GameManager.character_starting_ball)

	# Set state to playing and start
	GameManager.current_state = GameManager.GameState.PLAYING
	GameManager.game_started.emit()


func _save_session() -> void:
	"""Save the current game session for mid-run persistence."""
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	var session_data := GameManager.get_session_state()

	# Add BallRegistry state
	session_data["ball_registry"] = BallRegistry.get_session_state()

	# Add FusionRegistry state
	session_data["fusion_registry"] = FusionRegistry.get_session_state()

	# Add StageManager state
	if StageManager:
		session_data["current_stage"] = StageManager.current_stage

	MetaManager.save_session(session_data)


func _on_wave_changed_for_autosave(_new_wave: int) -> void:
	"""Auto-save session when wave changes."""
	_save_session()


func _on_game_started() -> void:
	if enemy_spawner:
		enemy_spawner.start_spawning()
	if baby_ball_spawner:
		baby_ball_spawner.start()
	MusicManager.start_music()


func _on_game_over() -> void:
	if enemy_spawner:
		enemy_spawner.stop_spawning()
	if baby_ball_spawner:
		baby_ball_spawner.stop()
	MusicManager.stop_music()
	# Clear all existing enemies so they stop moving
	if enemies_container:
		for enemy in enemies_container.get_children():
			if enemy is EnemyBase:
				enemy.queue_free()
	# Clear hazards
	_clear_hazards()
	# Clear the mid-run session save (run ended)
	MetaManager.clear_session()


func _on_player_damaged(_amount: int) -> void:
	if damage_vignette:
		damage_vignette.flash()


func _on_player_zone_body_entered(_body: Node2D) -> void:
	# Enemies now handle their own attack logic with warning + lunge
	# This function is kept for potential future use (other body types)
	pass


func _on_player_zone_area_entered(_area: Area2D) -> void:
	# Gems are now collected by player contact, not player_zone
	# This function is kept for potential future use
	pass


func _show_xp_text(pos: Vector2, xp: int) -> void:
	var DamageNumber := preload("res://scripts/effects/damage_number.gd")
	DamageNumber.spawn(self, pos, xp, Color(0.3, 1.0, 0.5), "+")  # Green "+X" for XP


func _on_enemy_spawned(enemy: EnemyBase) -> void:
	# Connect to enemy death to spawn gems
	enemy.died.connect(_on_enemy_died)
	# Connect to enemy damage for tutorial
	enemy.took_damage.connect(_on_enemy_took_damage)
	# Connect danger zone signals
	if danger_indicator:
		enemy.entered_danger_zone.connect(danger_indicator.add_danger)
		enemy.left_danger_zone.connect(danger_indicator.remove_danger)
		enemy.died.connect(func(_e):
			if enemy.in_danger_zone:
				danger_indicator.remove_danger()
		)


func _on_enemy_died(enemy: EnemyBase) -> void:
	_spawn_gem(enemy.global_position, enemy.xp_value)
	_maybe_spawn_fusion_reactor(enemy.global_position)
	_check_wave_progress()
	GameManager.record_enemy_kill()
	GameManager.add_ultimate_charge(GameManager.CHARGE_PER_KILL)


func _on_enemy_took_damage(_enemy: EnemyBase, _amount: int) -> void:
	# Notify tutorial
	if tutorial_overlay and tutorial_overlay.has_method("on_enemy_hit"):
		tutorial_overlay.on_enemy_hit()


func _spawn_gem(pos: Vector2, xp_value: int) -> void:
	if not gems_container:
		return

	# Get gem from pool if available
	var gem: Node
	if PoolManager:
		gem = PoolManager.get_gem()
	else:
		gem = gem_scene.instantiate()
	gem.position = pos
	gem.xp_value = xp_value
	# Reconnect signal (may have been disconnected on pool release)
	if not gem.collected.is_connected(_on_gem_collected):
		gem.collected.connect(_on_gem_collected)
	gems_container.add_child(gem)
	# Re-acquire player reference after being added to tree
	gem._player = get_tree().get_first_node_in_group("player")


func _on_gem_collected(_gem: Node2D) -> void:
	# Gems no longer give XP - XP is awarded on kill instead
	# Gems still give ultimate charge and count toward stats
	GameManager.record_gem_collected()
	GameManager.add_ultimate_charge(GameManager.CHARGE_PER_GEM)


func _check_wave_progress() -> void:
	enemies_killed_this_wave += 1
	if enemies_killed_this_wave >= enemies_per_wave:
		_advance_wave()


func _advance_wave() -> void:
	enemies_killed_this_wave = 0
	SoundManager.play(SoundManager.SoundType.WAVE_COMPLETE)
	GameManager.advance_wave()

	# Increase difficulty
	if enemy_spawner:
		# Increase spawn rate
		var new_interval: float = max(0.5, enemy_spawner.spawn_interval - 0.1)
		enemy_spawner.set_spawn_interval(new_interval)

	# Increase music intensity
	MusicManager.set_intensity(float(GameManager.current_wave))


func _on_player_moved(pos: Vector2) -> void:
	# Update ball spawner position to follow player
	if ball_spawner:
		ball_spawner.global_position = pos

	# Update PlayerZone position to follow player (for collision detection)
	if player_zone:
		player_zone.global_position = pos

	# Update aim line to follow player
	if aim_line:
		aim_line.update_position(pos)


func _on_move_joystick_direction_changed(direction: Vector2) -> void:
	# Control player movement only
	if player and player.has_method("set_movement_input"):
		player.set_movement_input(direction)

	# Notify tutorial
	if tutorial_overlay and tutorial_overlay.has_method("on_joystick_used"):
		tutorial_overlay.on_joystick_used()


func _on_move_joystick_released() -> void:
	# Stop player movement
	if player and player.has_method("set_movement_input"):
		player.set_movement_input(Vector2.ZERO)


func _on_aim_joystick_direction_changed(direction: Vector2) -> void:
	# Set aim direction on ball spawner
	if ball_spawner and direction.length() > 0.1:
		ball_spawner.set_aim_direction(direction)

	# Show aim line from player position
	if aim_line and player:
		if direction.length() > 0.1:
			aim_line.show_line(direction, player.global_position)
		else:
			aim_line.hide_line()

	# Notify tutorial
	if tutorial_overlay and tutorial_overlay.has_method("on_aim_joystick_used"):
		tutorial_overlay.on_aim_joystick_used()


func _on_aim_joystick_released() -> void:
	if aim_line:
		aim_line.hide_line()


func _on_fire_pressed() -> void:
	if ball_spawner:
		ball_spawner.fire()
		GameManager.record_ball_fired()

	# Notify tutorial
	if tutorial_overlay and tutorial_overlay.has_method("on_ball_fired"):
		tutorial_overlay.on_ball_fired()


func _on_ball_caught() -> void:
	"""Handle ball catch - give cooldown bonus to fire button"""
	if fire_button:
		fire_button.add_catch_bonus()
	SoundManager.play(SoundManager.SoundType.GEM_COLLECT)  # Reuse gem sound for catch


func try_catch_ball() -> bool:
	"""Attempt to catch a returning ball (active play bonus)"""
	if not ball_spawner:
		return false
	return ball_spawner.try_catch_ball()


func _on_auto_toggle_pressed(button_pressed: bool) -> void:
	if fire_button:
		fire_button.set_autofire(button_pressed)


func _on_autofire_state_changed(enabled: bool) -> void:
	# Keep toggle button in sync with fire button state
	if auto_toggle:
		auto_toggle.set_pressed_no_signal(enabled)


func _on_ultimate_activated() -> void:
	# Spawn the ultimate blast effect
	var blast_scene: PackedScene = load("res://scenes/effects/ultimate_blast.tscn")
	var blast: Node2D = blast_scene.instantiate()
	add_child(blast)
	blast.execute()


func _process(_delta: float) -> void:
	_cleanup_offscreen_balls()
	_handle_keyboard_input()


func _notification(what: int) -> void:
	# Auto-pause and save when app loses focus (mobile)
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if GameManager.current_state == GameManager.GameState.PLAYING:
			# Auto-save session before pausing
			_save_session()
			if pause_overlay:
				pause_overlay.show_pause()


func _cleanup_offscreen_balls() -> void:
	if not balls_container:
		return

	for ball in balls_container.get_children():
		if ball.global_position.y < -50 or ball.global_position.y > viewport_height + 50:
			ball.despawn()


func _on_biome_changed(biome: Biome) -> void:
	# Update background color
	if background:
		background.color = biome.background_color

	# Update wall colors (via modulate since walls are StaticBody2D)
	if left_wall:
		_set_wall_color(left_wall, biome.wall_color)
	if right_wall:
		_set_wall_color(right_wall, biome.wall_color)

	# Spawn environmental hazards for this biome
	_spawn_biome_hazards(biome)


func _set_wall_color(wall: StaticBody2D, color: Color) -> void:
	# Walls don't have visual by default, add ColorRect if needed
	var visual := wall.get_node_or_null("Visual") as ColorRect
	if not visual:
		visual = ColorRect.new()
		visual.name = "Visual"
		visual.size = Vector2(20, 1280)
		visual.position = Vector2(-10, -640)
		wall.add_child(visual)
	visual.color = color


func _spawn_biome_hazards(biome: Biome) -> void:
	"""Spawn environmental hazards for the current biome."""
	# Clear existing hazards
	_clear_hazards()

	# Check if biome has hazards configured
	if not biome.hazard_scene or biome.hazard_count <= 0:
		return

	# Ensure hazards container exists
	if not hazards_container:
		hazards_container = Node2D.new()
		hazards_container.name = "Hazards"
		$GameArea.add_child(hazards_container)

	# Define spawn bounds (game area excluding HUD and player starting area)
	var spawn_min := Vector2(80, 350)
	var spawn_max := Vector2(640, 900)

	# Spawn hazards at random positions
	for i in range(biome.hazard_count):
		var hazard: Node2D = biome.hazard_scene.instantiate()
		var pos := _get_random_hazard_position(spawn_min, spawn_max)
		hazard.position = pos
		hazards_container.add_child(hazard)


func _clear_hazards() -> void:
	"""Remove all existing hazards."""
	if not hazards_container:
		return

	for child in hazards_container.get_children():
		child.queue_free()


func _get_random_hazard_position(min_pos: Vector2, max_pos: Vector2) -> Vector2:
	"""Get a random position for hazard placement, avoiding overlap with existing hazards."""
	var attempts := 10
	var min_distance := 120.0  # Minimum distance between hazards

	for _i in range(attempts):
		var x := randf_range(min_pos.x, max_pos.x)
		var y := randf_range(min_pos.y, max_pos.y)
		var candidate := Vector2(x, y)

		# Check distance from existing hazards
		var valid := true
		if hazards_container:
			for existing in hazards_container.get_children():
				if existing.position.distance_to(candidate) < min_distance:
					valid = false
					break

		if valid:
			return candidate

	# Fallback: return random position even if overlapping
	return Vector2(
		randf_range(min_pos.x, max_pos.x),
		randf_range(min_pos.y, max_pos.y)
	)


func _on_boss_wave_reached(stage: int) -> void:
	# Stop enemy spawning
	if enemy_spawner:
		enemy_spawner.stop_spawning()

	# Stop baby ball spawner during boss
	if baby_ball_spawner:
		baby_ball_spawner.stop()

	# Spawn the boss based on stage
	_spawn_boss(stage)


func _on_stage_completed(_stage: int) -> void:
	# This is called when player chooses "Continue Playing" to extend the run
	# Stage progress is already recorded in _on_boss_defeated

	# Resume enemy spawning for next stage
	if enemy_spawner:
		enemy_spawner.start_spawning()

	# Resume baby ball spawner
	if baby_ball_spawner:
		baby_ball_spawner.start()


func _on_game_won() -> void:
	# Trigger victory state in GameManager
	GameManager.trigger_victory()
	# Clear mid-run session save (run complete)
	MetaManager.clear_session()
	# Show victory screen
	if stage_complete_overlay:
		stage_complete_overlay.show_victory()


func _on_leadership_changed(new_value: float) -> void:
	if baby_ball_spawner:
		baby_ball_spawner.set_leadership(new_value)


func _maybe_spawn_fusion_reactor(pos: Vector2) -> void:
	"""Chance to spawn a fusion reactor when enemy dies"""
	# Base 2% chance, +0.1% per wave
	var chance := 0.02 + GameManager.current_wave * 0.001
	if randf() < chance:
		_spawn_fusion_reactor(pos)


func _spawn_fusion_reactor(pos: Vector2) -> void:
	"""Spawn a fusion reactor drop at position"""
	if not gems_container:
		return

	var reactor := fusion_reactor_scene.instantiate()
	reactor.position = pos
	reactor.collected.connect(_on_fusion_reactor_collected)
	gems_container.add_child(reactor)


func _on_fusion_reactor_collected(_reactor: Node2D) -> void:
	"""Handle fusion reactor collection - show fusion UI"""
	if fusion_overlay:
		fusion_overlay.show_fusion_ui()


func spawn_test_boss() -> String:
	"""Spawn a Slime King boss for testing. Returns the boss path (for PlayGodot)."""
	if not slime_king_scene:
		slime_king_scene = load("res://scenes/entities/enemies/bosses/slime_king.tscn")

	var boss = slime_king_scene.instantiate()

	# Get container (may be null if @onready hasn't run yet)
	var container := enemies_container
	if not container:
		container = get_node_or_null("GameArea/Enemies")
	if not container:
		push_error("spawn_test_boss: Could not find enemies container")
		return ""

	container.add_child(boss)
	# Return path as string since PlayGodot can't serialize Node references
	return boss.get_path()


func spawn_test_enemy(scene_path: String) -> String:
	"""Spawn a specific enemy type for testing. Returns the enemy path (for PlayGodot)."""
	var scene: PackedScene = load(scene_path)
	if not scene:
		push_error("spawn_test_enemy: Could not load scene at " + scene_path)
		return ""

	var enemy = scene.instantiate()

	# Get container
	var container := enemies_container
	if not container:
		container = get_node_or_null("GameArea/Enemies")
	if not container:
		push_error("spawn_test_enemy: Could not find enemies container")
		return ""

	# Position enemy on screen
	enemy.global_position = Vector2(360, 200)

	container.add_child(enemy)
	# Return path as string since PlayGodot can't serialize Node references
	return enemy.get_path()


func get_enemy_spawner_path() -> String:
	"""Return the enemy spawner path for testing."""
	return "/root/Game/GameArea/Enemies/EnemySpawner"


func _spawn_boss(stage: int) -> void:
	"""Spawn the appropriate boss for the current stage"""
	# Lazy load boss scenes only when needed (avoids class resolution issues during import)
	if not slime_king_scene:
		slime_king_scene = load("res://scenes/entities/enemies/bosses/slime_king.tscn")
	if not frost_wyrm_scene:
		frost_wyrm_scene = load("res://scenes/entities/enemies/bosses/frost_wyrm.tscn")
	if not sand_golem_scene:
		sand_golem_scene = load("res://scenes/entities/enemies/bosses/sand_golem.tscn")
	if not void_lord_scene:
		void_lord_scene = load("res://scenes/entities/enemies/bosses/void_lord.tscn")

	var boss_scene: PackedScene = null

	# Select boss based on stage
	match stage:
		0:  # The Pit - Slime King
			boss_scene = slime_king_scene
		1:  # Frozen Depths - Frost Wyrm
			boss_scene = frost_wyrm_scene
		2:  # Burning Sands - Sand Golem
			boss_scene = sand_golem_scene
		3:  # Final Descent - Void Lord
			boss_scene = void_lord_scene
		_:
			# Fallback to Slime King
			boss_scene = slime_king_scene

	if not boss_scene:
		# No boss for this stage, auto-complete
		if stage_complete_overlay:
			stage_complete_overlay.show_stage_complete(stage)
		return

	# Instantiate boss
	_current_boss = boss_scene.instantiate()
	enemies_container.add_child(_current_boss)

	# Connect boss signals
	if _current_boss.has_signal("boss_defeated"):
		_current_boss.boss_defeated.connect(_on_boss_defeated)
	if _current_boss.has_signal("died"):
		_current_boss.died.connect(_on_boss_enemy_died)

	# Show boss HP bar
	if boss_hp_bar:
		boss_hp_bar.show_boss(_current_boss)

	# Announce boss
	SoundManager.play(SoundManager.SoundType.WAVE_COMPLETE)


func _on_boss_defeated() -> void:
	"""Handle boss defeat - show stage complete"""
	_current_boss = null

	# Hide boss HP bar
	if boss_hp_bar:
		boss_hp_bar.hide_boss()

	# Record stage completion immediately (before showing overlay)
	# This ensures progress is saved even if player returns to menu
	if MetaManager:
		# Record with character name for gear system (stage is 0-indexed)
		var character_name: String = "Unknown"
		if GameManager.selected_character:
			character_name = GameManager.selected_character.character_name
		MetaManager.record_stage_completion(StageManager.current_stage, character_name)
		# Also record for backwards compatibility
		MetaManager.record_stage_cleared(StageManager.current_stage + 1)  # cleared is 1-indexed

	# Wait a moment then show stage complete
	await get_tree().create_timer(1.5).timeout

	if stage_complete_overlay:
		stage_complete_overlay.show_stage_complete(StageManager.current_stage)


func _on_boss_enemy_died(_enemy: Node) -> void:
	"""Boss died signal handler - record kill"""
	GameManager.record_enemy_kill()


# ============================================================================
# KEYBOARD INPUT HANDLING
# ============================================================================

func _handle_keyboard_input() -> void:
	"""Handle continuous keyboard input for movement and aiming"""
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Get movement direction from WASD
	var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if move_dir.length() > 0.1:
		if player and player.has_method("set_movement_input"):
			player.set_movement_input(move_dir)
	else:
		# Only clear if no joystick is also providing input
		# Check if move joystick is not being used
		if move_joystick and not move_joystick.is_dragging:
			if player and player.has_method("set_movement_input"):
				player.set_movement_input(Vector2.ZERO)

	# Get aim direction from arrow keys
	var aim_dir := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_dir.length() > 0.1:
		_keyboard_aim_direction = aim_dir.normalized()
		_last_keyboard_aim = _keyboard_aim_direction

		# Set aim direction on ball spawner
		if ball_spawner:
			ball_spawner.set_aim_direction(_keyboard_aim_direction)

		# Show aim line from player position
		if aim_line and player:
			aim_line.show_line(_keyboard_aim_direction, player.global_position)
	else:
		# When no aim keys pressed, hide aim line (unless joystick is active)
		if aim_joystick and not aim_joystick.is_dragging:
			if _keyboard_aim_direction.length() > 0:
				_keyboard_aim_direction = Vector2.ZERO
				if aim_line:
					aim_line.hide_line()


func _unhandled_input(event: InputEvent) -> void:
	"""Handle discrete keyboard actions (fire, ultimate, toggle auto, mute)"""

	# Fire with Space (when autofire is off)
	if event.is_action_pressed("fire"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			if fire_button and fire_button.can_fire():
				# If no aim direction, use last known aim or default up
				if ball_spawner and _last_keyboard_aim.length() > 0:
					ball_spawner.set_aim_direction(_last_keyboard_aim)
				fire_button._try_fire()

	# Ultimate with E
	if event.is_action_pressed("ultimate"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			if ultimate_button:
				ultimate_button._try_activate()

	# Toggle autofire with Tab
	if event.is_action_pressed("toggle_auto"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			if fire_button:
				fire_button.toggle_autofire()

	# Toggle mute with M (works anytime)
	if event.is_action_pressed("toggle_mute"):
		SoundManager.toggle_mute()

	# Catch ball with C (when balls are catchable)
	if event.is_action_pressed("catch_ball"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			try_catch_ball()

	# Toggle game speed with R
	if event.is_action_pressed("toggle_speed"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			GameManager.toggle_speed()


func _input(event: InputEvent) -> void:
	"""Handle touch/click input for ball catching in game area"""
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Check for touch or click in the game area (not UI)
	var tap_position: Vector2 = Vector2.ZERO
	var is_tap := false

	if event is InputEventScreenTouch and event.pressed:
		tap_position = event.position
		is_tap = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tap_position = event.position
		is_tap = true

	if is_tap and tap_position.y < CATCH_TAP_ZONE_MAX_Y:
		# Check if there are catchable balls and try to catch
		if ball_spawner and ball_spawner.has_catchable_balls():
			if try_catch_ball():
				get_viewport().set_input_as_handled()
