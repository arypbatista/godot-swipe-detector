extends Node

const MouseSwipeInput = preload("res://addons/swipe-detector/input/mouse_swipe_input.gd")
const TouchSwipeInput = preload("res://addons/swipe-detector/input/touch_swipe_input.gd")

func on_touch_device():
  return OS.get_name() in ['Android', 'iOS']

func get_swipe_input(detector):
  var swipe_input
  if on_touch_device():
    swipe_input = TouchSwipeInput.new(detector)
  else:
    swipe_input = MouseSwipeInput.new(detector)
  return swipe_input
