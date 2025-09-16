class_name MapManager
extends Node2D

@export var player_scene: PackedScene
@export_file("*.tscn") var initial_map_filepath: String = ""

var current_map_filepath: String = ""
var next_map_filepath: String = ""

@export var player_location: Vector2  = Vector2(0, 0)
@export var player_direction: Vector2 = Vector2(0, 1)

enum TransitionType { NEW_MAP, PARTY_SCREEN, MENU_ONLY }
var transition_type: int = TransitionType.NEW_MAP

#region @onready variables
@onready var current_map := $CurrentMap as Node2D
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_new_map(initial_map_filepath)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("load_test_map"):
		player_location = Vector2i(112, 64)
		load_new_map("res://pokemon/maps/test/test_map.tscn")

func transition_to_party_screen() -> void:
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.PARTY_SCREEN


func transition_exit_party_screen() -> void:
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.MENU_ONLY


func transition_to_map(
		new_map_filepath: String, 
		spawn_location: Vector2i, 
		spawn_direction: Vector2i,
		) -> void:
	next_map_filepath = new_map_filepath
	player_location = spawn_location
	player_direction = spawn_direction
	transition_type = TransitionType.NEW_MAP
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	
func finished_fading() -> void:
	match transition_type:
		TransitionType.NEW_MAP:
			load_new_map(next_map_filepath)
		TransitionType.PARTY_SCREEN:
			$Menu.load_party_screen()
		TransitionType.MENU_ONLY:
			$Menu.unload_party_screen()
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")

func load_new_map(map_filepath: String) -> void:
	if current_map.get_child_count() > 0:
		current_map.get_child(0).queue_free()
			
	var next_level_instance := load(map_filepath).instantiate() as Node2D
	current_map.add_child(next_level_instance)

	current_map_filepath = map_filepath
	
	var player: Player = player_scene.instantiate()
	player.set_spawn(player_location, player_direction)
	next_level_instance.add_child(player)
