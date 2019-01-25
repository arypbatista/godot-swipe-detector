extends Control


onready var dropdown = $Panel/HBoxContainer/VBoxContainer/OptionButton
var options

func load_options():
  options  = {}
  options['Spawn points'] = 'swipe-spawner/swipe_spawner'
  options['Spawn points with limit'] = 'swipe-spawner/point_limited_swipe_spawner'
  options['Spawn points with duration limit'] = 'swipe-spawner/duration_limited_swipe_spawner'
  options['Impulse disks'] = 'swipe-impulse/swipe_impulse'
  options['Drag disks smoothly'] = 'swipe-impulse/swipe_smooth_impulse'
  options['Signals'] = 'swipe-signals/swipe_signals'
  options['Trail'] = 'swipe-trail/swipe_trail'
  options['Two areas'] = 'swipe-areas/swipe_areas'
  options['Swipe direction'] = 'swipe-direction/swipe_direction'
  options['Swipe direction (four directions)'] = 'swipe-direction/swipe_four_directions'
  options['Experimental: Gesture detection'] = 'gesture-detection/gesture_detection'
  options['Experimental: Gesture detection with patterns'] = 'gesture-detection/gesture_detection_with_patterns'

func populate_dropdown():
  for option in options.keys():
    dropdown.add_item(option)

func _ready():
  load_options()
  populate_dropdown()

func launch():
  if dropdown.get_selected() > -1:
    var selected_example = 0
    var selected_name = 'None'
    selected_name = options.keys()[dropdown.get_selected()]
    selected_example = options[selected_name]
    print('Selected example ', selected_name, ' : ', selected_example)
    load_example(selected_example)
  else:
    print('No example selected')

func load_example(example):
  print('Loading example ', example)
  get_tree().change_scene('res://examples/' + example + '_example.tscn')
