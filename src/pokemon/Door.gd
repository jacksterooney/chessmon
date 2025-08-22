class_name Door
extends Area2D

@export_file var next_scene_path: String = ""
@export var is_invisible: bool = false

@export var spawn_location := Vector2(0, 0)
@export var spawn_direction := Vector2(0, 0)

@onready var sprite = $Sprite
@onready var anim_player = $AnimationPlayer


func _ready():
	if is_invisible:
		$Sprite.texture = null
	sprite.visible = false
	var player: Node = Utils.get_player()
	if player != null:
		player.player_entered_door.connect(close_door)
	
func enter_door():
	anim_player.play("OpenDoor")
	
func close_door():
	anim_player.play("CloseDoor")

func door_closed():
	Utils.get_scene_manager().transition_to_scene(next_scene_path, spawn_location, spawn_direction)
