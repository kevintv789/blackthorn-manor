extends Node2D

signal in_range()
signal out_of_range()
signal picked_up(item: Node2D)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(InputManager.ITEM_PICKUP):
		_on_picked_up(self)

func _on_pickup_area_body_entered(_body: Node2D) -> void:
	in_range.emit()

func _on_pickup_area_body_exited(_body: Node2D) -> void:
	out_of_range.emit()

func _on_picked_up(item: Node2D) -> void:
	picked_up.emit(item)
	queue_free()
	ItemManager.has_key = true
