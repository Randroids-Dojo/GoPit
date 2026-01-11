extends Node
## SoundManager autoload - plays placeholder sounds using procedural audio
## Manages audio settings (volume, mute) with persistence

signal mute_changed(is_muted: bool)

var _players: Array[AudioStreamPlayer] = []
const MAX_PLAYERS := 8
const SAMPLE_RATE := 44100.0
const SETTINGS_PATH := "user://audio_settings.save"

# Audio settings
var master_volume: float = 1.0:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		_apply_bus_volume(0, master_volume)  # Master bus index 0
		_save_settings()

var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)
		var sfx_idx := AudioServer.get_bus_index("SFX")
		if sfx_idx >= 0:
			_apply_bus_volume(sfx_idx, sfx_volume)
		_save_settings()

var music_volume: float = 1.0:
	set(value):
		music_volume = clampf(value, 0.0, 1.0)
		var music_idx := AudioServer.get_bus_index("Music")
		if music_idx >= 0:
			_apply_bus_volume(music_idx, music_volume)
		_save_settings()

var is_muted: bool = false:
	set(value):
		is_muted = value
		AudioServer.set_bus_mute(0, is_muted)
		mute_changed.emit(is_muted)
		_save_settings()

enum SoundType {
	FIRE,
	HIT_WALL,
	HIT_ENEMY,
	ENEMY_DEATH,
	GEM_COLLECT,
	PLAYER_DAMAGE,
	LEVEL_UP,
	GAME_OVER,
	WAVE_COMPLETE,
	BLOCKED,
	# Ball type sounds
	FIRE_BALL,       # Whoosh with crackle
	ICE_BALL,        # Crystal chime
	LIGHTNING_BALL,  # Electric zap
	POISON_BALL,     # Bubbling drip
	BLEED_BALL,      # Wet slice
	IRON_BALL,       # Metallic clang
	# Status effect sounds
	BURN_APPLY,      # Ignition
	FREEZE_APPLY,    # Ice crack
	POISON_APPLY,    # Toxic splash
	BLEED_APPLY,     # Slice
	# Fusion sounds
	FUSION_REACTOR,  # Pickup sound
	EVOLUTION,       # Success fanfare
	FISSION,         # Energy burst
	# Ultimate ability
	ULTIMATE         # Screen-clearing blast
}

# Per-sound pitch/volume variance settings
const SOUND_SETTINGS := {
	SoundType.FIRE: {"pitch_var": 0.15, "vol_var": 0.1},
	SoundType.HIT_WALL: {"pitch_var": 0.2, "vol_var": 0.15},
	SoundType.HIT_ENEMY: {"pitch_var": 0.1, "vol_var": 0.1},
	SoundType.ENEMY_DEATH: {"pitch_var": 0.05, "vol_var": 0.05},
	SoundType.GEM_COLLECT: {"pitch_var": 0.2, "vol_var": 0.1},
	SoundType.PLAYER_DAMAGE: {"pitch_var": 0.05, "vol_var": 0.0},
	SoundType.LEVEL_UP: {"pitch_var": 0.0, "vol_var": 0.0},
	SoundType.GAME_OVER: {"pitch_var": 0.0, "vol_var": 0.0},
	SoundType.WAVE_COMPLETE: {"pitch_var": 0.0, "vol_var": 0.0},
	SoundType.BLOCKED: {"pitch_var": 0.1, "vol_var": 0.0},
	# Ball type sounds
	SoundType.FIRE_BALL: {"pitch_var": 0.1, "vol_var": 0.1},
	SoundType.ICE_BALL: {"pitch_var": 0.15, "vol_var": 0.1},
	SoundType.LIGHTNING_BALL: {"pitch_var": 0.2, "vol_var": 0.1},
	SoundType.POISON_BALL: {"pitch_var": 0.15, "vol_var": 0.1},
	SoundType.BLEED_BALL: {"pitch_var": 0.1, "vol_var": 0.1},
	SoundType.IRON_BALL: {"pitch_var": 0.1, "vol_var": 0.1},
	# Status effect sounds
	SoundType.BURN_APPLY: {"pitch_var": 0.1, "vol_var": 0.1},
	SoundType.FREEZE_APPLY: {"pitch_var": 0.15, "vol_var": 0.1},
	SoundType.POISON_APPLY: {"pitch_var": 0.1, "vol_var": 0.1},
	SoundType.BLEED_APPLY: {"pitch_var": 0.1, "vol_var": 0.1},
	# Fusion sounds
	SoundType.FUSION_REACTOR: {"pitch_var": 0.05, "vol_var": 0.05},
	SoundType.EVOLUTION: {"pitch_var": 0.0, "vol_var": 0.0},
	SoundType.FISSION: {"pitch_var": 0.1, "vol_var": 0.1},
	# Ultimate
	SoundType.ULTIMATE: {"pitch_var": 0.0, "vol_var": 0.0}
}


