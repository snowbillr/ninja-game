extends PlayerState


func _enter(_args: Dictionary):
	super(_args)
	self.player.animation_player.play("run")

func _physics_process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

	self.player.sprite_2d.flip_h = true if sign(x_input) == -1 else false
	self.player.velocity.x = lerp(
		self.player.velocity.x,
		self.player.player_stats.speed * sign(x_input),
		self.player.player_stats.acceleration_coefficient)
	
	self.player.move_and_slide()

func _process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("dash"):
		self.gsm.transition("dash")
	elif Input.is_action_just_pressed("jump") and self.player.is_on_floor():
		self.gsm.transition("jump")
	elif x_input == 0:
		self.gsm.transition("idle")
