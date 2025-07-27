class_name Pawn extends Piece

func get_piece_name() -> String:
	return "Pawn"

func get_moves() -> Array[Vector2i]:
	if self.is_white:
		return [current_square + Vector2i(0, 1)]
	else:
		return [current_square - Vector2i(0, 1)]