func _ready() -> void:
	_load_settings()
	for i in MAX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"  # Use SFX bus for sound effects
		add_child(player)
		_players.append(player)


func _apply_bus_volume(bus_idx: int, volume: float) -> void:
	## Convert linear volume (0.0-1.0) to decibels and apply to bus
	if volume <= 0.0:
		AudioServer.set_bus_volume_db(bus_idx, -80.0)  # Effectively silent
	else:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))


func set_master_volume(value: float) -> void:
	master_volume = value


func set_sfx_volume(value: float) -> void:
	sfx_volume = value


func set_music_volume(value: float) -> void:
	music_volume = value


func toggle_mute() -> void:
	is_muted = !is_muted


## Play sound for a specific ball type (when spawning/firing)
func play_ball_type_sound(ball_type: int) -> void:
	# Ball types: NORMAL=0, FIRE=1, ICE=2, LIGHTNING=3, POISON=4, BLEED=5, IRON=6
	match ball_type:
		1: play(SoundType.FIRE_BALL)
		2: play(SoundType.ICE_BALL)
		3: play(SoundType.LIGHTNING_BALL)
		4: play(SoundType.POISON_BALL)
		5: play(SoundType.BLEED_BALL)
		6: play(SoundType.IRON_BALL)
		# NORMAL (0) uses default FIRE sound


## Play sound when status effect is applied to enemy
func play_status_effect_sound(effect_type: int) -> void:
	# StatusEffect.Type: BURN=0, FREEZE=1, POISON=2, BLEED=3
	match effect_type:
		0: play(SoundType.BURN_APPLY)
		1: play(SoundType.FREEZE_APPLY)
		2: play(SoundType.POISON_APPLY)
		3: play(SoundType.BLEED_APPLY)


func _save_settings() -> void:
	var data := {
		"muted": is_muted,
		"master": master_volume,
		"sfx": sfx_volume,
		"music": music_volume
	}
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return

	var data = JSON.parse_string(file.get_as_text())
	if not data:
		return

	# Load and apply settings without triggering save (use backing fields)
	if data.has("muted"):
		is_muted = data["muted"]
	if data.has("master"):
		master_volume = data["master"]
	if data.has("sfx"):
		sfx_volume = data["sfx"]
	if data.has("music"):
		music_volume = data["music"]

	# Apply loaded settings to audio buses
	AudioServer.set_bus_mute(0, is_muted)
	_apply_bus_volume(0, master_volume)

	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx >= 0:
		_apply_bus_volume(sfx_idx, sfx_volume)

	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx >= 0:
		_apply_bus_volume(music_idx, music_volume)


func play(sound_type: SoundType) -> void:
	var player := _get_available_player()
	if not player:
		return

	player.stream = _generate_sound(sound_type)

	# Apply pitch and volume variance
	var settings: Dictionary = SOUND_SETTINGS.get(sound_type, {})
	var pitch_var: float = settings.get("pitch_var", 0.1)
	var vol_var: float = settings.get("vol_var", 0.1)

	player.pitch_scale = randf_range(1.0 - pitch_var, 1.0 + pitch_var)
	player.volume_db = randf_range(-vol_var * 6.0, vol_var * 6.0)

	player.play()


func _get_available_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	return _players[0]  # Fallback to first player


