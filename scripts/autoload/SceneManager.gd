extends Node

var current_scene = null

func _ready():
    var root = get_tree().root
    current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path: String):
    current_scene = path
    get_tree().change_scene_to_file("res://scenes/%s.tscn" % [path])