extends PlayerState

func _enter(_args: Dictionary) -> void:
	self.player.velocity.y = 0
	self.player.air_movement_charges.reset()
	
func _process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

	if x_input != 0:
		self.player.animation_player.play("run")
		self.player.sprite_2d.flip_h = true if sign(x_input) == -1 else false
	else:
		self.player.animation_player.play("idle")

func _physics_process(_delta: float) -> void:
	self._apply_horizontal_movement()

	self.player.move_and_slide()
	
	if not self.player.is_on_floor():
		self.gsm.transition("air")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		self.gsm.transition("air", { "do_jump": true })
	elif event.is_action_pressed("dash"):
		self.gsm.transition("dash")

## private

func _apply_horizontal_movement():
	var x_input = Input.get_axis("move_left", "move_right")

	if x_input != 0:
		self.player.velocity.x = lerp(
			self.player.velocity.x,
			self.player.player_stats.max_speed * x_input,
			self.player.player_stats.acceleration_coefficient)
	else:
		self.player.velocity.x = lerp(
			self.player.velocity.x,
			0.0,
			self.player.player_stats.friction_coefficient)
