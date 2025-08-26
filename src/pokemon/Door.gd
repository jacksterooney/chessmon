class_name Door
extends Area2D

@export_file("*.tscn") var next_scene_path: String = ""

@export var spawn_location := Vector2(0, 0)
@export var spawn_direction := Vector2(0, 0)

@onready var sprite = $Sprite
@onready var anim_player = $AnimationPlayer


func _ready():
	sprite.visible = false
	
func enter_door():
	anim_player.play("OpenDoor")


func door_closed():
	Utils.get_scene_manager().transition_to_scene(next_scene_path, spawn_location, spawn_direction)
