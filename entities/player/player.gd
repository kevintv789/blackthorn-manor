extends CharacterBody2D

class_name Player

@export var speed: int = 200
@export var rotation_speed: int = 25

@onready var player_sprite: Sprite2D = $SmoothNode/PlayerSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var flashlight_sprite: PointLight2D = $SmoothNode/PlayerSprite/Flashlight
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var prompt_button_scene: PackedScene = preload("res://scenes/UI/e_button.tscn")

var base_sprite_path: String = "res://assets/2D/sprites/player/base_male.png"
var flashlight_sprite_path: String = "res://assets/2D/sprites/player/male_flashlight.png"

var prompt_button: Node2D

var current_input_direction = Vector2.RIGHT

func _ready() -> void:
	InputManager.flashlight_toggle.connect(_on_flashlight_toggle)
	initialize_item_pickup_prompt()
	initialize_item_pickup_signals()

func _physics_process(delta: float) -> void:
	define_input_map()
	light_follow_mouse(delta)
	move_and_slide()
	
	# Move the button to the position of the player
	if prompt_button:
		prompt_button.global_position = global_position + Vector2(0, -50)
		prompt_button.rotation = -rotation

func initialize_item_pickup_prompt() -> void:
	prompt_button = prompt_button_scene.instantiate()
	add_child(prompt_button)
	prompt_button.visible = false
	prompt_button.scale = Vector2(1.5, 1.5)

func initialize_item_pickup_signals() -> void:
	var items = get_tree().get_nodes_in_group("Items") as Array[Node2D]
	for item in items:
		if item.has_signal("in_range"):
			item.connect("in_range", key_in_range)
		if item.has_signal("out_of_range"):
			item.connect("out_of_range", key_out_of_range)

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
	var snapped_angle = round(angle_to_mouse / (PI / 4)) * (PI / 4)

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

func key_in_range() -> void:
	prompt_button.visible = true

func key_out_of_range() -> void:
	prompt_button.visible = false

func _on_flashlight_toggle(is_on: bool) -> void:
	if is_on:
		flashlight_sprite.offset = Vector2(480, 0)

	player_sprite.texture = load(flashlight_sprite_path) if is_on else load(base_sprite_path)
