extends Node2D


onready var trail = get_node('Particles2D')
onready var directionLabel = get_node('DirectionLabel')
onready var sectors = get_node('Sectors')

func _ready():
	hide_spots()

func _on_SwipeDetector_swipe_started( partial_gesture ):
	var point = partial_gesture.last_point()
	trail.set_pos(point)
	trail.set_emitting(true)

func _on_SwipeDetector_swipe_updated( partial_gesture ):
	var point = partial_gesture.last_point()
	trail.set_pos(point)

func hide_spots():
	for spot in sectors.get_children():
		spot.hide()
		
func show_spot(index):
	sectors.get_children()[index].show()
	
func _on_SwipeDetector_swipe_ended( gesture ):
	trail.set_emitting(false)
	directionLabel.set_text(gesture.get_direction())
	hide_spots()
	show_spot(gesture.get_direction_index())


func _on_SwipeDetector_swiped( gesture ):
	print(gesture.get_direction())
