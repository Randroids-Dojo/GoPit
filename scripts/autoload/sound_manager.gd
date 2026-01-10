extends Node
## SoundManager autoload - plays placeholder sounds using procedural audio
## Manages audio settings (volume, mute) with persistence

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
	BLOCKED
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
	SoundType.BLOCKED: {"pitch_var": 0.1, "vol_var": 0.0}
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
