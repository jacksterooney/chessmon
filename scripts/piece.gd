class_name Piece extends Area2D

signal clicked_on(piece: Piece)
signal clicked_off(piece: Piece)

var selected: bool = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed() and !selected:
			clicked_on.emit(self)
			selected = true
		elif event.is_released() and selected:
			clicked_off.emit(self)
			selected = false

