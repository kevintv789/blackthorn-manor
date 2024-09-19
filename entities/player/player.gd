extends CharacterBody2D

@export var speed: int = 200
@export var rotation_speed: int = 25

@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var player_light: Light2D = $PlayerSprite/PlayerLight
@onready var flashlight: PointLight2D = $Flashlight
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Define animation states
enum PlayerState {
	IDLE,
	WALK_UP,
	WALK_DOWN,
	WALK_LEFT,
	WALK_RIGHT
}

const PlayerStateString = {
	PlayerState.IDLE: "idle",
	PlayerState.WALK_UP: "walk_up",
	PlayerState.WALK_DOWN: "walk_down",
	PlayerState.WALK_LEFT: "walk_left",
	PlayerState.WALK_RIGHT: "walk_right"
}

const PlayerIdleFrame = {
	PlayerState.IDLE: 1,
	PlayerState.WALK_UP: 19,
	PlayerState.WALK_DOWN: 1,
	PlayerState.WALK_LEFT: 7,
	PlayerState.WALK_RIGHT: 13
}

var current_state: PlayerState = PlayerState.IDLE
var last_state: PlayerState = PlayerState.IDLE

var original_flashlight_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Set flashlight to not visible
	initialize_player_light()
	original_flashlight_offset = flashlight.offset
	player_sprite.frame = 1

func _physics_process(_delta: float) -> void:
	define_input_map()
	light_follow_mouse()
	move_and_slide()

	if flashlight.visible:
		update_flashlight_size()

func initialize_player_light() -> void:
	flashlight.visible = false
	player_light.energy = 0.1
	player_light.texture_scale = 0.3

func _input(event: InputEvent) -> void:
	toggle_flashlight(event)

func define_input_map() -> void:
	var input_direction = Input.get_vector(InputManager.MOVE_LEFT, InputManager.MOVE_RIGHT, InputManager.MOVE_UP, InputManager.MOVE_DOWN)
	velocity = input_direction * speed
	update_player_state(input_direction)
	play_player_animation()

func update_player_state(input_direction: Vector2) -> void:
	if input_direction == Vector2.RIGHT:
		current_state = PlayerState.WALK_RIGHT
	elif input_direction == Vector2.LEFT:
		current_state = PlayerState.WALK_LEFT
	elif input_direction == Vector2.UP:
		current_state = PlayerState.WALK_UP
	elif input_direction == Vector2.DOWN:
		current_state = PlayerState.WALK_DOWN
	else:
		current_state = PlayerState.IDLE

func play_player_animation() -> void:
	if (current_state != PlayerState.IDLE):
		animation_player.play(PlayerStateString[current_state])

		 # Sets last state right before the player stops moving
		 # so we can use it to determine the idle frame of the direction the player is facing
		last_state = current_state
	else:
		animation_player.stop()
		var last_state_frame = PlayerIdleFrame[last_state]
		player_sprite.frame = last_state_frame
		
func toggle_flashlight(event: InputEvent) -> void:
	if event.is_action_pressed(InputManager.FLASHLIGHT_TOGGLE):
		flashlight.visible = !flashlight.visible
		player_light.energy = 1.0 if flashlight.visible else 0.5
		player_light.texture_scale = 1.0 if flashlight.visible else 0.3
		
func light_follow_mouse() -> void:
	var mouse_position = get_global_mouse_position()

	# Calculate the angle between the player and the mouse
	var angle_to_mouse = global_position.direction_to(mouse_position).angle()

	# Rotate the player towards the mouse using lerp_angle
	# lerp_angle is used to smoothly rotate the player towards the mouse
	# rotation = lerp_angle(rotation, angle_to_mouse, rotation_speed * get_physics_process_delta_time())

# This function updates the flashlight sized based on the player's rotation
# If the player is looking up or down, the flashlight's length should be reduced, but the width should be increased
func update_flashlight_size() -> void:
	var angle = rotation

	# Normalize the angle
	angle = fmod(angle, TAU)
	if angle < 0:
		angle += TAU
	

	# Calculate the length and width of the flashlight based on the angle
	var min_scale = 0.5

	# Cos(angle) will be between -1 and 1
	# If user is facing horizontally (0 to 180 degrees), the length would be 1
	# If user is facing vertically (90 to 270 degrees), the length would be 0 (or min_scale)
	var length_scale = max(min_scale, abs(cos(angle)))

	var max_width_scale = 1.3 # Maximum width scale when vertical
	var width_scale = lerp(1.0, max_width_scale, 1.0 - length_scale)

	flashlight.scale.x = length_scale
	flashlight.scale.y = width_scale

	# Use lerp to smoothly transition from 1 to 0.9 
	# lerp formula: result = start + (end - start) * weight
	# for our case, result = 1.0 + (0.9 - 1.0) * length_scale (which is between 0.5 and 1)
	# when length_scale is 0.5, offset_scale will be 0.95
	var offset_scale = lerp(1.0, 0.9, length_scale)
	flashlight.offset = original_flashlight_offset * offset_scale
