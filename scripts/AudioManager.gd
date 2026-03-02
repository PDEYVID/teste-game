extends Node

const SAMPLE_RATE: int = 22050

var sfx_volume_db: float = -8.0
var music_volume_db: float = -18.0
var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	_music_player.volume_db = music_volume_db
	_music_player.stream = _build_music_stream()
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)
	_music_player.play()

func play_shoot() -> void:
	_play_tone(760.0, 0.06, "square", -12.0, -200.0)

func play_enemy_hit(is_crit: bool = false) -> void:
	if is_crit:
		_play_tone(260.0, 0.10, "saw", -6.0, 180.0)
		_play_tone(520.0, 0.08, "sine", -10.0, -80.0)
	else:
		_play_tone(210.0, 0.05, "noise", -10.0, -20.0)

func play_player_hit() -> void:
	_play_tone(140.0, 0.12, "noise", -7.0, -40.0)
	_play_tone(120.0, 0.10, "sine", -12.0, -30.0)

func play_dash() -> void:
	_play_tone(330.0, 0.08, "sine", -11.0, 240.0)

func play_level_up() -> void:
	_play_sequence([
		{"freq": 523.25, "dur": 0.08, "wave": "square", "vol": -10.0, "slide": 0.0},
		{"freq": 659.25, "dur": 0.08, "wave": "square", "vol": -9.0, "slide": 0.0},
		{"freq": 783.99, "dur": 0.12, "wave": "sine", "vol": -8.0, "slide": 30.0}
	], 0.05)

func play_upgrade_select() -> void:
	_play_tone(700.0, 0.06, "square", -9.0, 120.0)

func play_game_over() -> void:
	_play_sequence([
		{"freq": 320.0, "dur": 0.11, "wave": "sine", "vol": -9.0, "slide": -60.0},
		{"freq": 240.0, "dur": 0.12, "wave": "sine", "vol": -8.0, "slide": -70.0},
		{"freq": 180.0, "dur": 0.14, "wave": "sine", "vol": -7.0, "slide": -80.0}
	], 0.04)

func play_boss_spawn() -> void:
	_play_sequence([
		{"freq": 120.0, "dur": 0.10, "wave": "saw", "vol": -6.0, "slide": 10.0},
		{"freq": 110.0, "dur": 0.10, "wave": "saw", "vol": -6.0, "slide": -10.0},
		{"freq": 100.0, "dur": 0.14, "wave": "saw", "vol": -5.0, "slide": -20.0}
	], 0.05)

func _on_music_finished() -> void:
	if _music_player:
		_music_player.stream = _build_music_stream()
		_music_player.play()

func _play_sequence(notes: Array, gap: float) -> void:
	_play_sequence_async(notes, gap)

func _play_sequence_async(notes: Array, gap: float) -> void:
	for note in notes:
		_play_tone(
			note.get("freq", 440.0),
			note.get("dur", 0.08),
			note.get("wave", "sine"),
			note.get("vol", -10.0),
			note.get("slide", 0.0)
		)
		await get_tree().create_timer(gap).timeout

func _play_tone(freq: float, duration: float, wave: String, volume_db: float, pitch_slide: float) -> void:
	var stream := _build_stream(freq, duration, wave, pitch_slide)
	var player := AudioStreamPlayer.new()
	player.bus = "Master"
	player.volume_db = volume_db + sfx_volume_db
	player.stream = stream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _build_stream(freq: float, duration: float, wave: String, pitch_slide: float) -> AudioStreamWAV:
	var total_samples: int = max(1, int(duration * SAMPLE_RATE))
	var data := PackedByteArray()
	data.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var lerp_t: float = float(i) / float(total_samples)
		var current_freq: float = max(20.0, freq + pitch_slide * lerp_t)
		phase += TAU * current_freq / float(SAMPLE_RATE)

		var sample: float = _sample_wave(phase, wave)
		var env: float = _envelope(lerp_t)
		sample *= env

		var s16: int = int(clamp(sample, -1.0, 1.0) * 32767.0)
		if s16 < 0:
			s16 += 65536
		data[i * 2] = s16 & 0xFF
		data[i * 2 + 1] = (s16 >> 8) & 0xFF

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	wav.data = data
	return wav

func _build_music_stream() -> AudioStreamWAV:
	var notes: Array = [
		220.0, 261.63, 293.66, 329.63,
		293.66, 261.63, 246.94, 196.0
	]
	var note_duration: float = 0.42
	var total_samples: int = max(1, int(float(notes.size()) * note_duration * SAMPLE_RATE))
	var data := PackedByteArray()
	data.resize(total_samples * 2)

	var global_phase: float = 0.0
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var note_index: int = clamp(int(t / note_duration), 0, notes.size() - 1)
		var freq: float = float(notes[note_index])
		global_phase += TAU * freq / float(SAMPLE_RATE)

		var pad: float = sin(global_phase) * 0.45
		var sub: float = sin(global_phase * 0.5) * 0.22
		var arp: float = (1.0 if sin(global_phase * 2.0) >= 0.0 else -1.0) * 0.13
		var note_pos: float = fposmod(t, note_duration) / note_duration
		var env: float = min(1.0, note_pos / 0.1) * min(1.0, (1.0 - note_pos) / 0.2)
		var sample: float = (pad + sub + arp) * env * 0.65

		var s16: int = int(clamp(sample, -1.0, 1.0) * 32767.0)
		if s16 < 0:
			s16 += 65536
		data[i * 2] = s16 & 0xFF
		data[i * 2 + 1] = (s16 >> 8) & 0xFF

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	wav.data = data
	return wav

func _sample_wave(phase: float, wave: String) -> float:
	match wave:
		"square":
			return 1.0 if sin(phase) >= 0.0 else -1.0
		"saw":
			var p := fposmod(phase / TAU, 1.0)
			return p * 2.0 - 1.0
		"noise":
			return randf_range(-1.0, 1.0)
		_:
			return sin(phase)

func _envelope(t: float) -> float:
	var attack: float = 0.08
	var release: float = 0.25
	var attack_env: float = min(1.0, t / attack)
	var release_env: float = min(1.0, (1.0 - t) / release)
	return min(attack_env, release_env)
