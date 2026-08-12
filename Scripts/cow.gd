extends CharacterBody2D

# Movement settings
@export var walk_speed: float = 40.0
@export var max_wander_distance: float = 150.0
@export var min_walk_time: float = 1.5
@export var max_walk_time: float = 4.0
@export var min_idle_time: float = 1.0
@export var max_idle_time: float = 3.0
@export var eat_chance: float = 0.35        # 35% chance to eat instead of idle
@export var min_eat_time: float = 2.0
@export var max_eat_time: float = 5.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const GRAVITY = 400.0

var home_position: Vector2
var state: String = "idle"
var state_timer: float = 0.0
var walk_direction: float = 1.0  # 1 = right, -1 = left

func _ready() -> void:
	home_position = global_position
	_pick_next_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	state_timer -= delta

	match state:
		"walking":
			_handle_walking(delta)
		"idle":
			velocity = Vector2.ZERO
			move_and_slide()
		"eating":
			velocity = Vector2.ZERO
			move_and_slide()

	if state_timer <= 0.0:
		_pick_next_state()

func _handle_walking(delta: float) -> void:
	var dist_from_home = global_position.x - home_position.x

	# Nudge back toward home if too far
	if abs(dist_from_home) > max_wander_distance:
		walk_direction = -sign(dist_from_home)

	velocity.x = walk_speed * walk_direction
	velocity.y = 0
	move_and_slide()

	# Flip sprite based on direction
	sprite.flip_h = walk_direction < 0

func _pick_next_state() -> void:
	if state == "walking":
		# After walking, idle or eat
		if randf() < eat_chance:
			_enter_state("eating")
		else:
			_enter_state("idle")
	else:
		# After idle/eating, walk in a random direction
		var dist_from_home = global_position.x - home_position.x
		# Bias toward home if near the edge
		if abs(dist_from_home) > max_wander_distance * 0.75:
			walk_direction = -sign(dist_from_home)
		else:
			walk_direction = [-1.0, 1.0].pick_random()
		_enter_state("walking")

func _enter_state(new_state: String) -> void:
	state = new_state
	match new_state:
		"walking":
			state_timer = randf_range(min_walk_time, max_walk_time)
			sprite.play("walking")
		"idle":
			state_timer = randf_range(min_idle_time, max_idle_time)
			sprite.play("idle")
		"eating":
			state_timer = randf_range(min_eat_time, max_eat_time)
			sprite.play("eating")
