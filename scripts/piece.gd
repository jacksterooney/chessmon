extends Node

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
	var is_white = piece < Piece.Black
	if is_white:
		piece = piece - Piece.White
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
		piece = piece - Piece.Black
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
