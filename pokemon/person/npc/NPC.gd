class_name NPC
extends Person

#region Enums
enum MovementPattern {STATIONARY, PATROL, WANDER}
#endregion

#region @export variables
@export var dialogue: Array[String]
@export var movement_pattern := MovementPattern.STATIONARY
@export var patrol_points: Array[Vector2i] = []
@export var wander_area := 2 # tiles in each direction from start
#endregion

#region regular variables
var current_patrol_index := 0
var wander_timer := 0.0
var current_movement_pattern: MovementPattern
var timeline: DialogicTimeline
var start_tile_pos: Vector2i
#endregion


func _ready() -> void:
	super ()
	add_to_group("npcs")
	_create_timeline()
	current_movement_pattern = movement_pattern
	start_tile_pos = current_tile_pos

func _process(delta: float) -> void:
	handle_movement_pattern(delta)
	
func handle_movement_pattern(delta: float) -> void:
	if is_moving:
		return

	match current_movement_pattern:
		MovementPattern.STATIONARY:
			pass # Do nothing
		MovementPattern.PATROL:
			handle_patrol(delta)
		MovementPattern.WANDER:
			handle_wander(delta)

func handle_patrol(delta: float) -> void:
	if patrol_points.is_empty():
		return

	move_timer += delta
	if move_timer >= move_duration + 1.0: # Wait 1 second at each point
		var target_point: Vector2i = patrol_points[current_patrol_index]
		if try_move_towards(target_point):
			current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		move_timer = 0.0


func handle_wander(delta: float) -> void:
	wander_timer += delta
	if wander_timer >= randf_range(2.0, 5.0): # Random wander interval
		var random_offset := Vector2i(
								randi_range(-wander_area, wander_area),
								randi_range(-wander_area, wander_area)
							)
		var target_tile: Vector2i = start_tile_pos + random_offset
		try_move_towards(target_tile)
		wander_timer = 0.0


func try_move_towards(target_tile: Vector2i) -> bool:
	var move_dir := get_direction_to_tile(target_tile)
	if move_dir != Vector2i.ZERO:
		if can_move_to_tile(current_tile_pos + move_dir):
			set_facing_direction(move_dir)
			move_to_tile(current_tile_pos + move_dir)
			return true
	return false


func get_direction_to_tile(target_tile: Vector2i) -> Vector2i:
	var diff: Vector2i = target_tile - current_tile_pos

	# Move one tile toward player
	var dir := Vector2i.ZERO
	if abs(diff.x) > abs(diff.y):
		dir = Vector2i.RIGHT if diff.x > 0 else Vector2i.LEFT
	elif diff.y != 0:
		dir = Vector2i.UP if diff.y < 0 else Vector2i.DOWN
	return dir

func start_conversation(player_position: Vector2) -> void:
	var player_tile_pos := Vector2i(player_position / TILE_SIZE)
	var dir_to_player: Vector2i = get_direction_to_tile(player_tile_pos)
	set_facing_direction(dir_to_player)
	current_movement_pattern = MovementPattern.STATIONARY
	
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start(timeline)
	
	
func _create_timeline() -> void:
	timeline = DialogicTimeline.new()
	var events: Array[DialogicEvent] = []
	for line in dialogue:
		var event := DialogicTextEvent.new()
		event.text = line
		events.append(event)
	
	var end_dialogue_event := DialogicEndTimelineEvent.new()
	events.append(end_dialogue_event)
	
	timeline.events = events
	timeline.events_processed = true


func _on_timeline_ended() -> void:
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	current_movement_pattern = movement_pattern
