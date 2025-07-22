extends GSMState

@onready var timer: Timer = $Timer

func _enter(_args: Dictionary):
	print("enter dash")
	var stats: PlayerStats = self.gsm.actor.player_stats
	
	self.gsm.actor.get_node("AnimationPlayer").play("dash")

	self.gsm.actor.velocity.x = (1 if not self.gsm.actor.get_node("Sprite2D").flip_h else -1) * stats.dash_speed
	self.gsm.actor.velocity.y = 0
	
	timer.wait_time = stats.dash_duration
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _physics_process(_delta: float) -> void:
	self.gsm.actor.move_and_slide()

func _on_timer_timeout():
	if not self.gsm.actor.is_on_floor():
		self.gsm.transition("fall")
	elif Input.get_axis("move_left", "move_right") != 0:
		self.gsm.transition("run")
	else:
		self.gsm.transition("idle")
