tool
extends RigidBody2D

export (bool) var emphasis = false setget set_emphasis
export (float) var point_scale = 1.0 setget set_point_scale

onready var initial_collision_radius = $Collision.get_shape().get_radius()
onready var initial_sprite_scale = $Sprite.get_scale()
onready var initial_emphasis_scale = $Emphasis.get_scale()

var ready = false

func _ready():
  ready = true
  apply_scale(point_scale)
  update_emphasis()

func update_emphasis():
  if emphasis:
    $Emphasis.show()
  else:
    $Emphasis.hide()

func set_emphasis(value):
  emphasis = value
  if ready:
    update_emphasis()


func colorize(color):
  $Sprite.set_modulate(color)
  return self
  

func set_point_scale(value):
  point_scale = value
  if ready:
    apply_scale(value)
  

func apply_scale(value):
  $Sprite.set_scale(initial_sprite_scale * value)
  $Emphasis.set_scale(initial_emphasis_scale * value)
  var new_shape = CircleShape2D.new()
  new_shape.set_radius(initial_collision_radius * value)
  $Collision.set_shape(new_shape)
  return self


func collision_radius():
  return $Collision.get_shape().get_radius()

func drag_radius():
  return $DragArea.get_shape().get_radius()

func is_drag_point(point):
  return get_position().distance_to(point) <= drag_radius()

func has(point):
  return get_position().distance_to(point) <= collision_radius()

func impulse(speed, angle=0):
  apply_impulse(Vector2(0,0), Vector2(0, -speed).rotated(angle))
  