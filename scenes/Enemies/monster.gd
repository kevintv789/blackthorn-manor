extends CharacterBody2D

var SPEED: float = 200

var last_position: Vector2 = Vector2.ZERO
var last_player_position: Vector2 = Vector2.ZERO
var stuck_time: float = 0.0
var unstuck_time: float = 0.0
const STUCK_DISTANCE_THRESHOLD: float = 2.0
const STUCK_TIME_THRESHOLD: float = 1.5

@export var player: Player

@onready var navigationAgent: NavigationAgent2D = %NavigationAgent2D
@onready var idle_sprite: Sprite2D = $IdleSprite
@onready var walking_sprite: Sprite2D = $WalkingSprite
@onready var attacking_sprite: Sprite2D = $AttackingSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var notice_zone: Area2D = $NoticeZone

signal player_caught()
var is_dragging_player: bool = false
var drag_target_position: Vector2 = Vector2(10000, 10000)

func _ready() -> void:
	initial_idle_state()

func _physics_process(delta: float) -> void:
	if is_dragging_player:
		var direction = (drag_target_position - global_position).normalized()
		set_velocity_with(delta, 10, 0.0001, direction)
		player.global_position = global_position + direction * 20  # Offset player slightly behind monster
		self.collision_mask &= ~4
		
	else:
		if not navigationAgent.is_navigation_finished() and ItemManager.has_key:
			var direction = calc_direction(player.global_position)
			set_velocity_with(delta, SPEED, 1.5, direction)


			if is_stuck(delta) and not is_colliding_with_player():
				last_player_position = player.global_position
				activate_ghost_mode()
			elif has_moved_sufficiently():
				last_player_position = Vector2.ZERO
				deactivate_ghost_mode()
				unstuck_time = 0.0

	move_and_slide()


func has_moved_sufficiently() -> bool:
	var time_has_passed = unstuck_time > STUCK_TIME_THRESHOLD
	var distance_has_increased = last_position.distance_to(global_position) > STUCK_DISTANCE_THRESHOLD
	return time_has_passed or distance_has_increased
			
func is_colliding_with_player() -> bool:
	return notice_zone.get_overlapping_bodies().has(player)

func make_path(player_position: Vector2) -> void:
	navigationAgent.target_position = player_position

func _on_timer_timeout() -> void:
	walking_state()
	if last_player_position != Vector2.ZERO:
		make_path(last_player_position)
	else:
		make_path(player.global_position)

func initial_idle_state() -> void:
	idle_sprite.visible = true
	walking_sprite.visible = false
	attacking_sprite.visible = false
	animation_player.play("idle")

func walking_state() -> void:
	idle_sprite.visible = false
	walking_sprite.visible = true
	attacking_sprite.visible = false
	animation_player.play("walking")

func attacking_state() -> void:
	idle_sprite.visible = false
	walking_sprite.visible = false
	attacking_sprite.visible = true
	animation_player.play("attacking")

# Check if the monster is stuck in front of a wall
func is_stuck(delta: float) -> bool:
	if last_position.distance_to(global_position) < STUCK_DISTANCE_THRESHOLD:
		stuck_time += delta
		unstuck_time = 0.0
		if stuck_time > STUCK_TIME_THRESHOLD:
			return true
	else:
		stuck_time = 0.0
		unstuck_time += delta
	
	last_position = global_position
	return false

func activate_ghost_mode() -> void:
	# Remove collision from wall by removing bit value 4
	self.collision_mask &= ~4
	self.collision_mask &= ~1

	var direction = calc_direction(last_player_position)
	self.modulate = Color(1, 1, 1, 0.5)
	set_velocity_with(1, SPEED, 5.0, direction)

func deactivate_ghost_mode() -> void:
	self.collision_mask |= 4
	self.collision_mask |= 1
	self.modulate = Color(1, 1, 1, 1)
	var direction = calc_direction(player.global_position)
	set_velocity_with(1, SPEED, 1.5, direction)

func set_velocity_with(delta: float, speed: float, acceleration: float, direction: Vector2) -> void:
	velocity = velocity.lerp(direction * speed, delta * acceleration)

func calc_direction(target_position: Vector2) -> Vector2:
	navigationAgent.target_position = target_position
	var direction = navigationAgent.get_next_path_position() - global_position
	return direction.normalized()

func _on_attack_zone_body_entered(body: Node2D) -> void:
	if body == player:
		is_dragging_player = true
		attacking_state()
		player_caught.emit()
		# GAME OVER HERE

func _on_attack_zone_body_exited(_body: Node2D) -> void:
	walking_state()
