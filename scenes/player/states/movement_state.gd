# @abstract (Godot 4.5.x)
class_name MovementState extends GSMState


var player: Player = null

func _ready():
	self.player = self.gsm.actor

func _enter(_args: Dictionary):
	self.player.animation_tree.set_active(true)
	
	var state_machine = self.player.animation_tree.get("parameters/playback")
	state_machine.travel(self.name)

func _apply_horizontal_movement(x_input: float = 0.0) -> void:
	if x_input != 0:
		self.player.velocity.x = lerp(
			self.player.velocity.x,
			self.player.player_stats.max_speed * x_input,
			self.player.player_stats.acceleration_coefficient)
	else:
		self.player.velocity.x = lerp(
			self.player.velocity.x,
			0.0,
			self.player.player_stats.friction_coefficient)

func _apply_gravity() -> void:
	self.player.velocity.y = lerp(
		self.player.velocity.y,
		self.player.player_stats.max_gravity,
		self.player.player_stats.gravity_coefficient
	)
