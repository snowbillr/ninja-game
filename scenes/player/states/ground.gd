extends MovementState

@export var attack_starter: ComboAttack = null

@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

# _args
#   start_attack_cooldown: bool
func _enter(args: Dictionary) -> void:
	super (args)
	self.player.velocity.y = 0
	self.player.air_movement_charges.reset()
	
	if args.get("start_attack_cooldown", false):
		attack_cooldown_timer.start()
	
func _exit():
	self.attack_cooldown_timer.stop()
	
func _physics_process(_delta: float) -> void:
	self._apply_horizontal_movement(Input.get_axis("move_left", "move_right"))

	self.player.move_and_slide()
	
	self.player.animation_tree.set("parameters/ground/blend_position", abs(self.player.velocity.x))
	
	if not self.player.is_on_floor():
		self.gsm.transition("air")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		self.gsm.transition("air", {"do_jump": true})
	elif event.is_action_pressed("dash"):
		self.gsm.transition("dash")
	elif event.is_action_pressed("attack") && self.attack_cooldown_timer.is_stopped():
		if Input.is_action_pressed("up"):
			self.gsm.transition("attack", {"combo_attack": attack_starter.next_up_attack})
		else:
			self.gsm.transition("attack", {"combo_attack": attack_starter.next_attack})
