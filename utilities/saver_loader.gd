class_name SaverLoader
extends Node

@onready var map_manager := %MapManager as MapManager

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quicksave"):
		save_game()
	elif Input.is_action_just_pressed("quickload"):
		load_game()
	
func save_game() -> void:
	print("Saving game...")
	var saved_game := SavedGame.new()
	
	var player := Utils.get_player()
	saved_game.player_position = player.global_position
	saved_game.player_direction = player.current_facing_dir

	saved_game.current_map_filepath = map_manager.current_map_filepath
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	

func load_game() -> void:
	print("Loading game...")
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame

	map_manager.load_new_map(saved_game.current_map_filepath)
	
	var player := Utils.get_player()
	player.global_position = saved_game.player_position
	player.current_tile_pos = player.position / Player.TILE_SIZE
	player.set_facing_direction(saved_game.player_direction)
