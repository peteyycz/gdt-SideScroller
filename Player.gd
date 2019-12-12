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
var power = 0
var isInvincible = false
var invincibilityDelta = 0

# Constants
const MAX_SPEED = 300
const MOV_MULTI = 800
const JUMP_FORCE = 350
const GRAVITY = 800
const UP = Vector2(0, -1)
const bricksParticle = preload('res://BricksParticle.tscn')
const Powerup = preload('res://Powerup.tscn')
const PowerupBox = preload('res://PowerupBox.tscn')

func _ready():
	sprite = get_node("Sprite")

func _animatePlayerMovement():
	if sprite.get('frame') > 2:
		sprite.set('frame', 0)
	sprite.set('frame', sprite.get('frame') + 1)
	deltaTime = 0

func _physics_process(delta):
	if isInvincible:
		sprite.set('opacity', 0)
		invincibilityDelta += delta
		if invincibilityDelta > 0.05:
			if sprite.get('visible'):
				sprite.set('visible', false)
			else:
				sprite.set('visible', true)				
		if invincibilityDelta > 1:
			invincibilityDelta = 0
			isInvincible = false
			sprite.set('visible', true)
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
		speedX -= MOV_MULTI * 1.5 * delta

	speedX = clamp(speedX, 0, MAX_SPEED)
	velocity.x = speedX * movementDirection
	velocity.y = speedY

	move_and_slide(velocity, Vector2(0, -1))
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.normal == Vector2(0, 1):
			var obj = collision.collider
			var objParent = obj.get_parent()
			if power > 0 and objParent.is_in_group("Bricks"):
				objParent.queue_free()
				speedY = 0
				var particleEffect = bricksParticle.instance()
				particleEffect.get_node(".").set("emitting", true)
				particleEffect.set('position', get('position') - Vector2(0, 20))
				get_tree().root.add_child(particleEffect)
			elif objParent.is_in_group("PowerupBricks"):
				var powerupBox = PowerupBox.instance()
				powerupBox.set('position', objParent.get('position'))
				objParent.queue_free()
				get_tree().root.add_child(powerupBox)
				var powerup = Powerup.instance()
				powerup.set("position", get('position') - Vector2(0, 64))
				powerup.add_to_group("Powerup")
				get_tree().root.add_child(powerup)

	var area = get_node("Area2D").get_overlapping_bodies()
	if area.size() != 0:
		for body in area:
			if body.is_in_group("Powerup"):
				power = 1
				body.queue_free()
				sprite.set('modulate', Color("#5d6dff"))
			elif body.is_in_group("Pits"):
				get_tree().reload_current_scene()
			elif body.is_in_group("Enemies"):
				if body.get('position').y > get('position').y + 10:
					body.get_node("CollisionShape2D").set('disabled', true)
				else:
					if !isInvincible:
						isInvincible = true
						power -= 1
						if power < 0:
							get_tree().reload_current_scene()
						else:
							sprite.set('modulate', Color("#ffffff"))