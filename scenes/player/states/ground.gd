extends PlayerState

func _enter(_args: Dictionary) -> void:
	super (_args)
	self.player.velocity.y = 0
	self.player.air_movement_charges.reset()
	
func _process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

	if x_input != 0:
		self.player.sprite_2d.flip_h = true if sign(x_input) == -1 else false

func _physics_process(_delta: float) -> void:
	self.player._apply_horizontal_movement(Input.get_axis("move_left", "move_right"))

	self.player.move_and_slide()
	
	self.player.animation_tree.set("parameters/ground/blend_position", abs(self.player.velocity.x))
	
	if not self.player.is_on_floor():
		self.gsm.transition("air")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		self.gsm.transition("air", {"do_jump": true})
	elif event.is_action_pressed("dash"):
		self.gsm.transition("dash")
	elif event.is_action_pressed("attack"):
		if Input.is_action_pressed("up"):
			self.gsm.transition("ground_attack_up")
		else:
			self.gsm.transition("ground_attack_1")
