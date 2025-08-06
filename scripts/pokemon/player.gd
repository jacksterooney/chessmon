class_name Player
extends Person

const TILE_SIZE := 16

enum PlayerState {
	IDLE,
	TURNING,
	WALKING,
}

enum FacingDirection {
	LEFT, RIGHT, UP, DOWN
}

@export var walk_speed := 4.0

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
@onready var ray := $RayCast2D as RayCast2D

var initial_position := Vector2(0, 0)
var input_direction := Vector2(0, 0)
var is_moving := false
var percent_moved_to_next_tile := 0.0

var player_state := PlayerState.IDLE
var facing_direction := FacingDirection.DOWN

func _ready() -> void:
	anim_tree.active = true
	initial_position = position

func _physics_process(delta: float) -> void:
	if player_state == PlayerState.TURNING:
		return
	if not is_moving:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel("Walk")
		move(delta)
	else:
		anim_state.travel("Idle")
		is_moving = false

func process_player_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)

		if need_to_turn():
			player_state = PlayerState.TURNING
			anim_state.travel("Turn")
		else:
			initial_position = position
			is_moving = true
	else:
		anim_state.travel("Idle")

func need_to_turn() -> bool:
	var new_facing_direction: FacingDirection
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
	
	var result = new_facing_direction != facing_direction
	facing_direction = new_facing_direction
	return result
	
func finished_turning():
	player_state = PlayerState.IDLE

func move(delta: float):
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	ray.target_position = desired_step
	if !ray.is_colliding():
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	else:
		is_moving = false
		percent_moved_to_next_tile = 0.0
