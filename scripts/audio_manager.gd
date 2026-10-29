# audio_manager.gd
# Global singleton — handles all game audio.
extends Node

var _sfx_players: Array = []
var _music_player: AudioStreamPlayer = null
var _voice_player: AudioStreamPlayer = null

# Preloaded sound effects
var _sounds: Dictionary = {}

const SFX_POOL_SIZE: int = 8  # max simultaneous SFX

func _ready() -> void:
	# Create SFX player pool
	for i in range(SFX_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)

	# Create music player
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	_music_player.volume_db = -6.0
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)

	# Create voice player (separate so it doesn't compete with SFX/music)
	_voice_player = AudioStreamPlayer.new()
	_voice_player.bus = "Master"
	_voice_player.volume_db = 0.0
	add_child(_voice_player)

	# Load all sounds
	_load_sounds()

var _current_track: String = "music"

# Normal music rotation — cycles through tracks each time one finishes
var _normal_tracks: Array = []
var _normal_track_index: int = 0

# Radio DJ system — plays clips between songs like a real radio station
var _radio_clips: Array = []       # shuffled queue of radio clip names
var _radio_clip_index: int = 0
var _play_radio_next: bool = false  # alternates: song -> radio -> song -> radio

func _load_sounds() -> void:
	var sound_files = [
		"sfx_shoot", "sfx_laser", "sfx_spread",
		"sfx_explosion", "sfx_pickup", "sfx_hit",
		"sfx_death", "sfx_trade", "sfx_mine",
		"sfx_win", "sfx_gameover", "sfx_enemy_shoot",
		"sfx_boss_warning",
	]
	for sname in sound_files:
		var path = "res://assets/sounds/%s.wav" % sname
		if ResourceLoader.exists(path):
			_sounds[sname] = load(path)

	# Load voice lines
	var voice_files = [
		"voice_intro", "voice_win",
		"voice_death", "voice_fuel",
	]
	for vname in voice_files:
		var path = "res://assets/sounds/%s.mp3" % vname
		if ResourceLoader.exists(path):
			_sounds[vname] = load(path)

	# Load music tracks
	var boss_path = "res://assets/sounds/music_boss.mp3"
	if ResourceLoader.exists(boss_path):
		_sounds["music_boss"] = load(boss_path)

	var nebula_path = "res://assets/sounds/music_nebula.mp3"
	if ResourceLoader.exists(nebula_path):
		_sounds["music_nebula"] = load(nebula_path)

	var death_path = "res://assets/sounds/music_death.mp3"
	if ResourceLoader.exists(death_path):
		_sounds["music_death"] = load(death_path)

	var dogfight_path = "res://assets/sounds/music_cosmic_dogfight.mp3"
	if ResourceLoader.exists(dogfight_path):
		_sounds["music_cosmic_dogfight"] = load(dogfight_path)

	var intro_path = "res://assets/sounds/music_intro.mp3"
	if ResourceLoader.exists(intro_path):
		_sounds["music_intro"] = load(intro_path)

	var mothership_path = "res://assets/sounds/music_mothership.mp3"
	if ResourceLoader.exists(mothership_path):
		_sounds["music_mothership"] = load(mothership_path)

	var void_runner_path = "res://assets/sounds/music_void_runner.mp3"
	if ResourceLoader.exists(void_runner_path):
		_sounds["music_void_runner"] = load(void_runner_path)

	var black_market_path = "res://assets/sounds/music_black_market.mp3"
	if ResourceLoader.exists(black_market_path):
		_sounds["music_black_market"] = load(black_market_path)

	# Build normal music rotation
	_normal_tracks.clear()
	if "music_cosmic_dogfight" in _sounds:
		_normal_tracks.append("music_cosmic_dogfight")
	if "music_void_runner" in _sounds:
		_normal_tracks.append("music_void_runner")
	if "music_black_market" in _sounds:
		_normal_tracks.append("music_black_market")
	if "music_nebula" in _sounds:
		_normal_tracks.append("music_nebula")

	# Load radio clips — scans for radio_01 through radio_99
	_radio_clips.clear()
	for i in range(1, 100):
		var clip_name = "radio_%02d" % i
		var clip_path = "res://assets/sounds/%s.mp3" % clip_name
		if ResourceLoader.exists(clip_path):
			_sounds[clip_name] = load(clip_path)
			_radio_clips.append(clip_name)
		else:
			break  # stop at first gap
	# Shuffle so broadcasts feel random
	_radio_clips.shuffle()
	_radio_clip_index = 0

	# Alias for backward compat
	if not _normal_tracks.is_empty():
		_sounds["music"] = _sounds[_normal_tracks[0]]

func play_sfx(sound_name: String, volume_db: float = 0.0) -> void:
	if sound_name not in _sounds:
		return
	# Find a free player
	for player in _sfx_players:
		if not player.playing:
			player.stream = _sounds[sound_name]
			player.volume_db = volume_db
			player.play()
			return
	# All busy — steal the first one
	_sfx_players[0].stream = _sounds[sound_name]
	_sfx_players[0].volume_db = volume_db
	_sfx_players[0].play()

func play_music(track: String = "music") -> void:
	if track not in _sounds:
		return
	# Don't restart if already playing this track
	if _current_track == track and _music_player.playing:
		return
	_current_track = track
	_music_player.stream = _sounds[track]
	_music_player.play()

func switch_to_boss_music() -> void:
	play_music("music_boss")

func switch_to_mothership_music() -> void:
	if "music_mothership" in _sounds:
		play_music("music_mothership")
	else:
		play_music("music_boss")  # fallback

func switch_to_normal_music() -> void:
	# Start from current rotation position
	if _normal_tracks.is_empty():
		play_music("music")
	else:
		play_music(_normal_tracks[_normal_track_index])

func play_voice(voice_name: String) -> void:
	if voice_name not in _sounds:
		return
	_voice_player.stream = _sounds[voice_name]
	_voice_player.play()

func stop_voice() -> void:
	_voice_player.stop()

func is_voice_playing() -> bool:
	return _voice_player.playing

func stop_music() -> void:
	_music_player.stop()

func _on_music_finished() -> void:
	# Boss/mothership/special tracks just loop themselves
	if _current_track not in _normal_tracks and _current_track not in _radio_clips:
		_music_player.play()
		return

	# Radio station pattern: Song -> Radio -> Song -> Radio
	if _play_radio_next and not _radio_clips.is_empty():
		# Play next radio clip
		_play_radio_next = false
		_current_track = _radio_clips[_radio_clip_index]
		_radio_clip_index += 1
		# Reshuffle when we've played them all
		if _radio_clip_index >= _radio_clips.size():
			_radio_clips.shuffle()
			_radio_clip_index = 0
		_music_player.stream = _sounds[_current_track]
		_music_player.volume_db = -3.0  # radio clips slightly louder (voice)
		_music_player.play()
	else:
		# Play next song
		_play_radio_next = true  # next time, play a radio clip
		_normal_track_index = (_normal_track_index + 1) % _normal_tracks.size()
		_current_track = _normal_tracks[_normal_track_index]
		_music_player.stream = _sounds[_current_track]
		_music_player.volume_db = -6.0  # normal music volume
		_music_player.play()
