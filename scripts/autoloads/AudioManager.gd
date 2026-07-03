extends Node

# =====================================================
# AudioManager.gd - Autoload
# Manejo centralizado de audio
# Responsable: Cricko (Semana 10)
# =====================================================

@onready var _music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var _sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

var music_volume: float = 1.0
var sfx_volume: float = 1.0


func _ready() -> void:
	add_child(_music_player)
	add_child(_sfx_player)
	_music_player.bus = "Music"
	_sfx_player.bus = "SFX"


func play_music(stream: AudioStream, loop: bool = true) -> void:
	_music_player.stream = stream
	_music_player.volume_db = linear_to_db(music_volume)
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func play_sfx(stream: AudioStream) -> void:
	_sfx_player.stream = stream
	_sfx_player.volume_db = linear_to_db(sfx_volume)
	_sfx_player.play()


func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	_music_player.volume_db = linear_to_db(music_volume)


func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
