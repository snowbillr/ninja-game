extends GSMState


func _enter(args: Dictionary):
	var stats: PlayerStats = self.gsm.actor.player_stats

	self.gsm.actor.velocity.y = -stats.jump_force
	self.gsm.actor.get_node("AnimationPlayer").play("jump")

func _physics_process(_delta: float) -> void:
	var stats: PlayerStats = self.gsm.actor.player_stats
	var x_input = Input.get_axis("move_left", "move_right")

	if x_input != 0:
		self.gsm.actor.get_node("Sprite2D").flip_h = true if sign(x_input) == -1 else false
		self.gsm.actor.velocity.x = lerp(self.gsm.actor.velocity.x, stats.speed * sign(x_input), stats.acceleration_coefficient)
	else:
		self.gsm.actor.velocity.x = lerp(self.gsm.actor.velocity.x, 0.0, stats.friction_coefficient)

	self.gsm.actor.velocity.y = lerp(self.gsm.actor.velocity.y, stats.max_gravity, stats.gravity_coefficient)
	
	self.gsm.actor.move_and_slide()
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("dash"):
		self.gsm.transition("dash")
	elif self.gsm.actor.velocity.y > 0:
		self.gsm.transition("fall")
