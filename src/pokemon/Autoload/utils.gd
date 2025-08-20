extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_player() -> Player:
	var current_scene: Node = get_node("/root/SceneManager/CurrentScene")
	if current_scene != null:
		return current_scene.get_children().back().find_child("Player")
	return null

func get_scene_manager() -> SceneManager:
	return get_node("/root/SceneManager") as SceneManager
