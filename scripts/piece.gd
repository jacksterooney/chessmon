class_name Piece extends Sprite2D

var is_white: bool
var current_filerank: String

func _init(white_piece: bool) -> void:
	self.is_white = white_piece
	if is_white:
		texture = _get_white_texture()
	else:
		texture = _get_black_texture()

func _get_white_texture() -> Texture2D:
	push_error("Function not implemented")
	return

func _get_black_texture() -> Texture2D:
	push_error("Function not implemented")
	return

func get_piece_name() -> String:
	push_error("Function not implemented")
	return ""

func get_moves() -> Array[Vector2i]:
	push_error("Function not implemented")
	return []
