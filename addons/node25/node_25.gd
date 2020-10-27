tool
extends Node2D
class_name Node25, "res://addons/node25/icons/node_25.png"

export var two_per_three = 32

export(Vector3) var spatial_position setget set_spatial_position, get_spatial_position

export(Vector2) var sprite_size setget set_sprite_size, get_sprite_size

const math_names = ['StaticBody', 'KinematicBody', 'RigidBody']
const sprite_names = ['Sprite', 'AnimatedSprite']

var spatial_node
var sprite_node

var collision_node

enum MathType {Empty, STATIC, RIGID, KINEMATIC}
enum SpriteType { ANIMATED_SPRITE, SPRITE, Empty}
export(MathType) var spatial_type setget set_spatial_type
export(SpriteType) var sprite_type setget set_sprite_type

func _get_configuration_warning() -> String:
  var notis = []
  if spatial_node == null:
    notis.append("Spatial node is missing")
  if sprite_node == null:
    notis.append("Sprite node is missing")
  
  return PoolStringArray(notis).join("\n")

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

func get_spatial_position():
  if spatial_node:
    return spatial_node.translation

  return Vector3()

func set_spatial_position(value):
  if spatial_node:
    spatial_node.translation = value

func get_spatial_node_name():
  if spatial_node:
    return spatial_node.get_name()
  return "empty node"

func set_sprite_size(value):
  if sprite_node:
    sprite_node.texture.set_size(value)
    if spatial_node:
      spatial_node.collison

func get_sprite_size():
  if sprite_node:
    return sprite_node.texture.get_size()
  return Vector2()

func set_spatial_type(value):
  if !spatial_node && has_node("math"):
    spatial_node = get_node("math")

  if spatial_type != value:
    spatial_type = value
    if spatial_node:
      if get_type(spatial_node.get_class()) != spatial_type:
        if spatial_node.get_parent() == self:
          remove_child(spatial_node)
        spatial_node.free()
        update_configuration_warning()
      else:
        return

    match value:
      MathType.STATIC:
        spatial_node = StaticBody.new()
      MathType.KINEMATIC:
        spatial_node = KinematicBody.new()
      MathType.RIGID:
        spatial_node = RigidBody.new()
      _:
        if spatial_node:
          spatial_node.queue_free()
    
    if spatial_node:
      spatial_node.set_name('math')
      add_child(spatial_node)
      # weird behavior - but we need correct owner or else the node won't display
      var own = get_owner() if get_owner() else self
      spatial_node.set_owner(own)
      
      # auto create a collision too
      collision_node = CollisionShape.new()
      collision_node.set_name("shape")
      spatial_node.add_child(collision_node)
      collision_node.set_owner(own)
    update_configuration_warning()


func set_sprite_type(value):
  if !sprite_node && has_node("sprite"):
    sprite_node = get_node("sprite")

  if sprite_type != value:
    sprite_type = value
    if sprite_node:
      if get_type(sprite_node.get_class()) != sprite_type:
        if sprite_node.get_parent() == self:
          remove_child(sprite_node)
        sprite_node.free()
        update_configuration_warning()
      else:
        return

    match value:
      SpriteType.SPRITE:
        sprite_node = Sprite.new()
      SpriteType.ANIMATED_SPRITE:
        sprite_node = AnimatedSprite.new()
      _:
        if sprite_node:
          sprite_node.queue_free()
    
    if sprite_node:
      sprite_node.set_name('sprite')
      .add_child(sprite_node)
      # weird behavior - but we need correct owner or else the node won't display
      var own = get_owner() if get_owner() else self
      sprite_node.set_owner(own)
    update_configuration_warning()

func remove_child(node):
  .remove_child(node)
  if node == spatial_node:
    set_spatial_type(MathType.Empty)
  if node == sprite_node:
    set_sprite_type(SpriteType.Empty)

func is_math_type(cls) -> bool:
  return math_names.has(cls)

func is_sprite_type(cls) -> bool:
  return sprite_names.has(cls)

func get_type(cls):
  var type = null
  match cls:
    "StaticBody": type = MathType.STATIC
    "KinematicBody": type = MathType.KINEMATIC
    "RigidBody": type = MathType.KINEMATIC
    "Sprite": type = SpriteType.SPRITE
    "AnimatedSprite": type = SpriteType.ANIMATED_SPRITE
  return type

func add_child(node,  legible_unique_name: bool = false):
  var cls = node.get_class()
  var type = get_type(cls)
  if !spatial_node && is_math_type(cls):
    set_spatial_type(type)
  elif !sprite_node && is_sprite_type(cls):
    set_sprite_type(type)
  else:
    .add_child(node)

