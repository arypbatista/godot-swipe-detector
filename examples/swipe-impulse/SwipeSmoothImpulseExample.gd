extends Node2D

var sliding_object

func get_object(point):
	var selected
	for o in get_node('Points').get_children():
		if o.has(point):
			selected = o
	return selected

func _on_SwipeDetector_swipe_started( partial_gesture ):
	var point = partial_gesture.last_point()
	sliding_object = get_object(point)
	if sliding_object:
		print('We have a sliding object on: ', sliding_object.get_pos())


func _on_SwipeDetector_swipe_updated_with_delta( partial_gesture, delta ):
	var point = partial_gesture.last_point()
	if sliding_object:
		var distance = sliding_object.get_pos().distance_to(point)
		var angle = sliding_object.get_pos().angle_to_point(point)
		var speed = distance / (delta * 100)
		sliding_object.impulse(speed, angle)

