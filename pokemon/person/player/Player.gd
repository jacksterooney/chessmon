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

var can_interact: bool       =  true
var can_move: bool		     =  true
#endregion

#region @onready variables
@onready var camera := $Camera2D as Camera2D
@onready var shadow := $Shadow as Sprite2D
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	shadow.visible = false
	camera.make_current()

	add_to_group("player")
	
	# Connect to Dialogic signals
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_ended)


func set_spawn(location: Vector2i, direction: Vector2i) -> void:
	if anim_tree == null:
		anim_tree = $AnimationTree as AnimationTree 

	global_position = location
	current_tile_pos = position / TILE_SIZE
	set_facing_direction(direction)


func _process(delta: float) -> void:
	handle_held_input(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		handle_player_interaction()


func handle_held_input(delta: float) -> void:
	if !can_move:
		return

	var input_dir := Vector2i.ZERO

	# Check for held input
	if Input.is_action_pressed("up"):
		input_dir = Vector2i.UP
	elif Input.is_action_pressed("down"):
		input_dir = Vector2i.DOWN
	elif Input.is_action_pressed("left"):
		input_dir = Vector2i.LEFT
	elif Input.is_action_pressed("right"):
		input_dir = Vector2i.RIGHT

	# If input direction changed or stopped
	if input_dir != current_input_dir:
		current_input_dir = input_dir
		move_timer = 0.0
		is_initial_move = true

		if input_dir != Vector2i.ZERO:
			set_facing_direction(current_input_dir)

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


func set_facing_direction(direction: Vector2i) -> void:
	current_facing_dir = direction

	var vector_2_direction := Vector2(direction)
	anim_tree.set("parameters/Idle/blend_position", vector_2_direction)
	anim_tree.set("parameters/Walk/blend_position", vector_2_direction)


func try_move(direction: Vector2i) -> void:
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


func move_into_door(door: Door) -> void:
	door.enter_door()
	sprite.visible = false


func handle_player_interaction() -> void:
	# Check for held input
	if can_interact:
		var tile_pos: Vector2i =  current_tile_pos + current_facing_dir
		var result             := query_tile(tile_pos)
		if !result.is_empty():
			var collider := result[0]["collider"] as CollisionObject2D
			if collider.is_in_group("npcs"):
				(collider as NPC).start_conversation(self.position)
			elif collider.is_in_group("interactables"):
				(collider as Interactable).start_interaction()


func _on_dialogue_started() -> void:
	can_interact = false


func _on_dialogue_ended() -> void:
	can_interact = true
