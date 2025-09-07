class_name SaverLoader
extends Node

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quicksave"):
		save_game()
	elif Input.is_action_just_pressed("quickload"):
		load_game()
	
func save_game():
	print("Saving game...")
	var saved_game := SavedGame.new()
	
	var player := Utils.get_player()
	saved_game.player_position = player.global_position
	saved_game.player_direction = player.current_facing_dir
	
	ResourceSaver.save(saved_game, "user://savegame.tres")
	

func load_game():
	print("Loading game...")
	var saved_game: SavedGame = load("user://savegame.tres") as SavedGame
	
	var player := Utils.get_player()
	player.global_position = saved_game.player_position
	player.current_tile_pos = player.position / Player.TILE_SIZE
	player.change_facing_direction(saved_game.player_direction)