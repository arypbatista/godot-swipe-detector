extends Node


###
# Swipe Detector implementation
# Captures a gesture and stores a history of all
# captured gestures.


## Signals

# Signal triggered when swipe captured
signal swiped(gesture)
signal swipe_ended(gesture) # alias for `swiped`

# Signal triggered when swipe started
signal swipe_started(point)

# Signal triggered when gesture is updated
signal swipe_updated(point)
signal swipe_updated_with_delta(point, delta)

# Signal triggered when swipe failed
# This means the swipe didn't pass thresholds and requirements
# to be detected as swipe.
signal swipe_failed()


## Exported Variables

# Enable or disable gesture detection
export var detect_gesture = true setget detect

# Determine process method to be used
const PROCESS_FIXED = 'Fixed'
const PROCESS_IDLE  = 'Idle'
export (String, 'Idle', 'Fixed') var process_method = PROCESS_FIXED

# Minimum distance between points
export var distance_threshold = 25.0

# Indicate minimum swipe duration
# "A swipe will be a swipe if it the duration 
# is at least {{duration_threshold}} seconds"
export var duration_threshold = 0.05

# Maximum duration
# You can the maximum swipe duration
export var limit_duration = false
export var maximum_duration = -1.0

# Minimum swipe points
# "A swipe will be captured if it has at least {{minimum_points}} points
export var minimum_points = 2

# Maximum points
# You can limit points captured so a Swipe will end prematurely
export var limit_points = false
export var maximum_points = -1


## Implementation

var capturing_gesture
var gesture_history
var gesture
var last_update_delta
var was_swiping
var swipe_input

func _ready():
	gesture_history = []
	capturing_gesture = false
	was_swiping = false
	swipe_input = MouseSwipeInput.new(self)

func on_touch_device():
	return OS.get_name() in ['Android', 'iOS'] 

func set_swipe_process(method, value):
	if method == PROCESS_IDLE:
		set_process(value)
	elif method == PROCESS_FIXED:
		set_fixed_process(value)

func detect(detect=true):
	set_swipe_process(process_method, detect)
	if not detect:
		clean_state()
	return self

func reached_point_limit():
	return limit_points and gesture.point_count() >= maximum_points
	
func reached_duration_limit():
	return limit_duration and gesture.get_duration() >= maximum_duration
	
func reached_limit():
	return reached_point_limit() or reached_duration_limit()

func _fixed_process(delta):
	process_swipe(delta)

func _process(delta):
	process_swipe(delta)

func process_swipe(delta, event=null):
	if not capturing_gesture and swiping_started():
		swipe_start()
	elif capturing_gesture and swiping() and not reached_limit():
		swipe_update(delta)
	elif capturing_gesture and swiping() and reached_limit():
		swipe_stop(true)
	elif capturing_gesture and not swiping():
		swipe_stop()
	was_swiping = swiping()

	
func clean_state():
	gesture = null
	last_update_delta = null
	capturing_gesture = false
	

func swiping_started():
	return not was_swiping and swiping()

func swiping():
	return swipe_input.swiping()


func swipe_point():
	return swipe_input.swipe_point()


func swipe_start():
	var point = swipe_point()
	capturing_gesture = true
	last_update_delta = 0
	gesture = SwipeGesture.new()
	add_gesture_data(point)
	emit_signal('swipe_started', point)
	return self


func swipe_stop(forced=false):
	if gesture.point_count() > minimum_points and gesture.get_duration() > duration_threshold:
		
		if forced:
			capturing_gesture = false
			
		emit_signal('swiped', gesture)
		emit_signal('swipe_ended', gesture)
		gesture_history.append(gesture)
	else:
		emit_signal('swipe_failed')
	clean_state()
	return self


func swipe_update(delta):
	var point = swipe_point()
	last_update_delta += delta
	if gesture.last_point().distance_to(point) > distance_threshold:
		add_gesture_data(point, last_update_delta)
		emit_signal('swipe_updated', point)
		emit_signal('swipe_updated_with_delta', point, last_update_delta) 
		last_update_delta = 0


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



## SwipeGesture class

class SwipeGesture:
	# Stores swipe data
	
	var points # list of points
	var duration # in seconds
	
	var distance
	var distance_points
	
	func _init():
		points = []
		duration = 0
	
	func get_distance():
		if not distance and distance_points != points.size():
			distance = calculate_distance()
			distance_points = points.size()
		return distance
	
	func calculate_distance():
		var last = points[0]
		var distance = 0
		for point in points:
			distance = last.distance_to(point)
			last = point
		return distance
	
	func get_speed():
		return get_distance() / get_duration() 
	
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


## Swipe Input

class SwipeInput:
	
	var detector
	
	func _init(detector):
		self.detector = detector


class MouseSwipeInput extends SwipeInput:

	func _init(detector).(detector):
		pass

	func swiping():
		return Input.is_mouse_button_pressed(BUTTON_LEFT)
		
	func swipe_point():
		return self.detector.get_viewport().get_mouse_pos()