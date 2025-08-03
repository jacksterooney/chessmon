class_name Piece extends Area2D

signal clicked_on(piece: Piece)
signal moved(piece_info: int, old_square: int, new_square: int)

var piece_info: int
var square: int
var selected: bool = false

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var input_event_mouse_button = event as InputEventMouseButton
		if input_event_mouse_button.pressed:
			clicked_on.emit(self)
			selected = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var input_event_mouse_button = event as InputEventMouseButton
		if selected and !input_event_mouse_button.pressed:
			selected = false
			var new_square = Board.position_to_square(global_position)
			position = Board.square_to_position(new_square)
			if new_square != square:
				moved.emit(piece_info, square, new_square)
				square = new_square
			
	elif selected and event is InputEventMouseMotion:
		global_position = get_global_mouse_position()
