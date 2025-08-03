class_name Board extends Node2D

var squares: Array[int] = []

func _ready() -> void:
	squares.resize(64)

static func square_to_position(square: int) -> Vector2:
	var x := square % 8
	var y := square / 8
	return Vector2(
		x * Chess.SQUARE_SIZE + (Chess.SQUARE_SIZE  / 2),
		(8 * Chess.SQUARE_SIZE) - (y * Chess.SQUARE_SIZE + (Chess.SQUARE_SIZE / 2)) 
	)

static func position_to_square(pos: Vector2) -> int:
	if pos.x < 0 or pos.x > Chess.SQUARE_SIZE * 8:
		return -1
	
	var x := int(pos.x / Chess.SQUARE_SIZE)
	var y := 7 - int(pos.y / Chess.SQUARE_SIZE)
	return x + y * 8
