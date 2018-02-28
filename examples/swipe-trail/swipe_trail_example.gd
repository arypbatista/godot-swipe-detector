extends Node2D


var trail

func _ready():
  trail = $Trail

func _on_SwipeDetector_swipe_started( partial_gesture ):
  var point = partial_gesture.last_point()
  trail.set_position(point)
  trail.set_emitting(true)


func _on_SwipeDetector_swipe_updated( partial_gesture ):
  var point = partial_gesture.last_point()
  trail.set_position(point)


func _on_SwipeDetector_swipe_ended( gesture ):
  trail.set_emitting(false)