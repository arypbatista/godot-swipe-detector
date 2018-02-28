extends Node2D


onready var trail = $Trail
onready var sectors = $Sectors

func _ready():
  $Values.hide()
  hide_spots()

func _on_SwipeDetector_swipe_started( partial_gesture ):
  var point = partial_gesture.last_point()
  trail.set_position(point)
  trail.set_emitting(true)

func _on_SwipeDetector_swipe_updated( partial_gesture ):
  var point = partial_gesture.last_point()
  trail.set_position(point)

func hide_spots():
  for spot in sectors.get_children():
    spot.hide()
    
func show_spot(index):
  sectors.get_children()[index].show()
  
func _on_SwipeDetector_swipe_ended( gesture ):
  trail.set_emitting(false)
  $Values/Direction.set_text(gesture.get_direction())
  $Values/Angle/Value.set_text(str(gesture.get_direction_angle()))
  $Values.show()
  hide_spots()
  show_spot(gesture.get_direction_index())


func _on_SwipeDetector_swiped( gesture ):
  print(gesture.get_direction())
