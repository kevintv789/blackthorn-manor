extends CharacterBody2D

@export var speed: int = 200
@export var rotation_speed: int = 25

@onready var player_sprite: Sprite2D = $SmoothNode/PlayerSprite
@onready var player_light: Light2D = $SmoothNode/PlayerSprite/PlayerLight
@onready var flashlight: PointLight2D = $Flashlight
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

var original_flashlight_offset: Vector2 = Vector2.ZERO
var current_input_direction = Vector2.RIGHT
	
func _ready() -> void:
	# Set flashlight to not visible
	initialize_player_light()
	original_flashlight_offset = flashlight.offset

func _physics_process(delta: float) -> void:
	define_input_map()
	light_follow_mouse(delta)
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

	if input_direction != Vector2.ZERO:
		animation_state.travel("Walking")
	else:
		animation_state.travel("Idle")
		
func toggle_flashlight(event: InputEvent) -> void:
	if event.is_action_pressed(InputManager.FLASHLIGHT_TOGGLE):
		flashlight.visible = !flashlight.visible
		player_light.energy = 1.0 if flashlight.visible else 0.5
		player_light.texture_scale = 1.0 if flashlight.visible else 0.3
		
func light_follow_mouse(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	
	# Calculate the angle between the player and the mouse
	var angle_to_mouse = global_position.direction_to(mouse_position).angle()

	# Snap to 8 directions (45-degree increments)
	var snapped_angle = round(angle_to_mouse / (PI/4)) * (PI/4)

	# Smoothly interpolate the rotation, but slower
	rotation = lerp_angle(rotation, snapped_angle, 5 * delta)
	
	# Update input direction for animations
	current_input_direction = Vector2.RIGHT.rotated(snapped_angle)

	# Update animation blend position
	animation_tree.set("parameters/Idle/blend_position", current_input_direction)
	animation_tree.set("parameters/Walking/blend_position", current_input_direction)

	# Set sprite rotation directly opposite to the player rotation
	player_sprite.rotation = -rotation

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
	flashlight.scale = Vector2(length_scale, width_scale)

	# Update offset if needed
	var offset_scale = lerp(1.0, 0.9, length_scale)
	flashlight.offset = original_flashlight_offset * offset_scale
