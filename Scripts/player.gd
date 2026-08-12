extends CharacterBody2D

# Player movement settings (editable in inspector)
@export var SPEED = 150.0
@export var JUMP_VELOCITY = -250.0
@export var ATTACK_FORCE = 500

# Attack delay before dash/launch
const ATTACK_WAIT = 1.7

# State variables
var attacking = false
var attack_direction = 1      # 1 = right, -1 = left
var idle_long = false         # currently unused
var hitbox_offset = 0.0       # stores original hitbox position

# Node references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HitBox
@onready var hitbox_shape: CollisionShape2D = $HitBox/CollisionShape2D

func _ready() -> void:
	# Disable attack hitbox when game starts
	hitbox_shape.disabled = true
	
	# Save original hitbox X position
	hitbox_offset = hitbox_shape.position.x
	
	
func _physics_process(delta: float) -> void:

	# Apply gravity while in air
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Jump input
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get left/right movement input
	var direction := Input.get_axis("move_left", "move_right")
	
	# Update facing direction
	if direction > 0:
		animated_sprite.flip_h = false
		attack_direction = 1
	
	elif direction < 0:
		animated_sprite.flip_h = true
		attack_direction = -1
	
	# Move attack hitbox to correct side
	hitbox_shape.position.x = hitbox_offset * attack_direction
		
	# Start attack if allowed
	if Input.is_action_just_pressed("attack") and is_on_floor() and not attacking:
		attack()
	
	# Attack state
	if attacking:
		animated_sprite.play("attacking")
		
		# Damage anything inside hitbox
		for body in hitbox.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(10)

		move_and_slide()
		return
	
	# Ground animations
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("running")
	
	# Air animations
	else:
		if velocity.y < 0:
			animated_sprite.play("jumping")
		else:
			animated_sprite.play("falling")
	
	# Horizontal movement
	if direction:
		velocity.x = direction * SPEED
	else:
		# Smooth slowdown
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()


func attack() -> void:
	# Enter attack state
	attacking = true
	
	# Stop movement before attack
	velocity.x = 0
	
	# Enable attack hitbox
	hitbox_shape.disabled = false

	# Wait before attack dash/launch
	await get_tree().create_timer(ATTACK_WAIT).timeout
	
	# Push player forward after attack delay
	velocity.x = attack_direction * ATTACK_FORCE
	
	# Keep hitbox active briefly
	await get_tree().create_timer(0.2).timeout

	# Disable hitbox and exit attack state
	hitbox_shape.disabled = true
	attacking = false


func _on_killzone_body_shape_entered(
	_body_rid: RID,
	_body: Node2D,
	_body_shape_index: int,
	_local_shape_index: int
) -> void:
	
	# Stop player when entering killzone
	set_physics_process(false)
