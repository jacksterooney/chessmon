class_name Chess extends Node

## Size of a board square in pixels
static var SQUARE_SIZE: int = 40

@export var light_col: Color
@export var dark_col: Color

@export_enum( 
	"Standard",
	"Sliding Pieces Only",
	"Dueling Kings"
) var start_fen: String = "Standard"

@onready var square_scene: PackedScene = preload("res://scenes/square.tscn")
@onready var piece_scene: PackedScene = preload("res://scenes/piece.tscn")
@onready var dot_scene: PackedScene = preload("res://scenes/dot.tscn")

@onready var board: Board = $Board
@onready var pieces: Node2D = $Pieces
@onready var dots: Node2D = $Dots

var friendly_color: int
var opponent_color: int

const FENS: Dictionary[String, String] = {
	"Standard": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
	"Sliding Pieces Only": "q6r/8/8/8/8/8/8/B7",
	"Dueling Kings": "k7/8/8/8/8/8/8/7K"
}

func _ready():
	friendly_color = Piece.White
	opponent_color = Piece.Black
	MoveGenerator.Precompute_Move_Data()
	
	load_position_from_fen(start_fen)
	create_graphical_board()
	MoveGenerator.Generate_Moves(Piece.White, Piece.Black)

func create_graphical_board():
	print_debug("Creating graphical board...")
	for file in 8:
		for rank in 8:
			var is_light_square: bool = (file + rank) % 2 != 0

			var square_colour := light_col if is_light_square else dark_col
			var position := Vector2(
				file * SQUARE_SIZE + (SQUARE_SIZE  / 2),
				(8 * SQUARE_SIZE) - (rank * SQUARE_SIZE + (SQUARE_SIZE / 2))
				)
			
			draw_square(square_colour, position)

	draw_pieces()

func draw_square(square_colour: Color, position: Vector2):
	var square: Sprite2D = square_scene.instantiate()
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
		var piece: Piece = piece_scene.instantiate()
		pieces.add_child(piece)
		piece.position = Board.square_to_position(i)
		piece.square = i
		piece.piece_info = Board.Square[i]

		piece.find_child("Sprite2D").texture = get_sprite_for_piece(Board.Square[i])
		piece.selected.connect(on_piece_selected)
		piece.deselected.connect(on_piece_deselected)
		piece.moved.connect(on_piece_moved)

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

	var fen_board: String = FENS[fen].split(' ')[0]
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
				var piece_type := piece_type_from_symbol[symbol.to_lower()]
				Board.Square[rank * 8 + file] = piece_color | piece_type
				file += 1

func next_turn():
	var current_color_to_move: int = Board.Color_To_Move
	var friendly_color = Piece.White if current_color_to_move == Piece.Black else Piece.Black
	var opponent_color = Piece.Black if current_color_to_move == Piece.Black else Piece.White
	
	Board.Color_To_Move = friendly_color
	print_debug("Next turn")
	MoveGenerator.Generate_Moves(friendly_color, opponent_color)

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

func on_piece_selected(piece: int, square: int):
	print_debug(str(piece) + " clicked on")
	show_moves(square)

func on_piece_deselected():
	print_debug("Deselected piece.")
	hide_moves()

func on_piece_moved(piece: int, move: Move):
	# Check move is valid
	if Move.Has_Move(MoveGenerator.Moves, move):
		print_debug(str(piece) + " moved from " + str(move.start_square) + " to " + str(move.target_square))
		Board.Square[move.target_square] = piece
		Board.Square[move.start_square] = 0
	draw_pieces()
	next_turn()

func show_moves(start_square: int):
	for move in MoveGenerator.Moves:
		if move.start_square == start_square:
			var target_square: int = move.target_square
			var dot: Sprite2D = dot_scene.instantiate()
			dot.global_position = Board.square_to_position(target_square)
			dots.add_child(dot)

func hide_moves():
	for dot in dots.get_children():
		dot.queue_free()
