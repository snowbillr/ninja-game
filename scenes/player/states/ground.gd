extends PlayerState

func _enter(_args: Dictionary) -> void:
	self.player.velocity.y = 0

func _physics_process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

	if x_input != 0:
		self.player.animation_player.play("run")
		self.player.sprite_2d.flip_h = true if sign(x_input) == -1 else false
		self.player.velocity.x = lerp(
			self.player.velocity.x,
			self.player.player_stats.speed * sign(x_input),
			self.player.player_stats.acceleration_coefficient)
	else:
		self.player.animation_player.play("idle")
		self.player.velocity.x = lerp(
			self.player.velocity.x,
			0.0,
			self.player.player_stats.friction_coefficient)

	self.player.move_and_slide()
