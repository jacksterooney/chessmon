class_name Map
extends Node2D

@export var is_exterior: bool

@export var connected_levels: Dictionary[String, Vector2i]

@onready var npcs := $NPCs as Node2D

func _ready() -> void:
	for npc in npcs.get_children():
		if npc is Trainer:
			var trainer := npc as Trainer
			trainer.connect("spotted_player", _on_trainer_spotted_player)

func _on_trainer_spotted_player() -> void:
	var player := Utils.get_player()
	player.can_move = false
