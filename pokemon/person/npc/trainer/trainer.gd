class_name Trainer
extends NPC

signal battle_initiated(trainer: Trainer)

#region @export variables
@export var detection_range := 4  # tiles
@export var sight_direction := Vector2i.DOWN  # Direction trainer is facing
@export var trainer_name := "Youngster Joey"

@export_category("Battle state")
@export var defeated := false
@export var can_battle_again := false

@export_category("Dialogue")
@export var pre_battle_dialogue: Array[String] = ["Hey! I challenge you to a battle!"]
#endregion

#region regular variables
var player_reference: Player = null
var has_spotted_player := false
var is_in_battle := false
#endregion

@onready var sight_ray := $SightRay2D as RayCast2D

func _ready() -> void:
	super()

	# Get player reference
	await get_tree().process_frame
	player_reference = Utils.get_player()

	# Setup raycast
	setup_sight_ray()

func _process(delta: float) -> void:
	if is_in_battle or has_spotted_player:
		return

	super(delta)

	check_line_of_sight()

func setup_sight_ray() -> void:
	if not sight_ray:
		return

	# Set raycast direction and length
	sight_ray.target_position = Vector2(sight_direction) * detection_range * TILE_SIZE
	sight_ray.collision_mask = 3  # Layer 1 (walls) + Layer 2 (player)
	sight_ray.enabled = true

func check_line_of_sight() -> void:
	if not player_reference or defeated or not sight_ray:
		return

	# Update raycast direction when facing changes
	sight_ray.target_position = Vector2(sight_direction) * detection_range * TILE_SIZE
	sight_ray.force_raycast_update()

	if sight_ray.is_colliding():
		var collider: Object = sight_ray.get_collider()
		if collider and collider.is_in_group("player") and not has_spotted_player:
			spot_player()

func spot_player() -> void:
	if defeated and not can_battle_again:
		return

	has_spotted_player = true
	print(trainer_name + " spotted the player!")

	# Stop current movement
	var current_tween := get_tween()
	if current_tween:
		current_tween.kill()
	is_moving = false

	# Move toward player
	approach_player()

func approach_player() -> void:
	if not player_reference:
		return

	var player_tile_pos := Vector2i(player_reference.global_position / TILE_SIZE)
	var move_dir := get_direction_to_tile(player_tile_pos)

	if move_dir != Vector2i.ZERO:
		if can_move_to_tile(current_tile_pos + move_dir):
			await move_to_tile(current_tile_pos + move_dir)

			# Check if close enough to battle
			var new_diff: Vector2i = player_tile_pos - current_tile_pos
			if abs(new_diff.x) <= 1 and abs(new_diff.y) <= 1:
				initiate_battle()
			else:
				approach_player()  # Continue approaching
		else:
			initiate_battle()  # Can't move closer, battle from here

func initiate_battle() -> void:
	if is_in_battle:
		return

	is_in_battle = true
	print(trainer_name + " wants to battle!")
	battle_initiated.emit(self)

func show_defeated_dialogue() -> void:
	print(trainer_name + ": You're really strong! I need to train more!")

func set_defeated() -> void:
	defeated = true
	has_spotted_player = false
	is_in_battle = false
	print(trainer_name + " was defeated!")

func reset_trainer() -> void:
	defeated = false
	has_spotted_player = false
	is_in_battle = false
	current_tile_pos = start_tile_pos
	position = Vector2(current_tile_pos * TILE_SIZE)

# Helper function for tweens
func get_tween() -> Tween:
	var tweens: Array[Tween] = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween.is_valid():
			return tween
	return null
