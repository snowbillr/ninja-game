extends PlayerState


func _enter(_args: Dictionary):
	super(_args)
	self.player.animation_player.play("fall")

func _physics_process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

	if not self.actor.is_on_floor():
		if x_input != 0:
			self.player.sprite_2d.flip_h = true if sign(x_input) == -1 else false
			self.player.velocity.x = lerp(
				self.player.velocity.x,
				self.player.player_stats.speed * sign(x_input),
				self.player.player_stats.acceleration_coefficient)
		else:
			self.player.velocity.x = lerp(
				self.player.velocity.x,
				0.0,
				self.player.player_stats.friction_coefficient)
		
		self.player.velocity.y = lerp(
			self.player.velocity.y,
			self.player.player_stats.max_gravity,
			self.player.player_stats.gravity_coefficient)
		
	self.actor.move_and_slide()
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("dash"):
		self.gsm.transition("dash")
	elif self.player.is_on_floor():
		if Input.get_axis("move_left", "move_right") == 0:
			self.gsm.transition("idle")
		else:
			self.gsm.transition("run")
