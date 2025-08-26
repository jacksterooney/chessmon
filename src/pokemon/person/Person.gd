class_name Person
extends CharacterBody2D

#region Constants
const TILE_SIZE: int        =  16
const WORLD_COLLISION_LAYER := 2
#endregion

#region @export variables
@export var move_duration: float = 0.2

#endregion

#region regular variables
var current_facing_dir := Vector2i.DOWN
var is_moving          := false
var move_timer: float  =  0.0
var current_tile_pos   := Vector2i.ZERO
var start_tile_pos     := Vector2i.ZERO

#endregion

#region @onready variables
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
#endregion

#region @onready variables
@onready var sprite := $Sprite as Sprite2D


#endregion

func _ready() -> void:
	sprite.visible = true
	anim_tree.active = true
	anim_tree.set("parameters/Idle/blend_position", current_facing_dir)
	anim_tree.set("parameters/Walk/blend_position", current_facing_dir)
	anim_tree.set("parameters/Turn/blend_position", current_facing_dir)

	start_tile_pos = position / TILE_SIZE
	current_tile_pos = start_tile_pos


func change_facing_direction(direction: Vector2i):
	current_facing_dir = direction
	anim_tree.set("parameters/Idle/blend_position", direction)
	anim_tree.set("parameters/Walk/blend_position", direction)


func can_move_to_tile(tile_pos: Vector2i) -> bool:
	return query_tile(tile_pos).is_empty()


func move_to_tile(target_tile: Vector2i) -> void:
	is_moving = true
	current_tile_pos = target_tile
	var target_pos := Vector2(target_tile * TILE_SIZE)

	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, move_duration)
	anim_state.travel("Walk")
	await tween.finished

	is_moving = false
	anim_state.travel("Idle")


func query_tile(tile_pos: Vector2i) -> Array[Dictionary]:
	@warning_ignore("integer_division")
	var world_pos   := Vector2(tile_pos * TILE_SIZE) + Vector2(TILE_SIZE/2, TILE_SIZE/2)
	var space_state := get_world_2d().direct_space_state
	var query       := PhysicsPointQueryParameters2D.new()
	query.position       = world_pos
	query.collision_mask = WORLD_COLLISION_LAYER
	query.collide_with_areas = true

	var result := space_state.intersect_point(query)
	return result
	
