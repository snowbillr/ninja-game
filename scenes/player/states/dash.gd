extends MovementState

@export var attack_starter: ComboAttack

@onready var timer: Timer = $Timer

func _ready():
	super ()
	timer.timeout.connect(_on_timer_timeout)

# _args
#   direction: -1 or 1
func _enter(args: Dictionary):
	super (args)

	if not self.player.is_on_floor():
		self.player.air_movement_charges.consume_dash()
	
	self.player.velocity.x = args.get("direction", self.player.direction) * self.player.player_stats.dash_speed
	self.player.velocity.y = 0
	
	timer.wait_time = self.player.player_stats.dash_duration
	timer.start()

func _physics_process(_delta: float) -> void:
	self.player.move_and_slide()

func _exit():
	timer.stop()

func _on_timer_timeout():
	if not self.player.is_on_floor():
		self.gsm.transition("air", {"do_jump": false})
	else:
		self.gsm.transition("ground")
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and self.player.air_movement_charges.can_jump():
		self.gsm.transition("air", {"do_jump": true})
	elif event.is_action_pressed("attack"):
		self.gsm.transition("attack", {"combo_attack": attack_starter.next_attack})
