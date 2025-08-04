class_name Chess extends Node

## Size of a board square in pixels
static var SQUARE_SIZE: int = 40

@export var light_col: Color
@export var dark_col: Color

@onready var square_scene = preload("res://scenes/square.tscn")
@onready var piece_scene = preload("res://scenes/piece.tscn")

@onready var board: Board = $Board
@onready var pieces: Node2D = $Pieces

var friendly_color: int
var opponent_color: int

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
				(8 * SQUARE_SIZE) - (rank * SQUARE_SIZE + (SQUARE_SIZE / 2))
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
		if board.Square[i] == 0:
			continue
		var piece = piece_scene.instantiate() as Piece
		pieces.add_child(piece)
		piece.position = Board.square_to_position(i)
		piece.square = i
		piece.piece_info = Board.Square[i]

		piece.find_child("Sprite2D").texture = get_sprite_for_piece(Board.Square[i])
		piece.connect("clicked_on", on_piece_clicked_on)
		piece.connect("moved", on_piece_moved)

func load_position_from_fen(fen: String):
	print_debug("Loading position from FEN: " + fen)
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
				Board.Square[rank * 8 + file] = piece_color | piece_type
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

func get_sprite_for_piece(piece: int) -> Texture2D:
	var is_white = piece < Piece.Black
	if is_white:
		piece = piece - Piece.White
		match piece:
			Piece.King:
				return white_king_sprite
			Piece.Pawn:
				return white_pawn_sprite
			Piece.Knight:
				return white_knight_sprite
			Piece.Bishop:
				return white_bishop_sprite
			Piece.Rook:
				return white_rook_sprite
			Piece.Queen:
				return white_queen_sprite
	else:
		piece = piece - Piece.Black
		match piece:
			Piece.King:
				return black_king_sprite
			Piece.Pawn:
				return black_pawn_sprite
			Piece.Knight:
				return black_knight_sprite
			Piece.Bishop:
				return black_bishop_sprite
			Piece.Rook:
				return black_rook_sprite
			Piece.Queen:
				return black_queen_sprite
	push_error("No sprite found for this color and piece")
	return null

#endregion

func on_piece_clicked_on(piece: Piece):
	print_debug(piece.to_string() + " clicked on")

func on_piece_moved(piece_info: int, old_square: int, new_square: int):
	print_debug(str(piece_info) + " clicked off")
	Board.Square[new_square] = piece_info
	Board.Square[old_square] = 0
	draw_pieces()

#region Generating Moves
static var Direction_Offsets: Array[int] = [
	8, -8, -1, 1, 7, -7, 9, -9
]
static var Num_Squares_To_Edge: Array[Array]

static func precomputed_move_data():
	for file in 8:
		for rank in 8:
			var num_north := 7 - rank
			var num_south := rank
			var num_west := file
			var num_east := 7 - file

			var square_index := rank * 8 + file
			Num_Squares_To_Edge[square_index] = [
				num_north,
				num_south,
				num_west,
				num_east,
				min(num_north, num_west),
				min(num_south, num_east),
				min(num_north, num_east),
				min(num_south, num_west)
			]

var moves: Array[Move]

func generate_moves() -> Array[Move]:
	moves = []

	for start_square: int in 64:
		var piece = Board.Square[start_square]
		if Piece.Is_Color(piece, Board.Color_To_Move):
			if Piece.Is_Sliding_Piece(piece):
				generate_sliding_moves(start_square, piece)
	
	return moves

func generate_sliding_moves(start_square: int, piece: int):
	var start_dir_index = 4 if Piece.Is_Type(piece, Piece.Bishop) else 0
	var end_dir_index = 4 if Piece.Is_Type(piece, Piece.Rook) else 8

	for direction_index in range(start_dir_index, end_dir_index):
		for n in Num_Squares_To_Edge[start_square][direction_index]:
			var target_square: int = start_square + Direction_Offsets[direction_index] * (n+1)
			var piece_on_target_square = Board.Square[target_square]

			# Blocked by friendly piece, so can't move further in this direction
			if Piece.Is_Color(piece_on_target_square, friendly_color):
				break
			
			moves.append(Move.new(start_square, target_square))

			# Can't move any further in this direction after capturing opponent's piece
			if Piece.Is_Color(piece_on_target_square, opponent_color):
				break
			

#endregion
