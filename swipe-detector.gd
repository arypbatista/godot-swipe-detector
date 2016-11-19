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

# Signal triggered when gesture detected
signal pattern_detected(pattern_name, actual_gesture)

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

# Threshold for gesture detection
export var pattern_detection_score_threshold = 80

# Debug mode: will print debug information
export var debug_mode = false

## Implementation

func debug(message, more1='', more2='', more3=''):
	if debug_mode:
		print('[DEBUG][SwipeDetector] ', message, more1, more2, more3)

const DIRECTION_UP = 'up'
const DIRECTION_DOWN = 'down'
const DIRECTION_RIGHT = 'right'
const DIRECTION_LEFT = 'left'

const DIRECTION_UP_LEFT = 'up_left'
const DIRECTION_UP_RIGHT = 'up_right'
const DIRECTION_DOWN_LEFT = 'down_left'
const DIRECTION_DOWN_RIGHT = 'down_right'

const DIRECTIONS = [
	DIRECTION_DOWN,
	DIRECTION_DOWN_RIGHT, 
	DIRECTION_RIGHT, 
	DIRECTION_UP_RIGHT,
	DIRECTION_UP, 
	DIRECTION_UP_LEFT,
	DIRECTION_LEFT,
	DIRECTION_DOWN_LEFT
]

onready var capturing_gesture = false
onready var gesture_history = []
var gesture
var last_update_delta
onready var was_swiping = false
var swipe_input
onready var ready = true

onready var pattern_detections = {}



func _ready():
	swipe_input = get_swipe_input()
	set_swipe_process(process_method, detect_gesture)
	add_children_as_patterns()

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

		detect_gestures(gesture)
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

func points_to_gesture(points):
	return SwipeGesture.new(points)


# Gesture/Curve detection methods

func add_pattern_detection(name, gesture):
	pattern_detections[name] = GesturePattern.new(name, gesture)

func remove_pattern_detections():
	pattern_detections = {}

func remove_pattern_detection(name):
	pattern_detections.erase(name)

func add_children_as_patterns():
	for child in get_children():
		var gesture = SwipeGesture.new()
		for point in child.get_children():
			gesture.add_point(point.get_pos())
		add_pattern_detection(child.get_name(), gesture)

func detect_gestures(gesture):
	var best_match
	for pattern_name in pattern_detections.keys():
		var actual_match = match_gestures(gesture, pattern_detections[pattern_name])
		if actual_match.is_match() and (not best_match or actual_match.better_than(best_match)):
			best_match = actual_match
	if best_match:
		debug('Matched gesture "', best_match.pattern.name, '" with score ', str(best_match.score()))
		emit_signal('pattern_detected', best_match.pattern.name, gesture)

func match_gestures(gestureA, gestureB):
	return EuclideanMatch.new(gestureA, gestureB, pattern_detection_score_threshold)

## Match classes

class GestureMatch:

	var sample
	var pattern
	var score
	var threshold

	func _init(sampleGesture, patternGesture, threshold):
		self.threshold = threshold
		self.sample = sampleGesture
		self.pattern = patternGesture

	func score():
		if not score:
			var relative_pattern = pattern.gesture.relative()
			var relative_sample  = sample.relative()
			var sample_scale = scale(relative_pattern, relative_sample)
			var pointsA = points(relative_sample.scale(sample_scale))
			var pointsB = points(relative_pattern)

			if pointsA.size() > pointsB.size():
				pointsA = pick_samples(pointsA, pointsB.size())
			elif pointsB.size() > pointsA.size():
				pointsB = pick_samples(pointsB, pointsA.size())

			score = similarity_algorithm().similarity_score(pointsA, pointsB)
		return score

	func similarity_algorithm():
		print('Subclass Responsibility!')
		breakpoint

	func is_match():
		return score() < threshold

	func points(gesture):
		var curve = gesture.get_curve()
		curve.set_bake_interval(min(gesture.get_point(0).distance_to(gesture.get_point(1)), 20))
		return curve.get_baked_points()

	func pick_samples(points, pick_count):
		var spacing = points.size()/pick_count
		var samples = []
		for i in range(pick_count):
			samples.append(points[floor(spacing * i)])
		return samples

	func scale(gA, gB):
		var minGA = gA.get_point(0)
		var minGB = gB.get_point(0)
		var maxGA = gA.get_point(0)
		var maxGB = gB.get_point(0)
		for i in range(min(gA.get_points().size(), gB.get_points().size())):
			if gA.get_point(i).distance_to(minGA) > minGA.distance_to(maxGA):
				maxGA = gA.get_point(i)
			elif gA.get_point(i).distance_to(maxGA) > minGA.distance_to(maxGA):
				minGA = gA.get_point(i)

			if gB.get_point(i).distance_to(minGB) > minGB.distance_to(maxGB):
				maxGB = gB.get_point(i)
			elif gB.get_point(i).distance_to(maxGB) > minGB.distance_to(maxGB):
				minGB = gB.get_point(i)

		var scale1 = minGA.distance_to(maxGA) / minGB.distance_to(maxGB)

		return Vector2(scale1, scale1)

	func better_than(otherMatch):
		return score() > otherMatch.score()


