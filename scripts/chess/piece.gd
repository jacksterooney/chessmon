class_name Piece extends Area2D

signal selected(piece: int, square: int)
signal deselected()
signal moved(piece: int, move: Move)

var piece_info: int
var square: int
var is_selected: bool = false

enum {
	None,
	King,
	Pawn,
	Knight,
	Bishop,
	Rook,
	Queen,


	White = 8,
	Black = 16
}

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var input_event_mouse_button := event as InputEventMouseButton
		if input_event_mouse_button.pressed:
			if Is_Color(piece_info, Board.Color_To_Move):
				selected.emit(piece_info, square)
				is_selected = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var input_event_mouse_button := event as InputEventMouseButton
		if selected and !input_event_mouse_button.pressed:
			is_selected = false
			var new_square: int = Board.position_to_square(global_position)
			if new_square != square:
				var move := Move.new(square, new_square)
				moved.emit(piece_info, move)
			else:
				deselected.emit()
				# Reset position
				global_position = Board.square_to_position(square)
			
	elif is_selected and event is InputEventMouseMotion:
		global_position = get_global_mouse_position()

static func Is_Color(piece: int, color_to_move: int) -> bool:
	return piece & 0b11000 == color_to_move

static func Is_Sliding_Piece(piece: int) -> bool:
	var piece_type: int = Get_Piece_Type(piece)
	match piece_type:
		Queen, Bishop, Rook:
			return true
	return false

static func Is_Type(piece: int, piece_type: int) -> bool:
	return Get_Piece_Type(piece) == piece_type

static func Get_Piece_Type(piece: int) -> int:
	return piece & 0b111 # Get the 3 least significant bits
