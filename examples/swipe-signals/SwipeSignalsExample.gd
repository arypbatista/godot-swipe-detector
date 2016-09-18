extends Node2D

const Point = preload('./Point.tscn')

export var point_scale_step = 0.1
export var max_scale = 5.0

var point_scale


func spawn_point(point, scale=1.0):
	var point_object = Point.instance()
	point_object.set_point_scale(scale)
	point_object.set_pos(point)
	get_node('Points').add_child(point_object)


func _on_SwipeDetector_swipe_started( point ):
	spawn_point(point, 2)
	point_scale = 0.2


func _on_SwipeDetector_swipe_ended( gesture ):
	spawn_point(gesture.last_point(), point_scale)


func _on_SwipeDetector_swipe_updated( point ):
	spawn_point(point, point_scale)
	point_scale = min(point_scale + point_scale_step, max_scale)
