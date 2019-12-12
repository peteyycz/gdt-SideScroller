extends KinematicBody2D

var sprite
var velocity = Vector2(200, 0)
var deltaTime = 0

const GRAVITY = 800

func _ready():
	sprite = get_node("Sprite")
	pass
	
func _animateMovement():
	if sprite.get('frame') == 4:
		sprite.set('frame', 0)
	sprite.set('frame', sprite.get('frame') + 1)
	deltaTime = 0

func _physics_process(delta):
	if get_node("CollisionShape2D").get('disabled'):
		sprite.set('frame', 4)
	else:
		deltaTime += delta
		if deltaTime > 0.1:
			_animateMovement()

	velocity.y += GRAVITY * delta


	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.normal == Vector2(0, -1):
			velocity = velocity.slide(collision.normal)
		if abs(collision.normal.x) == 1:
			velocity = velocity.bounce(collision.normal)
			if collision.normal.x > 0:
				sprite.set('flip_h', true)
			else:
				sprite.set('flip_h', false)