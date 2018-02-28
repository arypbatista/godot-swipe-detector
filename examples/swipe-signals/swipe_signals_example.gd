extends Node2D

const Point = preload('../resources/point.tscn')

export var point_scale_step = 0.1
export var max_scale = 5.0

var point_scale


func spawn_point(point, point_scale=1.0, emphasize=false):
  var point_object = Point.instance()
  point_object.set_point_scale(point_scale)
  point_object.set_position(point)
  point_object.set_emphasis(emphasize)
  get_node('Points').add_child(point_object)


func _on_SwipeDetector_swipe_started( partial_gesture ):
  var point = partial_gesture.last_point()
  print('Swipe started at: ', point)
  spawn_point(point, 2, true)
  point_scale = 0.2


func _on_SwipeDetector_swipe_ended( gesture ):
  print('Swipe ended at: ', gesture.last_point())
  spawn_point(gesture.last_point(), point_scale * 1.5, true)


func _on_SwipeDetector_swipe_updated( partial_gesture ):
  var point = partial_gesture.last_point()
  spawn_point(point, point_scale)
  point_scale = min(point_scale + point_scale_step, max_scale)


func _on_KillZone_body_enter( body ):
  body.queue_free()
