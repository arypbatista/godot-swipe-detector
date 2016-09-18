extends RigidBody2D


func collision_radius():
	return get_node('CollisionShape2D').get_shape().get_radius()

func has(point):
	return get_pos().distance_to(point) <= collision_radius()

func impulse(speed, angle=0):
	print('Applying impulse to object. Speed: ', speed, ', Angle: ', angle)
	set_linear_velocity(Vector2(0, -speed).rotated(angle))