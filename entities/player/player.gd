extends CharacterBody2D

@export var speed: int = 400

func _ready() -> void:
	# Set flashlight to not visible
	$Flashlight.visible = false

func _physics_process(_delta: float) -> void:
	define_input_map()
	follow_mouse()
	move_and_slide()

func _input(event: InputEvent) -> void:
	toggle_flashlight(event)

func define_input_map() -> void:
	var input_direction = Input.get_vector(InputManager.MOVE_LEFT, InputManager.MOVE_RIGHT, InputManager.MOVE_UP, InputManager.MOVE_DOWN)
	velocity = input_direction * speed

func toggle_flashlight(event: InputEvent) -> void:
	if event.is_action_pressed(InputManager.FLASHLIGHT_TOGGLE):
		$Flashlight.visible = !$Flashlight.visible

func follow_mouse() -> void:
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)
