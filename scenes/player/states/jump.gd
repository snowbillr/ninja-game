extends PlayerState


func _enter(_args: Dictionary):
	super(_args)

	self.player.velocity.y = -self.player.player_stats.jump_force
	self.player.animation_player.play("jump")

func _physics_process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

	if x_input != 0:
		self.player.sprite_2d.flip_h = true if sign(x_input) == -1 else false
		self.player.velocity.x = lerp(
			self.player.velocity.x,
			self.player.player_stats.speed * sign(x_input),
			self.player.player_stats.acceleration_coefficient)
	else:
		self.player.velocity.x = lerp(self.player.velocity.x,
		0.0,
		self.player.player_stats.friction_coefficient)

	self.player.velocity.y = lerp(
		self.player.velocity.y,
		self.player.player_stats.max_gravity,
		self.player.player_stats.gravity_coefficient)
	
	self.player.move_and_slide()
	
func _process(_delta: float) -> void:
	if self.player.velocity.y > 0:
		self.gsm.transition("fall")
