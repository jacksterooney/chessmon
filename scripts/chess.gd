class_name Chess extends Node

## Size of a board square in pixels
static var SQUARE_SIZE: int = 40

@export var light_col: Color
@export var dark_col: Color

@onready var square_scene = preload("res://scenes/square.tscn")
@onready var piece_scene = preload("res://scenes/piece.tscn")

@onready var board: Board = $Board
@onready var pieces: Node2D = $Pieces

const START_FEN: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"

func _ready():
	load_position_from_fen(START_FEN)
	create_graphical_board()

func create_graphical_board():
	print_debug("Creating graphical board...")
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
	# Clear any old squares
	for piece in pieces.get_children():
		piece.queue_free()

	for i in 64:
		if board.squares[i] == 0:
			continue
		var piece = piece_scene.instantiate() as Piece
		pieces.add_child(piece)
		piece.position = Board.square_to_position(i)
		piece.square = i
		piece.piece_info = board.squares[i]

		piece.find_child("Sprite2D").texture = get_sprite_for_piece(board.squares[i])
		piece.connect("clicked_on", on_piece_clicked_on)
		piece.connect("moved", on_piece_moved)

func load_position_from_fen(fen: String):
	print_debug("Loading position from FEN: " + fen)
	var piece_type_from_symbol: Dictionary[String, int] = {
		'k': PieceEnum.King,
		'p': PieceEnum.Pawn,
		'n': PieceEnum.Knight,
		'b': PieceEnum.Bishop,
		'r': PieceEnum.Rook,
		'q': PieceEnum.Queen,
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
				var piece_color := PieceEnum.White if symbol == symbol.to_upper() else PieceEnum.Black
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

enum PieceEnum {
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
	var is_white = piece < PieceEnum.Black
	if is_white:
		piece = piece - PieceEnum.White
		match piece:
			PieceEnum.King:
				return white_king_sprite
			PieceEnum.Pawn:
				return white_pawn_sprite
			PieceEnum.Knight:
				return white_knight_sprite
			PieceEnum.Bishop:
				return white_bishop_sprite
			PieceEnum.Rook:
				return white_rook_sprite
			PieceEnum.Queen:
				return white_queen_sprite
	else:
		piece = piece - PieceEnum.Black
		match piece:
			PieceEnum.King:
				return black_king_sprite
			PieceEnum.Pawn:
				return black_pawn_sprite
			PieceEnum.Knight:
				return black_knight_sprite
			PieceEnum.Bishop:
				return black_bishop_sprite
			PieceEnum.Rook:
				return black_rook_sprite
			PieceEnum.Queen:
				return black_queen_sprite
	push_error("No sprite found for this color and piece")
	return null

#endregion

func on_piece_clicked_on(piece: Piece):
	print_debug(piece.to_string() + " clicked on")

func on_piece_moved(piece_info: int, old_square: int, new_square: int):
	print_debug(str(piece_info) + " clicked off")
	board.squares[new_square] = piece_info
	board.squares[old_square] = 0
	draw_pieces()
