class_name Move

var start_square: int
var target_square: int

func _init(start: int, target: int) -> void:
	self.start_square = start
	self.target_square = target

static func Has_Move(moves: Array[Move], move: Move):
	for m in moves:
		if m.start_square == move.start_square and m.target_square == move.target_square:
			return true
	return false
