extends KinematicBody2D

# Variables
var speedX = 0
var speedY = 0
var velocity = Vector2(0, 0)
var facingDirection = 0
var movementDirection = 0

# Constants
const MAX_SPEED = 300
const MOV_MULTI = 600
const JUMP_FORCE = 350
const GRAVITY = 800
const UP = Vector2(0, -1)

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_up"):
		speedY = -JUMP_FORCE
	if Input.is_action_pressed("ui_left"):
		facingDirection = -1
	elif Input.is_action_pressed("ui_right"):
		facingDirection = 1
	else:
		facingDirection = 0

	if facingDirection != 0:
		speedX += MOV_MULTI * delta
		movementDirection = facingDirection
	else:
		speedX -= MOV_MULTI * 1.5 * delta

	speedX = clamp(speedX, 0, MAX_SPEED)
	speedY += GRAVITY * delta;
	velocity.x = speedX * delta * movementDirection
	velocity.y = speedY * delta
	
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)