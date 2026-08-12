extends CharacterBody2D

@onready var hearts = $Hearts
@onready var sprite = $AnimatedSprite2D

@export var speed = 60.0
@export var stop_distance = 15.0
@export var jump_force = -250.0
var player = null
var following = false
var touching_player = false

var stuck_timer = 0.0
var last_position = Vector2.ZERO

func _ready():

	hearts.emitting = false
	sprite.play("idle")

	last_position = global_position


func _physics_process(delta):

	# Gravity
	if not is_on_floor() and not touching_player:
		velocity += get_gravity() * delta

	if player == null:

		move_and_slide()
		return

	# FOLLOW PLAYER
	if following and not touching_player:

		var dir = player.global_position.x - global_position.x

		if abs(dir) > stop_distance:

			velocity.x = sign(dir) * speed

			if sprite.animation != "running":
				sprite.play("running")

			sprite.flip_h = dir < 0

			# Stuck detection
			stuck_timer += delta

			if stuck_timer > 0.4:

				if global_position.distance_to(
					last_position
				) < 2:

					if is_on_floor():

						velocity.y = jump_force

				last_position = global_position
				stuck_timer = 0.0

		else:

			velocity.x = 0

			if sprite.animation != "idle":
				sprite.play("idle")

	else:

		velocity.x = 0

		# ONLY switch back to idle if not touching
		if !touching_player:

			if sprite.animation != "idle":
				sprite.play("idle")

	move_and_slide()


func _on_detect_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):

		player = body
		following = true


func _on_detect_area_body_exited(body: Node2D) -> void:

	if body == player:

		following = false


func _on_touch_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):

		touching_player = true

		hearts.emitting = true

		velocity = Vector2.ZERO

		sprite.play("sitting")


func _on_touch_area_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):

		touching_player = false

		hearts.emitting = false

		if following:

			sprite.play("running")

		else:

			sprite.play("idle")
