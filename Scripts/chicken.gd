extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_player: Area2D = $DetectPlayer

@export var walk_speed: float = 70.0
@export var flee_speed: float = 100.0
@export var max_wander_distance: float = 100.0
@export var min_eat_time: float = 2.0
@export var max_eat_time: float = 5.0
@export var min_walk_time: float = 10.0
@export var max_walk_time: float = 10.5

var home_position: Vector2
var walk_direction: float = 1.0
var state: String = "eating"
var state_timer: float = 0.0
var player: Node2D = null

func _ready() -> void:
	home_position = global_position
	detect_player.body_entered.connect(_on_player_entered)
	detect_player.body_exited.connect(_on_player_exited)
	_enter_state("eating")

func _enter_state(new_state: String) -> void:
	state = new_state
	match state:
		"eating":
			state_timer = randf_range(min_eat_time, max_eat_time)
			sprite.play("eating")
		"walking":
			state_timer = randf_range(min_walk_time, max_walk_time)
			walk_direction = [-1.0, 1.0].pick_random()
			var dist = global_position.x - home_position.x
			if abs(dist) > max_wander_distance * 0.75:
				walk_direction = -sign(dist)
			sprite.play("walking")
		
		"fleeing":
			sprite.play("walking")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		"eating":
			velocity.x = 0
			move_and_slide()
			state_timer -= delta
			if state_timer <= 0.0:
				_enter_state("walking")

		"walking":
			var dist = global_position.x - home_position.x

			# turn back if too far away
			if abs(dist) > max_wander_distance:
				walk_direction = -sign(dist)

			velocity.x = walk_speed * walk_direction
			move_and_slide()

			sprite.flip_h = walk_direction < 0

			# turn around on walls
			if is_on_wall():
				walk_direction *= -1

			state_timer -= delta
			if state_timer <= 0.0:
				_enter_state("eating")

		"fleeing":
			if player:
				walk_direction = sign(global_position.x - player.global_position.x)
				if walk_direction == 0:
					walk_direction = 1.0
			velocity.x = flee_speed * walk_direction
			move_and_slide()
			sprite.flip_h = walk_direction < 0

func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		_enter_state("fleeing")

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		_enter_state("eating")
