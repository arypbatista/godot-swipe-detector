extends Container


onready var dropdown = get_node('PanelContainer/HBoxContainer/VBoxContainer/OptionButton')
var options

func load_options():
  options  = []
  options.append('swipe-spawner/swipe_spawner')
  options.append('swipe-spawner/point_limited_swipe_spawner')
  options.append('swipe-spawner/duration_limited_swipe_spawner')
  options.append('swipe-impulse/swipe_impulse')
  options.append('swipe-impulse/swipe_smooth_impulse')
  options.append('swipe-impulse/swipe_touch_smooth_impulse')
  options.append('swipe-signals/swipe_signals')
  options.append('swipe-trail/swipe_trail')
  options.append('swipe-areas/swipe_areas')
  options.append('swipe-direction/swipe_direction')
  options.append('gesture-detection/gesture_detection')
  options.append('gesture-detection/gesture_detection_with_patterns')

func populate_dropdown():
  for option in options:
    dropdown.add_item(option.split('/')[1])

func _ready():
  load_options()
  populate_dropdown()

func launch():
  var selected_example = 0
  if dropdown.get_selected() > 0:
    selected_example = dropdown.get_selected()
    
  print('Selected example ', selected_example)
  load_example(options[selected_example])

func load_example(example):
  print('Loading example ', example)
  get_tree().change_scene('res://examples/' + example + '_example.tscn')
