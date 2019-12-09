extends KinematicBody2D

# Variables
var speedX = 0
var speedY = 0
var velocity = Vector2(0, 0)
var facingDirection = 0
var movementDirection = 0
var sprite
var maxJumpCount = 1
var jumpCount = 0
var deltaTime = 0
var landed

# Constants
const MAX_SPEED = 300
const MOV_MULTI = 800
const JUMP_FORCE = 350
const GRAVITY = 800
const UP = Vector2(0, -1)

func _ready():
	sprite = get_node("Sprite")
	
func _animatePlayerMovement():
	if sprite.get('frame') > 2:
		sprite.set('frame', 0)
	sprite.set('frame', sprite.get('frame') + 1)
	deltaTime = 0

func _physics_process(delta):
	if is_on_floor():
		if !landed:
			sprite.set('frame', 0)
			landed = true
		jumpCount = 0
	else:
		speedY += GRAVITY * delta
		
	if Input.is_action_just_pressed("ui_up") and jumpCount < maxJumpCount:
		speedY = -JUMP_FORCE
		jumpCount += 1
		sprite.set('frame', 5)
		landed = false

	if Input.is_action_pressed("ui_left"):
		facingDirection = -1
		sprite.set('flip_h', true)
		deltaTime += delta
		if deltaTime > 0.1 and landed:
			_animatePlayerMovement()
	elif Input.is_action_pressed("ui_right"):
		facingDirection = 1
		sprite.set('flip_h', false)
		deltaTime += delta
		if deltaTime > 0.1 and landed:
			_animatePlayerMovement()
	else:
		facingDirection = 0
		if landed:
			sprite.set('frame', 4)
		
	if velocity.x == 0 and landed:
		sprite.set('frame', 0)

	if facingDirection != 0:
		speedX += MOV_MULTI * delta
		movementDirection = facingDirection
	else:
		speedX -= MOV_MULTI * 0.5 * delta

	speedX = clamp(speedX, 0, MAX_SPEED)
	velocity.x = speedX * movementDirection
	velocity.y = speedY

	move_and_slide(velocity, Vector2(0, -1))