func _generate_sound(sound_type: SoundType) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = int(SAMPLE_RATE)
	wav.stereo = false

	var data: PackedByteArray

	match sound_type:
		SoundType.FIRE:
			data = _generate_blip(0.08, 600.0, 400.0)
		SoundType.HIT_WALL:
			data = _generate_blip(0.05, 200.0, 150.0)
		SoundType.HIT_ENEMY:
			data = _generate_blip(0.1, 400.0, 200.0)
		SoundType.ENEMY_DEATH:
			data = _generate_sweep(0.15, 300.0, 80.0)
		SoundType.GEM_COLLECT:
			data = _generate_blip(0.1, 800.0, 1000.0)
		SoundType.PLAYER_DAMAGE:
			data = _generate_noise(0.12)
		SoundType.LEVEL_UP:
			data = _generate_arpeggio(0.3, [400.0, 500.0, 600.0, 800.0])
		SoundType.GAME_OVER:
			data = _generate_sweep(0.4, 400.0, 100.0)
		SoundType.WAVE_COMPLETE:
			data = _generate_arpeggio(0.4, [523.0, 659.0, 784.0, 1047.0])  # C5-E5-G5-C6
		SoundType.BLOCKED:
			data = _generate_blip(0.05, 100.0, 80.0)  # Short, low, muted click
		# Ball type sounds
		SoundType.FIRE_BALL:
			data = _generate_fire_whoosh()
		SoundType.ICE_BALL:
			data = _generate_ice_chime()
		SoundType.LIGHTNING_BALL:
			data = _generate_electric_zap()
		SoundType.POISON_BALL:
			data = _generate_bubble_drip()
		SoundType.BLEED_BALL:
			data = _generate_wet_slice()
		SoundType.IRON_BALL:
			data = _generate_metallic_clang()
		# Status effect sounds
		SoundType.BURN_APPLY:
			data = _generate_ignition()
		SoundType.FREEZE_APPLY:
			data = _generate_ice_crack()
		SoundType.POISON_APPLY:
			data = _generate_toxic_splash()
		SoundType.BLEED_APPLY:
			data = _generate_slice()
		# Fusion sounds
		SoundType.FUSION_REACTOR:
			data = _generate_reactor_pickup()
		SoundType.EVOLUTION:
			data = _generate_evolution_fanfare()
		SoundType.FISSION:
			data = _generate_energy_burst()
		# Ultimate
		SoundType.ULTIMATE:
			data = _generate_ultimate_blast_sound()

	wav.data = data
	return wav


func _generate_blip(duration: float, freq_start: float, freq_end: float) -> PackedByteArray:
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)  # 16-bit = 2 bytes

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var freq := lerpf(freq_start, freq_end, progress)
		var envelope := 1.0 - progress  # Linear fade out
		var sample := sin(t * freq * TAU) * envelope * 0.3
		var sample_16 := int(clampf(sample, -1.0, 1.0) * 32767)
		data.encode_s16(i * 2, sample_16)

	return data


func _generate_sweep(duration: float, freq_start: float, freq_end: float) -> PackedByteArray:
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var freq := lerpf(freq_start, freq_end, progress)
		var envelope := (1.0 - progress) * (1.0 - progress)  # Quadratic fade
		var sample := sin(t * freq * TAU) * envelope * 0.25
		sample += sin(t * freq * 0.5 * TAU) * envelope * 0.15  # Sub harmonic
		var sample_16 := int(clampf(sample, -1.0, 1.0) * 32767)
		data.encode_s16(i * 2, sample_16)

	return data


func _generate_noise(duration: float) -> PackedByteArray:
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var progress := float(i) / samples
		var envelope := 1.0 - progress
		var sample := (randf() * 2.0 - 1.0) * envelope * 0.2
		var sample_16 := int(clampf(sample, -1.0, 1.0) * 32767)
		data.encode_s16(i * 2, sample_16)

	return data


func _generate_arpeggio(duration: float, frequencies: Array) -> PackedByteArray:
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var note_samples := samples / frequencies.size()

	for i in samples:
		var note_index := mini(i / note_samples, frequencies.size() - 1)
		var freq: float = frequencies[note_index]
		var t := float(i) / SAMPLE_RATE
		var note_progress := float(i % note_samples) / note_samples
		var envelope := 1.0 - note_progress * 0.5  # Per-note envelope
		var overall_envelope := 1.0 - float(i) / samples * 0.3  # Overall fade
		var sample := sin(t * freq * TAU) * envelope * overall_envelope * 0.25
		var sample_16 := int(clampf(sample, -1.0, 1.0) * 32767)
		data.encode_s16(i * 2, sample_16)

	return data


# ============================================================================
# Ball Type Sounds
# ============================================================================

func _generate_fire_whoosh() -> PackedByteArray:
	"""Fire ball: Whoosh with crackle"""
	var samples := int(SAMPLE_RATE * 0.15)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 0.5)

		# White noise for whoosh
		var noise := (randf() * 2.0 - 1.0) * 0.3
		# Low frequency modulation for warmth
		var warm := sin(t * 150.0 * TAU) * 0.2
		# Crackle (random high-frequency pops)
		var crackle := 0.0
		if randf() < 0.1:
			crackle = (randf() * 2.0 - 1.0) * 0.4

		var sample := (noise + warm + crackle) * envelope * 0.25
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


