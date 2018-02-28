
extends Node2D


onready var trails = {
  'green' : get_node('GreenTrail'),
  'red'  : get_node('RedTrail')
}

func trail_for(gesture):
  var trail_name = gesture.get_area().get_name().to_lower()
  return trails[trail_name]

func _on_SwipeDetector_swipe_started( partial_gesture ):
  var trail = trail_for(partial_gesture)
  trail.set_position(partial_gesture.last_point())
  trail.set_emitting(true)

func _on_SwipeDetector_swipe_updated( partial_gesture ):
  var trail = trail_for(partial_gesture)
  trail.set_position(partial_gesture.last_point())

func _on_SwipeDetector_swipe_ended( gesture ):
  var trail = trail_for(gesture)
  trail.set_emitting(false)