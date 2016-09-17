extends Node

###
# Swipe Detector implementation
# Captures a gesture and stores a history of all
# captured gestures.

# Signal triggered when swipe captured
signal swiped(gesture)

# Minimum distance between points
export var distance_threshold = 25.0

# Indicate minimum swipe duration
# "A swipe will be a swipe if it the duration 
# is at least {{duration_threshold}} seconds"
export var duration_threshold = 0.05

# Minimum swipe points
# "A swipe will be captured if it has at least {{min_points}} points
export var min_points = 2

# Enable or disable gesture detection
export var detect_gesture = true setget detect


class SwipeGesture:
	# Stores swipe data
	
	var points # list of points
	var duration # in seconds
	
	func _init():
		points = []
		duration = 0
		
	func get_duration():
		return duration
	
	func add_duration(delta):
		duration += delta
		return self
	
	func add_point(point):
		points.append(point)
		return self

	func first_point():
		return points[0]

	func last_point():
		return points[points.size() - 1]

	func to_string():
		return ('Swipe ' + str(first_point()) + ':' + str(last_point()) + 
			   ' ' + str(points.size()) + ', length: ' + str(duration))
	

	func get_curve():
		# Get a Curve2D from swipe points		
		var curve = Curve2D.new()
		for point in points:
			curve.add_point(point)
		return curve

	func get_points():
		return points
		
	func point_count():
		return points.size()




var capturing_gesture = false
var gesture_history
var gesture


func _ready():
	gesture_history = []


func detect(detect=true):
	set_process(detect)
	if not detect:
		clean_state()
	return self


func _process(delta):
	if not capturing_gesture and swiping():
		start_capture()
		add_gesture_data(swipePoint(), delta)
	elif capturing_gesture and swiping():
		if gesture.last_point().distance_to(swipePoint()) > distance_threshold:
			add_gesture_data(swipePoint(), delta)
	elif capturing_gesture and not swiping():
		end_capture()

	
func clean_state():
	gesture = null
	capturing_gesture = false


func swiping():
	return Input.is_mouse_button_pressed(BUTTON_LEFT)


func swipePoint():
	return get_viewport().get_mouse_pos()


func start_capture():
	#print('Started gesture on: ', swipePoint())
	gesture = SwipeGesture.new()
	capturing_gesture = true
	return self

func end_capture():
	#print('Ended gesture')
	print(gesture.to_string())
	if gesture.point_count() > min_points and gesture.get_duration() > duration_threshold:
		print('Captured gesture!')
		emit_signal("swiped", gesture)
		gesture_history.append(gesture)
	clean_state()
	return self



func add_gesture_data(point, delta=0):
	gesture.add_point(point)
	gesture.add_duration(delta)
	return self

		
func history():
	return gesture_history


func set_duration_threshold(value):
	duration_threshold = value
	return self


func set_distance_threshold(value):
	distance_threshold = value
	return self