tool
extends EditorPlugin


func _enter_tree():
  add_custom_type("Node25", "Node2D", preload("node_25.gd"), preload("icons/node_25.png"))

func _exit_tree():
  remove_custom_type("Node25")
