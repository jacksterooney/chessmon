extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_player() -> Player:
	return get_tree().get_nodes_in_group("player").back()

func get_scene_manager() -> MapManager:
	return get_node("/root/Main/MapManager") as MapManager
