extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 40

const TEXTURE_HOLDER = preload("res://scenes/texture_holder.tscn")

const PIECE_MOVE = preload("res://assets/textures/Chess_test/Piece_move.png")

const BLACK_BISHOP = preload("res://assets/textures/Chess_test/black_bishop.png")
const BLACK_KING = preload("res://assets/textures/Chess_test/black_king.png")
const BLACK_KNIGHT = preload("res://assets/textures/Chess_test/black_knight.png")
const BLACK_PAWN = preload("res://assets/textures/Chess_test/black_pawn.png")
const BLACK_QUEEN = preload("res://assets/textures/Chess_test/black_queen.png")
const BLACK_ROOK = preload("res://assets/textures/Chess_test/black_rook.png")

const WHITE_BISHOP = preload("res://assets/textures/Chess_test/white_bishop.png")
const WHITE_KING = preload("res://assets/textures/Chess_test/white_king.png")
const WHITE_KNIGHT = preload("res://assets/textures/Chess_test/white_knight.png")
const WHITE_PAWN = preload("res://assets/textures/Chess_test/white_pawn.png")
const WHITE_QUEEN = preload("res://assets/textures/Chess_test/white_queen.png")
const WHITE_ROOK = preload("res://assets/textures/Chess_test/white_rook.png")

const TURN_WHITE = preload("res://assets/textures/Chess_test/turn-white.png")
const TURN_BLACK = preload("res://assets/textures/Chess_test/turn-black.png")

@onready var pieces = $Pieces
@onready var dots = $Dots
@onready var turn = $Turn

# Variables
# -6 = black king
# -5 = black queen
var board: Array
var white: bool
var state: bool
var moves = []
var selected_piece: Vector2

func _ready() -> void:
	board.append([4, 2, 3, 5, 6, 3, 2, 4])
	board.append([1, 1, 1, 1, 1, 1, 1, 1])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	board.append([-4, -2, -3, -5, -6, -3, -2, -4])
	
	display_board()

func display_board():
	for x in BOARD_SIZE:
		for y in BOARD_SIZE:
			var holder  = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.global_position = Vector2(x * CELL_WIDTH + (CELL_WIDTH / 2), y * CELL_WIDTH + (CELL_WIDTH / 2))
			
			match board[y][x]:
				-6: holder.texture = BLACK_KING
				-5: holder.texture = BLACK_QUEEN
				-4: holder.texture = BLACK_ROOK
				-3: holder.texture = BLACK_BISHOP
				-2: holder.texture = BLACK_KNIGHT
				-1: holder.texture = BLACK_PAWN
				0: holder.texture = null
				6: holder.texture = WHITE_KING
				5: holder.texture = WHITE_QUEEN
				4: holder.texture = WHITE_ROOK
				3: holder.texture = WHITE_BISHOP
				2: holder.texture = WHITE_KNIGHT
				1: holder.texture = WHITE_PAWN

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out(): return
			var var1 = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH
			var var2 = abs(snapped(get_global_mouse_position().y, 0) / CELL_WIDTH)
			if !state && (white && board[var2][var1] > 0 || !white && board[var2][var1] < 0):
				show_options()
				selected_piece = Vector2(var2, var1)
				state = true

func is_mouse_out() -> bool:
	var pos := get_global_mouse_position()
	return pos.x < 0 or pos.x > 144 or pos.y > 0 or pos.y < -144

func show_options():
	moves = get_moves()
	if len(moves) == 0:
		state = false
		return
	show_dots()

func show_dots():
	for i in moves:
		var holder = TEXTURE_HOLDER.instantiate()
		dots.add_child(holder)
		holder.texture = PIECE_MOVE
		holder.global_position = Vector2(i.y * CELL_WIDTH + (CELL_WIDTH / 2), -i.x * CELL_WIDTH - (CELL_WIDTH / 2))

func get_moves() -> Array:
	return []
