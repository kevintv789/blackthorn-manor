extends Node2D

@onready var monster_spawn_points: Node2D = $MonsterSpawnPoints
@onready var camera: FollowCamera = $FollowCamera

func _ready() -> void:
	var items = get_tree().get_nodes_in_group("Items") as Array[Node2D]
	for item in items:
		if item.has_signal("picked_up"):
			item.connect("picked_up", spawn_monster)

	get_tree().connect("node_added", _on_node_added)

func _on_node_added(node: Node) -> void:
	if node.is_in_group("Monster") and node.has_signal("player_caught"):
		node.player_caught.connect(_on_player_caught)

func spawn_monster(_item: Node2D) -> void:
	var monster = preload("res://scenes/Enemies/monster.tscn").instantiate()
	monster.player = get_tree().get_first_node_in_group("Player")
	var spawn_points = monster_spawn_points.get_children() as Array[Marker2D]
	var random_spawn_point = spawn_points.pick_random()
	monster.global_position = random_spawn_point.global_position
	add_child(monster)

func _on_player_caught() -> void:
	camera.stop_following()
