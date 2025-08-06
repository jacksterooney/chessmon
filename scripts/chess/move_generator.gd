class_name MoveGenerator

static var Moves: Array[Move]

static var Direction_Offsets: Array[int] = [
	8, -8, -1, 1, 7, -7, 9, -9
]
static var Num_Squares_To_Edge: Array[Array]

static func Precompute_Move_Data():
	Num_Squares_To_Edge.resize(64)
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

static func Generate_Moves(friendly_color: int, opponent_color: int):
	Moves = []

	for start_square: int in 64:
		var piece: int = Board.Square[start_square]
		if piece != 0 and Piece.Is_Color(piece, Board.Color_To_Move):
			if Piece.Is_Sliding_Piece(piece):
				Generate_Sliding_Moves(
						start_square, 
						piece, 
						friendly_color, 
						opponent_color
					)
			if Piece.Is_Type(piece, Piece.King):
				Generate_King_Moves(
					start_square,
					piece,
					friendly_color, 
					opponent_color
					)
			if Piece.Is_Type(piece, Piece.Pawn):
				Generate_Pawn_Moves(
					start_square,
					piece,
					friendly_color, 
					opponent_color
					)

static func Generate_Sliding_Moves(
		start_square: int, piece: int, 
		friendly_color: int, opponent_color: int
	):
	var start_dir_index: int = 4 if Piece.Is_Type(piece, Piece.Bishop) else 0
	var end_dir_index: int = 4 if Piece.Is_Type(piece, Piece.Rook) else 8

	for direction_index in range(start_dir_index, end_dir_index):
		for n in Num_Squares_To_Edge[start_square][direction_index]:
			var target_square: int = start_square + Direction_Offsets[direction_index] * (n+1)
			var piece_on_target_square: int = Board.Square[target_square]

			# Blocked by friendly piece, so can't move further in this direction
			if Piece.Is_Color(piece_on_target_square, friendly_color):
				break
			
			Moves.append(Move.new(start_square, target_square))

			# Can't move any further in this direction after capturing opponent's piece
			if Piece.Is_Color(piece_on_target_square, opponent_color):
				break

static func Generate_King_Moves(
		start_square: int, piece: int, 
		friendly_color: int, opponent_color: int
	):
	var start_dir_index: int = 0
	var end_dir_index: int = 8

	for direction_index in range(start_dir_index, end_dir_index):
		for n in Num_Squares_To_Edge[start_square][direction_index]:
			if n > 0:
				break

			var target_square: int = start_square + Direction_Offsets[direction_index] * (n+1)
			var piece_on_target_square: int = Board.Square[target_square]

			# Blocked by friendly piece, so can't move further in this direction
			if Piece.Is_Color(piece_on_target_square, friendly_color):
				break
			
			Moves.append(Move.new(start_square, target_square))

static func Generate_Pawn_Moves(
		start_square: int, piece: int, 
		friendly_color: int, opponent_color: int
	):
	var dir_index = 0 if Piece.Is_Color(piece, Piece.White) else 1

	var target_square: int = start_square + Direction_Offsets[dir_index]
	var piece_on_target_square: int = Board.Square[target_square]

	# Blocked by any piece, so can't move further in this direction
	if piece_on_target_square != 0:
		return
	else:
		Moves.append(Move.new(start_square, target_square))
