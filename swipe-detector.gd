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

# Debug mode: will print debug information
export var debug_mode = false

## Implementation

func debug(message, more1='', more2='', more3=''):
	if debug_mode:
		print('[DEBUG][SwipeDetector] ', message, more1, more2, more3)

var capturing_gesture
var gesture_history
var gesture
var last_update_delta
var was_swiping
var swipe_input
var ready = false

func _ready():
	ready = true
	gesture_history = []
	capturing_gesture = false
	was_swiping = false
	
	swipe_input = get_swipe_input()
	set_swipe_process(process_method, detect_gesture)
	
func _input(ev):
	swipe_input.process_input(ev)

func get_swipe_input():
	var swipe_input
	if on_touch_device():
		swipe_input = TouchSwipeInput.new(self)
	else:
		swipe_input = MouseSwipeInput.new(self)
	return swipe_input
	
func on_touch_device():
	return OS.get_name() in ['Android', 'iOS'] 

func set_swipe_process(method, value):
	if swipe_input.has_method('process_input'):
		set_process_input(true)
	
	if swipe_input.has_method('process'):
		if method == PROCESS_IDLE:
			set_process(value)
		elif method == PROCESS_FIXED:
			set_fixed_process(value)

func detect(detect=true):
	if ready:
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
	swipe_input.process(delta)

func _process(delta):
	swipe_input.process(delta)

func process_swipe(delta):
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
	debug('Swipe started on point ', point)
	capturing_gesture = true
	last_update_delta = 0.0
	gesture = SwipeGesture.new()
	add_gesture_data(point)
	emit_signal('swipe_started', point)
	return self


func swipe_stop(forced=false):
	if gesture.point_count() > minimum_points and gesture.get_duration() > duration_threshold:
		
		if forced:
			capturing_gesture = false
			
		debug('Swipe stopped on point ', gesture.last_point(), ' (forced: ' + str(forced) + ')')
		emit_signal('swiped', gesture)
		emit_signal('swipe_ended', gesture)
		gesture_history.append(gesture)
	else:
		debug('Swipe stopped on point ', gesture.last_point(), ' (failed)')
		emit_signal('swipe_failed')
	clean_state()
	return self


func swipe_update(delta):
	var point = swipe_point()
	last_update_delta += delta
	if gesture.last_point().distance_to(point) > distance_threshold:
		debug('Swipe updated with point ', point, ' (delta: ' + str(delta) + ')')
		add_gesture_data(point, last_update_delta)
		emit_signal('swipe_updated', point)
		emit_signal('swipe_updated_with_delta', point, last_update_delta) 
		last_update_delta = 0.0


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
		var distance = 0.0
		for point in points:
			distance += last.distance_to(point)
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

# SwipeMath utility class

class SwipeMath:
	
	func calculate_time(speed_vector, position, origin=Vector2(0,0)):
		var distance = position.distance_to(origin)
		var speed = speed_vector.distance_to(Vector2(0,0))
		return distance / speed

## Swipe Input

class SwipeInput:
	
	var detector
	
	func _init(detector):
		self.detector = detector
	
	# If defined, it will receive input events
	# from SwipeDetector.
	# func process_input(event):
	#     pass
	
	# If defined, it will be called on SwipeDetector
	# _process method.
	# func process(delta):
	#     pass


class EventSwipeInput extends SwipeInput:
	
	var swiping
	var point
	var last_time
	var delta
	
	func _init(detector).(detector):
		self.swiping = false
		delta = 0.0
	
	func event_types():
		return []
	
	func process_input(event):
		if event.type in self.event_types():
			if not last_time:
				delta = 0.0
			else:
				delta = (OS.get_ticks_msec() - last_time) / 1000.0
			
			process_event(event, delta)
			last_time = OS.get_ticks_msec()
	
	func process_event(event, delta):
		pass
	
	func swiping():
		return swiping
	
	func swipe_point():
		return point


class MouseSwipeInput extends EventSwipeInput:

	func _init(detector).(detector):
		pass

	func event_types():
		return [InputEvent.MOUSE_BUTTON, InputEvent.MOUSE_MOTION]

	func process_event(event, delta):
		if event.type == InputEvent.MOUSE_BUTTON and event.is_pressed():
			self.swiping = true
		
		self.point = event.pos
		detector.process_swipe(delta)
		
		if event.type == InputEvent.MOUSE_BUTTON and not event.is_pressed():
			self.swiping = false
			detector.process_swipe(delta)


class TouchSwipeInput extends EventSwipeInput:

	func _init(detector).(detector):
		pass
	
	func event_types():
		return [InputEvent.SCREEN_TOUCH, InputEvent.SCREEN_DRAG]
	
	func process_event(event, delta):
		if event.type == InputEvent.SCREEN_TOUCH and event.is_pressed():
			self.swiping = true
	
		self.point = event.pos
		detector.process_swipe(delta)
		
		if event.type == InputEvent.SCREEN_TOUCH and not event.is_pressed():
			self.swiping = false
			detector.process_swipe(delta)

