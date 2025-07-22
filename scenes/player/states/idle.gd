extends GSMState

func _enter(_args: Dictionary) -> void:
	self.gsm.actor.get_node(^"AnimationPlayer").play("idle")

func _process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

	if not self.gsm.actor.is_on_floor():
		self.gsm.transition("fall")
	elif Input.is_action_just_pressed("dash"):
		self.gsm.transition("dash")
	elif Input.is_action_just_pressed("jump") and self.gsm.actor.is_on_floor():
		self.gsm.transition("jump")
	elif abs(x_input) > 0:
		self.gsm.transition("run")
