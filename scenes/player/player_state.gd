class_name PlayerState extends GSMState

var player: Player = null

func _enter(_args: Dictionary):
	self.player = self.gsm.actor
