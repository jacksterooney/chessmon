class_name Player
extends Person

#region Enums
enum PlayerState { IDLE, TURNING, WALKING }
#endregion

#region Constants
const LANDING_DUST_EFFECT: PackedScene = preload("res://pokemon/LandingDustEffect.tscn")
#endregion

#region @export variables
@export var jump_speed: float = 4.0
@export var initial_delay: float = 0.0
@export var repeat_delay: float = 0.0

#endregion

#region regular variables
var jumping_over_ledge: bool =  false
var player_state             := PlayerState.IDLE
var current_input_dir        := Vector2i.ZERO
var stop_input               := false
var is_initial_move: bool    =  true

#endregion

#region @onready variables
@onready var camera: Camera2D = $Camera2D
@onready var shadow = $Shadow
#endregion

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	shadow.visible = false
	camera.make_current()

	add_to_group("player")


func set_spawn(location: Vector2, direction: Vector2):
	anim_tree.set("parameters/Idle/blend_position", direction)
	anim_tree.set("parameters/Walk/blend_position", direction)
	anim_tree.set("parameters/Turn/blend_position", direction)
	global_position = location
	current_tile_pos = position / TILE_SIZE


func _process(delta: float) -> void:
	handle_held_input(delta)
	handle_player_interaction()


func handle_held_input(delta) -> void:
	var input_dir := Vector2i.ZERO

	# Check for held input
	if Input.is_action_pressed("ui_up"):
		input_dir = Vector2i.UP
	elif Input.is_action_pressed("ui_down"):
		input_dir = Vector2i.DOWN
	elif Input.is_action_pressed("ui_left"):
		input_dir = Vector2i.LEFT
	elif Input.is_action_pressed("ui_right"):
		input_dir = Vector2i.RIGHT

	# If input direction changed or stopped
	if input_dir != current_input_dir:
		current_input_dir = input_dir
		move_timer = 0.0
		is_initial_move = true

		if input_dir != Vector2i.ZERO:
			change_facing_direction(current_input_dir)

		# Immediate move on new input
		if input_dir != Vector2i.ZERO and not is_moving:
			try_move(input_dir)
			return

	# Handle held input timing
	if current_input_dir != Vector2i.ZERO and not is_moving:
		move_timer += delta

		var delay_threshold: float = initial_delay if is_initial_move else repeat_delay

		if move_timer >= delay_threshold:
			try_move(current_input_dir)
			move_timer = 0.0
			is_initial_move = false


func change_facing_direction(direction: Vector2i):
	current_facing_dir = direction
	anim_tree.set("parameters/Idle/blend_position", direction)
	anim_tree.set("parameters/Walk/blend_position", direction)


func try_move(direction: Vector2i):
	var target_tile: Vector2i = current_tile_pos + direction

	if can_move_to_tile(target_tile):
		move_to_tile(target_tile)

	var door := can_move_into_door(target_tile)
	if door != null:
		move_into_door(door)


func can_move_into_door(tile_pos: Vector2i) -> Door:
	# Then check for StaticBody2D collision in the door group
	var results := query_tile(tile_pos)
	for result in results:
		if result["collider"] is Door:
			return result["collider"] as Door
	return null


func move_into_door(door: Door):
	door.enter_door()
	sprite.visible = false


func handle_player_interaction():
	# Check for held input
	if Input.is_action_just_pressed("interact"):
		var tile_pos: Vector2i =  current_tile_pos + current_facing_dir
		var result             := query_tile(tile_pos)
		if !result.is_empty():
			var collider = result[0]["collider"]
			if collider.is_in_group("npcs"):
				Dialogic.start('test_timeline')
