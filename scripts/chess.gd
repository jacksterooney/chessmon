class_name Chess extends Node

## Size of a board square in pixels
static var SQUARE_SIZE: int = 40

@export var light_col: Color
@export var dark_col: Color

@onready var square_scene = preload("res://scenes/square.tscn")
@onready var piece_scene = preload("res://scenes/piece.tscn")

@onready var board = $Board
@onready var pieces = $Pieces

const START_FEN: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"

func _ready():
	load_position_from_fen(START_FEN)
	create_graphical_board()

func create_graphical_board():
	for file in 8:
		for rank in 8:
			var is_light_square: bool = (file + rank) % 2 != 0

			var square_colour := light_col if is_light_square else dark_col
			var position = Vector2(
				file * SQUARE_SIZE + (SQUARE_SIZE  / 2),
				rank * SQUARE_SIZE + (SQUARE_SIZE / 2) 
				)
			
			draw_square(square_colour, position)

			draw_pieces()

func draw_square(square_colour: Color, position: Vector2):
	var square = square_scene.instantiate() as Sprite2D
	board.add_child(square)
	square.position = position
	square.modulate = square_colour

func draw_pieces():
	for i in 64:
		if board.squares[i] == 0:
			continue
		var piece = piece_scene.instantiate() as Sprite2D
		pieces.add_child(piece)
		piece.position = Board.square_to_position(i)

		piece.texture = Piece.get_sprite_for_piece(board.squares[i])

func load_position_from_fen(fen: String):
	var piece_type_from_symbol: Dictionary[String, int] = {
		'k': Piece.King,
		'p': Piece.Pawn,
		'n': Piece.Knight,
		'b': Piece.Bishop,
		'r': Piece.Rook,
		'q': Piece.Queen,
	}

	var fen_board: String = fen.split(' ')[0]
	var file := 0
	var rank := 7

	for symbol in fen_board:
		if symbol == '/':
			file = 0
			rank -= 1
		else:
			if symbol.is_valid_int():
				file += int(symbol)
			else:
				var piece_color := Piece.White if symbol == symbol.to_upper() else Piece.Black
				var piece_type = piece_type_from_symbol[symbol.to_lower()]
				board.squares[rank * 8 + file] = piece_color | piece_type
				file += 1
