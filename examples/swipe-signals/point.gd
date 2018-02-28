extends RigidBody2D

var sprite
var collision

var initial_collision_radius
var initial_sprite_scale

var ready = false
var point_scale = 1

func _ready():
  sprite = get_node('Sprite')
  initial_sprite_scale = sprite.get_scale()
  collision = get_node('CollisionShape2D')
  initial_collision_radius = collision.get_shape().get_radius()
  ready = true
  apply_scale(point_scale)


func colorize(color):
  get_node('Sprite').set_modulate(color)
  return self
  

func set_point_scale(value):
  point_scale = value
  if ready:
    apply_scale(value)
  

func apply_scale(value):
  sprite.set_scale(initial_sprite_scale * value)
  var new_shape = CircleShape2D.new()
  new_shape.set_radius(initial_collision_radius * value)
  collision.set_shape(new_shape)
  return self
  