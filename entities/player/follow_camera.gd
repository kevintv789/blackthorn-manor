extends Camera2D

class_name FollowCamera

@export var target: Player
@export var camera_offset: Vector2 = Vector2.ZERO
@export var follow_speed: float = 10.0

var is_following: bool = true

func _ready() -> void:
	position_smoothing_enabled = true
	rotation_smoothing_enabled = true
	zoom = Vector2(2.0, 2.0)

func _process(delta: float) -> void:
	if is_following and target:
		global_position = global_position.lerp(target.global_position + camera_offset, follow_speed * delta)

func stop_following() -> void:
	is_following = false
