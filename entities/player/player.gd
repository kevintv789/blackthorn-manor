extends CharacterBody2D

class_name Player

@export var speed: int = 200
@export var rotation_speed: int = 25

@onready var player_sprite: Sprite2D = $SmoothNode/PlayerSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

var current_input_direction = Vector2.RIGHT
	
func _physics_process(delta: float) -> void:
	define_input_map()
	light_follow_mouse(delta)
	move_and_slide()

func define_input_map() -> void:
	var input_direction = Input.get_vector(InputManager.MOVE_LEFT, InputManager.MOVE_RIGHT, InputManager.MOVE_UP, InputManager.MOVE_DOWN)
	velocity = input_direction * speed

	if input_direction != Vector2.ZERO:
		animation_state.travel("Walking")
	else:
		animation_state.travel("Idle")
		
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

func is_moving() -> bool:
	return velocity != Vector2.ZERO
