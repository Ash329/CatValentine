extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -250.0
const ATTACK_WAIT = 1.7
const ATTACK_FORCE = 500

var attacking = false
var attack_direction = 1
var idle_long = false 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
		attack_direction = 1
	elif direction < 0:
		animated_sprite.flip_h = true
		attack_direction = -1
	
	# Attack 
	
	if Input.is_action_just_pressed("attack") and is_on_floor():
		attack()
	
	#Animations: 
	if attacking:
		animated_sprite.play("attacking")
		move_and_slide()
		return
		
	elif is_on_floor():
		if direction ==0 : 
			animated_sprite.play("idle")
		else : 
			animated_sprite.play("running")
	else : 
		if velocity.y < 0: 
			animated_sprite.play("jumping")
		else:
			animated_sprite.play("falling")
	if direction:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()

func attack() -> void:
	attacking = true
	velocity.x = 0
	await get_tree().create_timer(ATTACK_WAIT).timeout
	velocity.x = attack_direction * ATTACK_FORCE
	await get_tree().create_timer(0.2).timeout
	attacking = false
	
	
func _on_killzone_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	set_physics_process(false)
