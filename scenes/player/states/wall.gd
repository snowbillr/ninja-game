extends MovementState


var falling := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super ()
	pass # Replace with function body.

func _enter(_args: Dictionary) -> void:
	super (_args)
	self.falling = false
	self.player.velocity.y = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		self.gsm.transition("dash", {"direction": self.player.direction * -1})
	elif event.is_action_pressed("jump"):
		self.player.velocity.x += self.player.player_stats.wall_exit_velocity * self.player.direction * -1
		self.gsm.transition("air", { "do_jump": true })
	else:
		self.falling = event.is_action_pressed("down")

func _physics_process(_delta: float) -> void:
	if falling:
		self._apply_gravity()
	else:
		self.player.velocity.y = lerp(self.player.velocity.y, 0.0, self.player.player_stats.friction_coefficient)
	
	self.player.move_and_slide()
