class_name Board extends Node2D

static var Square: Array[int] = []
static var Color_To_Move: int = Piece.White # Represented as an enum

func _ready() -> void:
	Square.resize(64)

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

static func Is_Rank(square: int, rank: int) -> bool:
	return square / 8 == rank - 1
