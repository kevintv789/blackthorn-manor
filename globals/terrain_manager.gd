extends Node

const WOOD = "wood"
const MARBLE = "marble"
const RUG = "rug"
const NONE = "none"

const WOOD_SOUNDS: Array[String] = [
	"res://assets/audio/wood/wood_01_a.wav",
	"res://assets/audio/wood/wood_01_b.wav",
	"res://assets/audio/wood/wood_01_c.wav",
	"res://assets/audio/wood/wood_01_d.wav",
]

const MARBLE_SOUNDS: Array[String] = [
	"res://assets/audio/stone/stone_01_a.wav",
	"res://assets/audio/stone/stone_01_b.wav",
	"res://assets/audio/stone/stone_01_c.wav",
	"res://assets/audio/stone/stone_01_d.wav",
]

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var tile_map_layers = get_tree().get_nodes_in_group("Terrain") as Array[TileMapLayer]

var audio_player: AudioStreamPlayer = null
var last_sound_time: float = 0.0
var last_played_sound_index: int = 0
var is_on_rug: bool = false
const SOUND_COOLDOWN: float = 0.5
const AUDIO_VOLUME_DB: float = -15
const RUG_AUDIO_VOLUME_DB_ADJUSTMENT: float = -10

func _ready() -> void:
	initialize_audio_player()

func _physics_process(_delta: float) -> void:
	if player.is_moving():
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_sound_time >= SOUND_COOLDOWN:
			var tile_type = get_tile_type()
			if tile_type == WOOD:
				play_sound(WOOD_SOUNDS)
			elif tile_type == MARBLE:
				play_sound(MARBLE_SOUNDS)
			last_sound_time = current_time
	else:
		audio_player.stop()

# Checks the topmost tile type at the player's position
func get_tile_type() -> String:
	var topmost_tile_type = NONE
	for tml in tile_map_layers:
		var on_cell = tml.local_to_map(tml.to_local(player.global_position))
		var tile_data: TileData = tml.get_cell_tile_data(on_cell)
		if tile_data:
			var material = tile_data.get_custom_data("material")
			if material and material != RUG:
				topmost_tile_type = material
				is_on_rug = false
			else:
				is_on_rug = true

	return topmost_tile_type

func initialize_audio_player() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = AUDIO_VOLUME_DB

func play_sound(sound_paths: Array[String]) -> void:
	audio_player.stream = load(sound_paths[last_played_sound_index])

	if is_on_rug:
		audio_player.volume_db = AUDIO_VOLUME_DB + RUG_AUDIO_VOLUME_DB_ADJUSTMENT
	else:
		audio_player.volume_db = AUDIO_VOLUME_DB

	audio_player.play()
	last_played_sound_index += 1
	if last_played_sound_index >= sound_paths.size():
		last_played_sound_index = 0
	last_sound_time = Time.get_ticks_msec() / 1000.0
