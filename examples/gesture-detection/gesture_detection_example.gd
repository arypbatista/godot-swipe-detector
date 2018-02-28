extends Node2D

const TrailGhost = preload('trail_ghost.tscn')

var recording = false

onready var recordButton = get_node('RecordButton')
onready var recordingLabel = get_node('RecordingLabel')
onready var swipeDetector = get_node('SwipeDetector')
onready var trail = get_node('Trail')
onready var recordedGesture = get_node('RecordedGesture')
onready var matchDetected = get_node('Match')
onready var matchGesture = get_node('MatchGesture')
  
  
func is_recording():
  return recording

func record_start():
  recording = true
  recordingLabel.show()
  $RecordingState.modulate.a = 1.0
  
func record_end(gesture):
  $RecordingState.modulate.a = 0.3
  recording = false
  recordingLabel.hide()
  swipeDetector.remove_pattern_detections()
  swipeDetector.add_pattern_detection('RecordedGesture', gesture)
  render_gesture(gesture, recordedGesture)
  
func render_gesture(gesture, container, color=Color('#20000000')):
  free_children(container)
  for point in gesture.get_points():
    var trailGhost = TrailGhost.instance()
    trailGhost.set_position(point)
    trailGhost.set_modulate(color)
    container.add_child(trailGhost)

func free_children(node):
  for child in node.get_children():
    child.queue_free()

func _on_RecordButton_pressed():
  if not is_recording():
    record_start()

func _on_SwipeDetector_swipe_started( partial_gesture ):
  var point = partial_gesture.last_point()
  matchDetected.hide()
  matchGesture.hide()

func _on_SwipeDetector_swipe_updated( partial_gesture ):
  var point = partial_gesture.last_point()
  trail.set_position(point)
  trail.set_emitting(true)

func _on_SwipeDetector_swipe_ended( gesture ):
  if is_recording():
    record_end(gesture)
  trail.set_emitting(false)

func _on_SwipeDetector_pattern_detected( pattern_name, actual_gesture ):
  if not is_recording():
    render_gesture(actual_gesture, matchGesture, Color('#450000FF'))
    matchDetected.show()
    matchGesture.show()
