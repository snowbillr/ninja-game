class_name AirMovementCharges
extends Resource

@export var allowed_jumps := 1
@export var allowed_dashes := 1

var jumps = allowed_jumps
var dashes = allowed_dashes

func can_jump() -> bool:
	return self.jumps > 0

func can_dash() -> bool:
	return self.dashes > 0
	
func consume_jump() -> void:
	self.jumps -= 1

func consume_dash() -> void:
	self.dashes -= 1

func reset() -> void:
	self.jumps = allowed_jumps
	self.dashes = allowed_dashes
