class_name Move

var start_square: int
var target_square: int

func _init(start: int, target: int) -> void:
	self.start_square = start
	self.target_square = target