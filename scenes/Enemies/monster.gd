extends CharacterBody2D

const SPEED: float = 200
const ACCELERATION: float = 2.0

@export var player: Player

@onready var navigationAgent: NavigationAgent2D = %NavigationAgent2D
@onready var idle_sprite: Sprite2D = $IdleSprite
@onready var walking_sprite: Sprite2D = $WalkingSprite
@onready var attacking_sprite: Sprite2D = $AttackingSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	initial_idle_state()

func _physics_process(delta: float) -> void:
	if not navigationAgent.is_navigation_finished():
		var direction = Vector3()

		navigationAgent.target_position = player.global_position

		direction = navigationAgent.get_next_path_position() - global_position
		direction = direction.normalized()

		velocity = velocity.lerp(direction * SPEED, delta * ACCELERATION)
		move_and_slide()

func make_path() -> void:
	if player:
		navigationAgent.target_position = player.global_position

func _on_timer_timeout() -> void:
	walking_state()
	make_path()

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
