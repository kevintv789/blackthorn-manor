extends Node2D

signal in_range(body: Node2D)
signal out_of_range(body: Node2D)

func _on_pickup_area_body_entered(body: Node2D) -> void:
	in_range.emit(body)


func _on_pickup_area_body_exited(body: Node2D) -> void:
	out_of_range.emit(body)
