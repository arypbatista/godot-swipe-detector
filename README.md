# godot-swipe-detector
Swipe Detector is a swipe detection script that monitor screen input
(mouse/touch) triggering different signals informing swipe progress
or swipe finalization. There are a lot of configurations available
to indicate detector when to consider a movement to a swipe or to
indicate the precision of the detected swipe curve. On swipe end you
will obtain a ﻿SwipeGesture﻿ object that holds swipe information such
as duration, speed, distance (from initial point), points, Curve2D.

It also implements some basic pattern detections, but it is still
experimental.

![Trail](https://github.com/arypbatista/godot-swipe-detector/blob/master/docs/trail.png?raw=true)

## Usage

Add the script to a node in your scene and connect to the [signals](#signals).
There are many [options available](#options-exported-variables) to customize Swipe Detector's behavior.

When swipe is detected, you will receive a `SwipeGesture` object with all
the gesture information. This includes `points` conforming the gesture
and `duration` of the swipe. [Read more](#swipegesture)

You can set patterns for automatic detection (experimental), see [Working With Patterns](#working-with-patterns).

You can get the history of all gestures through `history()` method on swipe
detector.

### Example

The following is an example of a callback connected to the `swiped` signal.
This callback instances a cloud for each point. The cloud is a custom scene,
you can replace it with your own.

```py
func swiped(gesture):
	for point in gesture.get_points():
		var cloud = Cloud.instance()
		cloud.set_pos(point)
		add_child(cloud)
```

See the [examples folder](./examples) for more examples.

### Working with Patterns

There are two ways to work with patterns, you can do it from editor by adding pattern nodes
to the `SwipeDetector` node or you can interact directly with [`SwipeDetector` API](#public-api-methods).

See all gesture detection examples [here](./examples/gesture-detection/).

#### Using Pattern Nodes

Pattern nodes is not a particular node type (maybe in a future) but a node grouping other nodes which
represent pattern points.

For example:

![Square Pattern Tree](https://github.com/arypbatista/godot-swipe-detector/blob/master/docs/square-pattern-tree.png?raw=true)
![Square Pattern Render](https://github.com/arypbatista/godot-swipe-detector/blob/master/docs/square-pattern-render.png?raw=true)

When nesting this tree under your `SwipeDetector` node it will be included as a trigger pattern with the same name as the pattern node.

See the [Gesture Detection Example With Patterns](./examples/gesture-detection/GestureDetectionExample.tscn) for pattern detection example.

#### Using `SwipeDetector` API to Add Patterns

The following example builds a square pattern and sets it as trigger pattern.

```
onready var swipeDetector = get_node('SwipeDetector')

func ready():
    var pattern_points = [v(0,0), v(0, 100), v(0, 200), v(100, 200), v(200, 200), v(200, 100), v(200, 0), v(100, 0)]
    var pattern_gesture = swipeDetector.points_to_pattern(pattern_points)
    swipeDetector.add_pattern_detection('SquarePattern', pattern_gesture)
    swipeDetector.connect('pattern_detected', self, 'on_pattern_detection')

# Alias for Vector2
func v(x, y):
    return Vector2(x, y)

func on_pattern_detection(pattern_name, gesture):
    if pattern_name == 'SquarePattern':
        print('Square Pattern was detected!')

```

You may see [Gesture Detection Example](./examples/gesture-detection/GestureDetectionExample.tscn) where `SwipeDetector` API is used
to set a recorded gesture as trigger pattern.



## Options (Exported Variables)

There are some options available:

- `Detect Gesture`: Indicates whether detector should detect or not swiping.
- `Process Method`: Indicates the process method to be used (Fixed or Idle).
- `Distance Threshold`: Indicates which is the minimum distance between two
points on the gesture, smaller this number, bigger the point count you will get
(i.e. more precisse information).
- `Duration Threshold`: Indicates how long a gesture needs to last to be
considered as a gesture. You can calibrate the swipe detector so you don't
accidentally swipe when intended to click.
- `Limit Duration`: Indicates whether to limit swipe by duration or not.
- `Maximum Duration`: Indicates the maximum duration for a swipe.
- `Minimum Points`: Indicates how many points makes a gesture. You may only
admit complex gestures with more than six points, for example.
- `Limit Points`: Indicates whether to limit swipe count points or not.
- `Maximum Points`: Indicates the maximum point count for a swipe.
- `Pattern Detection Threshold`: Indicates minimum score for pattern detection matching.
- `Debug Mode`: Enable/Disable debug output on console.


## Signals

- `swiped(gesture)` - Signal triggered when swipe captured.
- `swipe_ended(gesture)` - Alias for `swiped(gesture)`.
- `swipe_started(point)` - Signal triggered when swipe started.
- `swipe_updated(point)` - Signal triggered when gesture is updated.
- `swipe_updated_with_delta(point, delta)` - Signal triggered when gesture is updated. `delta` parameter indicates time delta from last update.
- `swipe_failed()` - Signal triggered when swipe failed. This means the swipe didn't pass thresholds and requirements to be detected as swipe.
- `pattern_detected(pattern_name, actual_gesture)` - Signal triggered when gesture matches predefined pattern.


## Public API Methods & constants

Methods intended for public usage are:

- `add_pattern_detection(name, gesture)` - add a pattern as trigger for `pattern_detected` signal.
- `remove_pattern_detection(name)` - remove a specific trigger pattern.
- `remove_pattern_detections()` - remove all trigger patterns.
- `history()` - list of all the gestures detected since component creation.
- `points_to_gesture(points)` - Build a gesture object from a list of points.

Direction constants:

- `DIRECTION_DOWN`
- `DIRECTION_DOWN_RIGHT`
- `DIRECTION_RIGHT`
- `DIRECTION_UP_RIGHT`
- `DIRECTION_UP`
- `DIRECTION_UP_LEFT`
- `DIRECTION_LEFT`
- `DIRECTION_DOWN_LEFT`
- `DIRECTIONS` - List of directions ordered.

## Class References

### `SwipeGesture`

The `SwipeGesture` class instances store all the information gathered from gestures.

#### API

Methods intended for public usage are:

- `get_duration()` - Returns gesture duration.
- `get_distance()` - Returns the path distance from the first to the last point.
- `get_speed()` - Distance divided by duration of swipe.
- `get_points()` - Returns the points conforming the gesture.
- `get_curve()` - Returns a Curve2D built from gesture points.
- `first_point()` - Returns the first point of the gesture.
- `last_point()` - Returns the last point of the gesture.
- `point_count()` - Returns the point count.
- `get_direction()` - Return a direction string use constants to test this values.
- `get_direction_vector()` - Returns the direction vector.
- `get_direction_angle()` - Returns the direction angle.
