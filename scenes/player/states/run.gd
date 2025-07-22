extends GSMState


func _enter(_args: Dictionary):
	self.gsm.actor.get_node("AnimationPlayer").play("run")

func _physics_process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")
	var stats: PlayerStats = self.gsm.actor.player_stats

	self.gsm.actor.get_node("Sprite2D").flip_h = true if sign(x_input) == -1 else false
	self.gsm.actor.velocity.x = lerp(self.gsm.actor.velocity.x, stats.speed * sign(x_input), stats.acceleration_coefficient)
	
	self.gsm.actor.move_and_slide()

func _process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("dash"):
		self.gsm.transition("dash")
	elif Input.is_action_just_pressed("jump") and self.gsm.actor.is_on_floor():
		self.gsm.transition("jump")
	elif x_input == 0:
		self.gsm.transition("idle")
