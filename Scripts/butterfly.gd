extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: float = 30.0
@export var max_wander_distance: float = 40.0
@export var min_fly_time: float = 1.0
@export var max_fly_time: float = 3.0
@export var min_rest_time: float = 0.5
@export var max_rest_time: float = 2.0
@export var ground_y: float = 320.0  # Set this to your ground Y position

var home_position: Vector2
var direction: Vector2 = Vector2.ZERO
var state: String = "flying"
var state_timer: float = 0.0

func _ready() -> void:
	home_position = global_position
	sprite.play("idle")
	_pick_next_state()

func _process(delta: float) -> void:
	state_timer -= delta

	if state == "flying":
		global_position += direction * speed * delta

		# Flip sprite based on horizontal direction
		sprite.flip_h = direction.x < 0

		# Don't go below ground
		if global_position.y > ground_y:
			global_position.y = ground_y
			direction.y = -abs(direction.y)

		# Stay within wander distance
		if global_position.distance_to(home_position) > max_wander_distance:
			direction = (home_position - global_position).normalized()

	if state_timer <= 0.0:
		_pick_next_state()

func _pick_next_state() -> void:
	if state == "flying":
		state = "resting"
		state_timer = randf_range(min_rest_time, max_rest_time)
		direction = Vector2.ZERO
	else:
		state = "flying"
		state_timer = randf_range(min_fly_time, max_fly_time)
		# Random direction including vertical
		direction = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 0.3)  # Bias upward slightly
		).normalized()
