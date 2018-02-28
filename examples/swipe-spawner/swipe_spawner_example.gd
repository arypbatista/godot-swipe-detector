extends Node2D

const Point = preload('../resources/point.tscn')

func _on_SwipeDetector_swiped( gesture ):
  print('Duration: ', gesture.get_duration())
  for point in gesture.get_points():
    spawn_point(point)

func spawn_point(point):
  var point_object = Point.instance()
  point_object.set_position(point)
  $Points.add_child(point_object)
