extends Node2D

@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var ground: Node2D = %Floor
@onready var floor_layer: TileMapLayer = ground.get_node("Ground").get_node("Floor")

func _physics_process(_delta: float) -> void:
	var tile_type = get_tile_type()

	if tile_type == "wood":
		print("play wood sound")
	elif tile_type == "marble":
		print("play marble sound")

func get_tile_type() -> String:
	# var adjusted_position = player_position + Vector2i(0, 16)
	var on_cell = floor_layer.local_to_map(floor_layer.to_local(player.global_position))
	var tile_data: TileData = floor_layer.get_cell_tile_data(on_cell)
	return tile_data.get_custom_data("material") if tile_data else "none"
