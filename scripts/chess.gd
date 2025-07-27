class_name Chess extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 40

const TEXTURE_HOLDER = preload("res://scenes/texture_holder.tscn")

const PIECE_MOVE = preload("res://assets/textures/Chess_test/Piece_move.png")

const TURN_WHITE = preload("res://assets/textures/Chess_test/turn-white.png")
const TURN_BLACK = preload("res://assets/textures/Chess_test/turn-black.png")

@onready var pieces = $Pieces
@onready var dots = $Dots
@onready var turn = $Turn

# Variables
# -6 = black king
# -5 = black queen etc
var board: Dictionary[String, Piece]
var white_to_play: bool = true
var moves = []
var selected_piece: Vector2

func _ready() -> void:
	# Rooks
	board["A1"] = Rook.new(true)
	board["H1"] = Rook.new(true)
	board["A8"] = Rook.new(false)
	board["H8"] = Rook.new(false)
	
	# Knights
	board["B1"] = Knight.new(true)
	board["G1"] = Knight.new(true)
	board["B8"] = Knight.new(false)
	board["G8"] = Knight.new(false)
	
	display_board()

func display_board():
	for file in "ABCDEFGH":
		for rank in BOARD_SIZE + 1:
			if !board.has(file + str(rank)):
				continue
			
			var piece = board[file + str(rank)]
			pieces.add_child(piece)
			piece.global_position = FileRank.to_global_position(file + str(rank))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out(): return
			var square_x = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH
			var square_y = abs(snapped(get_global_mouse_position().y, 0) / CELL_WIDTH)
			var filerank = FileRank.from_vector_2i(Vector2i(square_x, square_y))
			if !board.has(filerank):
				return
			
			var piece_selected = board[FileRank.from_vector_2i(Vector2i(square_x, square_y))]
			if (white_to_play && piece_selected != null):
				print_debug(piece_selected.get_piece_name() + " selected.")
				show_options()

func is_mouse_out() -> bool:
	var pos := get_global_mouse_position()
	return pos.x < 0 or pos.x > (BOARD_SIZE * CELL_WIDTH) or pos.y < 0 or pos.y > (BOARD_SIZE * CELL_WIDTH)

func show_options():
	moves = get_moves()
	if len(moves) > 0:
		show_dots()

func show_dots():
	for i in moves:
		var holder = TEXTURE_HOLDER.instantiate()
		dots.add_child(holder)
		holder.texture = PIECE_MOVE
		holder.global_position = Vector2(i.y * CELL_WIDTH + (CELL_WIDTH / 2), -i.x * CELL_WIDTH - (CELL_WIDTH / 2))

func get_moves() -> Array:
	return []
