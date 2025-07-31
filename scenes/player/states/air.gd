extends PlayerState

@onready var big_jump_timer: Timer = $BigJumpTimer

var do_jump := false
var did_short_jump = false

func _ready() -> void:
	super ()
	big_jump_timer.timeout.connect(self._do_big_jump)

func _enter(args: Dictionary) -> void:
	super(args)
	do_jump = args.get("do_jump", false)
	
	if do_jump:
		big_jump_timer.start()
		if not self.player.is_on_floor():
			player.air_movement_charges.consume_jump()

func _exit() -> void:
	big_jump_timer.stop()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		big_jump_timer.stop()
	elif event.is_action_pressed("jump"):
		if self.player.air_movement_charges.can_jump():
			self.gsm.transition("air", {"do_jump": true})
	elif event.is_action_pressed("dash"):
		if self.player.air_movement_charges.can_dash():
			self.gsm.transition("dash")

func _process(_delta: float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")

	if x_input != 0:
		self.player.sprite_2d.flip_h = true if sign(x_input) == -1 else false

func _physics_process(_delta: float) -> void:
	self.player._apply_horizontal_movement()

	if do_jump:
		self.player.velocity.y = - self.player.player_stats.little_jump_force
		do_jump = false
	else:
		self.player._apply_gravity()
		
	self.player.move_and_slide()


	if self.player.is_on_floor():
		self.gsm.transition("ground")

## private

func _do_big_jump():
	if Input.is_action_pressed("jump"):
		self.player.velocity.y = - self.player.player_stats.big_jump_force
