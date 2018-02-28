extends Node2D

onready var trail = get_node('Trail')
onready var matchDetected = get_node('Match')

func _on_SwipeDetector_swipe_started( partial_gesture ):
  var point = partial_gesture.last_point()
  matchDetected.hide()

func _on_SwipeDetector_swipe_updated( partial_gesture ):
  var point = partial_gesture.last_point()
  trail.set_position(point)
  trail.set_emitting(true)

func _on_SwipeDetector_swipe_ended( gesture ):
  trail.set_emitting(false)
  
func _on_SwipeDetector_pattern_detected( pattern_name, actual_gesture ):
  matchDetected.get_node('ResultPattern').set_text(pattern_name)
  matchDetected.show()
