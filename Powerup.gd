extends KinematicBody2D

var velocity = Vector2(200, 0)

const GRAVITY = 800

func _ready():
	pass

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.normal == Vector2(0, -1):
			velocity = velocity.slide(collision.normal)
		if abs(collision.normal.x) == 1:
			velocity = velocity.bounce(collision.normal)
