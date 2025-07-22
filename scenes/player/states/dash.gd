extends PlayerState


@onready var timer: Timer = $Timer

func _enter(_args: Dictionary):
	self.player.animation_player.play("dash")

	self.player.velocity.x = (1 if not self.player.sprite_2d.flip_h else -1) * self.player.player_stats.dash_speed
	self.player.velocity.y = 0
	
	timer.wait_time = self.player.player_stats.dash_duration
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _physics_process(_delta: float) -> void:
	self.player.move_and_slide()

func _exit():
	timer.stop()

func _on_timer_timeout():
	if not self.player.is_on_floor():
		self.gsm.transition("air", { "do_jump": false })
	else:
		self.gsm.transition("ground")
