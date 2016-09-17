# godot-swipe-detector
Detect gestures and swipes in your game.

## Usage

Add the script to a node in your scene and connect to the `swiped` signal.

There are some options available such as *distance threshold*, *duration threshold*
and *minimum points*. 

The *distance threshold* indicates which is the minimum distance
between two points on the gesture, smaller this number, bigger the point
count you will get (i.e. more precisse information).

The *duration threshold* indicates how long a gesture needs to last to be 
considered as a gesture. You can calibrate the swipe detector so you don't
accidentally swipe when intended to click.

The *minimum points* indicates how many points makes a gesture. You may only
admit complex gestures with more than six points, for example.

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

## `SwipeGesture` object

The `SwipeGesture` object stores all the information gathered from the gesture.

Methods intended for public usage are:

- `get_duration()` - Get gesture duration.
- `get_points()` - Obtain the points conforming the gesture.
- `get_curve()` - Get a Curve2D built from gesture points.
- `first_point()` - Get the first point of the gesture.
- `last_point()` - Get the last point of the gesture.
- `point_count()` - get the point count.
