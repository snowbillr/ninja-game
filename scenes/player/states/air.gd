extends MovementState

@export var attack_starter: ComboAttack = null

@onready var big_jump_timer: Timer = $BigJumpTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

var do_jump := false
var did_short_jump = false

func _ready() -> void:
	super ()
	big_jump_timer.timeout.connect(self._do_big_jump)

# _args
#   do_jump: bool
#   start_attack_cooldown: bool
func _enter(args: Dictionary) -> void:
	super (args)
	do_jump = args.get("do_jump", false)
	
	if do_jump:
		big_jump_timer.start()
		if not self.player.is_on_floor():
			player.air_movement_charges.consume_jump()
	
	if args.get("start_attack_cooldown", false):
		self.attack_cooldown_timer.start()

func _exit() -> void:
	self.big_jump_timer.stop()
	self.attack_cooldown_timer.stop()

func _process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

	if x_input != 0:
		self.player.sprite_2d.flip_h = true if sign(x_input) == -1 else false

func _physics_process(_delta: float) -> void:
	self._apply_horizontal_movement(Input.get_axis("move_left", "move_right"))

	if do_jump:
		self.player.velocity.y = - self.player.player_stats.little_jump_force
		do_jump = false
	else:
		self._apply_gravity()
		
	self.player.move_and_slide()

	if self.player.is_on_floor():
		self.gsm.transition("ground")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		big_jump_timer.stop()
	elif event.is_action_pressed("jump"):
		if self.player.air_movement_charges.can_jump():
			self.gsm.transition("air", {"do_jump": true})
	elif event.is_action_pressed("dash"):
		if self.player.air_movement_charges.can_dash():
			self.gsm.transition("dash")
	elif event.is_action_pressed("attack") && self.attack_cooldown_timer.is_stopped():
		if Input.is_action_pressed("down"):
			self.gsm.transition("attack", {"combo_attack": attack_starter.next_down_attack})
		else:
			self.gsm.transition("attack", {"combo_attack": attack_starter.next_attack})


## private

func _do_big_jump():
	if Input.is_action_pressed("jump"):
		self.player.velocity.y = - self.player.player_stats.big_jump_force