func _generate_ice_chime() -> PackedByteArray:
	"""Ice ball: Crystal chime"""
	var samples := int(SAMPLE_RATE * 0.2)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 1.5)

		# High frequencies for crystal
		var crystal := sin(t * 1200.0 * TAU) * 0.4
		crystal += sin(t * 1800.0 * TAU) * 0.25
		crystal += sin(t * 2400.0 * TAU) * 0.15
		# Add slight shimmer
		var shimmer := sin(t * 50.0 * TAU) * 0.1

		var sample := crystal * (1.0 + shimmer) * envelope * 0.2
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


func _generate_electric_zap() -> PackedByteArray:
	"""Lightning ball: Electric zap"""
	var samples := int(SAMPLE_RATE * 0.1)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 2.0)

		# Square wave for electric buzz
		var phase := fmod(t * 800.0, 1.0)
		var buzz := (1.0 if phase < 0.5 else -1.0) * 0.3
		# Modulated by high frequency
		buzz *= sin(t * 4000.0 * TAU) * 0.5 + 0.5
		# Add some noise
		var noise := (randf() * 2.0 - 1.0) * 0.2

		var sample := (buzz + noise) * envelope * 0.25
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


func _generate_bubble_drip() -> PackedByteArray:
	"""Poison ball: Bubbling drip"""
	var samples := int(SAMPLE_RATE * 0.15)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 0.7)

		# Bubble pops at random intervals
		var freq := 300.0 + sin(t * 20.0 * TAU) * 100.0
		var bubble := sin(t * freq * TAU) * 0.4
		# Low gurgle
		var gurgle := sin(t * 80.0 * TAU) * 0.2

		var sample := (bubble + gurgle) * envelope * 0.2
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


func _generate_wet_slice() -> PackedByteArray:
	"""Bleed ball: Wet slice"""
	var samples := int(SAMPLE_RATE * 0.08)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 1.5)

		# Sharp attack with noise
		var noise := (randf() * 2.0 - 1.0)
		# Filtered sweep
		var sweep := sin(t * lerpf(500.0, 200.0, progress) * TAU) * 0.3

		var sample := (noise * 0.3 + sweep) * envelope * 0.25
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


func _generate_metallic_clang() -> PackedByteArray:
	"""Iron ball: Metallic clang"""
	var samples := int(SAMPLE_RATE * 0.2)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 2.0)

		# Multiple harmonics for metallic sound
		var metal := sin(t * 400.0 * TAU) * 0.3
		metal += sin(t * 800.0 * TAU) * 0.2
		metal += sin(t * 1600.0 * TAU) * 0.15
		metal += sin(t * 3200.0 * TAU) * 0.1
		# Slight detuning for realism
		metal *= 1.0 + sin(t * 5.0 * TAU) * 0.02

		var sample := metal * envelope * 0.25
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


# ============================================================================
# Status Effect Sounds
# ============================================================================

func _generate_ignition() -> PackedByteArray:
	"""Burn apply: Ignition whoosh"""
	var samples := int(SAMPLE_RATE * 0.2)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples

		# Fast attack, medium decay
		var envelope: float
		if progress < 0.1:
			envelope = progress / 0.1
		else:
			envelope = pow(1.0 - (progress - 0.1) / 0.9, 0.5)

		# Rising whoosh with noise
		var freq := lerpf(100.0, 400.0, progress)
		var whoosh := sin(t * freq * TAU) * 0.3
		var noise := (randf() * 2.0 - 1.0) * 0.3

		var sample := (whoosh + noise) * envelope * 0.2
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


func _generate_ice_crack() -> PackedByteArray:
	"""Freeze apply: Ice crack"""
	var samples := int(SAMPLE_RATE * 0.15)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples

		# Sharp attack
		var envelope := pow(1.0 - progress, 2.5)

		# Cracking sound with high-freq components
		var crack := sin(t * 2000.0 * TAU) * 0.3
		crack += sin(t * 3500.0 * TAU) * 0.2
		# Noise burst at start
		var noise := (randf() * 2.0 - 1.0) * (1.0 if progress < 0.05 else 0.1)

		var sample := (crack + noise) * envelope * 0.25
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


