extends Node2D

signal in_range()
signal out_of_range()
signal picked_up(item: Node2D)

@onready var no_outline: AnimatedSprite2D = $AnimatedKey
@onready var outline: AnimatedSprite2D = $AnimatedKeyOutline
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	no_outline.visible = true
	outline.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(InputManager.ITEM_PICKUP):
		_on_picked_up(self)

func _on_pickup_area_body_entered(_body: Node2D) -> void:
	in_range.emit()
	no_outline.visible = false
	outline.visible = true

func _on_pickup_area_body_exited(_body: Node2D) -> void:
	out_of_range.emit()
	no_outline.visible = true
	outline.visible = false

func _on_picked_up(item: Node2D) -> void:
	audio.play()
	picked_up.emit(item)
	ItemManager.has_key = true
	self.hide()
	
	await audio.finished
	queue_free()
