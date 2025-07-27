class_name FileRank

static func to_vector2i(filerank: String) -> Vector2i:
	var y = 8 - int(filerank[1])
	var x: int
	match filerank[0]:
		"A":
			x = 0
		"B":
			x = 1
		"C":
			x = 2
		"D":
			x = 3
		"E":
			x = 4
		"F":
			x = 5
		"G":
			x = 6
		"H":
			x = 7
	return Vector2i(x, y)

static func from_vector_2i(v: Vector2i) -> String:
	var rank = Chess.BOARD_SIZE - v.y
	var file: String
	match v.x:
		0:
			file = "A"
		1:
			file = "B"
		2:
			file = "C"
		3:
			file = "D"
		4:
			file = "E"
		5:
			file = "F"
		6:
			file = "G"
		7:
			file = "H"
	return file + str(rank)

static func to_global_position(filerank: String) -> Vector2:
	var coord = to_vector2i(filerank)
	var x = coord.x * Chess.CELL_WIDTH + (Chess.CELL_WIDTH / 2)
	var y = coord.y * Chess.CELL_WIDTH + (Chess.CELL_WIDTH / 2)
	return Vector2(x, y)
