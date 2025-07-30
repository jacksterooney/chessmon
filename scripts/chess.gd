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
		var piece = piece_scene.instantiate() as Area2D
		pieces.add_child(piece)
		piece.position = Board.square_to_position(i)

		piece.find_child("Sprite2D").texture = get_sprite_for_piece(board.squares[i])
		piece.connect("clicked_on", board.on_piece_clicked_on)
		piece.connect("clicked_off", board.on_piece_clicked_off)

func load_position_from_fen(fen: String):
	var piece_type_from_symbol: Dictionary[String, int] = {
		'k': King,
		'p': Pawn,
		'n': Knight,
		'b': Bishop,
		'r': Rook,
		'q': Queen,
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
				var piece_color := White if symbol == symbol.to_upper() else Black
				var piece_type = piece_type_from_symbol[symbol.to_lower()]
				board.squares[rank * 8 + file] = piece_color | piece_type
				file += 1

#region Piece sprites

@onready var black_king_sprite = preload("res://assets/sprites/pieces/black/king.svg")
@onready var black_pawn_sprite = preload("res://assets/sprites/pieces/black/pawn.svg")
@onready var black_knight_sprite = preload("res://assets/sprites/pieces/black/knight.svg")
@onready var black_bishop_sprite = preload("res://assets/sprites/pieces/black/bishop.svg")
@onready var black_rook_sprite = preload("res://assets/sprites/pieces/black/rook.svg")
@onready var black_queen_sprite = preload("res://assets/sprites/pieces/black/queen.svg")

@onready var white_king_sprite = preload("res://assets/sprites/pieces/white/king.svg")
@onready var white_pawn_sprite = preload("res://assets/sprites/pieces/white/pawn.svg")
@onready var white_knight_sprite = preload("res://assets/sprites/pieces/white/knight.svg")
@onready var white_bishop_sprite = preload("res://assets/sprites/pieces/white/bishop.svg")
@onready var white_rook_sprite = preload("res://assets/sprites/pieces/white/rook.svg")
@onready var white_queen_sprite = preload("res://assets/sprites/pieces/white/queen.svg")

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

func get_sprite_for_piece(piece: int) -> Texture2D:
	var is_white = piece < Black
	if is_white:
		piece = piece - White
		match piece:
			King:
				return white_king_sprite
			Pawn:
				return white_pawn_sprite
			Knight:
				return white_knight_sprite
			Bishop:
				return white_bishop_sprite
			Rook:
				return white_rook_sprite
			Queen:
				return white_queen_sprite
	else:
		piece = piece - Black
		match piece:
			King:
				return black_king_sprite
			Pawn:
				return black_pawn_sprite
			Knight:
				return black_knight_sprite
			Bishop:
				return black_bishop_sprite
			Rook:
				return black_rook_sprite
			Queen:
				return black_queen_sprite
	push_error("No sprite found for this color and piece")
	return null

#endregion
