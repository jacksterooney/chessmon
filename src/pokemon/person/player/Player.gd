class_name Player
extends Person

#region Signals
signal player_entered_door
#endregion

#region Enums
enum PlayerState { IDLE, TURNING, WALKING }
#endregion

#region Constants
const LANDING_DUST_EFFECT: PackedScene = preload("res://pokemon/LandingDustEffect.tscn")
const TILE_SIZE: int                   = 16
#endregion

#region @export variables
@export var jump_speed: float = 4.0
@export var initial_delay: float = 0.3
@export var repeat_delay: float = 0.15
@export var move_duration: float = 0.2

#endregion

#region regular variables
var jumping_over_ledge: bool =  false
var player_state             := PlayerState.IDLE
var current_input_dir        := Vector2i.ZERO
var current_facing_dir       := Vector2i.DOWN
var is_moving                := false
var stop_input               := false
var move_timer: float        =  0.0
var is_initial_move: bool    =  true
var current_tile_pos         := Vector2i.ZERO

#endregion

#region @onready variables
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var camera: Camera2D = $Camera2D
@onready var shadow = $Shadow


#endregion

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.visible = true
	anim_tree.active = true
	shadow.visible = false
	anim_tree.set("parameters/Idle/blend_position", current_facing_dir)
	anim_tree.set("parameters/Walk/blend_position", current_facing_dir)
	anim_tree.set("parameters/Turn/blend_position", current_facing_dir)
	camera.make_current()
	current_tile_pos = position / TILE_SIZE

	add_to_group("player")
	set_physics_process(true)


func set_spawn(location: Vector2, direction: Vector2):
	anim_tree.set("parameters/Idle/blend_position", direction)
	anim_tree.set("parameters/Walk/blend_position", direction)
	anim_tree.set("parameters/Turn/blend_position", direction)
	position = location


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


func can_move_to_tile(tile_pos: Vector2i) -> bool:
	@warning_ignore("integer_division")
	var world_pos := Vector2(tile_pos * TILE_SIZE) + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)

	# First check tilemap collision
	var tilemap   := get_node("../OverworldTileMap") as TileMapLayer
	var tile_data := tilemap.get_cell_tile_data(tile_pos)
	if tile_data == null or not tile_data.get_custom_data("walkable"):
		return false

	# Then check for StaticBody2D collision
	return query_tile(world_pos).is_empty()


func move_to_tile(target_tile: Vector2i):
	is_moving = true
	current_tile_pos = target_tile
	var target_pos := Vector2(target_tile * TILE_SIZE)

	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, move_duration)
	anim_state.travel("Walk")
	await tween.finished

	is_moving = false
	anim_state.travel("Idle")


func handle_player_interaction():
	# Check for held input
	if Input.is_action_just_pressed("interact"):
		var tile_pos: Vector2i = current_tile_pos + current_facing_dir
		@warning_ignore("integer_division")
		var world_pos := Vector2(tile_pos * TILE_SIZE) + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
		var result    := query_tile(world_pos)
		if !result.is_empty():
			var collider = result[0]["collider"]
			if collider.is_in_group("npcs"):
				Dialogic.start('test_timeline')


func query_tile(world_pos: Vector2i) -> Array[Dictionary]:
	var space_state := get_world_2d().direct_space_state
	var query       := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collision_mask = 2 # Set to World layer

	var result := space_state.intersect_point(query)
	return result


func entered_door():
	print_debug("Player entered door")
	player_entered_door.emit()
