extends PlayerState


func _enter(_args: Dictionary) -> void:
	self.player.animation_player.play("idle")

func _process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

func _transition() -> Variant:
	if not self.player.is_on_floor():
		return "fall"
	
	return null