class EuclideanSimilarityAlgorithm:

	func similarity_score(xs, ys):
		var sum = 0
		for i in range(min(xs.size(), ys.size())):
			sum += point_similarity_score(xs[i], ys[i])
		return sum / float(min(xs.size(), ys.size()))

	func point_similarity_score(x, y):
		if TYPE_VECTOR2 == typeof(x):
			return x.distance_to(y)
		else:
			return abs(x - y)


class EuclideanMatch extends GestureMatch:

	func _init(sample, pattern, threshold).(sample, pattern, threshold):
		pass

	func similarity_algorithm():
		return EuclideanSimilarityAlgorithm.new()


class ShapeSimilarityAlgorithm:

	func similarity_score(pointsA, pointsB):
		return EuclideanSimilarityAlgorithm.new().similarity_score(delta_chain(pointsA), delta_chain(pointsB))

	func delta_chain(points):
		var chain = []
		var previous_point
		for point in points:
			if previous_point != null:
				var angle = rad2deg(Vector2(0,0).angle_to_point(point - previous_point))
				chain.append(angle)
			previous_point = point
		return chain

# Don't use yet, lot of false possitives
class ShapeMatch extends GestureMatch:

	func _init(sample, pattern, threshold).(sample, pattern, threshold):
		pass

	func similarity_algorithm():
		return ShapeSimilarityAlgorithm.new()

	func points(gesture):
		return gesture.get_points()

## GesturePattern

class GesturePattern:

	var gesture
	var name

	func _init(name, gesture):
		self.name = name
		self.gesture = gesture


## SwipeGesture class

class SwipeGesture extends Node: # Extend node to access duplicate function
	# Stores swipe data

	var points # list of points
	var duration # in seconds

	var relative # SwipeGesture with relative points

	var distance
	var distance_points

	func _init(points=[]):
		self.points = points
		self.duration = 0

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

	func get_point(index):
		return points[index]

	func point_count():
		return points.size()

	func relative():
		if not relative:
			relative = duplicate()
			relative.points = []
			for point in get_points():
				relative.points.append(point - first_point())
		return relative

	func scale(scale):
		var scaled = duplicate()
		scaled.relative = null
		scaled.points = []
		for point in get_points():
			scaled.points.append(Vector2(point.x * scale.x, point.y * scale.y))
		return scaled

	func get_direction_angle():
		return first_point().angle_to_point(last_point())

	func get_direction_vector():
		# Normalized direction vector
		return (last_point() - first_point()).normalized()

	func get_direction_index():
		var angle = get_direction_angle() + PI
		var percentage = angle/(PI*2.0) + 1.0/16
		var index = int(floor(percentage * 8)) % 8
		
		print("Angle: " , angle, ' index: ', index)
		print("Pecentage: ", percentage)
		return index

	func get_direction():
		return DIRECTIONS[get_direction_index()]

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
