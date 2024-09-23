extends PointLight2D

@onready var player_light: Light2D = $"../PlayerLight"

var audio_player: AudioStreamPlayer = null

const FLASHLIGHT_CLICK_ON_SOUND_PATH: String = "res://assets/audio/flashlight/flashlight_click_on.wav"
const FLASHLIGHT_CLICK_OFF_SOUND_PATH: String = "res://assets/audio/flashlight/flashlight_click_off.wav"
const AUDIO_VOLUME_DB: float = -5

func _ready() -> void:
	visible = false
	initialize_player_light()
	initialize_audio_player()

func _process(_delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)
	update_flashlight_size()

func _input(event: InputEvent) -> void:
	# Toggle flashlight with right mouse button
	if event.is_action_pressed(InputManager.FLASHLIGHT_TOGGLE):
		visible = !visible
		player_light.energy = 1.2 if visible else 0.5
		player_light.texture_scale = 1.2 if visible else 0.3
		play_sound(FLASHLIGHT_CLICK_ON_SOUND_PATH if visible else FLASHLIGHT_CLICK_OFF_SOUND_PATH)

func initialize_player_light() -> void:
	player_light.energy = 0.5
	player_light.texture_scale = 0.3

# This function updates the flashlight sizing based on the player's rotation
# If the player is looking up or down, the flashlight's length should be reduced, but the width should be increased
func update_flashlight_size() -> void:
	var angle = rotation
	var min_length_scale = 0.3
	var max_length_scale = 0.5
	var min_width_scale = 0.4
	var max_width_scale = 0.5

	# Get the cosine of the angle to determine the length scale
	# Cosine is 1 when the angle is 0 (horizontal) and 0 when the angle is 90 or 270 (vertical)
	var cos_angle = abs(cos(angle))

	# Calculate length scale (shorter when vertical, longer when horizontal)
	var length_scale = lerp(min_length_scale, max_length_scale, cos_angle)

	# Calculate width scale (wider when vertical, narrower when horizontal)
	var width_scale = lerp(min_width_scale, max_width_scale, 1.0 - length_scale)

	# Apply the new scale
	scale = Vector2(length_scale, width_scale)

func initialize_audio_player() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = AUDIO_VOLUME_DB

func play_sound(sound_path: String) -> void:
	audio_player.stream = load(sound_path)
	audio_player.play()
