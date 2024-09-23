extends CanvasLayer

@onready var itemRect: Sprite2D = $Control/TextureRect/Item

func _ready() -> void:
	var items = get_tree().get_nodes_in_group("Items") as Array[Node2D]
	for item in items:
		if item.has_signal("picked_up"):
			item.connect("picked_up", _on_item_picked_up)

func _on_item_picked_up(item: Node2D) -> void:
	var sprite = item.get_node_or_null("SilverKey")
	
	if sprite:
		itemRect.texture = sprite.texture
		
