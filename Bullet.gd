extends Area2D


@export var speed = 750

func start(_position, _direction):
	rotation = _direction
	position = _position
#	velocity = Vector2(speed, 0).rotated(rotation)
#	pass

func _physics_process(delta):
#	var collision = move_and_collide(velocity * delta)
#	if collision:
#		velocity = velocity.bounce(collision.get_normal())
#		if collision.get_collider().has_method("hit"):
#			collision.get_collider().hit()]
	# この一文、めちゃ大事なんだろうけどあんま分かってない
	position += transform.x * speed * delta
	
			

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
#	print(body.name)
	# あんまりよく分かってないけど上手くいってるっぽい
	if body.has_method("hit"):
		body.hit()
	
	queue_free()
