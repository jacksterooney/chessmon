class_name Door
extends Area2D

@export_file("*.tscn") var next_scene_path: String = ""

@export var requires_open_door_animation := true
@export var spawn_location := Vector2(0, 0)
@export var spawn_direction := Vector2(0, 0)

@onready var sprite = $Sprite
@onready var anim_player = $AnimationPlayer


func _ready():
	sprite.visible = false
	if next_scene_path == "":
		push_error("%s does not have a next scene path set." % name)
	
func enter_door():
	if requires_open_door_animation:
		anim_player.play("OpenDoor")
	else:
		transition_to_next_scene()


func transition_to_next_scene():
	Utils.get_scene_manager().transition_to_map(next_scene_path, spawn_location, spawn_direction)
