extends Node2D


var trail

func _ready():
	trail = get_node('Particles2D')

func _on_SwipeDetector_swipe_started( point ):
	trail.set_pos(point)
	trail.set_emitting(true)


func _on_SwipeDetector_swipe_updated( point ):
	trail.set_pos(point)


func _on_SwipeDetector_swipe_ended( gesture ):
	trail.set_emitting(false)
