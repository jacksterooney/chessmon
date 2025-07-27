class_name Rook extends Piece

var white_tex = preload("res://assets/textures/Chess_test/white_rook.png")
var black_tex = preload("res://assets/textures/Chess_test/black_rook.png")

func _get_white_texture() -> Texture2D:
	return white_tex

func _get_black_texture() -> Texture2D:
	return black_tex

func get_piece_name() -> String:
	return "Rook"
