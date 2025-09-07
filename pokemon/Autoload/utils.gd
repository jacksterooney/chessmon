extends Node


func get_player() -> Player:
	return get_tree().get_nodes_in_group("player").back()


func get_scene_manager() -> MapManager:
	return get_node("/root/Main/MapManager") as MapManager
