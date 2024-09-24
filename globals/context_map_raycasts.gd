extends Node2D

class_name ContextMapRaycasts

const UP: Vector2 = Vector2(0, -1)
const UP_RIGHT: Vector2 = Vector2(1, -1)
const RIGHT: Vector2 = Vector2(1, 0)
const DOWN_RIGHT: Vector2 = Vector2(1, 1)
const DOWN: Vector2 = Vector2(0, 1)
const DOWN_LEFT: Vector2 = Vector2(-1, 1)
const LEFT: Vector2 = Vector2(-1, 0)
const UP_LEFT: Vector2 = Vector2(-1, -1)

var directions: Array[Vector2] = [UP, UP_RIGHT, RIGHT, DOWN_RIGHT, DOWN, DOWN_LEFT, LEFT, UP_LEFT]
@onready var context_map_array: Array[RayCast2D] = [$"0", $"1", $"2", $"3", $"4", $"5", $"6", $"7"]

func update_and_get_collisions() -> Array[bool]:
	var collisions: Array[bool] = []
	for i in range(context_map_array.size()):
		var raycast = context_map_array[i]
		raycast.force_raycast_update()
		var is_colliding = raycast.is_colliding()
		collisions.append(is_colliding)
	return collisions
