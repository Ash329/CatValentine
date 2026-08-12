extends CharacterBody2D

@export var walk_speed: float = 35.0
@export var max_wander_distance: float = 120.0

@export var min_walk_time: float = 1.0
@export var max_walk_time: float = 3.0

@export var min_idle_time: float = 0.5
@export var max_idle_time: float = 2.0

@export var eat_chance: float = 0.25
@export var min_eat_time: float = 1.5
@export var max_eat_time: float = 3.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var home_position: Vector2
var walk_direction := 1.0
var state := "idle"
var state_timer := 0.0
var dead := false

func _ready() -> void:
	randomize()
	home_position = global_position
	_pick_next_state()

func _physics_process(delta: float) -> void:
	if dead:
		if not is_on_floor():
			velocity += get_gravity() * delta

		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	state_timer -= delta

	match state:
		"walking":
			_handle_walk()

		"idle":
			velocity.x = 0
			sprite.play("idle")

		"eating":
			velocity.x = 0
			sprite.play("eating")

	move_and_slide()

	if state_timer <= 0:
		_pick_next_state()

func _handle_walk() -> void:
	var distance = global_position.x - home_position.x

	if abs(distance) > max_wander_distance:
		walk_direction = -sign(distance)

	velocity.x = walk_speed * walk_direction

	if is_on_wall():
		walk_direction *= -1

	sprite.flip_h = walk_direction < 0
	sprite.play("walking")

func _pick_next_state() -> void:
	if state == "walking":

		if randf() < eat_chance:
			_enter_state("eating")
		else:
			_enter_state("idle")

	else:
		var distance = global_position.x - home_position.x

		if abs(distance) > max_wander_distance * 0.75:
			walk_direction = -sign(distance)
		else:
			walk_direction = [-1.0, 1.0].pick_random()

		_enter_state("walking")

func _enter_state(new_state: String) -> void:
	state = new_state

	match state:
		"walking":
			state_timer = randf_range(
				min_walk_time,
				max_walk_time
			)

		"idle":
			state_timer = randf_range(
				min_idle_time,
				max_idle_time
			)

		"eating":
			state_timer = randf_range(
				min_eat_time,
				max_eat_time
			)

func take_damage(_amount: int) -> void:
	if dead:
		return

	dead = true

	velocity = Vector2(
		walk_direction * 100,
		-250
	)

	sprite.play("idle")

	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	await get_tree().create_timer(2.0).timeout

	queue_free()
