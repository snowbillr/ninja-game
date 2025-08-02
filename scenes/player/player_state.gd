#          MovementState
class_name PlayerState extends GSMState


var player: Player = null

func _ready():
	self.player = self.gsm.actor

func _enter(_args: Dictionary):
	self.player.animation_tree.set_active(true)
	
	var state_machine = self.player.animation_tree.get("parameters/playback")
	state_machine.travel(self.name)
