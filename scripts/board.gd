class_name Board extends Node2D

var squares: Array[int] = []

func _ready() -> void:
	squares.resize(64)

static func square_to_position(square: int) -> Vector2:
	var x = square % 8
	var y = square / 8
	return Vector2(
		x * Chess.SQUARE_SIZE + (Chess.SQUARE_SIZE  / 2),
		y * Chess.SQUARE_SIZE + (Chess.SQUARE_SIZE / 2) 
	)