func _generate_toxic_splash() -> PackedByteArray:
	"""Poison apply: Toxic splash"""
	var samples := int(SAMPLE_RATE * 0.18)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 0.8)

		# Wet splash with bubbles
		var splash := sin(t * 200.0 * TAU) * 0.3
		var bubbles := sin(t * 600.0 * TAU) * sin(t * 15.0 * TAU) * 0.2
		var noise := (randf() * 2.0 - 1.0) * 0.15

		var sample := (splash + bubbles + noise) * envelope * 0.2
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


func _generate_slice() -> PackedByteArray:
	"""Bleed apply: Sharp slice"""
	var samples := int(SAMPLE_RATE * 0.1)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 3.0)

		# Sharp attack with downward sweep
		var freq := lerpf(1500.0, 300.0, progress)
		var slice := sin(t * freq * TAU) * 0.4
		var noise := (randf() * 2.0 - 1.0) * 0.2 * (1.0 - progress)

		var sample := (slice + noise) * envelope * 0.25
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


# ============================================================================
# Fusion Sounds
# ============================================================================

func _generate_reactor_pickup() -> PackedByteArray:
	"""Fusion reactor: Magical pickup"""
	var samples := int(SAMPLE_RATE * 0.3)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples
		var envelope := pow(1.0 - progress, 0.5)

		# Rising magical tone
		var freq := lerpf(300.0, 800.0, progress)
		var tone := sin(t * freq * TAU) * 0.3
		# Sparkle
		var sparkle := sin(t * 2000.0 * TAU) * sin(t * 30.0 * TAU) * 0.15

		var sample := (tone + sparkle) * envelope * 0.25
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


func _generate_evolution_fanfare() -> PackedByteArray:
	"""Evolution: Success fanfare"""
	return _generate_arpeggio(0.4, [523.0, 659.0, 784.0, 1047.0, 1319.0])  # C5-E5-G5-C6-E6


func _generate_energy_burst() -> PackedByteArray:
	"""Fission: Energy burst"""
	var samples := int(SAMPLE_RATE * 0.25)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples

		# Sharp attack, slow decay
		var envelope: float
		if progress < 0.05:
			envelope = progress / 0.05
		else:
			envelope = pow(1.0 - (progress - 0.05) / 0.95, 0.7)

		# Multiple frequencies spreading out
		var freq1 := lerpf(400.0, 200.0, progress)
		var freq2 := lerpf(400.0, 600.0, progress)
		var freq3 := lerpf(400.0, 1000.0, progress)

		var burst := sin(t * freq1 * TAU) * 0.3
		burst += sin(t * freq2 * TAU) * 0.25
		burst += sin(t * freq3 * TAU) * 0.2
		var noise := (randf() * 2.0 - 1.0) * 0.1

		var sample := (burst + noise) * envelope * 0.2
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data


# ============================================================================
# Ultimate Ability Sound
# ============================================================================

func _generate_ultimate_blast_sound() -> PackedByteArray:
	"""Ultimate ability: Epic power blast with rising tone and explosion"""
	var samples := int(SAMPLE_RATE * 0.6)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / SAMPLE_RATE
		var progress := float(i) / samples

		# Three-phase envelope: rise, peak, decay
		var envelope: float
		if progress < 0.15:
			# Rising power-up
			envelope = progress / 0.15
		elif progress < 0.25:
			# Peak explosion
			envelope = 1.0
		else:
			# Long decay
			envelope = pow(1.0 - (progress - 0.25) / 0.75, 0.5)

		# Rising pitch during power-up phase
		var base_freq: float
		if progress < 0.15:
			base_freq = lerpf(200.0, 800.0, progress / 0.15)
		else:
			base_freq = lerpf(800.0, 200.0, (progress - 0.15) / 0.85)

		# Multiple harmonics for full sound
		var tone := sin(t * base_freq * TAU) * 0.3
		tone += sin(t * base_freq * 2.0 * TAU) * 0.2
		tone += sin(t * base_freq * 3.0 * TAU) * 0.1

		# Add explosion noise during peak
		var noise := 0.0
		if progress > 0.1 and progress < 0.4:
			var noise_amount: float = 1.0 - abs(progress - 0.2) / 0.2
			noise = (randf() * 2.0 - 1.0) * noise_amount * 0.3

		# Low rumble throughout
		var rumble := sin(t * 60.0 * TAU) * 0.15

		var sample := (tone + noise + rumble) * envelope * 0.25
		data.encode_s16(i * 2, int(clampf(sample, -1.0, 1.0) * 32767))

	return data
