extends PlayerState

var do_jump := false

func _enter(args: Dictionary) -> void:
	do_jump = args.has("do_jump") and args.do_jump
	
	if do_jump:
		if not self.player.is_on_floor():
			player.air_movement_charges.jumps -= 1
			self.player.animation_player.play("double_jump")
		else:
			self.player.animation_player.play("jump")
	else:
		self.player.animation_player.play("fall")

func _transition() -> Variant:
	if Input.is_action_just_pressed("dash"):
		if self.player.air_movement_charges.dashes > 0:
			return "dash"
	return null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if self.player.air_movement_charges.jumps > 0:
			self._enter({ "do_jump": true })

func _physics_process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")
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

	if do_jump:
		self.player.velocity.y = -self.player.player_stats.jump_force
		do_jump = false
	else:
		self.player.velocity.y = lerp(
			self.player.velocity.y,
			self.player.player_stats.max_gravity,
			self.player.player_stats.gravity_coefficient)
		
	self.player.move_and_slide()

	if self.player.velocity.y > 0:
		self.player.animation_player.play("fall")
