extends Node2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer: Timer = $Timer

var vol_increase_delay: float = 5 # every 5 seconds
var vol_increase_amount: float = 2 # increase the volume by x db

func _ready() -> void:
	audio_player.autoplay = true
	timer.wait_time = vol_increase_delay
	timer.start()

func _on_audio_stream_player_2d_finished() -> void:
	audio_player.play()
	audio_player.volume_db = 0

func _on_timer_timeout() -> void:
	audio_player.volume_db += vol_increase_amount
