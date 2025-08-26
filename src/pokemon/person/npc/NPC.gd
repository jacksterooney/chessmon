class_name NPC
extends Person

#region Enums
enum MovementPattern { STATIONARY, PATROL, WANDER }
#endregion

#region @export variables
@export var movement_pattern := MovementPattern.STATIONARY
@export var patrol_points: Array[Vector2i] = []
@export var wander_area := 2  # tiles in each direction from start
#endregion

#region regular variables
var current_patrol_index := 0
var wander_timer := 0.0
#endregion


func _ready() -> void:
	super()
	add_to_group("npcs")

func _process(delta) -> void:

	handle_movement_pattern(delta)
	
func handle_movement_pattern(delta) -> void:
	if is_moving:
		return

	match movement_pattern:
		MovementPattern.STATIONARY:
			pass  # Do nothing
		MovementPattern.PATROL:
			handle_patrol(delta)
		MovementPattern.WANDER:
			handle_wander(delta)

func handle_patrol(delta) -> void:
	if patrol_points.is_empty():
		return

	move_timer += delta
	if move_timer >= move_duration + 1.0:  # Wait 1 second at each point
		var target_point: Vector2i = patrol_points[current_patrol_index]
		if try_move_towards(target_point):
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		move_timer = 0.0

func handle_wander(delta):
	wander_timer += delta
	if wander_timer >= randf_range(2.0, 5.0):  # Random wander interval
		var random_offset := Vector2i(
								randi_range(-wander_area, wander_area),
								randi_range(-wander_area, wander_area)
							)
		var target_tile: Vector2i = start_tile_pos + random_offset
		try_move_towards(target_tile)
		wander_timer = 0.0

func try_move_towards(target_tile: Vector2i) -> bool:
	# Simple pathfinding - move one tile toward target
	var diff: Vector2i = target_tile - current_tile_pos
	var move_dir := Vector2i.ZERO

	if abs(diff.x) > abs(diff.y):
		move_dir = Vector2i.RIGHT if diff.x > 0 else Vector2i.LEFT
	elif diff.y != 0:
		move_dir = Vector2i.UP if diff.y < 0 else Vector2i.DOWN

	if move_dir != Vector2i.ZERO:
		if can_move_to_tile(current_tile_pos + move_dir):
			change_facing_direction(move_dir)
			move_to_tile(current_tile_pos + move_dir)
			return true
	return false
