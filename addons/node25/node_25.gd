tool
extends Node2D
class_name Node25, "res://addons/node25/icons/node_25.png"

export var two_per_three = 32

export(Vector3) var spatial_position setget set_spatial_position, get_spatial_position

const body_names = ['StaticBody', 'KinematicBody', 'RigidBody']

var spatial_node
enum BodyType {Empty, STATIC, RIGID, KINEMATIC}
export(BodyType) var spatial_type setget set_spatial_type

func _get_configuration_warning() -> String:
  if spatial_node == null:
    return "Spatial node is missing"
  return ""

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
    update_configuration_warning()

func get_spatial_node_name():
  if spatial_node:
    return spatial_node.get_name()
  return "empty node"

func set_spatial_type(value):
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
    BodyType.STATIC:
      spatial_node = StaticBody.new()
    BodyType.KINEMATIC:
      spatial_node = KinematicBody.new()
    BodyType.RIGID:
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
  update_configuration_warning()

func remove_child(node):
  .remove_child(node)
  if node == spatial_node:
    set_spatial_type(BodyType.Empty)

func get_type(cls):
  var type = null
  match cls:
    "StaticBody": type = BodyType.STATIC
    "KinematicBody": type = BodyType.KINEMATIC
    "RigidBody": type = BodyType.KINEMATIC
  return type

func add_child(node,  legible_unique_name: bool = false):
  var body_type = get_type(node.get_class())
  if !spatial_node && body_type:
    set_spatial_type(body_type)
  else:
    .add_child(node)
  
