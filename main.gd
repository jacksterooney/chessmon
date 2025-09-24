extends Node

@onready var map_manager := $MapManager as MapManager

func _on_main_menu_new_game_selected() -> void:
	map_manager.load_new_map(map_manager.initial_map_filepath)
