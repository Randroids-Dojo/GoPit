extends Node
## MusicManager - Procedural background music that intensifies with gameplay

const SAMPLE_RATE := 44100.0
const BPM := 120.0
const BEAT_DURATION := 60.0 / BPM

var _bass_player: AudioStreamPlayer
var _drum_player: AudioStreamPlayer
var _melody_player: AudioStreamPlayer

var is_playing: bool = false
var current_intensity: float = 1.0  # Increases with wave

# Music state
var _beat_timer: Timer
var _current_beat: int = 0
var _bar_length: int = 4

# Bass pattern (notes relative to root)
var _bass_pattern: Array[int] = [0, 0, 7, 5, 0, 0, 3, 5]
var _root_note: float = 110.0  # A2

# Drum pattern (1 = kick, 2 = snare, 3 = hihat)
var _drum_pattern: Array[int] = [1, 3, 2, 3, 1, 3, 2, 3]


func _ready() -> void:
	_setup_players()
	_setup_timer()


func _setup_players() -> void:
	_bass_player = AudioStreamPlayer.new()
	_bass_player.bus = "Master"
	_bass_player.volume_db = -8.0
	add_child(_bass_player)

	_drum_player = AudioStreamPlayer.new()
	_drum_player.bus = "Master"
	_drum_player.volume_db = -6.0
	add_child(_drum_player)

	_melody_player = AudioStreamPlayer.new()
	_melody_player.bus = "Master"
	_melody_player.volume_db = -10.0
	add_child(_melody_player)


func _setup_timer() -> void:
	_beat_timer = Timer.new()
	_beat_timer.wait_time = BEAT_DURATION / 2.0  # Eighth notes
	_beat_timer.timeout.connect(_on_beat)
	add_child(_beat_timer)


func start_music() -> void:
	if is_playing:
		return
	is_playing = true
	current_intensity = 1.0
	_current_beat = 0
	_beat_timer.start()


func stop_music() -> void:
	is_playing = false
	_beat_timer.stop()


func set_intensity(intensity: float) -> void:
	current_intensity = clampf(intensity, 1.0, 5.0)
	_bass_player.volume_db = lerpf(-12.0, -4.0, (intensity - 1.0) / 4.0)
	_drum_player.volume_db = lerpf(-10.0, -2.0, (intensity - 1.0) / 4.0)


func _on_beat() -> void:
	if not is_playing:
		return

	var beat_index: int = _current_beat % _bass_pattern.size()

	# Play bass on every beat
	_play_bass(_bass_pattern[beat_index])

	# Play drums
	var drum_type: int = _drum_pattern[beat_index]
	_play_drum(drum_type)

	# Occasional melody at higher intensity
	if current_intensity >= 2.0 and randf() < 0.2:
		_play_melody_note()

	_current_beat += 1


func _play_bass(semitone: int) -> void:
	var freq: float = _root_note * pow(2.0, semitone / 12.0)
	_bass_player.stream = _generate_bass_note(freq, BEAT_DURATION * 0.45)
	_bass_player.play()


func _play_drum(drum_type: int) -> void:
	match drum_type:
		1:  # Kick
			_drum_player.stream = _generate_kick()
		2:  # Snare
			_drum_player.stream = _generate_snare()
		3:  # Hihat
			_drum_player.stream = _generate_hihat()
	_drum_player.play()


func _play_melody_note() -> void:
	var scale: Array[int] = [0, 2, 3, 5, 7, 10, 12]  # Minor pentatonic
	var note: int = scale[randi() % scale.size()]
	var freq: float = _root_note * 4.0 * pow(2.0, note / 12.0)  # Two octaves up
	_melody_player.stream = _generate_melody_note(freq, BEAT_DURATION * 0.3)
	_melody_player.play()


func _generate_bass_note(freq: float, duration: float) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = int(SAMPLE_RATE)
	wav.stereo = false

	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t: float = float(i) / SAMPLE_RATE
		var progress: float = float(i) / samples

		# Attack-decay envelope
		var envelope: float
		if progress < 0.05:
			envelope = progress / 0.05
		else:
			envelope = pow(1.0 - (progress - 0.05) / 0.95, 0.5)

		# Sub bass with slight saw character
		var phase: float = fmod(t * freq, 1.0)
		var sample: float = sin(t * freq * TAU) * 0.6
		sample += (phase * 2.0 - 1.0) * 0.2  # Slight saw
		sample += sin(t * freq * 0.5 * TAU) * 0.3  # Sub octave

		sample *= envelope * 0.3
		var sample_16: int = int(clampf(sample, -1.0, 1.0) * 32767)
		data.encode_s16(i * 2, sample_16)

	wav.data = data
	return wav


func _generate_kick() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = int(SAMPLE_RATE)
	wav.stereo = false

	var duration: float = 0.15
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t: float = float(i) / SAMPLE_RATE
		var progress: float = float(i) / samples

		# Pitch drops from 150Hz to 50Hz quickly
		var freq: float = lerpf(150.0, 50.0, pow(progress, 0.3))
		var envelope: float = pow(1.0 - progress, 2.0)

		var sample: float = sin(t * freq * TAU) * envelope * 0.5
		var sample_16: int = int(clampf(sample, -1.0, 1.0) * 32767)
		data.encode_s16(i * 2, sample_16)

	wav.data = data
	return wav


func _generate_snare() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = int(SAMPLE_RATE)
	wav.stereo = false

	var duration: float = 0.12
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var progress: float = float(i) / samples
		var envelope: float = pow(1.0 - progress, 1.5)

		# Noise with some tonal component
		var noise: float = (randf() * 2.0 - 1.0) * 0.6
		var tone: float = sin(float(i) / SAMPLE_RATE * 200.0 * TAU) * 0.3

		var sample: float = (noise + tone) * envelope * 0.3
		var sample_16: int = int(clampf(sample, -1.0, 1.0) * 32767)
		data.encode_s16(i * 2, sample_16)

	wav.data = data
	return wav


func _generate_hihat() -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = int(SAMPLE_RATE)
	wav.stereo = false

	var duration: float = 0.05
	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var progress: float = float(i) / samples
		var envelope: float = pow(1.0 - progress, 3.0)

		# High-frequency noise
		var sample: float = (randf() * 2.0 - 1.0) * envelope * 0.15
		var sample_16: int = int(clampf(sample, -1.0, 1.0) * 32767)
		data.encode_s16(i * 2, sample_16)

	wav.data = data
	return wav


func _generate_melody_note(freq: float, duration: float) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = int(SAMPLE_RATE)
	wav.stereo = false

	var samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t: float = float(i) / SAMPLE_RATE
		var progress: float = float(i) / samples

		# Quick attack, slow decay
		var envelope: float
		if progress < 0.02:
			envelope = progress / 0.02
		else:
			envelope = pow(1.0 - (progress - 0.02) / 0.98, 0.7)

		# Simple sine with slight vibrato
		var vibrato: float = sin(t * 5.0 * TAU) * 0.01
		var sample: float = sin(t * freq * (1.0 + vibrato) * TAU) * envelope * 0.2

		var sample_16: int = int(clampf(sample, -1.0, 1.0) * 32767)
		data.encode_s16(i * 2, sample_16)

	wav.data = data
	return wav
