extends PlayerState

var do_jump := false
var remaining_movements := {
	"jumps": 0
}

func _enter(args: Dictionary) -> void:
	do_jump = args.has("do_jump") and args.do_jump
	
	if do_jump:
		self.player.animation_player.play("jump")
	else:
		self.player.animation_player.play("fall")
	
	remaining_movements.jumps = 1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if remaining_movements.jumps > 0:
			remaining_movements.jumps -= 1
			self.player.velocity.y = -self.player.player_stats.jump_force
			self.player.animation_player.play("double_jump")

func _physics_process(_delta: float) -> void:
	if self.player.velocity.y > 0:
		self.player.animation_player.play("fall")
	
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
