# godot-swipe-detector
Swipe Detector is a swipe detection script that monitor screen input (mouse/touch) triggering different signals informing swipe progress or swipe finalization. There are a lot of configurations available to indicate detector when to consider a movement to a swipe or to indicate the precision of the detected swipe curve. On swipe end you will obtain a ﻿SwipeGesture﻿ object that holds swipe information such as duration, speed, distance (from initial point), points, Curve2D.

![Trail](https://github.com/arypbatista/godot-swipe-detector/blob/master/docs/trail.png?raw=true)

## Usage

Add the script to a node in your scene and connect to the [signals](#signals).
There are many [options available](#options-exported-variables) to customize Swipe Detector's behavior.


When swipe is detected, you will receive a `SwipeGesture` object with all
the gesture information. This includes `points` conforming the gesture
and `duration` of the swipe. [Read more](#swipegesture-object)

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

## Options (Exported Variables)

There are some options available:

- **Detect Gesture**: Indicates whether detector should detect or not swiping.
- **Process Method**: Indicates the process method to be used (Fixed or Idle).
- **Distance Threshold**: Indicates which is the minimum distance between two 
points on the gesture, smaller this number, bigger the point count you will get
(i.e. more precisse information).
- **Duration Threshold**: Indicates how long a gesture needs to last to be 
considered as a gesture. You can calibrate the swipe detector so you don't 
accidentally swipe when intended to click.
- **Limit Duration**: Indicates whether to limit swipe by duration or not.
- **Maximum Duration**: Indicates the maximum duration for a swipe.
- **Minimum Points**: Indicates how many points makes a gesture. You may only 
admit complex gestures with more than six points, for example.
- **Limit Points**: Indicates whether to limit swipe count points or not.
- **Maximum Points**: Indicates the maximum point count for a swipe.
- **Debug Mode**: Enable/Disable debug output on console.


## Signals

- `swiped(gesture)` - Signal triggered when swipe captured.
- `swipe_ended(gesture)` - Alias for `swiped(gesture)`.
- `swipe_started(point)` - Signal triggered when swipe started.
- `swipe_updated(point)` - Signal triggered when gesture is updated.
- `swipe_updated_with_delta(point, delta)` - Signal triggered when gesture is updated. `delta` parameter indicates time delta from last update.
- `swipe_failed()` - Signal triggered when swipe failed. This means the swipe didn't pass thresholds and requirements to be detected as swipe.

## `SwipeGesture` object

The `SwipeGesture` object stores all the information gathered from the gesture.

Methods intended for public usage are:

- `get_duration()` - Get gesture duration.
- `get_distance()` - Get the path distance from the first to the last point.
- `get_speed()` - Distance divided by duration of swipe.
- `get_points()` - Obtain the points conforming the gesture.
- `get_curve()` - Get a Curve2D built from gesture points.
- `first_point()` - Get the first point of the gesture.
- `last_point()` - Get the last point of the gesture.
- `point_count()` - get the point count.
